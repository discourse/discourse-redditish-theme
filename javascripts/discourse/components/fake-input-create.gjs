import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import TopicDraftsDropdown from "discourse/components/topic-drafts-dropdown";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";

export default class FakeInputCreate extends Component {
  @service composer;
  @service currentUser;
  @service routeContext;

  @action
  createTopic() {
    const editor = document.querySelector(".d-editor-input");

    if (editor) {
      editor.focus();
      return;
    }

    this.composer.openNewTopic({
      category: this.routeContext.category,
      tags: this.routeContext.tag?.name,
    });
  }

  <template>
    {{#if this.currentUser.can_create_topic}}
      <div class="custom-post-bar">
        <div class="custom-post-bar-contents">
          <a href="/u/{{this.currentUser.username}}">
            {{avatar this.currentUser imageSize="medium"}}
          </a>
          <button
            type="button"
            class="custom-post-bar-input"
            {{on "click" this.createTopic}}
          >
            {{i18n (themePrefix "post_input_placeholder")}}
          </button>
          {{#if this.currentUser.draft_count}}
            <TopicDraftsDropdown />
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}
