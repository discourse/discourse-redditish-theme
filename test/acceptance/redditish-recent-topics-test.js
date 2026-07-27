import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import discoveryFixture from "discourse/tests/fixtures/discovery-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

function topicListResponse() {
  return cloneJSON(discoveryFixture["/latest.json"]);
}

let readRequests;
let readResponse;

acceptance("Redditish Theme | recent topics sidebar", function (needs) {
  // "top" is deliberately left out so it can be used as a non-top route, which
  // is what unmounts the sidebar
  needs.settings({ top_menu: "latest|new|unread|categories" });
  needs.user({ sidebar_tags: [], sidebar_category_ids: [] });

  needs.pretender((server, helper) => {
    readRequests = 0;
    readResponse = topicListResponse();

    server.get("/read.json", () => {
      readRequests++;
      return helper.response(readResponse);
    });

    server.get("/hot.json", () => helper.response(topicListResponse()));
    server.get("/top.json", () => helper.response(topicListResponse()));
  });

  test("renders the read list", async function (assert) {
    await visit("/latest");

    assert.dom(".custom-right-sidebar_recent h4").hasText("Recent topics");
    assert
      .dom(".custom-right-sidebar_recent-topics-wrapper")
      .exists({ count: 3 });

    // the byline is stitched together from topic_list.users by core's
    // TopicList.munge, so this breaks if the poster payload changes shape
    assert
      .dom(
        ".custom-right-sidebar_recent-topics-wrapper:first-child .custom-topic-layout_meta-posted a"
      )
      .hasText("@reyman64");
  });

  test("falls back to hot topics when there is no read history", async function (assert) {
    readResponse = topicListResponse();
    readResponse.topic_list.topics = [];

    await visit("/latest");

    assert.dom(".custom-right-sidebar_recent h4").hasText("Hot topics");
    assert
      .dom(".custom-right-sidebar_recent-topics-wrapper")
      .exists({ count: 3 });
  });

  test("serves the list from cache after remounting", async function (assert) {
    await visit("/latest");
    await visit("/top"); // not in top_menu, so the sidebar unmounts
    await visit("/latest");

    assert
      .dom(".custom-right-sidebar_recent-topics-wrapper")
      .exists({ count: 3 });
    assert.strictEqual(readRequests, 1, "the list is served from cache");
  });
});
