module Pwgen
  class CLI
    def self.run(args = ARGV)
      new(args).run
    end

    def self.format_password(password : String, color : Bool = true) : String
      return password unless color

      String.build do |io|
        password.each_char do |character|
          io << colorize_character(character)
        end
      end
    end

    def initialize(args, @output : IO = STDOUT)
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

      parser.on("-C", "--no-capitals", "Don't include capital letters") do
        @options.flags &= ~Feature::Uppers
      end

      parser.on("-N", "--no-numerals", "Don't include numbers") do
        @options.flags &= ~Feature::Digits
      end

      parser.on("-S", "--no-symbols", "Don't include special symbols") do
        @options.flags &= ~Feature::Symbols
      end

      parser.on("-A", "--no-ambiguous", "Don't include ambiguous characters") do
        @options.flags |= Feature::Ambiguous
      end

      parser.on("-V", "--no-vowels", "Don't include vowels") do
        @options.flags |= Feature::NoVowels
        @options.generator = GeneratorKind::Random
      end

      parser.on("-E", "--exclude CHARS", "Remove given characters") do |chars|
        @options.remove_chars = chars
        @options.generator = GeneratorKind::Random
      end

      parser.on("-r", "--random", "Generate completely random passwords") do
        @options.generator = GeneratorKind::Random
      end

      parser.on("-1", "--one", "Single column") do
        @options.columns = false
      end

      parser.on("-m", "--no-color", "Disable ANSI color output") do
        @options.color = false
      end

      parser.on("-n", "--num NUM", "Number of passwords to generate") do |num|
        @options.count = parse_positive_int(num, "number of passwords")
      end

      parser.on("-H", "--sha1 FILE[#seed]", "Use sha1 hash of given file") do |spec|
        @options.sha1_source = Sha1Source.new(spec)
      end

      parser.on("-h", "--help", "Print this help message") do
        puts parser
        exit
      end

      parser.on("-v", "--version", "Print version") do
        puts "pwgen #{Pwgen::VERSION} (#{Pwgen::REPOURL})"
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
      if @options.columns?
        @options.column_count * 20
      else
        1
      end
    end

    private def emit_passwords(generator : Generator, count : Int32)
      if @options.columns?
        columns = @options.column_count
        count.times do |idx|
          password = generator.generate(@options.length, @options.flags, @options.remove_chars)
          rendered = render_password(password)
          if ((idx % columns) == (columns - 1)) || (idx == count - 1)
            @output.puts rendered
          else
            @output.print rendered
            @output.print ' '
          end
        end
      else
        count.times do
          password = generator.generate(@options.length, @options.flags, @options.remove_chars)
          @output.puts render_password(password)
        end
      end
    end

    private def render_password(password : String) : String
      self.class.format_password(password, @options.color?)
    end

    private def self.colorize_character(character : Char) : String
      text = character.to_s
      return text.colorize.cyan.mode(:bold).to_s if DIGITS.includes?(character)
      return text.colorize.bold.mode(:bold).to_s if UPPERS.includes?(character)
      return text.colorize.red.mode(:bold).to_s if SYMBOLS.includes?(character)
      text
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
    @output : IO
  end
end
