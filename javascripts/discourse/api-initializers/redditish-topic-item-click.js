import { wantsNewWindow } from "discourse/lib/intercept-click";
import { withPluginApi } from "discourse/lib/plugin-api";
import showModal from "discourse/lib/show-modal";

export default {
  name: "redditish-customize-topic-list-item",

  initialize() {
    withPluginApi("0.8", (api) => {
      api.modifyClass("component:topic-list-item", {
        pluginId: "redditish-theme",

        click(event) {
          let target = event.target;
          if (!target) {
            return this._super(event);
          }

          if (
            (target.nodeName === "A" && !target.closest(".raw-link")) ||
            target.closest(".badge-wrapper")
          ) {
            if (wantsNewWindow(event)) {
              return true;
            }
            return true;
          }

          if (target.classList.contains("custom-topic-layout")) {
            if (wantsNewWindow(event)) {
              window.open(this.topic.lastUnreadUrl, "_blank");
              return false;
            }
            return this.navigateToTopic(this.topic, this.topic.lastUnreadUrl);
          }

          if (target.closest(".share-toggle")) {
            const controller = showModal("share-topic", {
              model: this.topic.category,
            });
            controller.set("topic", this.topic);
            return true;
          }

          return this.navigateToTopic(this.topic, this.topic.lastUnreadUrl);
        },
      });
    });
  },
};
