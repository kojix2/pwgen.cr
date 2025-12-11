module Pwgen
  DIGITS    = "0123456789"
  UPPERS    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  LOWERS    = "abcdefghijklmnopqrstuvwxyz"
  SYMBOLS   = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
  AMBIGUOUS = "B8G6I1l0OQDS5Z2"
  VOWELS    = "01aeiouyAEIOUY"

  @[Flags]
  enum Feature : UInt32
    None      =      0
    Digits    = 0x0001
    Uppers    = 0x0002
    Symbols   = 0x0004
    Ambiguous = 0x0008
    NoVowels  = 0x0010
  end

  class Error < Exception
  end

  def self.die(message : String, code : Int32 = 1)
    STDERR.puts(message)
    exit(code)
  end

  def self.contains_any?(text : String, characters : String) : Bool
    text.each_char.any? { |ch| characters.includes?(ch) }
  end

  def self.ambiguous?(char : Char) : Bool
    AMBIGUOUS.includes?(char)
  end

  def self.vowel_char?(char : Char) : Bool
    VOWELS.includes?(char)
  end
end
