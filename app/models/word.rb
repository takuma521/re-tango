class Word < ApplicationRecord
  belongs_to :book

  validates :name, presence: true
  validates :translation, presence: true
end
