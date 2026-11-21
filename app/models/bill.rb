# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id               :integer          not null, primary key
#  bill_type        :string
#  congress         :integer
#  number           :integer
#  original_chamber :string
#  summary          :text
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Bill < ApplicationRecord
  validates :title, :congress, :number, :original_chamber, :bill_type, :summary, presence: true
end
