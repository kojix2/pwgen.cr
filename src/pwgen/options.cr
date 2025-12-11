module Pwgen
  # Specifies the type of password generator to use.
  enum GeneratorKind
    Phonemes # Pronounceable password generator
    Random   # Secure random password generator
  end

  # Configuration options for password generation.
  #
  # Holds all settings parsed from command-line arguments or set programmatically.
  class Options
    property length : Int32
    property count : Int32?
    property flags : Feature
    property generator : GeneratorKind
    property remove_chars : String?
    property columns : Bool
    property sha1_source : Sha1Source?
    property term_width : Int32

    def initialize
      @length = 8
      @count = nil
      @flags = Feature::Digits | Feature::Uppers
      @generator = GeneratorKind::Phonemes
      @remove_chars = nil
      @columns = STDOUT.tty?
      @sha1_source = nil
      @term_width = (ENV["COLUMNS"]?.try &.to_i?) || 80
    end

    def column_count : Int32
      width = @term_width
      width = 80 if width <= 0
      cols = width // (@length + 1)
      cols > 0 ? cols : 1
    end
  end
end
