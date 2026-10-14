import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class CustomTagBanner extends Component {
  @service routeContext;

  <template>
    {{#unless this.routeContext.category}}
      {{#if this.routeContext.tag}}
        <div class="custom-tag-banner">
          <div class="custom-tag-banner_meta">
            <div class="custom-tag-banner_meta-text">
              <h1>
                <a href={{this.routeContext.tag.url}}>
                  {{icon "tag"}}
                  {{this.routeContext.tag.name}}
                </a>
              </h1>
            </div>
          </div>
        </div>
      {{/if}}
    {{/unless}}
  </template>
}
