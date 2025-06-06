import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class CustomTagBanner extends Component {
  @service router;

  get category() {
    return this.router.currentRoute?.attributes?.category;
  }

  get tag() {
    return this.router.currentRoute?.params?.tag_id;
  }
}
