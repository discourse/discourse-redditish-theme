import Component from "@glimmer/component";
import { action, get } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import categoryLink from "discourse/helpers/category-link";
import { NotificationLevels } from "discourse/lib/notification-levels";
import { getCategoryAndTagUrl } from "discourse/lib/url";
import CategoryNotificationsButton from "discourse/select-kit/components/category-notifications-button";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import AddToSidebar from "./add-to-sidebar";
import CreateTopicButton from "./create-topic-button";

export default class SidebarAboutCategory extends Component {
  @service site;
  @service currentUser;
  @service routeContext;

  get category() {
    return this.routeContext.category;
  }

  get topTags() {
    return this.site.categoryTopTags.map((tag) => ({
      name: tag.name,
      href: getCategoryAndTagUrl(this.category, true, tag),
    }));
  }

  get linkedDescription() {
    return i18n(themePrefix("about_category_admin_tip_description"), {
      topicUrl: this.category.topic_url,
    });
  }

  get categoryNotificationLevel() {
    const indirectlyMuted = this.currentUser
      ? get(this.currentUser, "indirectly_muted_category_ids")
      : null;

    if (indirectlyMuted?.includes(this.category.id)) {
      return NotificationLevels.MUTED;
    }

    return get(this.category, "notification_level");
  }

  @action
  changeCategoryNotificationLevel(notificationLevel) {
    return this.category.setNotification(notificationLevel);
  }

  <template>
    {{#if this.category}}
      {{! ensure we've got something to show so we don't get an empty block}}
      {{#if (or this.category.description this.currentUser)}}
        <div class="custom-right-sidebar_category-about">
          {{#if this.category.description}}
            <h3>{{i18n (themePrefix "about_category")}}</h3>
            <p>{{htmlSafe this.category.description}}</p>
          {{else}}
            {{#if this.currentUser.admin}}
              <h3>{{i18n (themePrefix "about_admin_tip_headline")}}</h3>
              <p>
                {{htmlSafe this.linkedDescription}}
              </p>
            {{/if}}
          {{/if}}
          {{#if this.currentUser}}
            <div class="custom-right-sidebar_controls">
              <CreateTopicButton class="btn-default" @icon="plus" />
              <CategoryNotificationsButton
                @value={{this.categoryNotificationLevel}}
                @category={{this.category}}
                @onChange={{this.changeCategoryNotificationLevel}}
              />

              <AddToSidebar @category={{this.category}} />
            </div>
          {{/if}}

        </div>
        {{#if (or this.category.subcategories this.topTags.length)}}

          <div
            class="custom-right-sidebar_category-about -tags-and-subcategories"
          >

            {{#if this.category.subcategories}}
              <div class="custom-right-sidebar_subcategories">
                <h4>{{i18n (themePrefix "subcategories")}}</h4>
                {{#each this.category.subcategories as |subcategory|}}
                  {{categoryLink subcategory}}
                {{/each}}
              </div>
            {{/if}}

            {{#if this.topTags.length}}
              <div class="custom-right-sidebar_tags">
                <h4>{{i18n (themePrefix "top_tags")}}</h4>
                <div class="discourse-tags">
                  {{#each this.topTags as |tag|}}
                    <a
                      href={{tag.href}}
                      data-tag-name={{tag.name}}
                      class="discourse-tag simple"
                    >
                      {{tag.name}}
                    </a>
                  {{/each}}
                </div>
              </div>
            {{/if}}
          </div>
        {{/if}}
      {{/if}}
    {{/if}}
  </template>
}
