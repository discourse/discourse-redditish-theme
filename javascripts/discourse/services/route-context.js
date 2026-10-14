import Service, { service } from "@ember/service";

export default class RouteContext extends Service {
  @service router;

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get tag() {
    return this.router.currentRoute?.attributes?.tag;
  }
}
