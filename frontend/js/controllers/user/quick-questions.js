app.controller('quickQuestionsController', function($scope, $timeout, $localStorage, $location) {
    $scope.questions = [0, 1, 2, 3];
    $scope.countries = [];
    $scope.countryIndex = 0;

    $scope.educationOptions = ["Primary Education", "Secondary Education", "Bachelor Degree", "Master Degree", "Doctoral"];

    $scope.challengeDomain = "Guess if business will be funded by Kickstarter";

    if($localStorage.currQuestion === undefined) {
        $localStorage.currQuestion = 0;
    }
    $scope.currQuestion = $localStorage.currQuestion;

    if($localStorage.user === undefined) {
        $localStorage.user = {};
    }
    $scope.user = $localStorage.user;
    updateCountries($scope.user.country);

    $scope.setCurrQuestion = function(index) {
        $scope.currQuestion = index;
        $localStorage.currQuestion = index;
    }

    $scope.countryMouseEnter = function(index) {
        $scope.countryIndex = index;
    }

    $scope.selectCountry = function() {
        var index = $scope.countryIndex;
        if(index < 0 || index >= $scope.countries.length) {
            return;
        }
        $scope.user.country = $scope.countries[index];
    }

    $scope.setGender = function(gender) {
        $scope.user.gender = gender;
        next();
    }

    $scope.next = function() {
        next();
    }

    $scope.prev = function() {
        prev();
    }

    $scope.countryKeydown = function(e) {
        if(e.which === 38 || e.which === 40 || e.which === 13) {
            e.preventDefault();
        }
        // up arrow pressed
        if(e.which === 38 && $scope.countryIndex > 0) {
            $scope.countryIndex--;
        }
        // down arrow pressed
        if(e.which === 40 && $scope.countryIndex < $scope.countries.length - 1) {
            $scope.countryIndex++;
        }
        if(e.which === 13) {
            if(validCountry($scope.user.country)) {
                next();
                return;
            }
            $scope.selectCountry();
        }
    }

    $scope.validInput = function() {
        if($scope.currQuestion === 0) {
            return validGender($scope.user.gender);
        }
        if($scope.currQuestion === 1) {
            return validAge($scope.user.age);
        }
        if($scope.currQuestion === 2) {
            return validCountry($scope.user.country);
        }
        if($scope.currQuestion === 3) {
            return validEducation($scope.user.education);
        }
        if($scope.currQuestion === 4) {
            return validRank($scope.user.rank);
        }
    }

    $scope.validCountry = function(country) {
        return validCountry(country);
    }

    $scope.updateCountries = function(searchText) {
        updateCountries(searchText);
        $scope.countryIndex = 0;
    }

    function updateCountries(searchText) {
        $scope.countries = [];
        if(searchText === undefined || searchText.length === 0) {
            return;
        }
        var firstLetter = searchText.toLowerCase()[0];
        if(!(firstLetter in countryKeyArr)) {
            return;
        }
        var subCountries = countryKeyArr[firstLetter];
        var searchTextLower = searchText.toLowerCase();
        for(var i = 0; i < subCountries.length; i++) {
            var country = subCountries[i];
            if(country.toLowerCase().indexOf(searchTextLower) === 0) {
                $scope.countries.push(country);
            }
        }
    }

    function validGender(gender) {
        if(gender === "male" || gender === "female") {
            return true;
        }
        return false;
    }

    function validAge(age) {
        if(!isInt(age)) {
            return false;
        }
        age = parseInt(age);
        if(age < 1 || age > 200) {
            return false;
        }
        return true;
    }

    function validCountry(country) {
        for(var i = 0; i < $scope.countries.length; i++) {
            if($scope.countries[i] === country) {
                return true;
            }
        }
        return false;
    }

    function validEducation(education) {
        for(var i = 0; i < $scope.educationOptions.length; i++) {
            if($scope.educationOptions[i] === education) {
                return true;
            }
        }
        return false;
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

    function next() {
        if(!$scope.validInput()) {
            return;
        }
        if($scope.currQuestion == $scope.questions.length - 1) {
            $location.path("user/terms-and-conditions");
            return;
        }

        $scope.setCurrQuestion($scope.currQuestion + 1);

        if($scope.currQuestion === 1) {
            $timeout(function(){
                $(".quick-questions .age input").focus();
            });
        }

        if($scope.currQuestion === 2) {
            $timeout(function(){
                $(".quick-questions .country input").focus();
            });
        }
    }

    function prev() {
        $scope.setCurrQuestion($scope.currQuestion - 1);
    }

});