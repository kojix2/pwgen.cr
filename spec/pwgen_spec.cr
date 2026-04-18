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

    formatted.should eq("\e[1;36mA\e[0ma\e[1;33m0\e[0m\e[1;31m!\e[0m")
  end

  it "returns plain text when color is disabled" do
    Pwgen::CLI.format_password("Aa0!", false).should eq("Aa0!")
  end

  it "prints colored output by default" do
    output = IO::Memory.new

    Pwgen.with_number_source(sequential_proc) do
      Pwgen::CLI.new(["-s", "-c", "1"], output).run
    end

    output.to_s.should eq("\e[1;36mA\e[0m\n")
  end

  it "disables colors with --no-color" do
    output = IO::Memory.new

    Pwgen.with_number_source(sequential_proc) do
      Pwgen::CLI.new(["--no-color", "-s", "-c", "1"], output).run
    end

    output.to_s.should eq("A\n")
  end

  it "keeps column output layout intact" do
    output = IO::Memory.new

    Pwgen.with_number_source(sequential_proc) do
      Pwgen::CLI.new(["--no-color", "-C", "-s", "-c", "1", "2"], output).run
    end

    output.to_s.should eq("A B\n")
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
