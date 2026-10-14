import Component from "@glimmer/component";
import { action, get, set } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { or } from "discourse/truth-helpers";

export default class AddToSidebar extends Component {
  @service currentUser;

  get isInSidebar() {
    const { category, tag } = this.args;

    if (category) {
      return get(this.currentUser, "sidebar_category_ids")?.includes(
        category.id
      );
    }

    return get(this.currentUser, "sidebar_tags")?.some(
      (savedTag) => savedTag.name === tag.name
    );
  }

  @action
  async toggleInSidebar() {
    const { category, tag } = this.args;

    if (category) {
      const ids = this.currentUser.sidebar_category_ids ?? [];

      set(
        this.currentUser,
        "sidebar_category_ids",
        this.isInSidebar
          ? ids.filter((id) => id !== category.id)
          : [...ids, category.id]
      );
    } else {
      const names = (this.currentUser.sidebar_tags ?? []).map((t) => t.name);

      set(
        this.currentUser,
        "sidebar_tag_names",
        this.isInSidebar
          ? names.filter((name) => name !== tag.name)
          : [...names, tag.name]
      );
    }

    try {
      const result = await this.currentUser.save([
        "sidebar_category_ids",
        "sidebar_tag_names",
      ]);

      if (result.user.sidebar_tags) {
        set(this.currentUser, "sidebar_tags", result.user.sidebar_tags);
      }
    } catch (error) {
      popupAjaxError(error);
    }
  }

  <template>
    {{#if (or @category @tag)}}
      <DButton
        @action={{this.toggleInSidebar}}
        @icon={{if this.isInSidebar "star" "far-star"}}
        class="btn-default add-to-sidebar {{if this.isInSidebar 'in-sidebar'}}"
      />
    {{/if}}
  </template>
}
