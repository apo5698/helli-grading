require 'helli/error'
require 'open-uri'
require 'yaml'

# External dependencies are used for grading (compile, execute, javadoc, etc.) and loaded from
# the dependencies file on server initialization (see config/initializers/dependencies.rb)
class Helli::Dependency < ActiveRecord::Base
  self.table_name = 'dependencies'

  validates :name, presence: true, uniqueness: true
  validates :version, :source_type, presence: true

  after_validation do
    self.executable = File.basename(source) if executable.blank?
    self.path = "#{ENV['DEPENDENCY_ROOT']}/#{source_type}/#{name}/#{executable}"
  end

  before_destroy { FileUtils.remove_entry_secure(File.dirname(path)) }

  enum visibility: {
    private: :private,
    public: :public
  }, _prefix: true

  # Downloads or updates all dependencies.
  def self.download_all
    Helli::Command::Git::Submodule.update
    all.find_each(&:download)
  end

  # Loads dependencies from the YAML file.
  def self.load(path)
    # +load_file()+ return +false+ if file is empty, not +nil+ or empty hash
    dependencies = YAML.load_file(path)
    raise Helli::EmptyFileError, 'empty dependencies file' unless dependencies

    ENV['DEPENDENCY_ROOT'] = dependencies.delete('root')

    dependencies.each do |name, prop|
      find_or_initialize_by(name: name).update(
        version: prop['version'],
        source: prop['source'],
        source_type: prop['source_type'],
        executable: prop['executable'],
        visibility: prop['visibility'] || :private
      )
    end

    dependencies
  end

  # Returns the absolute path of a dependency by name, *including* executable.
  def self.path(name)
    Rails.root.join(find_by(name: name).path).to_s
  end

  # Returns the root path of dependencies.
  def self.root
    ENV['DEPENDENCY_ROOT']
  end

  # Returns all public dependencies.
  def self.public_dependencies
    where(visibility: :public)
  end

  # Downloads the dependency from its source.
  def download
    case source_type
    when 'direct'
      FileUtils.mkdir_p(File.dirname(path))
      Helli::Attachment.download_from_url(source, path)
    when 'git'
      # keep submodules clean
      if Rails.env.test?
        Helli::Command::Git.clone(source, File.dirname(path))
      else
        Helli::Command::Git::Submodule.add(source, File.join(self.class.root, source_type, name))
      end
    else
      raise NotImplementedError, "#{source_type} is not supported for downloading"
    end
  end
end
