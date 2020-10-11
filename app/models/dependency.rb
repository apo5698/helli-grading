require 'open-uri'
require 'yaml'

# External dependencies are used for grading (compile, execute, javadoc, etc.) and loaded from
# config/dependencies.yml file on app initialization (see config/initializers/dependencies.rb)
class Dependency < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
  validates :source, presence: true
  validates :source_type, presence: true

  attr_reader :path

  after_initialize do
    @path = "vendor/dependencies/#{source_type}/#{name}/"
    @path << File.basename(source) if source_type == 'direct'
    @path << executable if source_type == 'git'
  end

  # Returns the local path of a specified dependency name.
  def self.path(name)
    find_by(name: name).path
  end

  # Writes the dependencies to JSON.
  def self.json
    url = 'api/dependencies.json'
    File.open("public/#{url}", 'w') { |f| f.write(@dependencies.to_json) }
    url
  end

  # Loads dependencies from the YAML file.
  def self.load(yml)
    @dependencies = YAML.load_file(yml)
    @dependencies.each do |name, prop|
      old = find_by(name: name)
      new = new(name: name,
                version: prop['version'],
                source: prop['source'],
                source_type: prop['source_type'],
                executable: prop['executable'] || File.basename(prop['source']))

      if old.nil?
        new.save
      elsif old.attributes != new.attributes
        old.update(new.attributes.except('id'))
      end
    end
  end

  # Downloads (or update if exists) all local files of dependencies.
  def self.download
    direct = where(source_type: 'direct')
    direct.each do |d|
      FileUtils.mkdir_p(File.dirname(d.path))
      File.open(d.path, 'wb') do |f|
        URI.open(d.source, 'rb') { |o| f.write(o.read) }
      end
    end
  end
end
