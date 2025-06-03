import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import categoryLink from "discourse/helpers/category-link";
import htmlSafe from "discourse/helpers/html-safe";
import { bind } from "discourse/lib/decorators";
import { NotificationLevels } from "discourse/lib/notification-levels";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import CategoryNotificationsButton from "select-kit/components/category-notifications-button";
import AddToSidebar from "./add-to-sidebar";

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
            <div
              class="custom-right-sidebar_controls"
              {{didInsert this.updateCategoryNotificationLevel}}
            >
              {{#if this.currentUser.can_create_topic}}
                <DButton
                  class="btn-default"
                  @id="custom-create-topic"
                  @action={{action "customCreateTopic"}}
                  @icon="plus"
                  @translatedLabel={{i18n "topic.create"}}
                />
              {{/if}}
              <CategoryNotificationsButton
                @value={{this.categoryNotificationLevel}}
                @category={{this.category}}
                @onChange={{action "changeCategoryNotificationLevel"}}
              />

              <AddToSidebar @tag={{this.tag}} @category={{this.category}} />
            </div>
          {{/if}}

        </div>
        {{#if (or this.category.subcategories this.site.category_top_tags)}}

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

            {{#if this.site.category_top_tags}}
              <div class="custom-right-sidebar_tags">
                <h4>{{i18n (themePrefix "top_tags")}}</h4>
                <div class="discourse-tags">
                  {{#each this.site.category_top_tags as |tag|}}
                    <a
                      href="/tags/c/{{this.category.slug}}/{{tag}}"
                      data-tag-name={{tag}}
                      class="discourse-tag simple"
                    >
                      {{tag}}
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
