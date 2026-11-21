# frozen_string_literal: true

require 'rails_helper'

describe NewsItemsController do
  let(:user) { User.create!(uid: 'news-viewer', provider: :github, first_name: 'Test', last_name: 'User') }
  let(:representative) { Representative.create!(name: 'Barbara Lee', title: 'representative', ocdid: '400237') }
  let(:news_item) do
    item = NewsItem.new(title: 'Floor speech', link: 'https://example.com/speech', representative: representative)
    item.save!(validate: false)
    item
  end

  before { session[:user_id] = user.id }

  describe 'GET index' do
    it 'returns a successful response' do
      get :index, params: { representative_id: representative.id }
      expect(response).to be_successful
    end

    it 'assigns the news items for the representative' do
      news_item
      get :index, params: { representative_id: representative.id }
      expect(assigns(:news_items)).to eq([news_item])
    end

    it 'assigns the current user id' do
      get :index, params: { representative_id: representative.id }
      expect(assigns(:curr_user_id)).to eq(user.id)
    end
  end

  describe 'GET show' do
    it 'returns a successful response' do
      get :show, params: { representative_id: representative.id, id: news_item.id }
      expect(response).to be_successful
    end

    it 'assigns the news item' do
      get :show, params: { representative_id: representative.id, id: news_item.id }
      expect(assigns(:news_item)).to eq(news_item)
    end
  end
end
