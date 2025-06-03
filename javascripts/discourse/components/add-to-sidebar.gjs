import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, set } from "@ember/object";
import { dependentKeyCompat } from "@ember/object/compat";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class AddToSidebar extends Component {
  @service currentUser;

  @tracked saved = false;
  @tracked sidebarChanged = false;
  saveAttrNames = ["sidebar_category_ids", "sidebar_tag_names"];

  get shouldNotRender() {
    const category = this.args.category;
    const tag = this.args.tag;
    return (category && tag) || (!category && !tag);
  }

  @dependentKeyCompat
  get isInSidebar() {
    // need to do this to get DButton to update
    this.sidebarChanged;
    const category = this.args.category;
    const tag = this.args.tag;

    return (
      (category &&
        this.currentUser.sidebar_category_ids?.includes(category.id)) ||
      (tag &&
        this.currentUser.sidebar_tags.some(
          (savedTag) => savedTag.name === tag.name
        ))
    );
  }

  get buttonIcon() {
    return this.isInSidebar ? "star" : "far-star";
  }

  @action
  toggleInSidebar() {
    let sidebarCategories = this.currentUser.sidebar_category_ids;
    let sidebarTags = this.currentUser.sidebar_tags;

    if (this.args.category) {
      let categoryId = this.args.category.id;
      if (sidebarCategories.includes(categoryId)) {
        sidebarCategories = sidebarCategories.filter((id) => id !== categoryId);
      } else {
        sidebarCategories = [...sidebarCategories, categoryId];
      }

      set(this.currentUser, "sidebar_category_ids", sidebarCategories);
    } else if (this.args.tag) {
      let sidebarTagNames = sidebarTags.map((tag) => tag.name);
      let tagIsMatched = sidebarTags.some(
        (tag) => tag.name === this.args.tag.name
      );

      if (tagIsMatched) {
        sidebarTagNames = sidebarTagNames.filter(
          (name) => name !== this.args.tag.name
        );
      } else {
        sidebarTagNames.push(this.args.tag.name);
      }

      sidebarTags = sidebarTagNames.map((name) => {
        return { name };
      });
      set(this.currentUser, "sidebar_tag_names", sidebarTagNames);
    }

    return this.currentUser
      .save(this.saveAttrNames)
      .then((result) => {
        this.saved = true;

        if (result.user.sidebar_tags) {
          set(this.currentUser, "sidebar_tags", result.user.sidebar_tags);
        }

        // Update after the currentUser properties change
        this.sidebarChanged = !this.sidebarChanged;
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.error("Error updating sidebar:", error);
        this.saved = false;
      })
      .finally(() => {});
  }

  <template>
    {{#unless this.shouldNotRender}}
      <DButton
        @action={{action "toggleInSidebar"}}
        class="btn-default add-to-sidebar {{if this.isInSidebar 'in-sidebar'}}"
        @icon={{this.buttonIcon}}
      />
    {{/unless}}
  </template>
}
