import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class CreateTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service routeContext;

  @action
  createTopic() {
    this.composer.openNewTopic({
      category: this.routeContext.category,
      tags: this.routeContext.tag?.name,
    });
  }

  <template>
    {{#if this.currentUser.can_create_topic}}
      <DButton
        @id="custom-create-topic"
        @action={{this.createTopic}}
        @icon={{@icon}}
        @label="topic.create"
        ...attributes
      />
    {{/if}}
  </template>
}
