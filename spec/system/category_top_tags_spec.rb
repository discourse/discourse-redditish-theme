# frozen_string_literal: true

require_relative "page_objects/components/sidebar_tags"

RSpec.describe "Category top tags in sidebar", system: true do
  let!(:theme) { upload_theme }
  let(:sidebar_tags) { PageObjects::Components::SidebarTags.new }

  fab!(:user)
  fab!(:tag1) { Fabricate(:tag, name: "ruby") }
  fab!(:tag2) { Fabricate(:tag, name: "javascript") }
  fab!(:category)
  fab!(:topic1) { Fabricate(:topic, category: category, tags: [tag1]) }
  fab!(:topic2) { Fabricate(:topic, category: category, tags: [tag2]) }

  before do
    SiteSetting.tagging_enabled = true
    sign_in(user)
  end

  it "displays category top tags with correct links" do
    visit("/c/#{category.slug}/#{category.id}")

    expect(sidebar_tags).to have_tag_link(tag_name: tag1.name, category_slug: category.slug)
    expect(sidebar_tags).to have_tag_link(tag_name: tag2.name, category_slug: category.slug)
  end

  it "does not display tags section when category has no top tags" do
    category_without_tags = Fabricate(:category)

    visit("/c/#{category_without_tags.slug}/#{category_without_tags.id}")

    expect(sidebar_tags).to have_no_tag_links
  end
end
