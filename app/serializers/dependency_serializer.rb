class DependencySerializer < ActiveModel::Serializer
  attributes :name, :version, :source, :executable, :checksum
end
