# frozen_string_literal: true

RSpec.describe "Creating a topic from the custom post bar", system: true do
  let!(:theme) { upload_theme }
  let(:composer) { PageObjects::Components::Composer.new }

  # without refreshing auto groups the user isn't in trust_level_0, so
  # can_create_topic? is false and the post bar renders nothing
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  before { sign_in(user) }

  it "opens the composer when the fake input is clicked" do
    visit("/latest")

    find(".custom-post-bar-contents input").click

    expect(composer).to be_opened
  end
end
