require "digest/sha1"

module Pwgen
  # Provides deterministic pseudo-random number generation using SHA1.
  #
  # This class implements a PRNG by repeatedly hashing a file's content
  # with an incrementing seed. Useful for generating reproducible passwords.
  class Sha1Source
    DEFAULT_SEED = "pwgen"
    BUFFER_SIZE  = 20

    def initialize(spec : String)
      path, seed = parse_spec(spec)
      @seed = seed.to_slice
      @ctx = Digest::SHA1.new
      load_file(path)
      @buffer = Bytes.new(0)
      @index = BUFFER_SIZE
    end

    def to_proc : NumberProc
      ->(max : Int32) { next_number(max) }
    end

    def next_number(max : Int32) : Int32
      raise Error.new("max must be positive") if max <= 0
      refill_buffer if @index >= BUFFER_SIZE
      byte = @buffer[@index]
      @index += 1
      ((byte.to_f64 / 256.0) * max).floor.to_i
    end

    private def parse_spec(spec : String) : {String, String}
      if idx = spec.index('#')
        {spec[0, idx], spec[idx + 1, spec.size - idx - 1]}
      else
        {spec, DEFAULT_SEED}
      end
    end

    private def load_file(path : String)
      File.open(path) do |file|
        buffer = Bytes.new(4096)
        while (read = file.read(buffer)) > 0
          @ctx.update(buffer[0, read])
        end
      end
    rescue ex : File::Error
      raise Error.new("Couldn't open file: #{path} (#{ex.message})")
    end

    private def refill_buffer
      @ctx.update(@seed)
      ctx = @ctx.dup
      @buffer = ctx.final
      @index = 0
    end

    @ctx : Digest::SHA1
    @seed : Bytes
    @buffer : Bytes
    @index : Int32
  end
end
