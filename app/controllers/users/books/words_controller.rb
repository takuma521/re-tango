class Users::Books::WordsController < ApplicationController
  before_action :set_book, only: %w(index create destroy)
  before_action :set_word, only: %w(destroy)

  def index
    @words = @book.words
  end

  def create
    word = @book.words.new(name: params[:name], translation: params[:translation])
    if word.save!
      redirect_to user_book_words_path
    else
      redirect_to user_book_words_path, status: 422
    end
  end

  def destroy
    if @word.destroy
      redirect_to user_book_words_path
    else
      redirect_to user_book_words_path, status: 422
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_word
    @word = @book.words.find(params[:id])
  end
end
