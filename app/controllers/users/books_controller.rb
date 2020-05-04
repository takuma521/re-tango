class Users::BooksController < ApplicationController
  before_action :set_book, only: %w(destroy)
  before_action :authenticate_user!

  def index
    @books = current_user.books
  end

  def create
    book = current_user.books.new(name: params[:name])
    if book.save
      redirect_to user_books_path
    else
      redirect_to user_books_path, status: 422
    end
  end

  def destroy
    if @book.destroy
      redirect_to user_books_path
    else
      redirect_to user_books_path, status: 422
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end
end
