module RailsLts
  def self.release_name
    "Rails #{VERSION::STRING} LTS"
  end

  def self.product_name
    'Rails LTS'
  end

  def self.configuration_name
    'rails_lts_options'.freeze
  end

  def self.configuration_link
    'https://makandracards.com/railslts/16311-enabling-additional-security-features-rails-lts'.freeze
  end

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :disable_json_parsing
    attr_accessor :disable_xml_parsing

    attr_accessor :escape_html_entities_in_json

    attr_accessor :strict_unambiguous_table_names

    attr_accessor :allow_strings_for_polymorphic_paths

    attr_accessor :cast_integers_on_mysql_string_columns

    def self.prepare(rails_lts_options)
      RailsLts.configuration = new(rails_lts_options)
      after_prepare
    end

    def self.after_prepare
      # hook for whitelabeling
    end

    def self.finalize
      RailsLts.configuration.finalize
    end

    def initialize(options)
      @configured = !!options
      options ||= {}

      set_defaults(options.delete(:default) || :compatible)

      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def finalize
      unless @configured
        message = %{Please configure your #{RailsLts.configuration_name} using config.#{RailsLts.configuration_name} in config/environment.rb. Defaulting to "#{RailsLts.configuration_name} = { :default => :compatible }.}
        if RailsLts.configuration_link
          message << " See #{RailsLts.configuration_link} for documentation."
        end
        $stderr.puts(message)
      end
      finalize_param_parsers
      finalize_json_html_entity_escaping
    end

    private

    def set_defaults(default)
      unless [:hardened, :compatible].include?(default)
        raise ArgumentError.new("Rails LTS: default needs to be :hardened or :compatible")
      end
      case default
      when :hardened
        self.disable_json_parsing = true
        self.disable_xml_parsing = true
        self.escape_html_entities_in_json = true
        self.strict_unambiguous_table_names = true
        self.allow_strings_for_polymorphic_paths = false
        self.cast_integers_on_mysql_string_columns = true
      when :compatible
        self.disable_json_parsing = false
        self.disable_xml_parsing = false
        self.escape_html_entities_in_json = false
        self.strict_unambiguous_table_names = false
        self.allow_strings_for_polymorphic_paths = false
        self.cast_integers_on_mysql_string_columns = false
      end
    end

    def finalize_param_parsers
      if disable_json_parsing
        ActionController::Base.param_parsers.delete(Mime::JSON)
      end
      if disable_xml_parsing
        ActionController::Base.param_parsers.delete(Mime::XML)
      end
    end

    def finalize_json_html_entity_escaping
      if escape_html_entities_in_json
        ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
      end
    end
  end

end
