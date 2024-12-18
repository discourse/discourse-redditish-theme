import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Composer from "discourse/models/composer";

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
}
