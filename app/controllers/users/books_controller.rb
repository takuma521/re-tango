class Users::BooksController < ApplicationController
  before_action :set_books, only: %w(index)

  def index
  end

  def create
    book = current_user.books.new(name: params[:name])
    book.save!
    redirect_to user_books_path(current_user)
  end

  private

  def set_books
    @books = current_user.books.all
  end
end
