import { click, currentURL, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import discoveryFixture from "discourse/tests/fixtures/discovery-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Redditish Theme | custom topic list item", function (needs) {
  needs.user({ sidebar_tags: [], sidebar_category_ids: [] });

  needs.pretender((server, helper) => {
    server.get("/latest.json", () => {
      const response = cloneJSON(discoveryFixture["/latest.json"]);

      // point the first row at a topic the default pretender can serve, so
      // clicking it can actually navigate
      const topic = response.topic_list.topics[0];
      topic.id = 280;
      topic.slug = "internationalization-localization";
      topic.title = "Internationalization / localization";
      topic.fancy_title = "Internationalization / localization";

      return helper.response(response);
    });

    // the recent topics sidebar fetches this on top routes
    server.get("/read.json", () =>
      helper.response(cloneJSON(discoveryFixture["/latest.json"]))
    );
  });

  test("renders the custom layout", async function (assert) {
    await visit("/latest");

    assert
      .dom(".topic-list-item .raw-topic-link")
      .hasText("Internationalization / localization");

    // pins the poster payload the outlet hands us
    assert
      .dom(".topic-list-item .custom-topic-layout_meta-posted a")
      .hasText("@reyman64");
  });

  test("opens the topic when the row is clicked", async function (assert) {
    await visit("/latest");

    await click(".topic-list-item .custom-topic-layout");

    assert.true(
      currentURL().startsWith("/t/internationalization-localization/280"),
      "navigates into the topic"
    );
  });
});
