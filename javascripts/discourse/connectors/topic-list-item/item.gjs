import TopicCard from "../../components/topic-card";

const Item = <template>
  <TopicCard
    @topic={{@outletArgs.topic}}
    @hideCategory={{@outletArgs.hideCategory}}
    @tagsForUser={{@outletArgs.tagsForUser}}
    @showTopicPostBadges={{@outletArgs.showTopicPostBadges}}
    @onNavigate={{@outletArgs.navigateToTopic}}
  />
</template>;

export default Item;
