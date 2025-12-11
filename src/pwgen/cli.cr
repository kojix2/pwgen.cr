module Pwgen
  class CLI
    def self.run(args = ARGV)
      new(args).run
    end

    def initialize(args)
      @args = args.dup
      @options = Options.new
    end

    def run
      parse_args
      apply_length_rules
      configure_number_source
      generator = select_generator
      count = determine_count
      emit_passwords(generator, count)
    rescue ex : Pwgen::Error
      Pwgen.die(ex.message || ex.to_s)
    rescue ex : OptionParser::Exception
      Pwgen.die(ex.message || ex.to_s)
    end

    private def parse_args
      parser = OptionParser.new
      parser.banner = "Usage: pwgen [ OPTIONS ] [ pw_length ] [ num_pw ]"
      parser.summary_indent = "  "
      parser.summary_width = 25

      parser.on("-c", "--capitalize", "Include at least one capital letter") do
        @options.flags |= Feature::Uppers
      end

      parser.on("-A", "--no-capitalize", "Don't include capital letters") do
        @options.flags &= ~Feature::Uppers
      end

      parser.on("-n", "--numerals", "Include at least one number") do
        @options.flags |= Feature::Digits
      end

      parser.on("-0", "--no-numerals", "Don't include numbers") do
        @options.flags &= ~Feature::Digits
      end

      parser.on("-y", "--symbols", "Include at least one special symbol") do
        @options.flags |= Feature::Symbols
      end

      parser.on("-B", "--ambiguous", "Don't include ambiguous characters") do
        @options.flags |= Feature::Ambiguous
      end

      parser.on("-v", "--no-vowels", "Don't include vowels") do
        @options.flags |= Feature::NoVowels
        @options.generator = GeneratorKind::Random
      end

      parser.on("-r", "--remove-chars CHARS", "Remove given characters") do |chars|
        @options.remove_chars = chars
        @options.generator = GeneratorKind::Random
      end

      parser.on("-s", "--secure", "Generate completely random passwords") do
        @options.generator = GeneratorKind::Random
      end

      parser.on("-C", "Print the generated passwords in columns") do
        @options.columns = true
      end

      parser.on("-1", "Don't print the generated passwords in columns") do
        @options.columns = false
      end

      parser.on("-N", "--num-passwords NUM", "Number of passwords to generate") do |num|
        @options.count = parse_positive_int(num, "number of passwords")
      end

      parser.on("-H", "--sha1 FILE[#seed]", "Use sha1 hash of given file") do |spec|
        @options.sha1_source = Sha1Source.new(spec)
      end

      parser.on("-h", "--help", "Print this help message") do
        puts parser
        exit
      end

      parser.on("-V", "--version", "Print version") do
        puts "pwgen #{Pwgen::VERSION}"
        exit
      end

      parser.parse(@args)
      apply_positionals
    end

    private def apply_positionals
      if @args.size > 0
        @options.length = parse_positive_int(@args.shift, "password length")
      end
      if @args.size > 0
        @options.count = parse_positive_int(@args.shift, "number of passwords")
      end
      if @args.size > 0
        raise Pwgen::Error.new("Too many positional arguments")
      end
    end

    private def apply_length_rules
      if @options.length < 5
        @options.generator = GeneratorKind::Random
      elsif @options.generator == GeneratorKind::Phonemes
        if @options.length <= 2
          @options.flags &= ~Feature::Uppers
        end
        if @options.length <= 1
          @options.flags &= ~Feature::Digits
        end
      end
    end

    private def configure_number_source
      if source = @options.sha1_source
        Pwgen.number_source = source.to_proc
      else
        Pwgen.reset_number_source
      end
    end

    private def select_generator : Generator
      case @options.generator
      when GeneratorKind::Phonemes
        PhonemeGenerator.new
      when GeneratorKind::Random
        RandomGenerator.new
      else
        raise Pwgen::Error.new("Unsupported generator type")
      end
    end

    private def determine_count : Int32
      if count = @options.count
        return count
      end
      if @options.columns
        @options.column_count * 20
      else
        1
      end
    end

    private def emit_passwords(generator : Generator, count : Int32)
      if @options.columns
        columns = @options.column_count
        count.times do |idx|
          password = generator.generate(@options.length, @options.flags, @options.remove_chars)
          if ((idx % columns) == (columns - 1)) || (idx == count - 1)
            puts password
          else
            print password
            print ' '
          end
        end
      else
        count.times do
          password = generator.generate(@options.length, @options.flags, @options.remove_chars)
          puts password
        end
      end
    end

    private def parse_positive_int(value : String, label : String) : Int32
      number = value.to_i64?
      raise Pwgen::Error.new("Invalid #{label}: #{value}") unless number
      raise Pwgen::Error.new("#{label.capitalize} must be positive") if number <= 0
      if number > Int32::MAX
        raise Pwgen::Error.new("#{label.capitalize} is too large")
      end
      number.to_i
    end

    @args : Array(String)
    @options : Options
  end
end
