class Users::BooksController < ApplicationController
  before_action :set_books, only: %w(index)

  def index
  end

  private

  def set_books
    @books = current_user.books.all
  end
end
