require "random"

module Pwgen
  alias NumberProc = Proc(Int32, Int32)

  @@number_source : NumberProc? = nil

  def self.number_source=(proc : NumberProc)
    @@number_source = proc
  end

  def self.reset_number_source
    @@number_source = nil
  end

  def self.with_number_source(proc : NumberProc, &)
    previous = current_number_source
    @@number_source = proc
    yield
  ensure
    @@number_source = previous
  end

  def self.next_number(max : Int32) : Int32
    raise Error.new("max must be positive") if max <= 0
    current_number_source.call(max)
  end

  private def self.secure_rand(max : Int32) : Int32
    raise Error.new("max must be positive") if max <= 0
    Random::Secure.rand(0...max)
  end

  private def self.current_number_source : NumberProc
    @@number_source ||= ->(max : Int32) { secure_rand(max) }
  end
end
