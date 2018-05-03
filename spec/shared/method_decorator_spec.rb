require "spec_helper"
require "app/shared/method_decorator"

describe FastlaneCI::MethodDecorator do
  let(:snitch) { double("Snitch") }

  module Snitcher
    def poke
    end
  end

  class SomeClass
    extend FastlaneCI::MethodDecorator

    decorate :touch, with: lambda {
      snitch.poke
      super()
    }

    decorate :touch, with: -> { Snitcher.method(:poke) }

    def touch
      "touched!"
    end
  end

  it "call method" do
  end
end
