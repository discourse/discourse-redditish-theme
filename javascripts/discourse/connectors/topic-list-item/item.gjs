import Component from "@glimmer/component";
import { get } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ShareTopicModal from "discourse/components/modal/share-topic";
import PluginOutlet from "discourse/components/plugin-outlet";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";
import TopicLink from "discourse/components/topic-list/topic-link";
import UnreadIndicator from "discourse/components/topic-list/unread-indicator";
import TopicPostBadges from "discourse/components/topic-post-badges";
import TopicStatus from "discourse/components/topic-status";
import categoryLink from "discourse/helpers/category-link";
import icon from "discourse/helpers/d-icon";
import discourseTags from "discourse/helpers/discourse-tags";
import formatDate from "discourse/helpers/format-date";
import lazyHash from "discourse/helpers/lazy-hash";
import topicFeaturedLink from "discourse/helpers/topic-featured-link";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import { i18n } from "discourse-i18n";

export default class Item extends Component {
  @service currentUser;
  @service historyStore;
  @service modal;

  get newDotText() {
    return this.currentUser?.trust_level > 0
      ? ""
      : i18n("filters.new.lower_title");
  }

  @action
  onTitleFocus(event) {
    event.target.closest(".topic-list-item").classList.add("selected");
  }

  @action
  onTitleBlur(event) {
    event.target.closest(".topic-list-item").classList.remove("selected");
  }

  @action
  openTopic(event) {
    if (
      (event.target.nodeName === "A" && !event.target.closest(".raw-link")) ||
      event.target.closest(".badge-wrapper")
    ) {
      return;
    }

    const { navigateToTopic, topic } = this.args.outletArgs;

    if (wantsNewWindow(event)) {
      window.open(topic.lastUnreadUrl, "_blank");
    } else {
      navigateToTopic(topic, topic.lastUnreadUrl);
    }
  }

  @action
  share(event) {
    event.stopPropagation();
    this.modal.show(ShareTopicModal, {
      model: { topic: this.args.outletArgs.topic },
    });
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div {{on "click" this.openTopic}} class="custom-topic-layout">
      <div class="custom-topic-layout_meta">
        {{#unless @outletArgs.hideCategory}}
          {{#unless @outletArgs.topic.isPinnedUncategorized}}
            <PluginOutlet
              @name="topic-list-before-category"
              @outletArgs={{lazyHash topic=@outletArgs.topic}}
            />
            {{categoryLink @outletArgs.topic.category}}
            <span class="bullet-separator">&bull;</span>
          {{/unless}}
        {{/unless}}

        <span class="custom-topic-layout_meta-posted">
          <span class="custom-topic-layout_meta-posted-by">
            {{i18n (themePrefix "posted_by")}}
          </span>

          <a
            data-user-card={{get @outletArgs "topic.posters.0.user.username"}}
            href="/u/{{get @outletArgs 'topic.posters.0.user.username'}}"
          >@{{get @outletArgs "topic.posters.0.user.username"}}</a>

          {{formatDate
            @outletArgs.topic.createdAt
            format="medium"
            noTitle="true"
            leaveAgo="true"
          }}
        </span>
      </div>

      <h2 class="link-top-line">
        <TopicStatus @topic={{@outletArgs.topic}} />

        <TopicLink
          {{on "focus" this.onTitleFocus}}
          {{on "blur" this.onTitleBlur}}
          @topic={{@outletArgs.topic}}
          class="raw-link raw-topic-link"
        />

        {{#if @outletArgs.topic.featured_link}}
          {{topicFeaturedLink @outletArgs.topic}}
        {{/if}}

        <PluginOutlet
          @name="topic-list-after-title"
          @outletArgs={{lazyHash topic=@outletArgs.topic}}
        />

        <UnreadIndicator @topic={{@outletArgs.topic}} />

        {{#if @outletArgs.showTopicPostBadges}}
          <TopicPostBadges
            @unreadPosts={{@outletArgs.topic.unread_posts}}
            @unseen={{@outletArgs.topic.unseen}}
            @newDotText={{this.newDotText}}
            @url={{@outletArgs.topic.lastUnreadUrl}}
          />
        {{/if}}
      </h2>

      <div class="link-bottom-line">
        {{discourseTags
          @outletArgs.topic
          mode="list"
          tagsForUser=@outletArgs.tagsForUser
        }}
      </div>

      {{#if @outletArgs.topic.thumbnails}}
        <div class="custom-topic-layout_image">
          <img
            height={{get @outletArgs "topic.thumbnails.0.height"}}
            width={{get @outletArgs "topic.thumbnails.0.width"}}
            src={{get @outletArgs "topic.thumbnails.0.url"}}
          />
        </div>
      {{/if}}

      {{#unless @outletArgs.topic.thumbnails}}
        <div class="custom-topic-layout_excerpt">
          <TopicExcerpt @topic={{@outletArgs.topic}} />
        </div>
      {{/unless}}

      <div class="custom-topic-layout_bottom-bar">
        <span class="reply-count">
          {{icon "reply"}}
          {{@outletArgs.topic.replyCount}}
          {{i18n "replies"}}
        </span>

        {{! template-lint-disable no-invalid-interactive }}
        <span {{on "click" this.share}} class="share-toggle">
          {{icon "link"}}
          {{i18n "post.quote_share"}}
        </span>
      </div>
    </div>
  </template>
}
