import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { get } from "@ember/helper";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import categoryLink from "discourse/helpers/category-link";
import icon from "discourse/helpers/d-icon";
import discourseTags from "discourse/helpers/discourse-tags";
import formatDate from "discourse/helpers/format-date";
import topicLink from "discourse/helpers/topic-link";
import { i18n } from "discourse-i18n";

export default class LatestTopicsSidebar extends Component {
  @service router;
  @service store;
  @service siteSettings;
  @service currentUser;

  @tracked latestTopics = null;

  @action
  async getLatestTopics() {
    let topicList;

    if (this.currentUser) {
      topicList = await this.store.findFiltered("topicList", {
        filter: "read",
        params: {
          order: "latest",
        },
      });
    } else {
      topicList = await this.store.findFiltered("topicList", {
        filter: "latest",
        params: {
          order: "created",
        },
      });
    }

    this.latestTopics = topicList.topics
      .filter((topic) => !topic.closed)
      .slice(0, 5);
  }

  <template>
    <h4>{{i18n (themePrefix "recent_topics")}}</h4>

    <div
      class="custom-right-sidebar_recent-topics"
      {{didInsert this.getLatestTopics}}
    >
      {{#each this.latestTopics as |topic|}}
        {{! this is largely topic-list-item.hbr,
        but using that component directly was causing
        eyeline issues with loading more topics on }}
        <div class="custom-right-sidebar_recent-topics-wrapper">
          {{! template-lint-disable no-nested-interactive }}
          <a
            class="custom-topic-layout"
            href="{{topic.url}}/{{topic.last_read_post_number}}"
          >
            <div class="custom-topic-layout_meta">
              {{#unless this.hideCategory}}
                {{#unless topic.isPinnedUncategorized}}
                  {{categoryLink topic.category}}
                  <span class="bullet-separator">&bull;</span>
                {{/unless}}
              {{/unless}}

              <span class="custom-topic-layout_meta-posted">
                <span class="custom-topic-layout_meta-posted-by">Posted by</span>
                <a
                  data-user-card={{get topic.posters "0.user.username"}}
                  href="/u/{{get topic.posters '0.user.username'}}"
                >@{{get topic.posters "0.user.username"}}</a>
                {{formatDate
                  topic.createdAt
                  format="medium"
                  noTitle="true"
                  leaveAgo="true"
                }}
              </span>
            </div>

            <h2 class="link-top-line">
              {{~topicLink topic class="raw-link raw-topic-link"}}
            </h2>

            <div class="link-bottom-line">
              {{discourseTags topic mode="list" tagsForUser=this.tagsForUser}}
            </div>

            {{#if topic.thumbnails}}
              <div class="custom-topic-layout_image">
                <img
                  height={{get topic.thumbnails "0.height"}}
                  width={{get topic.thumbnails "0.width"}}
                  src={{get topic.thumbnails "0.url"}}
                />
              </div>
            {{/if}}

            <div class="custom-topic-layout_bottom-bar">
              <span class="reply-count">
                {{icon "reply"}}
                {{topic.replyCount}}
                {{i18n "replies"}}
              </span>
              <span class="share-toggle">
                {{icon "link"}}
                {{i18n "post.quote_share"}}
              </span>
            </div>
          </a>
        </div>
      {{/each}}
    </div>
  </template>
}
