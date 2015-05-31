/*
This is a placeholder for the class in api.js
It is used to simulate server response and returns fixed results for queries
For actual server results, use the code in api.js
 */
app.factory('LocalApi', function($timeout) {
    var api = {};

    // expects user to have fields: gender, age, education, country
    // returns token if successful
    api.register = function(user, success, error) {
        post(success, {token: "sample_token"});
    };

    // expects data to have fields: token, rank
    api.submitExpectedRank = function(data, success, error) {
        post(success, {message: "rank submitted"});
    }

    // simulate a post to server, by delaying callback
    function post(callback, data) {
        $timeout(function(){
            callback(data);
        }, 2000);
    }

    return api;
});