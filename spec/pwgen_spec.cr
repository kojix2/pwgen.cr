require "./spec_helper"

describe Pwgen::RandomGenerator do
  it "generates passwords with the requested length" do
    generator = Pwgen::RandomGenerator.new
    password = Pwgen.with_number_source(sequential_proc) do
      generator.generate(10, Pwgen::Feature::None, nil)
    end
    password.size.should eq(10)
  end
end

describe Pwgen::CLI do
  it "colors uppercase letters, digits, and symbols" do
    formatted = Pwgen::CLI.format_password("Aa0!", true)

    upper = "A".colorize.bold.mode(:bold).to_s
    digit = "0".colorize.cyan.mode(:bold).to_s
    symbol = "!".colorize.red.mode(:bold).to_s

    formatted.should eq("#{upper}a#{digit}#{symbol}")
  end

  it "returns plain text when color is disabled" do
    Pwgen::CLI.format_password("Aa0!", false).should eq("Aa0!")
  end

  it "prints colored output by default" do
    output = IO::Memory.new
    previous = Colorize.enabled?

    Colorize.enabled = true
    Pwgen::CLI.new(["8", "1"], output).run
    Colorize.enabled = previous

    rendered = output.to_s
    rendered.includes?("\e[").should be_true
    rendered.ends_with?("\n").should be_true
  end

  it "disables colors with --no-color" do
    output = IO::Memory.new

    Pwgen::CLI.new(["--no-color", "8", "1"], output).run

    rendered = output.to_s
    rendered.includes?("\e[").should be_false
    rendered.ends_with?("\n").should be_true
    rendered.chomp.size.should eq(8)
  end

  it "uses --num to control generated count" do
    output = IO::Memory.new

    Pwgen::CLI.new(["--no-color", "-1", "-n", "2", "8"], output).run

    lines = output.to_s.lines
    lines.size.should eq(2)
    lines.each do |line|
      line.includes?("\e[").should be_false
      line.chomp.size.should eq(8)
    end
  end
end

describe Pwgen::PhonemeGenerator do
  it "produces pronounceable strings" do
    generator = Pwgen::PhonemeGenerator.new
    password = Pwgen.with_number_source(sequential_proc) do
      generator.generate(8, Pwgen::Feature::None, nil)
    end
    password.size.should eq(8)
  end
end

describe Pwgen::Sha1Source do
  it "generates a stream of numbers that changes over time" do
    # Create a dummy file for seeding
    filename = "test_seed_file"
    File.write(filename, "some random content")

    source = Pwgen::Sha1Source.new(filename + "#seed")

    # Generate 40 numbers (2 batches of 20)
    numbers = (1..40).map { source.next_number(256) }

    first_batch = numbers[0, 20]
    second_batch = numbers[20, 20]

    # They should not be identical (extremely unlikely with SHA1)
    first_batch.should_not eq(second_batch)

    File.delete(filename)
  end
end

private def sequential_proc
  counter = 0
  ->(max : Int32) do
    raise "max must be positive" if max <= 0
    value = counter % max
    counter += 1
    value
  end
end
