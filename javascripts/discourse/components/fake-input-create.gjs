import Component from "@glimmer/component";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and } from "truth-helpers";
import TopicDraftsDropdown from "discourse/components/topic-drafts-dropdown";
import avatar from "discourse/helpers/avatar";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";

export default class FakeInputCreate extends Component {
  @service composer;
  @service router;
  @service currentUser;

  get hasDrafts() {
    return this.currentUser.get("draft_count");
  }

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get tag() {
    return this.router.currentRoute?.attributes?.tag;
  }

  @action
  customCreateTopic() {
    if (document.querySelector(".d-editor-input")) {
      document.querySelector(".d-editor-input").focus();
    } else {
      this.composer.open({
        action: Composer.CREATE_TOPIC,
        draftKey: Composer.NEW_TOPIC_KEY,
        categoryId: this.category?.id,
        tags: this.tag?.id,
      });
    }
  }

  <template>
    {{#if (and this.currentUser this.currentUser.can_create_topic)}}
      <div class="custom-post-bar-contents">
        <a href="/u/{{this.currentUser.username}}">
          {{avatar this.currentUser imageSize="medium"}}
        </a>
        <Input
          @type="text"
          placeholder={{i18n (themePrefix "post_input_placeholder")}}
          {{on "click" this.customCreateTopic}}
        />
        {{#if this.hasDrafts}}
          <TopicDraftsDropdown />
        {{/if}}
      </div>
    {{/if}}
  </template>
}
