# The stupid content tracker, as described in man page ( ͡° ͜ʖ ͡°)
module Helli::Command::Git
  # Clone a repository into a new directory.
  #   git clone <repository> <path>
  def self.clone(repository, path)
    Helli::Process.new.open("git clone #{repository} #{path}", timeout: 0)
  end

  # Behaves as same as #clone, but also raises Helli::Process::Error if the process exits with a non-zero status.
  def self.clone!(repository, path)
    Helli::Process.new.open!("git clone #{repository} #{path}", timeout: 0)
  end

  # Fetch from and integrate with another repository or a local branch
  #   git -C <git-working-directory> pull
  def self.pull(path)
    Helli::Process.new.open("git -C #{path} pull", timeout: 0)
  end

  # Behaves as same as #pull, but also raises Helli::Process::Error if the process exits with a non-zero status.
  def self.pull!(path)
    Helli::Process.new.open!("git -C #{path} pull", timeout: 0)
  end

  # Initialize, update or inspect git submodules.
  module Submodule
    # Add the given repository as a submodule at the given path.
    #   git submodule add [--force] <repository> <path>
    def self.add(repository, path, force: true)
      Helli::Process.new.open("git submodule add #{force ? '--force' : ''} #{repository} #{path}", timeout: 0)
    end

    # Behaves as same as #add, but also raises Helli::Process::Error if the process exits with a non-zero status.
    def self.add!(repository, path, force: true)
      Helli::Process.new.open!("git submodule add #{force ? '--force' : ''} #{repository} #{path}", timeout: 0)
    end

    # Recurse into the registered submodules, and update any nested submodules within.
    #   git submodule update [--init] [--recursive]
    def self.update(init: true, recursive: true)
      Helli::Process.new.open("git submodule update #{init ? '--init' : ''} #{recursive ? '--recursive' : ''}", timeout: 0)
    end

    # Behaves as same as #update, but also raises Helli::Process::Error if the process exits with a non-zero status.
    def self.update!(init: true, recursive: true)
      Helli::Process.new.open!("git submodule update #{init ? '--init' : ''} #{recursive ? '--recursive' : ''}", timeout: 0)
    end
  end
end
