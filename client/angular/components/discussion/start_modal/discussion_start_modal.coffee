Records = require 'shared/services/records.coffee'

{ applySequence } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').factory 'DiscussionStartModal', ->
  templateUrl: 'generated/components/discussion/start_modal/discussion_start_modal.html'
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, discussion) ->
        $scope.announcement = Records.announcements.buildFromModel(discussion, 'new_discussion')
  ]