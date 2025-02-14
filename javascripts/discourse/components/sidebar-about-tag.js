import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { getOwner } from "discourse/lib/get-owner";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";

export default class SidebarAboutTag extends Component {
  @service store;
  @service router;
  @service currentUser;
  @service composer;

  @tracked tag = null;
  @tracked tagNotification = null;

  get tagId() {
    return this.router.currentRoute.params?.tag_id;
  }

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get linkedDescription() {
    return i18n(themePrefix("about_tag_admin_tip_description"), {
      topicUrl: "test",
    });
  }

  @action
  async getTagInfo() {
    const tag = this.tagId;
    if (tag) {
      const result = await this.store.find("tag-info", tag);
      this.tag = result;
    } else {
      this.tag = null;
    }
  }

  @action
  toggleInfo() {
    const controller = getOwner(this).lookup("controller:tag.show");
    controller.toggleProperty("showInfo");
  }

  @action
  async getTagNotificationLevel() {
    this.tagNotification = await this.store.find(
      "tagNotification",
      this.tagId.toLowerCase()
    );
  }

  @action
  changeTagNotificationLevel(notificationLevel) {
    this.tagNotification
      .update({ notification_level: notificationLevel })
      .then((response) => {
        const payload = response.responseJson;

        this.tagNotification.set("notification_level", notificationLevel);

        this.currentUser.setProperties({
          watched_tags: payload.watched_tags,
          watching_first_post_tags: payload.watching_first_post_tags,
          tracked_tags: payload.tracked_tags,
          muted_tags: payload.muted_tags,
          regular_tags: payload.regular_tags,
        });
      });
  }

  @action
  customCreateTopic() {
    this.composer.open({
      action: Composer.CREATE_TOPIC,
      draftKey: Composer.NEW_TOPIC_KEY,
      categoryId: this.category?.id,
      tags: this.tag?.name,
    });
  }
}
