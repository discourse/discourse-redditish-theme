import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import SidebarAboutCategory from "../../components/sidebar-about-category";
import SidebarAboutTag from "../../components/sidebar-about-tag";
import SidebarWelcome from "../../components/sidebar-welcome";

@tagName("")
export default class CustomRightSidebar extends Component {
  <template>
    <div class="custom-right-sidebar">
      <SidebarAboutCategory />
      <SidebarAboutTag />
      <SidebarWelcome />
    </div>
  </template>
}
