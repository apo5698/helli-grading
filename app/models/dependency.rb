require 'open-uri'
require 'yaml'

# External dependencies are used for grading (compile, execute, javadoc, etc.) and loaded from
# the dependencies file on server initialization (see config/initializers/dependencies.rb)
class Dependency < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :version, :source_type, presence: true

  after_validation do
    self.executable = File.basename(source) if executable.blank?
    self.path = "#{ENV['DEPENDENCY_ROOT']}/#{source_type}/#{name}/#{executable}"
  end

  before_destroy do
    FileUtils.remove_entry_secure(File.dirname(path))
  end

  # Downloads or updates all dependencies.
  def self.download_all
    Command::Git::Submodule.update
    all.find_each(&:download)
  end

  # Loads dependencies from the YAML file.
  def self.load(path)
    # +load_file()+ return +false+ if file is empty, not +nil+ or empty hash
    dependencies = YAML.load_file(path)
    raise EmptyFileError, 'empty dependencies file' unless dependencies

    ENV['DEPENDENCY_ROOT'] = dependencies.delete('root')

    dependencies.each do |name, prop|
      find_or_initialize_by(name: name).update(
        version: prop['version'],
        source: prop['source'],
        source_type: prop['source_type'],
        executable: prop['executable']
      )
    end

    dependencies
  end

  # Finds the local path by name, *including* executable.
  def self.path(name)
    find_by(name: name).path
  end

  # Returns the root path of dependencies.
  def self.root
    ENV['DEPENDENCY_ROOT']
  end

  # Downloads the dependency from its source.
  def download
    case source_type
    when 'direct'
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb') do |f|
        URI.open(source, 'rb') { |o| f.write(o.read) }
      end
    when 'git'
      # keep submodules clean
      if Rails.env.test?
        Command::Git.clone(source, File.dirname(path))
      else
        Command::Git::Submodule.add(source, "#{ENV['DEPENDENCY_ROOT']}/#{source_type}/#{name}")
      end
    else
      raise NotImplementedError, "#{source_type} is not supported for downloading"
    end
  end
end
