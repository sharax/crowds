app.controller('challengeTaskController', function($scope, $interval, $location) {
    $scope.currentSlide = 1;

    $scope.selectedAnswer = undefined;
    $scope.selectedCL = undefined;

    $scope.confidenceLevels = numberArray(0, 4);
    $scope.answers = [];

    var timerSize = 50;
    var timerLineWidth = 6;

    // custom size styling for large devices (large desktops, 1280px and up)
    if($(document).height() > 960) {
        timerLineWidth = 8;
        timerSize = 80;
    }

    $scope.questions = numberArray(0, 19);
    var questionArr = getQuestionArr();
    setCurrQuestion(0);

    initTimer();
    resetTimer();
    startTimer();

    $scope.validInput = function(answer, selectedCL) {
        if(!isValidCL(selectedCL)) {
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

    $scope.selectAnswer = function(answer) {
        $scope.selectedAnswer = answer;
    }

    $scope.next = function() {
        next();
    }

    $scope.setCurrQuestion = function(index) {
        setCurrQuestion(index);
    }

    function isValidCL(cl) {
        var minCL = $scope.confidenceLevels[0];
        var maxCL = $scope.confidenceLevels[$scope.confidenceLevels.length-1];
        if(cl === undefined || !isInt(cl) || cl < minCL || cl > maxCL) {
            return false;
        }
        return true;
    }

    function isValidAnswer(answer) {
        if($scope.question.type === 'number') {
            return isInt(answer);
        }

        for(var i = 0; i < $scope.answers.length; i++) {
            if($scope.answers[i] === answer) {
                return true;
            }
        }
        return false;
    }

    function next() {
        setCurrQuestion($scope.currQuestion + 1);
    }

    function setCurrQuestion(index) {
        if(index === 4) {
            $location.path("challenge/done");
            return;
        }
        $scope.currQuestion = index;
        $scope.question = questionArr[$scope.currQuestion];
        $scope.previousResponses = $scope.question.previousResponses;
        $scope.answers =$scope.question.answers;
        updatePreviousResponseCount();

        $scope.selectedAnswer = undefined;
        $scope.selectedCL = undefined;

        switchSlides();
        resetTimer();
    }

    function updatePreviousResponseCount() {
        $scope.previousResponseCount = 0;
        if($scope.previousResponses === undefined) {
            return;
        }
        if($scope.question.type === "number") {
            $scope.previousResponseCount = $scope.previousResponses.length;
            return;
        }
        for(var i = 0; i < $scope.previousResponses.length; i++) {
            var response = $scope.previousResponses[i];
            $scope.previousResponseCount += response.count;
        }
    }

    function switchSlides() {
        if($scope.currentSlide === 1) {
            $scope.currentSlide = 2;
        } else {
            $scope.currentSlide = 1;
        }
    }

    function initTimer() {
        $scope.timerOptions = {
            animate:{
                duration:300,
                enabled:true
            },
            barColor:'#feeed9',
            scaleColor:false,
            trackColor:'#f7a32b',
            lineWidth:timerLineWidth,
            lineCap:'circle',
            size: timerSize
        };
    }

    function startTimer() {
        $interval(function(){
            $scope.timeLeft--;
            $scope.timerPercent += 3.33;
        }, 1000, 30);
    }

    function resetTimer() {
        $scope.timeLeft = 30;
        $scope.timerPercent = 0;
    }


    function getQuestionArr() {
        var questions = [
            {
                text: "Will this business be funded by Kickstarter?",
                type: "options",
                imagePath: "question-media/sockless-shoes.png",
                answers: ["Yes", "No"]
                //answers: ["Mary Poppins", "Star Wars", "Jurrasic Park", "Titanic"]
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
                text: "What is this country’s landmass in square meters?",
                type: "number",
                imagePath: "question-media/brazil.png",
                previousResponses: [28497, 328472, 124, 0, 23498]
            }
        ];
        return questions;
    }
});