app.controller('challengeStartController', function($scope, $location, $localStorage, Api, Logger) {
    $scope.user = {};
    $scope.challengeDomain = "Guess if a business will be funded by Kickstarter.";
    $scope.prev = function() {
        $location.path('user/terms-and-conditions');
    }
    $scope.validInput = function() {
        if(validRank($scope.user.rank)) {
            return true;
        }
        return false;
    }

    $scope.startChallenge = function() {
        if(!$scope.validInput()) {
            return;
        }
        var data = {};
        data.token = $localStorage.token;
        data.rank = $scope.user.rank;
        Api.submitExpectedRank(data, function(success){
            $location.path('challenge/task');
        }, function(error){
            alert(error);
        });
    }

    function validRank(rank) {
        if(!isInt(rank)) {
            return false;
        }
        rank = parseInt(rank);
        if(rank < 1 || rank > 100) {
            return false;
        }
        return true;
    }
});