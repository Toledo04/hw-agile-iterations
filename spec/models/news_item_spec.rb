# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
require 'rails_helper'

describe NewsItem do
  let(:representative) { Representative.create!(name: 'Alex Padilla', title: 'senator', ocdid: '456791') }

  describe '.find_for' do
    it 'returns the news item for the representative' do
      item = described_class.create!(title: 'Floor speech', link: 'https://example.com/speech',
                                     representative: representative, issue: 'Immigration')
      expect(described_class.find_for(representative.id)).to eq(item)
    end

    it 'returns nil when the representative has no news items' do
      expect(described_class.find_for(representative.id)).to be_nil
    end
  end

  describe 'issue' do
    let(:valid_attributes) do
      { title: 'Article about immigration', link: 'https://example.com/article', representative: representative }
    end

    it 'accepts an issue from the Iteration 2 list' do
      item = described_class.new(valid_attributes.merge(issue: 'Immigration'))

      expect(item).to be_valid
    end

    it 'rejects an issue outside the Iteration 2 list' do
      item = described_class.new(valid_attributes.merge(issue: 'Education'))

      expect(item).not_to be_valid
      expect(item.errors[:issue]).to be_present
    end

    it 'requires an issue' do
      item = described_class.new(valid_attributes)

      expect(item).not_to be_valid
      expect(item.errors[:issue]).to be_present
    end

    it 'provides the Iteration 2 issue list for the create form' do
      expect(described_class.issues).to eq([
        'Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare', 'Abortion',
        'Student Loans', 'Gun Control', 'Unemployment', 'Climate Change', 'Homelessness',
        'Racism', 'Tax Reform', 'Net Neutrality', 'Religious Freedom', 'Border Security',
        'Minimum Wage', 'Equal Pay'
      ])
    end
  end
end
