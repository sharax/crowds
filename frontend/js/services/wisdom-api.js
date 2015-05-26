/*
In general, api functions follow this structure: (data, success callback function, error callback function)
 */

app.factory('WisdomApi', function($http) {
    var api = {};

    // expects user to have fields: gender, education, employment, age
    // returns token if successful
    api.register = function(user, success, error) {

    };

    // expects data to have fields: token, rank
    api.submitExpectedRank = function(data, success, error) {

    }

    return api;


});