import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import discoveryFixture from "discourse/tests/fixtures/discovery-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Redditish Theme | tag routes", function (needs) {
  needs.settings({ tagging_enabled: true });
  needs.user({
    can_create_topic: true,
    sidebar_tags: [],
    sidebar_category_ids: [],
  });

  needs.pretender((server, helper) => {
    server.get("/tag/1/info.json", () => {
      return helper.response({
        tag_info: {
          id: 1,
          name: "important",
          slug: "important",
          description: "Important topics for discussion",
          topic_count: 5,
          pm_only: false,
        },
        categories: [],
        tag_group_names: [],
      });
    });

    server.get("/tag/1/l/latest.json", () => {
      return helper.response(
        cloneJSON(discoveryFixture["/tag/important/l/latest.json"])
      );
    });

    server.get("/tag/1/notifications.json", () => {
      return helper.response({
        tag_notification: {
          id: 1,
          notification_level: 1,
        },
      });
    });
  });

  test("displays tag banner with tag name", async function (assert) {
    await visit("/tag/important/1");

    assert
      .dom(".custom-tag-banner h1")
      .hasText("important", "tag banner displays the tag name");
  });
});
