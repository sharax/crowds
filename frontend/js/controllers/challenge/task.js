app.controller('challengeTaskController', function($scope, $interval, $location) {
    $scope.currentSlide = 1;

    $scope.answers = ["yes", "no"];
    $scope.answer = undefined;
    $scope.selectedCL = undefined;

    $scope.confidenceLevels = [0,1,2,3,4];

    $scope.questions = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
    $scope.currQuestion = 0;
    $scope.question = {};
    $scope.question.text = "Will this business be funded by Kickstarter?";
    $scope.question.imagePath = "question-media/sockless-shoes.png";

    $scope.timerPercent = 0;
    $scope.timeLeft = 30;
    $scope.timerOptions = {
        animate:{
            duration:300,
            enabled:true
        },
        barColor:'#feeed9',
        scaleColor:false,
        trackColor:'#f7a32b',
        lineWidth:6,
        lineCap:'circle',
        size: 50
    };
    startTimer();

    $scope.validInput = function(answer, selectedCL) {
        if(selectedCL === undefined || selectedCL < 0 || selectedCL > 4) {
            return false;
        }
        if(!isValidAnswer(answer)) {
            return false;
        }
        return true;
    }

    $scope.setCL = function(cl) {
        $scope.selectedCL = cl;
    }

    $scope.setAnswer = function(answer) {
        $scope.answer = answer;
    }

    $scope.next = function() {
        next();
    }

    function startTimer() {
        $interval(function(){
            $scope.timeLeft--;
            $scope.timerPercent += 3.33;
        }, 1000, 30);
    }

    function isValidAnswer(answer) {
        for(var i = 0; i < $scope.answers.length; i++) {
            if($scope.answers[i] === answer) {
                return true;
            }
        }
        return false;
    }

    function next() {
        switchSlides();
        resetTimer();
        $scope.currQuestion++;
        $scope.answer = undefined;
        $scope.selectedCL = undefined;
        if($scope.currQuestion === 2) {
            $location.path("challenge/done");
        }
    }

    function switchSlides() {
        if($scope.currentSlide === 1) {
            $scope.currentSlide = 2;
        } else {
            $scope.currentSlide = 1;
        }
    }

    function resetTimer() {
        $scope.timeLeft = 30;
        $scope.timerPercent = 0;
    }
});