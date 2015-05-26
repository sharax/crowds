app.factory('Logger', function() {
    var logger = {};
    logger.log = function(str) {
        console.log(str);
    };
    return logger;
});