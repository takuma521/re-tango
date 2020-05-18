class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    basic_action
  end

  private

  def basic_action
    @omniauth = request.env['omniauth.auth']
    if @omniauth.present?
      @profile = User.where(provider: @omniauth['provider'], uid: @omniauth['uid']).first
      if @profile
        @profile.set_values(@omniauth)
        sign_in(:user, @profile)
        notice = 'ログインしました。'
      else
        @profile = User.new(provider: @omniauth['provider'], uid: @omniauth['uid'])
        @profile = current_user || User.create!(provider: @omniauth['provider'], uid: @omniauth['uid'], name: @omniauth['info']['name'], password: Devise.friendly_token[0, 20])
        @profile.set_values(@omniauth)
        sign_in(:user, @profile)
        notice = 'ユーザーが登録されました。'
      end
    end
    flash[:notice] = notice
    redirect_to user_words_path(@profile)
  end
end
