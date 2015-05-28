// Select an Api
// LocalApi: used to simulate server responses
// WisdomApi: actual server responses
app.factory('Api', function(LocalApi, WisdomApi) {
    var localMode = true;
    if(localMode) {
        return LocalApi;
    }
    return WisdomApi;
});