require 'permalink_fu/railtie'
require 'permalink_fu/active_record'

module PermalinkFu
  class << self
    def escape(string)
      result = ::I18n.transliterate(string.to_s)
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
      result.downcase!
      result.size.zero? ? random_permalink : result
    rescue
      random_permalink
    end

    def random_permalink
      ::SecureRandom.hex(16)
    end
  end
end