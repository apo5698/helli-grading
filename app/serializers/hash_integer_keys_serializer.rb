# Used for saving hashes with integer keys in PostgreSQL.
class HashIntegerKeysSerializer < ActiveModel::Serializer
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    (hash || {}).transform_keys(&:to_i)
  end
end
