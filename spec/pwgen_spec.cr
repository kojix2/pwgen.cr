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
