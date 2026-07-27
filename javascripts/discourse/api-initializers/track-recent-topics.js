import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const recentTopics = api.container.lookup("service:recent-topics");
  const appEvents = api.container.lookup("service:app-events");

  appEvents.on("page:topic-loaded", recentTopics, "recordVisit");
});
