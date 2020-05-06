class Word < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :translation, presence: true
end
