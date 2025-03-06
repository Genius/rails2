module MailHelper
  # Uses Text::Format to take the text and format it, indented two spaces for
  # each line, and wrapped at 72 columns.
  def block_format(text)
    formatted = text.split(/\n\r\n/).collect { |paragraph|
      Text::Format.new(
        :columns => 72, :first_indent => 2, :body_indent => 2, :text => paragraph
      ).format
    }.join("\n")

    # Make list points stand on their own line
    output = ""
    splits = formatted.split(/(\*+|\#+)/)
    while line = splits.shift
      if line.start_with?("*", "#") && splits[0] && splits[0].start_with?(" ")
        output.chomp!(" ") while output.end_with?(" ")
        output << "  #{line} #{splits.shift.strip}\n"
      else
        output << line
      end
    end

    output
  end
end
