import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import CustomCategoryBanner0 from "../../components/custom-category-banner";
import CustomTagBanner from "../../components/custom-tag-banner";

@tagName("")
export default class CustomCategoryBannerConnector extends Component {
  <template>
    <CustomCategoryBanner0 />
    <CustomTagBanner />
  </template>
}
