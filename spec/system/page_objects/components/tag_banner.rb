# frozen_string_literal: true

module PageObjects
  module Components
    class TagBanner < PageObjects::Components::Base
      SELECTOR = ".custom-tag-banner"

      def has_tag_link?(tag)
        has_css?("#{SELECTOR} h1 a[href='#{tag.url}']", text: tag.name)
      end
    end
  end
end
