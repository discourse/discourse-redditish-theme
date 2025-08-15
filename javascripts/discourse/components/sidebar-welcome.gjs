import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and } from "truth-helpers";
import DButton from "discourse/components/d-button";
import basePath from "discourse/helpers/base-path";
import htmlSafe from "discourse/helpers/html-safe";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import SidebarLatestTopics from "./sidebar-latest-topics";

export default class SidebarWelcome extends Component {
  @service router;
  @service composer;
  @service siteSettings;
  @service site;
  @service currentUser;

  get isTopRoute() {
    const { currentRoute } = this.router;
    const topMenuRoutes = this.siteSettings.top_menu.split("|").filter(Boolean);
    return topMenuRoutes.includes(currentRoute.localName);
  }

  @action
  customCreateTopic() {
    this.composer.open({
      action: Composer.CREATE_TOPIC,
      draftKey: Composer.NEW_TOPIC_KEY,
      categoryId: this.args.category?.id,
      tags: this.args.tag?.id,
    });
  }

  <template>
    {{#if this.isTopRoute}}
      <div class="custom-right-sidebar_welcome">
        <h2>{{i18n (themePrefix "top_route_welcome")}}</h2>
        <p>
          {{htmlSafe
            (i18n (themePrefix "top_route_description") basePath=(basePath))
          }}
        </p>
        {{#if (and this.currentUser this.currentUser.can_create_topic)}}
          <DButton
            class="btn-primary"
            @id="custom-create-topic"
            @action={{this.customCreateTopic}}
            @label="topic.create"
          />
        {{/if}}
      </div>
      <div class="custom-right-sidebar_recent">
        <SidebarLatestTopics />
      </div>
    {{/if}}
  </template>
}
