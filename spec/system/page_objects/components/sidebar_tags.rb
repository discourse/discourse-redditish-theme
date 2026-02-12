# frozen_string_literal: true

module PageObjects
  module Components
    class SidebarTags < PageObjects::Components::Base
      SELECTOR = ".custom-right-sidebar_tags"

      def has_tag_link?(tag:, category:)
        has_css?(
          "#{SELECTOR} .discourse-tag[data-tag-name='#{tag.name}'][href='/tags/c/#{category.slug}/#{category.id}/#{tag.slug}/#{tag.id}']",
          text: tag.name,
        )
      end

      def has_no_tag_links?
        has_no_css?(SELECTOR)
      end
    end
  end
end
