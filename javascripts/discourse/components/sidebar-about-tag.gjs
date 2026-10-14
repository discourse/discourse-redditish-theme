import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import TagNotificationsButton from "discourse/select-kit/components/tag-notifications-button";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import AddToSidebar from "./add-to-sidebar";
import CreateTopicButton from "./create-topic-button";

// holds the result of a store request once it arrives; a fresh one is made
// per tag, so a slow response for a previous tag can't overwrite the current
class StoreResult {
  @tracked value = null;

  constructor(id, promise) {
    this.id = id;
    promise.then((value) => (this.value = value)).catch(() => {});
  }
}

export default class SidebarAboutTag extends Component {
  @service store;
  @service currentUser;
  @service routeContext;

  get adminTip() {
    return i18n(themePrefix("about_tag_admin_tip_description"), {
      editUrl: `${this.routeContext.tag.url}/edit`,
    });
  }

  get tagId() {
    return this.routeContext.category ? null : this.routeContext.tag?.id;
  }

  #results = {};

  get tagInfo() {
    return this.#find("tag-info");
  }

  get tagNotification() {
    return this.currentUser ? this.#find("tagNotification") : null;
  }

  // the route's tag object is replaced on every transition (e.g. latest -> top),
  // so key on the id to avoid refetching for the same tag
  #find(type) {
    const id = this.tagId;

    if (!id) {
      return null;
    }

    if (this.#results[type]?.id !== id) {
      this.#results[type] = new StoreResult(id, this.store.find(type, id));
    }

    return this.#results[type];
  }

  @action
  async changeTagNotificationLevel(notificationLevel) {
    const tagNotification = this.tagNotification.value;
    const response = await tagNotification.update({
      notification_level: notificationLevel,
    });
    const payload = response.responseJson;

    tagNotification.set("notification_level", notificationLevel);

    this.currentUser.setProperties({
      watched_tags: payload.watched_tags,
      watching_first_post_tags: payload.watching_first_post_tags,
      tracked_tags: payload.tracked_tags,
      muted_tags: payload.muted_tags,
      regular_tags: payload.regular_tags,
    });
  }

  <template>
    {{#let this.tagInfo.value as |tag|}}
      {{#if tag}}
        {{#if (or tag.description this.currentUser)}}
          <div class="custom-right-sidebar_tag-about">
            {{#if tag.description}}
              <h3>{{i18n (themePrefix "about_tag")}}</h3>
              <p>{{htmlSafe tag.description}}</p>
            {{else if this.currentUser.canEditTags}}
              <h3>{{i18n (themePrefix "about_admin_tip_headline")}}</h3>
              <p>{{htmlSafe this.adminTip}}</p>
            {{/if}}
            {{#if this.currentUser}}
              <div class="custom-right-sidebar_controls">
                <CreateTopicButton class="btn-default" @icon="plus" />
                <TagNotificationsButton
                  @onChange={{this.changeTagNotificationLevel}}
                  @value={{this.tagNotification.value.notification_level}}
                />
                <AddToSidebar @tag={{tag}} />
              </div>
            {{/if}}
          </div>
        {{/if}}
      {{/if}}
    {{/let}}
  </template>
}
