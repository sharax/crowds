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

function segment(arr, segmentLength) {
    var segments = [];
    var tempSegment = [];
    for(var i = 0; i < arr.length; i++) {
        tempSegment.push(arr[i]);
        if((i+1) % segmentLength === 0) {
            segments.push(tempSegment);
            tempSegment = [];
        }
    }
    if(tempSegment.length > 0) {
        segments.push(tempSegment);
    }
    return segments;
}
