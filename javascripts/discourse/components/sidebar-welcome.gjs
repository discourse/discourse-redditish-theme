import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import basePath from "discourse/helpers/base-path";
import { i18n } from "discourse-i18n";
import CreateTopicButton from "./create-topic-button";
import SidebarLatestTopics from "./sidebar-latest-topics";

export default class SidebarWelcome extends Component {
  @service router;
  @service siteSettings;

  get isTopRoute() {
    const { currentRoute } = this.router;
    const topMenuRoutes = this.siteSettings.top_menu.split("|").filter(Boolean);
    return topMenuRoutes.includes(currentRoute.localName);
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
        <CreateTopicButton class="btn-primary" />
      </div>
      <SidebarLatestTopics />
    {{/if}}
  </template>
}
