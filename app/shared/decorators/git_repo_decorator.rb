
module FastlaneCI
  module Decorators
    # This class offers the ability to wrap a block with git repo operations.
    # Can be used by the MethodDecorator to wrap methods that depend on repo state
    class GitRepoDecorator
      def initialize(repo)
        @repo = repo
        @pull_mutex = Mutex.new
        @commit_mutex = Mutex.new
      end

      def pull_before(&block)
        return if @pull_mutex.locked?
        @pull_mutex.synchronize do
          @repo.pull
          block.call
        end
      end

      def commit_after(&block)
        return if @commit_mutex.locked?
        @commit_mutex.synchronize do
          block.call.tap do
            @repo.commit_changes!
            @repo.push
          end
        end
      end
    end
  end
end
