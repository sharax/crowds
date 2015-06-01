function isInt(value) {
    return !isNaN(parseInt(value,10)) && (parseFloat(value,10) == parseInt(value,10));
}

function numberArray(start, end, interval) {
    if(interval === undefined) {
        interval = 1;
    }
    var arr = [];
    for(var i = start; i <= end; i++) {
        arr.push(i);
    }
    return arr;
}
