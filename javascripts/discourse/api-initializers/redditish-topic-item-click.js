import ShareTopicModal from "discourse/components/modal/share-topic";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "redditish-customize-topic-list-item",

  initialize() {
    withPluginApi("0.8", (api) => {
      const modal = api.container.lookup("service:modal");

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
            modal.show(ShareTopicModal, {
              model: { topic: this.topic },
            });

            return true;
          }

          return this.navigateToTopic(this.topic, this.topic.lastUnreadUrl);
        },
      });
    });
  },
};
