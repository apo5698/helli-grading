# Used for saving hashes in PostgreSQL.
class HashSerializer < ActiveModel::Serializer
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    (hash || {}).symbolize_keys
  end
end
