require "option_parser"

require "./pwgen/constants"
require "./pwgen/random_source"
require "./pwgen/sha1_source"
require "./pwgen/generator"
require "./pwgen/random_generator"
require "./pwgen/phoneme_generator"
require "./pwgen/options"
require "./pwgen/cli"

# Pwgen is a secure password generator library and CLI tool.
#
# It provides two password generation strategies:
# - Phoneme-based: Generates pronounceable passwords using phonetic rules
# - Random: Generates cryptographically secure random passwords
#
# Example:
# ```
# # Generate a pronounceable password
# generator = Pwgen::PhonemeGenerator.new
# password = generator.generate(12, Pwgen::Feature::Digits | Pwgen::Feature::Uppers, nil)
#
# # Generate a random password
# generator = Pwgen::RandomGenerator.new
# password = generator.generate(16, Pwgen::Feature::Digits | Pwgen::Feature::Uppers | Pwgen::Feature::Symbols, nil)
# ```
module Pwgen
  VERSION = "0.1.0"
end
