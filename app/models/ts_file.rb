class TsFile < ApplicationRecord
  belongs_to :assignment
  has_one_attached :file
end
