class Users::Books::WordsController < ApplicationController
  before_action :set_words, only: %w(index)

  def index
  end

  def create
    word = Word.new(book_id: params[:book_id], name: params[:name], translation: params[:translation])
    word.save!
    redirect_to user_book_words_path
  end

  private

  def set_words
    @words = Word.where(book_id: params[:book_id])
  end
end
