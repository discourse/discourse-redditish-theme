import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class CustomTagBanner extends Component {
  @service router;

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get tag() {
    return this.router.currentRoute?.attributes?.tag;
  }

  <template>
    {{#unless this.category}}
      {{#if this.tag}}
        <div class="custom-tag-banner">
          <div class="custom-tag-banner_meta">
            <div class="custom-tag-banner_meta-text">
              <h1>
                <a href={{this.tag.url}}>
                  {{icon "tag"}}
                  {{this.tag.name}}
                </a>
              </h1>
            </div>
          </div>
        </div>
      {{/if}}
    {{/unless}}
  </template>
}
