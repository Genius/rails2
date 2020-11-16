require 'uri'

if RUBY_VERSION >= '1.9' && RUBY_VERSION < '2.6' # Fixed in Ruby 2.6 and 2.7
  str = "\xE6\x97\xA5\xE6\x9C\xAC\xE8\xAA\x9E" # Ni-ho-nn-go in UTF-8, means Japanese.
  str.force_encoding(Encoding::UTF_8) if str.respond_to?(:force_encoding)

  unless str == URI.unescape(URI.escape(str))
    URI::Parser.class_eval do
      remove_method :unescape
      def unescape(str, escaped = @regexp[:ESCAPED])
        ModernRubySupport.unescape_safe_characters(str, escaped)
      end
    end
  end
end

URI.class_eval do
  # `URI.escape` and URI.unescape` have been marked "obsolete" for a long time.
  # Since Ruby 2.7, they always print a warning.
  #
  # Usually, calling `URI.unescape` is discouraged and not what you want, but Rails 2.3 uses it exactly that way.
  # Since we do not want to rewrite Rails' router to fix that, we use a solution similar to modern Rails versions
  # and ship our own URL encoder and decoder.
  #
  # Note that `CGI.escape` or similar core methods behave differently and always escape a specific set of characters.
  #
  # Old Ruby version will still call the native URI methods because of paranoia.

  def self.escape_unsafe_characters(string, pattern)
    if RUBY_VERSION < '2.6'
      escape(string, pattern)
    else
      ModernRubySupport.escape_unsafe_characters(string, pattern)
    end
  end

  def self.unescape_uri(string)
    if RUBY_VERSION < '2.6'
      unescape(string)
    else
      ModernRubySupport.unescape_uri(string)
    end
  end

  if RUBY_VERSION >= '1.9'
    module ModernRubySupport
      ENCODE   = '%%%02X'.freeze
      US_ASCII = Encoding::US_ASCII
      UTF_8    = Encoding::UTF_8
      EMPTY    = ''.force_encoding(US_ASCII).freeze
      DEC2HEX  = (0..255).to_a.map { |i| ENCODE % i }.map { |s| s.force_encoding(US_ASCII) }.freeze

      ALPHA = "a-zA-Z".freeze
      DIGIT = "0-9".freeze
      UNRESERVED = "#{ALPHA}#{DIGIT}\\-\\._~".freeze
      SUB_DELIMS = "!\\$&'\\(\\)\\*\\+,;=".freeze

      ESCAPED  = /%[a-fA-F0-9]{2}/.freeze

      FRAGMENT = /[^#{UNRESERVED}#{SUB_DELIMS}:@\/\?]/.freeze
      SEGMENT  = /[^#{UNRESERVED}#{SUB_DELIMS}:@]/.freeze
      PATH     = /[^#{UNRESERVED}#{SUB_DELIMS}:@\/]/.freeze

      module_function

      def escape_unsafe_characters(string, pattern)
        # Passing a 2nd argument to `URI.escape` defines which characters to URI-encode, e.g. `URI.escape(value, "\r\n")`.
        # This approach is safe, as long as the correct character list or regexp is passed, so we provide a method for
        # that use case.
        string.gsub(pattern) { |unsafe| percent_encode(unsafe) }.force_encoding(US_ASCII)
      end

      def unescape_safe_characters(string, regexp = ESCAPED)
        encoding = (string.encoding == US_ASCII) ? UTF_8 : string.encoding
        string.gsub(regexp) { [$&[1, 2].hex].pack('C') }.force_encoding(encoding)
      end

      def unescape_uri(string)
        unescape_safe_characters(string, ESCAPED)
      end

      def percent_encode(unsafe)
        safe = EMPTY.dup
        unsafe.each_byte { |b| safe << DEC2HEX[b] }
        safe
      end
    end
  end
end
