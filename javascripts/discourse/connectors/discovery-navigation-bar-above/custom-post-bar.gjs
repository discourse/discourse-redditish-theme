import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import FakeInputCreate from "../../components/fake-input-create";

@classNames("discovery-navigation-bar-above-outlet", "custom-post-bar")
export default class CustomPostBar extends Component {
  <template><FakeInputCreate /></template>
}
