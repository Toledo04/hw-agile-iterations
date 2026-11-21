# frozen_string_literal: true

require 'rails_helper'

describe MyNewsItemsController do
  let(:user) { User.create!(uid: 'news-tester', provider: :github, first_name: 'Test', last_name: 'User') }
  let(:representative) { Representative.create!(name: 'Barbara Lee', title: 'representative', ocdid: '400237') }
  let(:news_item) do
    item = NewsItem.new(title: 'Floor speech', link: 'https://example.com/speech', representative: representative)
    item.save!(validate: false)
    item
  end

  context 'when not logged in' do
    it 'redirects to the login page' do
      get :new, params: { representative_id: representative.id }
      expect(response).to redirect_to(login_url)
    end

    it 'asks the user to log in' do
      get :new, params: { representative_id: representative.id }
      expect(flash[:notice]).to eq('Please login before continuing.')
    end
  end

  context 'when logged in' do
    before { session[:user_id] = user.id }

    describe 'GET new' do
      it 'returns a successful response' do
        get :new, params: { representative_id: representative.id }
        expect(response).to be_successful
      end

      it 'assigns a new news item' do
        get :new, params: { representative_id: representative.id }
        expect(assigns(:news_item)).to be_a_new(NewsItem)
      end

      it 'assigns the list of representatives for the form' do
        get :new, params: { representative_id: representative.id }
        expect(assigns(:representatives_list)).to eq([['Barbara Lee', representative.id]])
      end
    end

    describe 'GET edit' do
      it 'returns a successful response' do
        get :edit, params: { representative_id: representative.id, id: news_item.id }
        expect(response).to be_successful
      end

      it 'assigns the news item' do
        get :edit, params: { representative_id: representative.id, id: news_item.id }
        expect(assigns(:news_item)).to eq(news_item)
      end
    end

    describe 'DELETE destroy' do
      it 'deletes the news item' do
        news_item
        expect { delete :destroy, params: { representative_id: representative.id, id: news_item.id } }
          .to change(NewsItem, :count).by(-1)
      end

      it 'redirects to the representative news list' do
        delete :destroy, params: { representative_id: representative.id, id: news_item.id }
        expect(response).to redirect_to(representative_news_items_path(representative))
      end
    end
  end
end
