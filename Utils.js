.pragma library

function pr(){
    for (var i in arguments)
        console.log(arguments[i]);
    return arguments[0];
}

function blankevent(date){
    return {
        id: -1,
        name: "",
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
    var l = daysInMonth(date.getYear(), date.getMonth() );
    var x = [];
    for (var i = 1; i < l; ++ i){
        x.push(i);
    }
    return x;
}

function addOpacity(color, opacity) {
    return Qt.rgba(color.r, color.g, color.b, color.a * opacity);
}

var m_config = {
    "lang": 0,
    "locked": 0,
    "drag": 1
};

function config(){
    return m_config;
}

var applicationManager;

function setAppManager(x){
    applicationManager = x;
}

function loadConfig(){
    console.log(applicationManager.loadConfig());
    m_config = JSON.parse(applicationManager.loadConfig());
}

function setConfig(x, y){
    m_config[x] = y;
    m_config = m_config;
    applicationManager.saveConfig(JSON.stringify(m_config) );
    //console.log(JSON.stringify(m_config) );
}
