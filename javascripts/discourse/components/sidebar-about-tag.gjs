import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import htmlSafe from "discourse/helpers/html-safe";
import { getOwner } from "discourse/lib/get-owner";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import TagNotificationsButton from "select-kit/components/tag-notifications-button";
import AddToSidebar from "./add-to-sidebar";

export default class SidebarAboutTag extends Component {
  @service store;
  @service router;
  @service currentUser;
  @service composer;

  @tracked tag = null;
  @tracked tagNotification = null;

  get shouldShow() {
    return this.tag && !this.category;
  }

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

  <template>
    {{#if this.tagId}}
      <div
        {{didInsert this.getTagInfo}}
        {{didUpdate this.getTagInfo this.tagId}}
        {{didInsert this.getTagNotificationLevel}}
        {{didUpdate this.getTagNotificationLevel this.tagId}}
      >
        {{#if this.shouldShow}}
          {{#if (or this.tag.description this.currentUser)}}
            <div class="custom-right-sidebar_tag-about">
              {{#if this.tag.description}}
                <h3>{{i18n (themePrefix "about_tag")}}</h3>
                <p>{{htmlSafe this.tag.description}}</p>
              {{/if}}
              {{#if this.currentUser}}
                <div class="custom-right-sidebar_controls">
                  {{#if this.currentUser.can_create_topic}}
                    <DButton
                      class="btn-default"
                      @id="custom-create-topic"
                      @action={{this.customCreateTopic}}
                      @icon="plus"
                      @translatedLabel={{i18n "topic.create"}}
                    />
                  {{/if}}
                  <TagNotificationsButton
                    @onChange={{this.changeTagNotificationLevel}}
                    @value={{this.tagNotification.notification_level}}
                  />
                  <AddToSidebar @tag={{this.tag}} @category={{this.category}} />
                </div>
              {{/if}}
            </div>
          {{/if}}
        {{/if}}
      </div>
    {{/if}}
  </template>
}
