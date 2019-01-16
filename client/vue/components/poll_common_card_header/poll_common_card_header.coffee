AbilityService = require 'shared/services/ability_service'

{ iconFor } = require 'shared/helpers/poll'

module.exports =
  props:
    poll: Object
  methods:
    pollHasActions: ->
      AbilityService.canEditPoll(@poll)  ||
      AbilityService.canClosePoll(@poll) ||
      AbilityService.canDeletePoll(@poll)||
      AbilityService.canExportPoll(@poll)

    icon: ->
      iconFor(@poll)
  template:
    """
    <div class="poll-common-card-header lmo-flex lmo-flex__space-between">
      <div class="poll-common-card-header lmo-flex">
        <i class="'mdi mdi-24px ' + icon()"></i>
        <h2 v-t="'poll_types.' + poll.pollType" class="lmo-card-heading poll-common-card-header__poll-type"></h2>
      </div>
      <!-- <poll_common_actions_dropdown poll="poll" ng-if="pollHasActions()" class="pull-right"></poll_common_actions_dropdown> -->
    </div>
    """