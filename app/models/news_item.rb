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
class NewsItem < ApplicationRecord
  attr_accessor :rating

  ISSUES = [
    'Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare', 'Abortion',
    'Student Loans', 'Gun Control', 'Unemployment', 'Climate Change', 'Homelessness',
    'Racism', 'Tax Reform', 'Net Neutrality', 'Religious Freedom', 'Border Security',
    'Minimum Wage', 'Equal Pay'
  ].freeze

  # TODO: this belongs to a user (creator_id)
  belongs_to :representative
  validates :issue, inclusion: { in: ISSUES }, allow_nil: true
  validates :issue, presence: true, if: :issue_required?

  def self.issues
    ISSUES
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end

  private

  def issue_required?
    new_record? || will_save_change_to_issue?
  end
end
