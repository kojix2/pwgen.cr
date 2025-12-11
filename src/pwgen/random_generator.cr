module Pwgen
  # Generates completely random passwords using secure random number generation.
  #
  # This generator creates passwords by randomly selecting characters from
  # a pool based on the specified feature flags. It ensures cryptographic
  # security by using `Random::Secure`.
  class RandomGenerator < Generator
    # Generates a random password.
    #
    # - `length`: Length of the password (must be positive)
    # - `flags`: Feature flags (Digits, Uppers, Symbols, Ambiguous, NoVowels)
    # - `remove`: Optional string of characters to exclude
    #
    # Raises `Pwgen::Error` if parameters are invalid or if the character pool
    # becomes empty after removals.
    def generate(length : Int32, flags : Feature, remove : String?) : String
      raise Error.new("Password length must be positive") if length <= 0
      chars = build_char_pool(flags)
      apply_removals(chars, remove)
      ensure_valid_pool(chars, flags)
      enforcement_flags = length > 2 ? flags : Feature::None

      loop do
        password = build_password(length, chars, flags)
        return password if requirements_met?(password, enforcement_flags)
      end
    end

    private def build_char_pool(flags : Feature) : Array(Char)
      pool = [] of Char
      if flags.includes?(Feature::Digits)
        DIGITS.each_char { |ch| pool << ch }
      end
      if flags.includes?(Feature::Uppers)
        UPPERS.each_char { |ch| pool << ch }
      end
      LOWERS.each_char { |ch| pool << ch }
      if flags.includes?(Feature::Symbols)
        SYMBOLS.each_char { |ch| pool << ch }
      end
      pool
    end

    private def apply_removals(pool : Array(Char), remove : String?)
      return unless remove
      remove.each_char do |target|
        pool.reject! { |ch| ch == target }
      end
    end

    private def ensure_valid_pool(pool : Array(Char), flags : Feature)
      raise Error.new("Error: No characters left in the valid set") if pool.empty?
      if flags.includes?(Feature::Digits) && !pool.any? { |ch| DIGITS.includes?(ch) }
        raise Error.new("Error: No digits left in the valid set")
      end
      if flags.includes?(Feature::Uppers) && !pool.any? { |ch| UPPERS.includes?(ch) }
        raise Error.new("Error: No upper case letters left in the valid set")
      end
      if flags.includes?(Feature::Symbols) && !pool.any? { |ch| SYMBOLS.includes?(ch) }
        raise Error.new("Error: No symbols left in the valid set")
      end
    end

    private def build_password(length : Int32, pool : Array(Char), flags : Feature) : String
      builder = Array(Char).new(length)
      while builder.size < length
        ch = pool[Pwgen.next_number(pool.size)]
        if flags.includes?(Feature::Ambiguous) && Pwgen.ambiguous?(ch)
          next
        end
        if flags.includes?(Feature::NoVowels) && Pwgen.vowel_char?(ch)
          next
        end
        builder << ch
      end
      String.build do |io|
        builder.each { |ch| io << ch }
      end
    end

    private def requirements_met?(password : String, flags : Feature) : Bool
      return true if flags == Feature::None
      if flags.includes?(Feature::Digits) && !Pwgen.contains_any?(password, DIGITS)
        return false
      end
      if flags.includes?(Feature::Uppers) && !Pwgen.contains_any?(password, UPPERS)
        return false
      end
      if flags.includes?(Feature::Symbols) && !Pwgen.contains_any?(password, SYMBOLS)
        return false
      end
      true
    end
  end
end
