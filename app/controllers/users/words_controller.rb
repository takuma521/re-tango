class Users::WordsController < ApplicationController
  before_action :set_word, only: %w(destroy update)
  before_action :authenticate_user!
  protect_from_forgery :except => [:update]

  def index
    @words = current_user.words.order(id: 'DESC')
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

  def update
    if @word.update(translation: params[:translation])
      redirect_to user_words_path
    else
      redirect_to user_words_path, status: 422
    end
  end

  private

  def set_word
    @word = Word.find(params[:id])
  end
end
