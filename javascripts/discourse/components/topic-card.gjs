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
import DiscourseURL from "discourse/lib/url";
import { and, not, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

// The reddit-style card used by both the topic list and the recent topics
// sidebar. @compact drops the parts the sidebar has no room for
export default class TopicCard extends Component {
  @service currentUser;
  @service modal;

  get newDotText() {
    return this.currentUser?.trust_level > 0
      ? ""
      : i18n("filters.new.lower_title");
  }

  @action
  onTitleFocus(event) {
    event.target.closest(".topic-list-item")?.classList.add("selected");
  }

  @action
  onTitleBlur(event) {
    event.target.closest(".topic-list-item")?.classList.remove("selected");
  }

  @action
  openTopic(event) {
    // other links in the card (category, poster, tags) go where they point
    if (event.target.closest("a:not(.raw-link)")) {
      return;
    }

    const { topic, onNavigate } = this.args;

    if (wantsNewWindow(event)) {
      window.open(topic.lastUnreadUrl, "_blank");
    } else if (onNavigate) {
      onNavigate(topic, topic.lastUnreadUrl);
    } else {
      DiscourseURL.routeTo(topic.lastUnreadUrl);
    }
  }

  @action
  share(event) {
    event.stopPropagation();
    this.modal.show(ShareTopicModal, { model: { topic: this.args.topic } });
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div {{on "click" this.openTopic}} class="custom-topic-layout">
      <div class="custom-topic-layout_meta">
        {{#unless (or @hideCategory @topic.isPinnedUncategorized)}}
          {{#unless @compact}}
            <PluginOutlet
              @name="topic-list-before-category"
              @outletArgs={{lazyHash topic=@topic}}
            />
          {{/unless}}
          {{categoryLink @topic.category}}
          {{#unless @compact}}
            <span class="bullet-separator">&bull;</span>
          {{/unless}}
        {{/unless}}

        <span class="custom-topic-layout_meta-posted">
          <span class="custom-topic-layout_meta-posted-by">
            {{i18n (themePrefix "posted_by")}}
          </span>

          <a
            data-user-card={{get @topic "posters.0.user.username"}}
            href="/u/{{get @topic 'posters.0.user.username'}}"
          >@{{get @topic "posters.0.user.username"}}</a>

          {{formatDate
            @topic.createdAt
            format="medium"
            noTitle="true"
            leaveAgo="true"
          }}
        </span>
      </div>

      <h2 class="link-top-line">
        {{#unless @compact}}
          <TopicStatus @topic={{@topic}} />
        {{/unless}}

        <TopicLink
          {{on "focus" this.onTitleFocus}}
          {{on "blur" this.onTitleBlur}}
          @topic={{@topic}}
          class="raw-link raw-topic-link"
        />

        {{#unless @compact}}
          {{#if @topic.featured_link}}
            {{topicFeaturedLink @topic}}
          {{/if}}

          <PluginOutlet
            @name="topic-list-after-title"
            @outletArgs={{lazyHash topic=@topic}}
          />

          <UnreadIndicator @topic={{@topic}} />

          {{#if @showTopicPostBadges}}
            <TopicPostBadges
              @unreadPosts={{@topic.unread_posts}}
              @unseen={{@topic.unseen}}
              @newDotText={{this.newDotText}}
              @url={{@topic.lastUnreadUrl}}
            />
          {{/if}}
        {{/unless}}
      </h2>

      {{#unless @compact}}
        <div class="link-bottom-line">
          {{discourseTags @topic mode="list" tagsForUser=@tagsForUser}}
        </div>
      {{/unless}}

      {{#if @topic.thumbnails}}
        <div class="custom-topic-layout_image">
          <img
            height={{get @topic "thumbnails.0.height"}}
            width={{get @topic "thumbnails.0.width"}}
            src={{get @topic "thumbnails.0.url"}}
          />
        </div>
      {{else}}
        {{#unless @compact}}
          <div class="custom-topic-layout_excerpt">
            <TopicExcerpt @topic={{@topic}} />
          </div>
        {{/unless}}
      {{/if}}

      <div class="custom-topic-layout_bottom-bar">
        {{#if (and settings.show_like_count (not @compact))}}
          <span class="like-count">
            {{icon "heart"}}
            {{@topic.like_count}}
            {{i18n "likes"}}
          </span>
        {{/if}}

        <span class="reply-count">
          {{icon "reply"}}
          {{@topic.replyCount}}
          {{i18n "replies"}}
        </span>

        {{#unless @compact}}
          <span {{on "click" this.share}} class="share-toggle">
            {{icon "link"}}
            {{i18n "post.quote_share"}}
          </span>
        {{/unless}}
      </div>
    </div>
  </template>
}
