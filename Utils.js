
function pr(){
    for (var i in arguments)
        console.log(arguments[i]);
    return arguments[0];
}

/*function blankevent(){
    return {
        id: 0,
        name: "rubbish",
        type: 1,
        mask: "0 2 4 6",
        color: "pink",
        startDate: new Date(),
        endDate: new Date((new Date() ).setMonth(10))
    }
}*/

function blankevent(date){
    return {
        id: -1,
        name: "None",
        type: 0,
        mask: "",
        color: "red",
        startDate: date.getTime().toString(),
        endDate: date.getTime().toString()
    }
}

function daysInMonth(month,year) {
    return new Date(year, month, 0).getDate();
}

function getDayItems(date){
    var l = Utils.daysInMonth(date.getYear(), date.getMonth() );
    var x = [];
    for (var i = 1; i < l; ++ i){
        x.push(i);
    }
    return x;
}

//function transfer_color(, opacity)
