# frozen_string_literal: true

module PageObjects
  module Components
    class SidebarTags < PageObjects::Components::Base
      SELECTOR = ".custom-right-sidebar_tags"

      def has_tag_link?(tag_name:, category_slug:)
        has_css?(
          "#{SELECTOR} .discourse-tag[data-tag-name='#{tag_name}'][href*='/tags/c/#{category_slug}/#{tag_name}']",
          text: tag_name,
        )
      end

      def has_no_tag_links?
        has_no_css?(SELECTOR)
      end
    end
  end
end
