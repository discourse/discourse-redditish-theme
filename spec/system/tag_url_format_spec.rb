# frozen_string_literal: true

require_relative "page_objects/components/tag_banner"
require_relative "page_objects/components/sidebar_tags"

RSpec.describe "Tag URL format", system: true do
  let!(:theme) { upload_theme }

  fab!(:user)
  fab!(:tag) { Fabricate(:tag, name: "important") }
  fab!(:category)
  fab!(:category_topic) { Fabricate(:topic, category: category, tags: [tag]) }

  let(:tag_banner) { PageObjects::Components::TagBanner.new }
  let(:sidebar_tags) { PageObjects::Components::SidebarTags.new }

  before do
    SiteSetting.tagging_enabled = true
    sign_in(user)
  end

  it "displays tag banner with correct link format" do
    visit("/tag/#{tag.name}")

    expect(tag_banner).to have_tag_link(tag)
  end

  it "displays category top tags with correct link format" do
    visit("/c/#{category.slug}/#{category.id}")

    expect(sidebar_tags).to have_tag_link(tag: tag, category: category)
  end
end
