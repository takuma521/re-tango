class Users::WordsController < ApplicationController
  before_action :set_word, only: %w(destroy)
  before_action :authenticate_user!

  def index
    @words = current_user.words
  end

  def create
    word = current_user.words.new(name: params[:name], translation: params[:translation])
    word.translation = Translate.to_japanese(word.name) if word.translation.blank?
    if word.save
      redirect_to user_words_path
    else
      redirect_to user_words_path, status: 422
    end
  end

  def destroy
    if @word.destroy
      redirect_to user_words_path
    else
      # TODO: error message 表示
      redirect_to user_words_path, status: 422
    end
  end

  private

  def set_word
    @word = Word.find(params[:id])
  end
end
