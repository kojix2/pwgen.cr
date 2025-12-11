require "./constants"

module Pwgen
  # Abstract base class for password generators.
  #
  # Subclasses must implement the `generate` method to create passwords
  # according to their specific algorithm (phoneme-based or random).
  abstract class Generator
    # Generates a password with the specified parameters.
    #
    # - `length`: Length of the password to generate
    # - `flags`: Feature flags controlling password characteristics
    # - `remove`: Optional string of characters to exclude from generation
    #
    # Returns a String containing the generated password.
    abstract def generate(length : Int32, flags : Feature, remove : String?) : String
  end
end
