require "spec_helper"
require "app/shared/decorators/git_repo_decorator"
require "app/shared/method_decorator"

describe FastlaneCI::Decorators::GitRepoDecorator do
  let(:repo) { double("Repo") }
  let(:decorator) { FastlaneCI::Decorators::GitRepoDecorator.new(repo) }

  describe "example usage" do
    class SomeService
      extend FastlaneCI::MethodDecorator

      decorate(:touch) { @decorator.method(:pull_before) }

      def initialize(decorator)
        @decorator = decorator
      end

      def touch
        "touched!"
      end
    end

    it "calling #touch should also call Decorator#pull_before" do
      expect(repo).to receive(:pull)
      expect(decorator).to receive(:pull_before).and_call_original

      service = SomeService.new(decorator)
      expect(service.touch).to eq("touched!")
    end
  end

  describe "#pull_before" do
    it "returns if the mutex is locked"
  end

  describe "#commit_after" do
    it "returns if the mutex is locked"
  end
end
