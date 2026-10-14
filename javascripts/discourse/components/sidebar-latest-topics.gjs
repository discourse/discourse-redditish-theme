import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import { TOPIC_COUNT } from "../services/recent-topics";
import TopicCard from "./topic-card";

// one per topic we render, so the sidebar reserves its height while loading
const PLACEHOLDERS = Array.from({ length: TOPIC_COUNT });

export default class LatestTopicsSidebar extends Component {
  @service recentTopics;

  constructor() {
    super(...arguments);
    this.recentTopics.load();
  }

  get isLoading() {
    return this.recentTopics.topics === null;
  }

  <template>
    {{! hidden entirely rather than left as an empty card }}
    {{#unless this.recentTopics.isEmpty}}
      <div class="custom-right-sidebar_recent">
        {{#if this.recentTopics.usingFallback}}
          <h4>{{i18n (themePrefix "hot_topics")}}</h4>
        {{else}}
          <h4>{{i18n (themePrefix "recent_topics")}}</h4>
        {{/if}}

        <div class="custom-right-sidebar_recent-topics">
          {{#if this.isLoading}}
            {{#each PLACEHOLDERS}}
              <div class="custom-right-sidebar_recent-topics-wrapper">
                <div class="custom-right-sidebar_recent-topics-placeholder">
                  <div
                    class="placeholder-line --meta placeholder-animation"
                  ></div>
                  <div
                    class="placeholder-line --title placeholder-animation"
                  ></div>
                  <div
                    class="placeholder-line --title --short placeholder-animation"
                  ></div>
                  <div
                    class="placeholder-line --meta placeholder-animation"
                  ></div>
                </div>
              </div>
            {{/each}}
          {{/if}}

          {{#each this.recentTopics.topics as |topic|}}
            <div class="custom-right-sidebar_recent-topics-wrapper">
              <TopicCard @topic={{topic}} @compact={{true}} />
            </div>
          {{/each}}
        </div>
      </div>
    {{/unless}}
  </template>
}
