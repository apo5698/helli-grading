require 'yaml'

module ConfigHelper
  @config_path = Rails.root.join('config', 'ags.yml')
  @config = YAML.safe_load(File.open(@config_path))
  @lib_root = Rails.root.join('public', 'lib')

  # Returns all config.
  def self.config
    @config
  end

  # Reloads and overwrites current config instance.
  def self.reload
    @config = YAML.safe_load(File.open(@config_path))
  end

  # Returns a path in config.
  def self.path(item)
    p = @config&.dig('path', item)
    return nil if p.nil?

    Rails.root.join(p)
  end

  # Returns the information of a library.
  def self.lib_info(lib)
    @config&.dig('library', lib)
  end

  # Returns the absolute path of a library; +nil+ if given library does not exist.
  # If +version+ is specified and the corresponding version exists, returns the path of the given
  # version of this library; otherwise returns it with the default version.
  def self.lib_path(lib, version = nil)
    info = lib_info(lib)
    return nil if info.nil?

    current = info['version']
    version ||= current
    lib_path = @lib_root.join(lib)
    ver_path = lib_path.join(version.to_s)
    File.exist?(ver_path) ? ver_path : lib_path.join(current.to_s)
  end
end
