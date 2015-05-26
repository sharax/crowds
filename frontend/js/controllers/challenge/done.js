app.controller('challengeDoneController', function($scope, $location) {
    $scope.numCorrect = 16;
    $scope.numQuestions = 20;
    $scope.rank = 40;
    $scope.crowdRank = 320;
    $scope.numBees = 3942;

    $scope.startNewChallenge = function() {
        $location.path('challenge/start');
    }
});