var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
var apiPartnerIds;
var mId = "";
function LoadModule(menuType) {
    scroll(0, 0);
    return;
    //switch (menuType.toLowerCase()) {
    //    case "adminstration":
    //        window.open("/Administration.aspx?mtype=adminstration", "mainFrame")
    //        break;

    //    case "customer_management":
    //        window.open("/Administration.aspx?mtype=customer_management", "mainFrame")
    //        break;

    //    case "applicationsetting":
    //        window.open("/Administration.aspx?mtype=applicationsetting", "mainFrame")
    //        break;

    //    case "sub_administration":
    //        window.open("/Administration.aspx?mtype=sub_administration", "mainFrame")
    //        break;

    //    case "system_security":
    //        window.open("/Administration.aspx?mtype=system_security", "mainFrame")
    //        break;

    //    case "remittance":
    //        window.open("/Administration.aspx?mtype=remittance", "mainFrame")
    //        break;

    //    case "servicecharge_and_commission":
    //        window.open("/Administration.aspx?mtype=servicecharge_and_commission", "mainFrame")
    //        break;

    //    case "creditrisk_management":
    //        window.open("/Administration.aspx?mtype=creditrisk_management", "mainFrame")
    //        break;

    //    case "transaction":
    //        window.open("/Administration.aspx?mtype=transaction", "mainFrame")
    //        break;

    //    case "report":
    //        window.open("/Administration.aspx?mtype=report", "mainFrame")
    //        break;

    //    case "account":
    //        window.open("/Administration.aspx?mtype=account", "mainFrame")
    //        break;

    //    case "remittance_report":
    //        window.open("/Administration.aspx?mtype=remittance_report", "mainFrame")
    //        break;

    //    case "account_report":
    //        window.open("/Administration.aspx?mtype=account_report", "mainFrame")
    //        break;

    //    case "sub_account":
    //        window.open("/Administration.aspx?mtype=sub_account", "mainFrame")
    //        break;
    //}
}

function LoadModuleAgentMenu(menuType) {
    return;
    //switch (menuType.toLowerCase()) {
    //    case "send_money":
    //        window.open("/AgentMenuTileView.aspx?mtype=send_money", "mainFrame");
    //        break;

    //    case "pay_money":
    //        window.open("/AgentMenuTileView.aspx?mtype=pay_money", "mainFrame");
    //        break;

    //    case "reports":
    //        window.open("/AgentMenuTileView.aspx?mtype=reports", "mainFrame");
    //        break;

    //    case "other_services":
    //        window.open("/AgentMenuTileView.aspx?mtype=other_services", "mainFrame");
    //        break;
    //}
}

Date.prototype.toUSFormat = function () {
    var dd = this.getDate();
    if (dd < 10) dd = '0' + dd;
    var mm = this.getMonth() + 1;
    if (mm < 10) mm = '0' + mm;
    var yyyy = this.getFullYear();
    return String(mm + "\/" + dd + "\/" + yyyy);
}
function OpenInNewWindowModifyChrome(url, param) {
    if (param === undefined || param === "") {
        param = "width=600,height=400,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
    }
    return window.open(url, window.self, param);
}
function PopUpWindowWithCallBackBigSize(url, param) {
    if (param === undefined || param === "") {
        param = "dialogHeight:1000px;dialogWidth:1100px;dialogLeft:150;dialogTop:50;center:yes";
    }
    if (isChrome) {
        return window.open(url, "_blank", param);
    } else {
        return window.showModalDialog(url, window.self, param);
    }
    //return window.showModalDialog(url, window.self, param);
}
function RemoveComma(value) {
    return value.replace(/,/g, "");
}

function FilterString(value) {
    //alert(value);
    value = value.replace("NaN", "");
    return value.replace(/[^a-zA-Z0-9 .()]/g, "");
}

function FilterStringReceiverName(value) {
    //alert(value);
    value = value.replace("NaN", "");
    return value.replace(/[^a-zA-Z0-9^/ .()]/g, "");
}

function bookmarksite() {
    var title = document.title, url = window.location.href;
    if (window.sidebar) // firefox
        window.sidebar.addPanel(title, url, "");
    else if (window.opera && window.print) { // opera
        var elem = document.createElement('a');
        elem.setAttribute('href', url);
        elem.setAttribute('title', title);
        elem.setAttribute('rel', 'sidebar');
        elem.click();
    }
    else if (document.all)// ie
        window.external.AddFavorite(url, title);
}

function EnableDisableBtn(id, boolDisabled) {
    try {
        var ctl = GetElement(id);
        ctl.disabled = boolDisabled;

        var cssClass = "button" + (boolDisabled ? "Disabled" : "");
        var thisClass = ctl.className;

        thisClass = thisClass.replace("buttonDisabled", "");
        thisClass = thisClass.replace("buttonEnabled", "");
        cssClass = cssClass + " " + thisClass;
        SetCSSByObj(ctl, cssClass);
    } catch (ex) {
        return;
    }
}

function LoadRegion(flag, divZip, divDistrict, region) {
    if (flag === 'o') {                          //o - for Other
        ShowElement(divZip);
        HideElement(divDistrict);
        GetElement(region).innerHTML = "State";
        return;
    }
    else if (flag === 'n') {                     //n - for Nepal
        ShowElement(divDistrict);
        HideElement(divZip);
        GetElement(region).innerHTML = "Zone";
        return;
    }
}

function MoveWindowToTop() {
    var target = window.parent.document.getElementById('Td1');
    target.scrollIntoView();
}

function ReadData(id, singleQuote, focusIfNull) {
    var obj = document.getElementById(id);
    if (obj) return (singleQuote ? "'" + obj.value + "'" : obj.value);
    return "null";
}

function IsCSVFile(fileName) {
    var file_parts = fileName.split(".");

    if (file_parts[file_parts.length - 1].toUpperCase() === "CSV")
        return true;
    return false;
}

function GetListBoxItems(id, selectedOnly) {
    var list = document.getElementById(id);
    var valueList = "";
    var cnt = list.options.length;
    var values = [];
    for (var i = 0; i < cnt; i++) {
        var item = list.options[i];
        if (item.selected || (!selectedOnly)) {
            values.push(item.value);
        }
    }

    return values;
}

function HideElement(id) {
    ObjHide(GetElement(id));
}

function ObjHide(obj) {
    try {
        obj.style.display = "none";
    } catch (ex) { return; }
}

function ShowElement(id) {
    ObjShow(GetElement(id));
}

function ObjShow(obj) {
    try {
        obj.style.display = "block";
    } catch (ex) { return; }
}

var guid = (function () {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    return function () {
        return s4() + s4() + '' + s4() + '' + s4();
    };
})();

function OpenInNewWindow(url) {
    url = url + "&srcCode=" + guid;
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}
function OpenInNewSmallWindow(url) {
    url = url + "&srcCode=" + guid;
    window.open(url, "", "width=430,height=300,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}
function GetValue(id) {
    var obj = document.getElementById(id);
    if (obj === null || obj === undefined)
        return "";
    return obj.value;
}

function GetElement(id) {
    return document.getElementById(id);
}

function GetDateValue(id) {
    var value = GetValue(id);

    if (value === "")
        return value;

    var dateParts = value.split("/");

    if (dateParts.length < 3)
        return "";

    var y = dateParts[0].toString("0000");
    var m = dateParts[1].toString("00");
    var d = dateParts[2].toString("00");

    return y + "/" + m + '/' + d;
}

function SelectOrClearByElement(elements, boolSelect) {
    for (var i = 0; i < elements.length; i++) {
        try {
            elements[i].checked = boolSelect;
        } catch (ex) {
            return;
        }
    }
}

function SelectOrClearById(cbContainerId, boolSelect) {
    var elements = GetElement(cbContainerId).getElementsByTagName("input");
    SelectOrClearByElement(elements, boolSelect);
}

function EnableOrDisableDdlByElement(elements, boolDisabled) {
    for (var i = 0; i < elements.length; i++) {
        try {
            elements[i].disabled = boolDisabled;
        } catch (ex) {
            return;
        }
    }
}

function EnableOrDisableDdlById(cbContainerId, boolDisabled) {
    var elements = GetElement(cbContainerId).getElementsByTagName("select");
    EnableOrDisableDdlByElement(elements, boolDisabled);
}

function PrintWindow() {
    window.parent.frames["frmame_main"].focus();
    window.parent.frames["frmame_main"].document.execCommand('print', false, null);
    return false;
}
function ReportPrint() {
    window.print();
    return false;
}
function DownloadReport(path) {
    url = path + "/Download.aspx?mode=report";
    OpenInNewWindow(url);
}
function HasValidExtension(fileName, ext) {
    var file_parts = fileName.split(".");

    if (file_parts[file_parts.length - 1].toUpperCase() === ext.toUpperCase())
        return true;

    return false;
}

function DownloadInNewWindow(url) {
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}

function SelectFunctions(me, parent) {
    var elements = document.getElementsByName("functionId");
    var cssName = me.className;
    var cssLength = cssName.length;

    var newCss = "";
    var boolChecked = false;
    if (cssName.substr(cssLength - 8, cssLength) === "Selected") {
        newCss = cssName.substr(0, cssLength - 8);
    } else {
        newCss = cssName + "Selected";
        boolChecked = true;
    }

    var parentLength = parent.length;
    for (var i = 0; i < elements.length; i++) {
        if (!elements[i].disabled) {
            var value = elements[i].value;
            if (value.substr(0, parentLength) === parent) {
                elements[i].checked = boolChecked;
            }
        }
    }
    me.className = newCss;
}
function Redirect(url) {
    window.parent.location = url;
}
function RedirectLocal(url) {
    window.location = url;
}
function OpenDialog(url, height, width, left, top) {
    if (isChrome) {
        var param = "";
        if (param === undefined || param === "")
            param = "width=1000,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
        return window.open(url, "_blank", param);
    } else {
        return window.showModalDialog(url, window.self, "dialogHeight:" + height + "px;dialogWidth:" + width + "px;dialogLeft:" + left + "px;dialogTop:" + top + "px");
    }
}

function CloseDialog(returnValue) {
    window.returnValue = returnValue;
    window.close();
}

function GoBack() {
    if (confirm("Are you sure to want to go back?")) {
        window.history.back(1);
    }
}

function OpenWindow(url) {
    var browser = navigator.appName;
    if (browser === "Microsoft Internet Explorer") {
        window.opener = self;
    }

    window.open(url, "", "width=900,height=750,toolbar=no,scrollbars=yes,location=no,resizable =yes");
    window.moveTo(0, 0);
    window.resizeTo(screen.width, screen.height - 100);
    self.close();
}

function PopUpWindow(url, param) {
    if (param === undefined || param === "") {
        param = "dialogHeight:500px;dialogWidth:600px;dialogLeft:300;dialogTop:100;center:yes";
    }
    if (isChrome) {
        window.open(url, "_blank", param);
    } else {
        return window.showModalDialog(url, window.self, param);
    }
}
function PopUpWithCallBack(url, param) {
    if (param === undefined || param === "") {
        param = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
    }
    if (isChrome) {
        window.open(url, "_blank", param);
    } else {
        window.showModalDialog(url, window.self, param);
    }
    CallBack();
}

//function OpenInNewWindow(url) {
//    window.open(url, "_blank", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
//}
function PopUpWindowWithCallBack(url, param) {
    if (param === undefined || param === "") {
        param = "width=1000,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
    }
    if (isChrome) {
        return window.open(url, "_blank", param);
    } else {
        return window.showModalDialog(url, window.self, param);
    }
}
function downloadInNewWindow(url) {
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}

function FindPos(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
        curleft = obj.offsetLeft;
        curtop = obj.offsetTop;
        while (obj === obj.offsetParent) {
            curleft += obj.offsetLeft;
            curtop += obj.offsetTop;
        }
    }
    return [curleft, curtop];
}

function numericOnly(obj, e, supportDecimal, doNotSupportNegative) {
    var evtobj = window.event ? event : e;
    if (evtobj.altKey || evtobj.ctrlKey)
        return true;
    var charCode = e.which || e.keyCode;
    if (doNotSupportNegative) {
        if (charCode === 189 || charCode === 109) {
            return false;
        }
    }
    if (charCode === 46 || charCode === 8 || charCode === 9 || charCode === 37 || charCode === 39 || charCode === 109)
        return true;
    var char = String.fromCharCode(charCode);
    if (char === "." || char === "¾" || charCode === 110) {
        if (obj.value.indexOf(".") > -1)
            return false;
        else
            return true;
    }
    if ((char >= "0" && char <= "9") || (charCode >= 96 && charCode <= 105))
        return true;
    return false;
}

function TrackChanges(hddField) {
    GetElement(hddField).value = 'y';
}

function manageOnPaste(me) {
    return true;
}

function resetInput(obj, hint, type, isNum, allowBlank) {
    var val = parseFloat(obj.value);
    if (type === 1) {
        if (val === hint || (isNum && isNaN(obj.value))) { obj.value = ""; }
    }
    else {
        if (val.length === 0 || (isNum && isNaN(obj.value))) {
            if (allowBlank) {
                obj.value = "";
            } else {
                obj.value = hint;
            }
        }
    }
}

function ParseMessageToArray(mes) {
    var results = mes.split("-:::-");
    return results;
}

function GetIds(name) {
    var elements = document.getElementsByName(name);
    var list = "";
    for (var i = 0; i < elements.length; i++) {
        try {
            if (elements[i].checked) {
                list = list + (list !== "" ? ", " : "") + elements[i].value;
            }
        }
        catch (ex) {
            return "";
        }
    }
    return list;
}

function CurrencyFormatted(amount) {
    var i = parseFloat(amount);
    if (isNaN(i)) { i = 0.00; }
    var minus = '';
    if (i < 0) { minus = '-'; }
    i = Math.abs(i);
    i = parseInt((i + .005) * 100);
    i = i / 100;
    s = new String(i);
    if (s.indexOf('.') < 0) { s += '.00'; }
    if (s.indexOf('.') === (s.length - 2)) { s += '0'; }
    s = minus + s;
    return s;
}

function CommaFormatted(amount) {
    var delimiter = ",";
    var a = amount.split('.', 2);
    var d = a[1];
    var i = parseInt(a[0]);
    if (isNaN(i)) { return ''; }
    var minus = '';
    if (i < 0) { minus = '-'; }
    i = Math.abs(i);
    var n = new String(i);
    a = [];
    while (n.length > 3) {
        var nn = n.substr(n.length - 3);
        a.unshift(nn);
        n = n.substr(0, n.length - 3);
    }
    if (n.length > 0) { a.unshift(n); }
    n = a.join(delimiter);
    if (d.length < 1) { amount = n; }
    else { amount = n + '.' + d; }
    amount = minus + amount;
    return amount;
}

function UpdateComma(obj) {
    var s = new String();
    var amt = obj.value.replace(",", "");
    amt = amt.replace(",", "");
    amt = amt.replace(",", "");
    amt = amt.replace(",", "");
    s = CurrencyFormatted(amt);
    s = CommaFormatted(s);
    obj.value = s;
}

function roundNumber(rnum, rlength) {
    var newnumber = Math.round(rnum * Math.pow(10, rlength)) / Math.pow(10, rlength);
    return parseFloat(newnumber);
}

function roundNumberUp(rnum, rlength) {
    var ad = 5 / Math.pow(10, rlength + 1);
    return roundNumber(rnum + ad, rlength);
}

function roundNumberDown(rnum, rlength) {
    var ad = 5 / Math.pow(10, rlength + 1);
    return roundNumber(rnum - ad, rlength);
}

document.onkeydown = KeyDownHandler;
document.onkeyup = KeyUpHandler;

var CTRL = false;
var SHIFT = false;
var ALT = false;
var CHAR_CODE = -1;

function KeyDownHandler(e) {
    var x = '';
    if (document.all) {
        var evnt = window.event;
        x = evnt.keyCode;
    }
    else {
        x = e.keyCode;
    }
    DetectKeys(x, true);
    MenuControl();
}

function KeyUpHandler(e) {
    var x = '';
    if (document.all) {
        var evnt = window.event;
        x = evnt.keyCode;
    }
    else {
        x = e.keyCode;
    }
    DetectKeys(x, false);
    MenuControl();
}

function MenuControl() {
}

function DetectKeys(KeyCode, IsKeyDown) {
    if (KeyCode === '16') {
        SHIFT = IsKeyDown;
        CHAR_CODE = -1;
    }
    else if (KeyCode === '17') {
        CTRL = IsKeyDown;
        CHAR_CODE = -1;
    }
    else if (KeyCode === '18') {
        ALT = IsKeyDown;
        CHAR_CODE = -1;
    }
    else {
        if (IsKeyDown)
            CHAR_CODE = KeyCode;
        else
            CHAR_CODE = -1;
    }
}
function Lock() {
    if (ALT && CHAR_CODE === 76) {
        if (confirm("Are you sure you want to lock application?")) {
            var url = window.parent.document.getElementById("frmame_main").contentWindow.location.href;
            window.parent.location.replace('/Lock.aspx?url=' + url);
        }
    }
}

function checkRateMasking(obj, beforeLength, afterLength) {
    if (isNaN(obj.value)) {
        alert("Please, Enter valid number !");
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    if (obj.value.indexOf(".") >= 0) {
        var resStr = obj.value.split(".");
        if (beforeLength !== "99" && obj.value !== "0" && obj.value !== "") {
            var bdValue = resStr[0];
            var bdValueLength = bdValue.length;
            if (parseFloat(obj.value) < 0)
                bdValueLength = bdValue.length - 1;
            if (bdValueLength > beforeLength) {
                if (parseInt(bdValueLength) > parseInt(beforeLength)) {
                    alert("Error, Only " + beforeLength + " digit(s) are allowed before decimal !");
                    setTimeout(function () { obj.focus(); }, 1);
                    return 1;
                }
            }
        }
        if (afterLength !== "99" && obj.value !== "0" && obj.value !== "") {
            if (resStr[1].length > afterLength) {
                if (resStr[1].length > afterLength) {
                    alert("Error, Only " + afterLength + " digit(s) are allowed after decimal !");
                    setTimeout(function () { obj.focus(); }, 1);
                    return 1;
                }
            }
        }
    }
    else {
        if (beforeLength !== "99" && obj.value !== "0" && obj.value !== "") {
            bdValue = obj.value;
            bdValueLength = bdValue.length;
            if (bdValue < 0)
                bdValueLength = bdValue.length - 1;
            if (parseInt(bdValueLength) > parseInt(beforeLength)) {
                alert("Error, Only " + beforeLength + " digit(s) are allowed before decimal !");
                setTimeout(function () { obj.focus(); }, 1);
                return 1;
            }
        }
    }
    return 0;
}

function CheckNumberWithMsg(obj) {
    if (isNaN(obj.value)) {
        alert("Input value = " + obj.value + "\n\nPlease enter valid number!");
        obj.value = 0;
        setTimeout(function () { obj.focus(); }, 1);
    }
}

function checkRateCapping2(obj, currentValue, min, max, value, id, errorImg) {
    if (isNaN(obj.value)) {
        alert("Please, Enter valid number !");
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    value = roundNumber(value, 6);
    var msg = "";
    GetElement("status_" + id).innerHTML = "";
    EnableDisableBtn("btnUpdate_" + id, false);
    if (value > max) {
        msg = "Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max;
        alert(msg);
        obj.value = currentValue;
        if (currentValue > max) {
            GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\"/>";
            EnableDisableBtn("btnUpdate_" + id, true);
        }
        else if (currentValue < min) {
            GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\"/>";
            EnableDisableBtn("btnUpdate_" + id, true);
        }
        else
            setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    if (value < min) {
        msg = "Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max;
        alert(msg);
        obj.value = currentValue;
        if (currentValue > max) {
            GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\"/>";
            EnableDisableBtn("btnUpdate_" + id, true);
        }
        else if (currentValue < min) {
            GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\"/>";
            EnableDisableBtn("btnUpdate_" + id, true);
        }
        else
            setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    return 0;
}

function checkRateCapping(obj, currentValue, min, max, value) {
    if (isNaN(obj.value)) {
        alert("Please, Enter valid number !");
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    value = roundNumber(value, 6);
    if (value > max) {
        alert("Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max);
        if (currentValue > max)
            currentValue = 0;
        obj.value = currentValue;
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    if (value < min) {
        alert("Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max);
        if (currentValue < min)
            currentValue = 0;
        obj.value = currentValue;
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    return 0;
}

function checkCrossRateCapping(obj, currentValue, cMin, cMax, pMin, pMax, crossRate, crossRateMaskAd) {
    if (isNaN(obj.value)) {
        alert("Please, Enter valid number !");
        setTimeout(function () { obj.focus(); }, 1);
        return 1;
    }
    var minCustomerRate = pMin / cMax;
    minCustomerRate = roundNumber(minCustomerRate, crossRateMaskAd);

    var maxCustomerRate = pMax / cMin;
    maxCustomerRate = roundNumber(maxCustomerRate, crossRateMaskAd);

    if (crossRate > maxCustomerRate) {
        alert("Input value = " + crossRate + "\n\nRate must lie between " + minCustomerRate + " and " + maxCustomerRate);
        setTimeout(function () { obj.focus(); }, 1);
        obj.value = currentValue;
        return 1;
    }
    else if (crossRate < minCustomerRate) {
        alert("Input value = " + crossRate + "\n\nRate must lie between " + minCustomerRate + " and " + maxCustomerRate);
        setTimeout(function () { obj.focus(); }, 1);
        obj.value = currentValue;
        return 1;
    }
    return 0;
}

function ParseResultJsPrint(errorCode, msg, id) {
    return errorCode + "-:::-" + msg + "-:::-" + id;
}

function cVal(data) {
    var res = parseFloat(data);
    if (isNaN(res)) res = 0;
    return res;
}
function hideMessageBox() {
    var rptCentraizeMassege = document.getElementById("rptCentraizeMassege");
    rptCentraizeMassege.innerHTML = "";
    rptCentraizeMassege.className = "";
}

function SetValueById(id, value, innerHTML) {
    SetValueByObj(GetElement(id), value, innerHTML);
}

function SetValueByObj(obj, value, innerHTML) {
    if (innerHTML) {
        obj.innerHTML = innerHTML;
    } else {
        obj.value = value;
    }
}

function SetValueIfNotById(id, value, innerHTML, notValue) {
    SetValueIfNotByObj(GetElement(id), value, innerHTML, notValue);
}

function SetValueIfNotByObj(obj, value, innerHTML, notValue) {
    value1 = GetValueByObj(obj, innerHTML);
    if (value1.toLowerCase() !== notValue.toLowerCase()) {
        if (innerHTML) {
            obj.innerHTML = value;
        } else {
            obj.value = value;
        }
    }
}

function SetValueIfBlankById(id, value, innerHTML) {
    SetValueIfBlankByObj(GetElement(id), value, innerHTML);
}

function SetValueIfBlankByObj(obj, value, innerHTML) {
    var value1 = GetValueByObj(obj, innerHTML);
    if (value1 === "") {
        if (innerHTML) {
            obj.innerHTML = value;
        } else {
            obj.value = value;
        }
    }
}

function SetValueIfZeroById(id, value, innerHTML) {
    SetValueIfZeroByObj(GetElement(id), value, innerHTML);
}

function SetValueIfZeroByObj(obj, value, innerHTML) {
    var value1 = parseFloat(GetValueByObj(obj, innerHTML));

    if (value1 === 0) {
        if (innerHTML) {
            obj.innerHTML = value;
        } else {
            obj.value = value;
        }
    }
}

function SetCSSById(id, css) {
    SetCSSByObj(GetElement(id), css);
}

function SetCSSByObj(obj, css) {
    obj.className = css;
}

function CheckNumber(obj) {
    obj.value = cVal(obj.value);
}

function IntegerOnly(obj) {
    if (isNaN(obj.value)) {
        obj.value = "";
        return;
    }

    if (obj.value.indexOf(".") > -1) {
        obj.value = "";
        return;
    }
}

function FloatOnly(obj) {
    if (isNaN(obj.value)) {
        obj.value = "";
        return;
    }
}

function setCookie(c_name, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays === null) ? "" : "; expires=" + exdate.toUTCString());
    document.cookie = c_name + "=" + c_value;
}

function getCookie(c_name) {
    var i, x, y, ARRcookies = document.cookie.split(";");
    for (i = 0; i < ARRcookies.length; i++) {
        x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
        y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
        x = x.replace(/^\s+|\s+$/g, "");
        if (x === c_name) {
            return unescape(y);
        }
    }
    return "";
}

function FixDecimalWithRound(num, afterDecimalCount) {
    return num.toFixed(afterDecimalCount).replace(/\.?0+$/, "");
}

function SetColorById(id, value) {
    if (value < 0)
        GetElement(id).setAttribute('style', 'color: red !important;');
    else
        GetElement(id).setAttribute('style', 'color: green !important;');
}

function datediff(fromDate, interval) {
    var second = 1000, minute = second * 60, hour = minute * 60, day = hour * 24, week = day * 7;
    var currentDate = new Date()
    fromDate = new Date(fromDate);
    toDate = new Date(currentDate);

    var timediff = toDate - fromDate;
    if (isNaN(timediff)) return NaN;
    switch (interval) {
        case "years": return toDate.getFullYear() - fromDate.getFullYear();
        case "months": return (
            (toDate.getFullYear() * 12 + toDate.getMonth())
            -
            (fromDate.getFullYear() * 12 + fromDate.getMonth())
        );
        case "weeks": return Math.floor(timediff / week);
        case "days": return Math.floor(timediff / day);
        case "hours": return Math.floor(timediff / hour);
        case "minutes": return Math.floor(timediff / minute);
        case "seconds": return Math.floor(timediff / second);
        default: return undefined;
    }
}

function PrintMessage(msg, errorCode) {
    window.parent.SetMessageBox(msg, errorCode);
}

function CheckForSpecialCharacter(nField, fieldName) {
    var userInput = nField.value;
    if (userInput === "" || userInput === undefined) {
        return;
    }

    if (/^[a-zA-Z0-9- ./\\()-]*$/.test(userInput) === false) {
        alert('Special Character(e.g. !@#$%^&*) are not allowed in field : ' + fieldName);
        setTimeout(function () { nField.focus(); }, 1);
    }
}
function CheckForMobileNumber(nField, fieldName) {
    var userInput = nField.value;
    if (userInput === "" || userInput === undefined) {
        return;
    }

    if (/^[0-9- ./\\()]*$/.test(userInput) === false) {
        alert('Special Character(e.g. !@#$%^&*) are not allowed in field : ' + fieldName);
        setTimeout(function () { nField.focus(); }, 1);
    }
}
function CheckAlfabetOnly(nField, fieldName) {
    var userInput = nField.value;
    if (userInput === "" || userInput === undefined) {
        return;
    }

    if (/^[a-zA-Z ]*$/.test(userInput) === false) {
        alert('Only Character are allowed in field : ' + fieldName);
        setTimeout(function () { nField.focus(); }, 1);
    }
}
function CheckAddressValidation(nField, fieldName) {
    var userInput = nField.value;
    if (userInput === "" || userInput === undefined) {
        return;
    }

    if (/^[a-zA-Z .,/\()]*$/.test(userInput) === false) {
        alert('Only Character are allowed in field : ' + fieldName);
        setTimeout(function () { nField.focus(); }, 1);
    }
}
function RemoveElement(id) {
    var el = document.getElementById(id);
    if (el)
        document.body.removeChild(el);
}

function RemoveProcessDiv() {
    var id = "divProcess";
    RemoveElement(id);
}

function RemoveProcessDivWithMsg(msg) {
    var id = "divProcess";
    RemoveElement(id);
    alert(msg);
}
function Process() {
    var id = "divProcess";
    RemoveProcessDiv();
    var newdiv = document.createElement('div');
    newdiv.setAttribute('id', id);

    newdiv.style.width = "100%";

    var height = document.body.scrollHeight;
    if (height <= 826)
        height = '826';
    var html = "<center>";
    html += "<div class=\"still-bg\" id=\"progress\" style=\"height:" + height + "px;\">";
    html += "<div class=\"inner-bg\">";
    html += "<h3 style=\"color:white;\">Processing... Please wait.</h3>";
    html += "</div>";
    html += "</div>";
    html += "</center>";
    newdiv.innerHTML = html;
    document.body.appendChild(newdiv);
    return true;
}

function ProcessWithConfirm(msg) {
    if (msg === undefined || msg === null) msg = "Are you sure to approve SELECTED transaction?";
    if (confirm(msg)) {
        return Process();
    }
    return false;
}

function SpecialCharToLineBreak(val) {
    var sep = "-:::-";
    var list = val.split(sep);
    return list.join("\n");
}
function onlyAlphabets(e, t) {
    try {
        var charCode = "";
        if (window.event) {
            charCode = window.event.keyCode;
        }
        else if (e) {
            charCode = e.which;
        }
        else { return true; }
        if ((charCode > 64 && charCode < 91) || (charCode > 96 && charCode < 123) || charCode === 8 || charCode === 32 || charCode === 9 || charCode === 0)
            return true;
        else
            return false;
    }
    catch (err) {
        alert(err.Description);
    }
}

function MakeNumericContactNoIdNo(obj, e) {
    var evtobj = window.event ? event : e;
    if (evtobj.altKey || evtobj.ctrlKey)
        return true;
    var charCode = e.which || e.keyCode;
    if (charCode === 46 || charCode === 8 || charCode === 9 || charCode === 37 || charCode === 39 || charCode === 109 || charCode === 189 || charCode === 111 || charCode === 109)
        return true;
    var char = String.fromCharCode(charCode);

    if (!isNaN(char))
        return true;
    if ((char >= "0" && char <= "9") || (charCode >= 96 && charCode <= 105 || charCode === 173 || charCode === 191 || charCode === 189 || charCode === 111 || charCode === 109))
        return true;
    return false;
}

function isInt(value) {
    if (isNaN(value)) {
        return false;
    }
    var x = parseFloat(value);
    return (x | 0) === x;
}
function ContactNoValidation(obj) {
    var rIdNo = obj.value;
    var isIntegerVal = isInt(rIdNo);
    if (isIntegerVal === true) {
        var rIdN = parseInt(rIdNo);
        if (rIdN === 0) {
            rIdNo = rIdN;
        }
    }
    if (rIdNo === 0 || rIdNo === "0" || rIdNo === "00" || rIdNo === "1234" || rIdNo.length < 6 || rIdNo.length > 10) {
        alert("Invalid Input.");
        obj.value = "";
        obj.focus();
        return false;
    }
    return true;
}
function IdNoValidation(obj) {
    var rIdNo = obj.value;
    var isIntegerVal = isInt(rIdNo);
    if (isIntegerVal === true) {
        var rIdN = parseInt(rIdNo);
        if (rIdN === 0) {
            rIdNo = rIdN;
        }
    }
    if (rIdNo === 0 || rIdNo === "0" || rIdNo === "1234") {
        alert("Invalid Input.");
        obj.value = "";
        obj.focus();
        return false;
    }
    return true;
}

function OpenInNewWindowWithCallBack(url, param, callback) {
    if (param === undefined || param === "")
        param = "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
    var res = window.open(url, "", param);
    if (typeof (callback) === "function") {
        try {
            res.attachEvent("onbeforeunload", callback);
        }
        catch (err) {
            res.onbeforeunload = callback;
        }
    }
}
var validchars = /^[A-Za-z0-9\/\\ -]{1,20}$/;

function checkIfValidChars(strValue) {
    try {
        if (!validchars.test(strValue)) {
            alert("Cheque number you provided is invalid.");
            return false;
        }
    }
    catch (err) {
        alert(err);
    }
    return true;
}
function checkIfAllCharIsSame(strValue) {
    try {
        if (strValue.length > 1) {
            var charToCompare = strValue[0];
            var isAllCharSame = true;
            for (var i = 0; i < strValue.length; i++) {
                if (charToCompare !== strValue[i]) {
                    isAllCharSame = false;
                    break;
                }
            }

            if (isAllCharSame) {
                alert("Cheque number you provided is invalid.");
                return false;
            }
        }
    }
    catch (err) {
        alert(err);
    }
    return true;
}
function checkIfFistCharIsValid(strValue) {
    try {
        if (strValue === "-" || strValue === "/" || strValue === "\\") {
            alert("Cheque number cannot started with this value [-/\\].");
            return false;
        }
    }
    catch (err) {
        alert(err);
    }
    return true;
}

function checkIfCharsRepeated(strValue) {
    try {
        if (strValue.length > 1) {
            var charToCompare = "-- // \\\\ -/ /- -\\ \\- /\\ \\/".split(" ");
            var isCharRepeated = false;
            for (var i = 0; i < charToCompare.length && !isCharRepeated; i++) {
                for (var j = 0; j < strValue.length - 1; j++) {
                    if (charToCompare[i] === strValue.substring(j, j + 2)) {
                        isCharRepeated = true;
                        break;
                    }
                }
            }

            if (isCharRepeated) {
                alert("Cheque number you provided is invalid.");
                return false;
            }
        }
    }
    catch (err) {
        alert(err);
    }
    return true;
}
function ValidRequiredField(RequiredField) {
    var Isvalid = true;
    var OtherPersonFld = new Array;
    var fld = RequiredField.split(',');
    for (n = 0; n < fld.length - 1; n++) {
        OtherPersonFld[n] = fld[n];
    }
    for (i = 0; i < OtherPersonFld.length; i++) {
        $('#' + OtherPersonFld[i]).css('background-color', '#FFFFFF');
        var a = $('#' + OtherPersonFld[i]).val();
        if (a === "" || a === null || a === "0") {
            $('#' + OtherPersonFld[i]).css('background-color', '#FFCCD2');
            Isvalid = false;
        }
    }
    if (Isvalid === false) {
        alert("Required Field(s)\n _____________________________ \n The red fields are required!")
    }
    return Isvalid;
}

function ValidRequiredFieldAC(RequiredField) {
    var Isvalid = true;
    var OtherPersonFld = new Array;
    var fld = RequiredField.split(',');
    for (n = 0; n < fld.length - 1; n++) {
        OtherPersonFld[n] = fld[n];
    }
    for (i = 0; i < OtherPersonFld.length; i++) {
        GetElement(OtherPersonFld[i]).style.background = "#FFFFFF";
        $(OtherPersonFld[i]).css('background-color', '#FFFFFF');
        if (GetElement(OtherPersonFld[i]).value === "") {
            $(OtherPersonFld[i]).css('background-color', '#FFCCD2');
            Isvalid = false;
        }
    }
    if (Isvalid === false) {
        alert("Required Field(s)\n _____________________________ \n The red fields are required!");
    }
    return Isvalid;
}