# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserController do
  describe 'GET #profile' do
    it 'shows the logged-in user profile' do
      user = User.create!(uid: 'profile-tester', provider: :github, first_name: 'Test', last_name: 'User')
      session[:user_id] = user.id

      get :profile

      expect(response).to be_successful
      expect(assigns(:user)).to eq(user)
    end

    it 'redirects to login when logged out' do
      get :profile

      expect(response).to redirect_to(login_url)
    end
  end
end
