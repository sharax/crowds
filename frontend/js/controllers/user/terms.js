app.controller('termsController', function($scope, $location, $localStorage, Api, Logger) {
    $scope.prev = function() {
        $location.path('user/quick-questions');
    }

    $scope.startChallenge = function() {
        var user = {};
        user.gender = $localStorage.user.gender;
        user.age = $localStorage.user.age;
        user.education = $localStorage.user.education;
        user.country = $localStorage.user.country;
        Api.register(user, function(success){
            $localStorage.token = success['token'];
            $location.path('challenge/start');
        }, function(error){
            alert(error);
            Logger.log(error);
        });

    }
});