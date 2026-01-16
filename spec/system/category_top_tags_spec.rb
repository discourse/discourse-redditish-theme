# frozen_string_literal: true

RSpec.describe "Category top tags in sidebar", type: :system do
  fab!(:tag) { Fabricate(:tag, name: "help", public_topic_count: 10) }
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category:, tags: [tag]) }
  fab!(:post) { Fabricate(:post, topic:) }
  fab!(:user)

  let!(:theme) { upload_theme }

  before do
    SiteSetting.tagging_enabled = true
    sign_in(user)
  end

  it "displays category page with sidebar" do
    visit("/c/#{category.slug}/#{category.id}")
    expect(page).to have_css(".custom-right-sidebar_category-about")
  end
end
