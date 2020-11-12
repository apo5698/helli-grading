require 'open3'

module Helli
  module Process
    # The stupid content tracker, as described in man page ( ͡° ͜ʖ ͡°)
    module Git
      # Clone a repository into a new directory.
      #   git clone <repository> <path>
      def self.clone(repository, path)
        Open3.capture3("git clone #{repository} #{path}")
      end

      # Fetch from and integrate with another repository or a local branch
      #   git -C <git-working-directory> pull
      def self.pull(path)
        Open3.capture3("git -C #{path} pull")
      end

      # Initialize, update or inspect git submodules.
      module Submodule
        # Add the given repository as a submodule at the given path.
        #   git submodule add [--force] <repository> <path>
        def self.add(repository, path, force: true)
          Open3.capture3("git submodule add #{force ? '--force' : ''} #{repository} #{path}")
        end

        # Recurse into the registered submodules, and update any nested submodules within.
        #   git submodule update [--init] [--recursive]
        def self.update(init: true, recursive: true)
          Open3.capture3("git submodule update #{init ? '--init' : ''} #{recursive ? '--recursive' : ''}")
        end
      end
    end
  end
end
