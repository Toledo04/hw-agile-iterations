# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
  let(:google_auth) do
    OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid:      '12345',
      info:     { first_name: 'Test', last_name: 'User', email: 'test@example.com' }
    )
  end

  let(:github_auth) do
    OmniAuth::AuthHash.new(
      provider: 'github',
      uid:      '67890',
      info:     { name: 'Octo Cat', email: 'octo@example.com' }
    )
  end

  describe 'GET #create' do
    context 'with Google' do
      before { request.env['omniauth.auth'] = google_auth }

      it 'creates a new user' do
        expect { get :create, params: { provider: 'google_oauth2' } }
          .to change(User, :count).by(1)
      end

      it 'logs the user in' do
        get :create, params: { provider: 'google_oauth2' }
        expect(session[:user_id]).to eq(User.last.id)
      end

      it 'redirects to the home page' do
        get :create, params: { provider: 'google_oauth2' }
        expect(response).to redirect_to(root_url)
      end

      it 'reuses an existing Google user' do
        User.create!(provider: :google_oauth2, uid: '12345', first_name: 'Test', last_name: 'User')
        expect { get :create, params: { provider: 'google_oauth2' } }
          .not_to change(User, :count)
      end
    end

    context 'with GitHub' do
      before { request.env['omniauth.auth'] = github_auth }

      it 'splits the full name into first and last name' do
        get :create, params: { provider: 'github' }
        expect(User.last).to have_attributes(first_name: 'Octo', last_name: 'Cat')
      end
    end
  end
end
