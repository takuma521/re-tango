class Word < ApplicationRecord
  belongs_to :book

  validates :name, presence: true, uniqueness: true
  validates :translation, presence: true
end
