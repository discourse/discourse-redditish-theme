import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";

const STORAGE_KEY = "deddit_recent_topics";
const TOPIC_COUNT = 3;

const CACHE_DURATION = 5 * 60 * 1000;

const MAX_RESTORE_AGE = 24 * 60 * 60 * 1000;

const PERSISTED_FIELDS = [
  "id",
  "title",
  "fancy_title",
  "slug",
  "created_at",
  "posts_count",
  "category_id",
  "pinned",
  "closed",
  "tags",
  "last_read_post_number",
  "like_count",
];

function serializeTopic(topic) {
  const attrs = {};

  for (const field of PERSISTED_FIELDS) {
    attrs[field] = topic[field];
  }

  attrs.posters = (topic.posters ?? []).map((poster) => ({
    user: { username: poster.user?.username },
  }));

  attrs.thumbnails = (topic.thumbnails ?? []).map((thumbnail) => ({
    url: thumbnail.url,
    width: thumbnail.width,
    height: thumbnail.height,
  }));

  return attrs;
}

export default class RecentTopics extends Service {
  @service store;
  @service currentUser;
  @service keyValueStore;

  @tracked topics = null;
  @tracked usingFallback = false;

  cachedAt = 0;
  pendingRequest = null;

  constructor() {
    super(...arguments);
    this.restore();
  }

  get isStale() {
    return !this.topics || Date.now() - this.cachedAt > CACHE_DURATION;
  }

  // only true once we've actually loaded and found nothing — while topics is
  // still null the sidebar should show its placeholders
  get isEmpty() {
    return this.topics?.length === 0;
  }

  async load() {
    if (!this.isStale) {
      return;
    }

    this.pendingRequest ??= this.fetch();

    try {
      await this.pendingRequest;
    } catch {
      // nothing here is worth surfacing an error for, but leaving topics null
      // would shimmer forever — hide the section until the next page load
      this.topics ??= [];
    } finally {
      this.pendingRequest = null;
    }
  }

  recordVisit(topic) {
    if (!this.currentUser || !topic || topic.closed) {
      return;
    }

    // TopicViewSerializer has no posters, so a topic opened by direct URL has
    // nothing to render a byline from. Leave those to the next refresh rather
    // than showing a blank "@"
    if (!topic.posters?.length) {
      return;
    }

    const others = this.usingFallback
      ? []
      : (this.topics ?? []).filter((t) => t.id !== topic.id);

    this.usingFallback = false;
    this.topics = [topic, ...others].slice(0, TOPIC_COUNT);
    this.persist();
  }

  async fetch() {
    let topics = await this.fetchList(
      this.currentUser
        ? { filter: "read", params: { order: "latest" } }
        : { filter: "latest", params: { order: "created" } }
    );

    this.usingFallback = topics.length === 0;

    if (this.usingFallback) {
      topics = await this.fetchList({ filter: "hot" });
    }

    this.topics = topics;
    this.cachedAt = Date.now();
    this.persist();
  }

  async fetchList(args) {
    const topicList = await this.store.findFiltered("topicList", args);

    return topicList.topics
      .filter((topic) => !topic.closed)
      .slice(0, TOPIC_COUNT);
  }

  persist() {
    try {
      this.keyValueStore.setObject({
        key: STORAGE_KEY,
        value: {
          userId: this.currentUser?.id ?? null,
          cachedAt: this.cachedAt,
          usingFallback: this.usingFallback,
          topics: this.topics.map(serializeTopic),
        },
      });
    } catch {
      this.keyValueStore.remove(STORAGE_KEY);
    }
  }

  restore() {
    const cached = this.keyValueStore.getObject(STORAGE_KEY);

    if (!cached || !cached.topics?.length) {
      return;
    }

    if (cached.userId !== (this.currentUser?.id ?? null)) {
      return;
    }

    if (Date.now() - cached.cachedAt > MAX_RESTORE_AGE) {
      return;
    }

    try {
      this.topics = cached.topics.map((attrs) =>
        this.store.createRecord("topic", attrs)
      );
      this.usingFallback = cached.usingFallback ?? false;
      this.cachedAt = cached.cachedAt;
    } catch {
      this.topics = null;
      this.keyValueStore.remove(STORAGE_KEY);
    }
  }
}
