import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { bind } from "discourse/lib/decorators";
import { NotificationLevels } from "discourse/lib/notification-levels";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";

export default class SidebarAboutCategory extends Component {
  @service site;
  @service router;
  @service currentUser;
  @service composer;

  @tracked topTags = this.site.category_top_tags;
  @tracked categoryNotificationLevel;

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get showTopicsForSubCategory() {
    if (!this.category.subcategories) {
      return false;
    }

    return this.category.subcategory_list_style.includes("topics");
  }

  get linkedDescription() {
    return i18n(themePrefix("about_category_admin_tip_description"), {
      topicUrl: this.category.topic_url,
    });
  }

  @action
  async changeCategoryNotificationLevel(notificationLevel) {
    await this.category.setNotification(notificationLevel);
    this.updateCategoryNotificationLevel();
  }

  @action
  customCreateTopic() {
    this.composer.open({
      action: Composer.CREATE_TOPIC,
      draftKey: Composer.NEW_TOPIC_KEY,
      categoryId: this.category?.id,
      tags: this.tag?.id,
    });
  }

  @bind
  updateCategoryNotificationLevel() {
    if (
      this.currentUser?.indirectly_muted_category_ids?.includes(
        this.category.id
      )
    ) {
      this.categoryNotificationLevel = NotificationLevels.MUTED;
    } else {
      this.categoryNotificationLevel = this.category.notification_level;
    }
  }
}
