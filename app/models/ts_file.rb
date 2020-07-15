class TsFile < ApplicationRecord
  belongs_to :assignment
  has_many_attached :files
end
