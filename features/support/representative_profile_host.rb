# frozen_string_literal: true

Before('@representative_profile') do
  @original_default_host = Capybara.default_host
  Capybara.default_host = 'http://127.0.0.1'
end

After('@representative_profile') do
  Capybara.default_host = @original_default_host
end
