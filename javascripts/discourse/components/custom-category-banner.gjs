import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import CategoryLogo from "discourse/components/category-logo";

export default class CustomCategoryBanner extends Component {
  @service router;

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get tag() {
    return this.router.currentRoute?.attributes?.tag;
  }

  get bannerBg() {
    return htmlSafe(
      `background: url("${this.category.uploaded_background?.url}");
       background-size: cover; 
       background-position: center center;;`
    );
  }

  get categoryBgColor() {
    return htmlSafe(
      `background-color: var(--category-${this.category.id}-color);`
    );
  }

  get categoryTextColor() {
    return htmlSafe(`color: ${this.category.text_color};`);
  }

  get categorySlug() {
    return this.category.slug || this.generateSlug(this.category.name);
  }

  generateSlug(name) {
    return name
      .toLowerCase() // Convert to lowercase
      .replace(/\s+/g, "-") // Replace spaces with hyphens
      .replace(/[^\w\-]+/g, "") // Remove all non-word characters
      .replace(/\-\-+/g, "-") // Replace multiple hyphens with a single hyphen
      .replace(/^-+/, "") // Trim hyphens from the start
      .replace(/-+$/, ""); // Trim hyphens from the end
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
                <a
                  href="/c/{{this.categorySlug}}"
                  style={{this.categoryTextColor}}
                >
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
