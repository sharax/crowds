app.controller('challengeTaskController', function($scope, $interval, $location) {
    $scope.currentSlide = 1;

    $scope.answer = undefined;
    $scope.selectedCL = undefined;

    $scope.confidenceLevels = [0,1,2,3,4];

    $scope.questions = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
    $scope.questionContent = [
        {
            text: "Will this business be funded by Kickstarter?",
            type: "options",
            imagePath: "question-media/sockless-shoes.png",
            answers: ["Yes", "No"]
        },
        {
            text: "Will this business be funded by Kickstarter?",
            type: "options",
            imagePath: "question-media/sockless-shoes.png",
            answers: ["Yes", "No"],
            previousResponses: [{text: "Yes", count: 3}, {text: "No", count: 2}]
        },
        {
            text: "What is the name of this constellation?",
            type: "options",
            imagePath: "question-media/constellation.png",
            answers: ["Leo", "Apus", "Lupus", "Columba", "Gemini"],
            previousResponses: [{text: "Leo", count: 500}, {text: "Apus", count: 2}, {text: "Lupus", count: 2},
            {text: "Columba", count: 2}, {text: "Gemini", count: 200}]
        },
        {
            text: "What is this country’s landmass?",
            type: "number",
            imagePath: "question-media/brazil.png",
            previousResponses: [28497, 328472, 124, 0, 23498]
        }
    ];

    $scope.currQuestion = 0;
    $scope.question = $scope.questionContent[$scope.currQuestion];

    $scope.previousResponses = [];
    $scope.previousResponseCount = 0;

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

    $scope.setQuestion = function(index) {
        $scope.currQuestion = index;
        $scope.question = $scope.questionContent[$scope.currQuestion];
        $scope.previousResponses = $scope.question.previousResponses;
        updatePreviousResponseCount();
    }

    function updatePreviousResponseCount() {
        $scope.previousResponseCount = 0;
        if($scope.question.type === "number") {
            $scope.previousResponseCount = $scope.previousResponses.length;
            return;
        }
        for(var i = 0; i < $scope.previousResponses.length; i++) {
            var response = $scope.previousResponses[i];
            $scope.previousResponseCount += response.count;
        }
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
        $scope.setQuestion($scope.currQuestion + 1);
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