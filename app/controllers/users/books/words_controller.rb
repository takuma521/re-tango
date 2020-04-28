class Users::Books::WordsController < ApplicationController
  before_action :set_words, only: %w(index)

  def index
  end

  private

  def set_words
    @words = Word.where(book_id: params[:book_id])
  end
end
