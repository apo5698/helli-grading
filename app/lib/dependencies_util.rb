require 'yaml'

module DependenciesUtil
  # Returns all config.
  def self.config
    @config
  end

  # Reloads and overwrites current config instance.
  def self.reload
    @config = YAML.load_file(@config_path)
  end

  def self.json
    reload
    link = File.join('api', 'dependencies.json')
    File.open(Rails.root.join('public', link), 'w') { |_| _.write(@config.to_json) }
    link
  end

  # Returns the information of a dependency; +nil+ if it not exists.
  def self.lib_info(lib)
    @config.dig(lib)
  end

  # Returns the absolute path of a dependency; +nil+ if given dependency does not exist.
  # If +version+ is specified and it exists, returns the absolute path at the given version;
  # otherwise returns it with the version declared in dependencies.yml.
  def self.path(lib, version: nil)
    info = lib_info(lib)
    return nil if info.nil?

    current_version = info['version']
    type = info['type']
    version ||= current_version

    path = @lib_root.join(type, lib)
    path = path.join(version.to_s) if type != 'git'
    path = path.join(info['executable'] || '')
    path.to_s
  end

  private

  @lib_root = Rails.root.join('lib', 'dependencies')
  @config_path = Rails.root.join(@lib_root, 'dependencies.yml')
  @config = YAML.load_file(@config_path)
end
