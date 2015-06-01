app.config(function($routeProvider) {
    $routeProvider
        .when('/intro/welcome', {
            templateUrl : 'views/intro/welcome.html',
            controller  : 'introWelcomeController'
        })
        .when('/intro/explanation', {
            templateUrl : 'views/intro/explanation.html'
        })
        .when('/intro/experiment', {
            templateUrl : 'views/intro/experiment.html'
        })
        .when('/intro/questions', {
            templateUrl : 'views/intro/experiment.html'
        })
        .when('/user/quick-questions', {
            templateUrl : 'views/user/quick-questions.html',
            controller  : 'quickQuestionsController'
        })
        .when('/user/terms-and-conditions', {
            templateUrl : 'views/user/terms.html',
            controller  : 'termsController'
        })
        .when('/challenge/start', {
            templateUrl : 'views/challenge/start.html',
            controller  : 'challengeStartController'
        })
        .when('/challenge/task', {
            templateUrl : 'views/challenge/task.html',
            controller  : 'challengeTaskController'
        })
        .when('/challenge/done', {
            templateUrl : 'views/challenge/done.html',
            controller  : 'challengeDoneController'
        })
        .when('/about/research', {
            templateUrl : 'views/about/research.html'
        })
        .when('/about/team', {
            templateUrl : 'views/about/team.html',
            controller  : 'aboutTeamController'
        })
        .otherwise({
            templateUrl: 'views/404.html'
        });
})