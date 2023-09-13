var xmlHttp;
var obj_name;
var call_back_func = "";
var trace = false;

function exec_AJAX(url_name, return_obj, call_back_par) {
    obj_name = return_obj;
    call_back_func = call_back_par
    xmlHttp = GetXmlHttpObject();
    if (xmlHttp == null) {
        alert("Your browser does not support AJAX!");
        return;
    }
    var url = "/include/" + url_name;
    xmlHttp.onreadystatechange = stateChanged;
    xmlHttp.open("post", url, true);
    xmlHttp.send(null);
}

function stateChanged() {
    if (xmlHttp.readyState == 4) {
        document.getElementById(obj_name).innerHTML = xmlHttp.responseText;

        if (call_back_func != "") {
            eval(call_back_func);
        }
    }
}

function GetXmlHttpObject() {
    var xmlHttp = null;
    try {
        // Firefox, Opera 8.0+, Safari
        xmlHttp = new XMLHttpRequest();
    }
    catch (e) {
        // Internet Explorer
        try {
            xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
    }
    return xmlHttp;
}

function get_AJAXArray(url_name, return_obj, call_back_par, istrace) {
    obj_name = return_obj;
    call_back_func = call_back_par
    trace = istrace;
    xmlHttp = GetXmlHttpObject();

    if (xmlHttp == null) {
        alert("Your browser does not support AJAX!");
        return;
    }
    var url = "../include/" + url_name;
    if (trace == true) {
        url = url + "&trace=true";
    }
    xmlHttp.onreadystatechange = getRecordset;
    xmlHttp.open("post", url, true);
    xmlHttp.send(null);
}

function getRecordset() {
    if (xmlHttp.readyState == 3) {
    }
    if (xmlHttp.readyState == 4) {
        var return_array = new Array();
        return_value = xmlHttp.responseText;

        if (trace == true) {
            x = window.open("", "_blank")
            x.document.write(return_value)
            return;
        }
        return_array = buildArray(return_value);
        if (call_back_func != "") {
            eval(call_back_func + "(return_array)");
        }
    }
}

function buildArray(str) {
    row_array = str.split("--tr_end--")
    result_set_array = new Array()
    result_set_array[0] = 'Error';
    for (i = 1; i < row_array.length - 1; i++) {
        row_id = i - 1;
        clm_array = row_array[i].split("--td_end--")
        result_set_array[row_id] = new Array()
        for (j = 0; j < clm_array.length - 1; j++) {
            clm_td = clm_array[j];
            clm_value = clm_td.split("--td_clm--");
            clm_name = clm_value[0];
            clm_data = clm_value[1];
            result_set_array[row_id][clm_name.toLowerCase()] = clm_data;
        }
    }
    return result_set_array;
}