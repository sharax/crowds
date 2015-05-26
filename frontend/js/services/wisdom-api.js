/*
In general, api functions follow this structure: (data, success callback function, error callback function)
*/

app.factory('WisdomApi', function($http, Logger) {
    var api = {};
    var url = "http://crowds.5harad.com/api";

    // expects user to have fields: gender, education, employment, age
    // returns token if successful
    api.register = function(user, success, error) {
        post(url + "/users", user, success, error);
    }

    // expects data to have fields: token, rank
    api.submitExpectedRank = function(data, success, error) {
    }

    function post(url, data, success, error) {
        $http.post(url, data)
            .success(function(response) {
                success(response);
            })
            .error(function(response) {
                error(response);
                Logger.log(response);
            });
    }

    return api;


});