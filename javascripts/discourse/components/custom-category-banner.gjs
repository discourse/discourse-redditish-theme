import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import CategoryLogo from "discourse/components/category-logo";

export default class CustomCategoryBanner extends Component {
  @service routeContext;

  get category() {
    return this.routeContext.category;
  }

  get bannerBg() {
    const url = this.category.uploaded_background?.url;

    if (!url) {
      return null;
    }

    return htmlSafe(`background: url("${url}") center center / cover;`);
  }

  get categoryBgColor() {
    return htmlSafe(
      `background-color: var(--category-${this.category.id}-color);`
    );
  }

  // text_color is stored as bare hex, without the #
  get categoryTextColor() {
    return htmlSafe(`color: #${this.category.text_color};`);
  }

  <template>
    {{#if this.category}}
      <div class="custom-category-banner">
        {{#if this.category.uploaded_logo.url}}
          <div
            class="custom-category-banner_background"
            style={{this.bannerBg}}
          >
            <CategoryLogo @category={{this.category}} />
          </div>
        {{/if}}
        <div class="custom-category-banner_meta" style={{this.categoryBgColor}}>
          {{#unless this.category.uploaded_logo.url}}
            <div class="custom-category-banner_meta-text">
              <h1>
                <a href={{this.category.url}} style={{this.categoryTextColor}}>
                  {{this.category.name}}
                </a>
              </h1>
            </div>
          {{/unless}}
        </div>
      </div>
    {{/if}}
  </template>
}
