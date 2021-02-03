# frozen_string_literal: true

require 'yaml'

# External dependencies are used for grading (compile, execute, javadoc, etc.) and loaded from
# the dependencies file on server initialization (see config/initializers/dependencies.rb)
class Dependency < ApplicationRecord
  self.inheritance_column = nil

  CONFIG = 'config/dependencies.yml'
  ROOT = 'vendor/dependencies'

  validates :name, presence: true, uniqueness: true
  validates :version, :type, presence: true

  before_destroy { :delete_downloads }

  enum type: {
    direct: 'direct',
    git: 'git'
  }

  # Loads dependencies from config to database.
  #
  # @return [Array<String>] name of loaded dependencies
  def self.load
    YAML.load_file(CONFIG, fallback: {}).each do |name, prop|
      find_or_initialize_by(name: name).update(
        type: prop['type'],
        version: prop['version'],
        source: prop['source'],
        executable: prop['executable'] || File.basename(prop['source']),
        checksum: prop['checksum'],
        public: prop['public'].to_b || false
      )
    end
  end

  # Downloads or updates all dependencies.
  def self.download_all
    all.find_each(&:download)
  end

  # Loads and downloads all dependencies from config.
  def self.setup
    load
    download_all
  end

  # Returns all public dependencies.
  def self.public_dependencies
    where(public: true)
  end

  # Deletes local files of all dependencies.
  def self.delete_all_downloads
    all.find_each(&:delete_downloads)
  end

  # Downloads the dependency from its source.
  def download
    # noinspection RubyCaseWithoutElseBlockInspection
    case type
    when 'direct'
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      Attachment.download_from_url(source, dir)
    when 'git'
      FileUtils.mkdir_p(File.dirname(path))
      ::Open3.capture3('git submodule update --init --recursive')
    end
  end

  # Returns the directory where the dependency is downloaded.
  def dir
    Rails.root.join(ROOT, type, name).to_s
  end

  # Returns the full path of directory with executable of the dependency.
  def path
    Rails.root.join(ROOT, type, name, executable).to_s
  end

  # Deletes all local files of the dependency.
  def delete_downloads
    FileUtils.remove_entry_secure(dir) if Dir.exist?(dir)
  end
end
