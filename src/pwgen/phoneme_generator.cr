module Pwgen
  @[Flags]
  enum ElementFlag : UInt32
    Consonant = 0x0001
    Vowel     = 0x0002
    Diphthong = 0x0004
    NotFirst  = 0x0008
  end

  struct Element
    getter text : String
    getter flags : ElementFlag

    def initialize(@text : String, @flags : ElementFlag)
    end
  end

  # Generates pronounceable passwords using phonetic rules.
  #
  # This generator creates passwords by combining phonetic elements
  # (consonants, vowels, and diphthongs) according to pronunciation rules,
  # making them easier to remember and type.
  class PhonemeGenerator < Generator
    # Phonetic elements used for password generation.
    # Each element has a text representation and flags indicating its type.
    ELEMENTS = [
      Element.new("a", ElementFlag::Vowel),
      Element.new("ae", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("ah", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("ai", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("b", ElementFlag::Consonant),
      Element.new("c", ElementFlag::Consonant),
      Element.new("ch", ElementFlag::Consonant | ElementFlag::Diphthong),
      Element.new("d", ElementFlag::Consonant),
      Element.new("e", ElementFlag::Vowel),
      Element.new("ee", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("ei", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("f", ElementFlag::Consonant),
      Element.new("g", ElementFlag::Consonant),
      Element.new("gh", ElementFlag::Consonant | ElementFlag::Diphthong | ElementFlag::NotFirst),
      Element.new("h", ElementFlag::Consonant),
      Element.new("i", ElementFlag::Vowel),
      Element.new("ie", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("j", ElementFlag::Consonant),
      Element.new("k", ElementFlag::Consonant),
      Element.new("l", ElementFlag::Consonant),
      Element.new("m", ElementFlag::Consonant),
      Element.new("n", ElementFlag::Consonant),
      Element.new("ng", ElementFlag::Consonant | ElementFlag::Diphthong | ElementFlag::NotFirst),
      Element.new("o", ElementFlag::Vowel),
      Element.new("oh", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("oo", ElementFlag::Vowel | ElementFlag::Diphthong),
      Element.new("p", ElementFlag::Consonant),
      Element.new("ph", ElementFlag::Consonant | ElementFlag::Diphthong),
      Element.new("qu", ElementFlag::Consonant | ElementFlag::Diphthong),
      Element.new("r", ElementFlag::Consonant),
      Element.new("s", ElementFlag::Consonant),
      Element.new("sh", ElementFlag::Consonant | ElementFlag::Diphthong),
      Element.new("t", ElementFlag::Consonant),
      Element.new("th", ElementFlag::Consonant | ElementFlag::Diphthong),
      Element.new("u", ElementFlag::Vowel),
      Element.new("v", ElementFlag::Consonant),
      Element.new("w", ElementFlag::Consonant),
      Element.new("x", ElementFlag::Consonant),
      Element.new("y", ElementFlag::Consonant),
      Element.new("z", ElementFlag::Consonant),
    ]

    def generate(length : Int32, flags : Feature, remove : String?) : String
      raise Error.new("Password length must be positive") if length <= 0
      if remove
        raise Error.new("--remove-chars is only supported with random passwords")
      end
      enforcement_flags = length > 2 ? flags : Feature::None

      loop do
        password = attempt_generation(length, flags, enforcement_flags)
        next unless password
        if flags.includes?(Feature::Ambiguous) && Pwgen.contains_any?(password, AMBIGUOUS)
          next
        end
        return password
      end
    end

    private def attempt_generation(length : Int32, flags : Feature, enforcement : Feature) : String?
      chars = Array(Char).new(length)
      feature_flags = enforcement
      prev = ElementFlag::Consonant
      should_be = initial_target
      first = true

      while chars.size < length
        element = ELEMENTS[Pwgen.next_number(ELEMENTS.size)]
        next unless element.flags.includes?(should_be)
        next if first && element.flags.includes?(ElementFlag::NotFirst)
        if prev.includes?(ElementFlag::Vowel) && element.flags.includes?(ElementFlag::Vowel) && element.flags.includes?(ElementFlag::Diphthong)
          next
        end
        if element.text.size > (length - chars.size)
          next
        end

        start_index = chars.size
        element.text.each_char { |ch| chars << ch }

        if flags.includes?(Feature::Uppers)
          if (first || element.flags.includes?(ElementFlag::Consonant)) && Pwgen.next_number(10) < 2
            chars[start_index] = chars[start_index].upcase
            feature_flags &= ~Feature::Uppers
          end
        end

        break if chars.size >= length

        if flags.includes?(Feature::Digits) && !first && Pwgen.next_number(10) < 3
          chars << random_digit(flags)
          feature_flags &= ~Feature::Digits
          first = true
          prev = ElementFlag::Consonant
          should_be = initial_target
          next
        end

        if flags.includes?(Feature::Symbols) && !first && Pwgen.next_number(10) < 2
          chars << random_symbol(flags)
          feature_flags &= ~Feature::Symbols
        end

        should_be = next_target(should_be, prev, element.flags)
        prev = element.flags
        first = false
      end

      needs = Feature::Digits | Feature::Uppers | Feature::Symbols
      return nil unless (feature_flags & needs) == Feature::None

      String.build do |io|
        chars.each { |ch| io << ch }
      end
    end

    private def initial_target : ElementFlag
      Pwgen.next_number(2).zero? ? ElementFlag::Vowel : ElementFlag::Consonant
    end

    private def next_target(current : ElementFlag, prev : ElementFlag, latest : ElementFlag) : ElementFlag
      if current == ElementFlag::Consonant
        ElementFlag::Vowel
      else
        if prev.includes?(ElementFlag::Vowel) || latest.includes?(ElementFlag::Diphthong) || Pwgen.next_number(10) > 3
          ElementFlag::Consonant
        else
          ElementFlag::Vowel
        end
      end
    end

    private def random_digit(flags : Feature) : Char
      loop do
        ch = (Pwgen.next_number(10) + '0'.ord).chr
        return ch unless flags.includes?(Feature::Ambiguous) && Pwgen.ambiguous?(ch)
      end
    end

    private def random_symbol(flags : Feature) : Char
      loop do
        ch = SYMBOLS[Pwgen.next_number(SYMBOLS.size)]
        return ch unless flags.includes?(Feature::Ambiguous) && Pwgen.ambiguous?(ch)
      end
    end
  end
end
