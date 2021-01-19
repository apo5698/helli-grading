# frozen_string_literal: true

class ActiveStorageAttachmentSerializer < ActiveModel::Serializer
  attributes :id, :filename, :content_type, :byte_size, :checksum, :data

  def data
    object.download
  end
end
