var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
var gridName1;
function PopUp(gridName, url, param) {
    gridName1 = gridName;
    if (param == undefined || param == "") {
        param = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
    }
    if (isChrome) {
        window.open(url, "_blank", param);
    } else {
        errorCode = window.showModalDialog(url, window.self, param);
    }
    //errorCode = window.showModalDialog(url, window.self, param);

    try {
        if (errorCode != 0)
            return;

        SubmitForm(gridName);
        //CallBack();
    }
    catch (ex) { }
}

function ShowMessageToParent(errorCode) {
    if (errorCode != 0)
        return;

    SubmitForm(gridName1);
}

function PopUp2(url, param) {
    if (param == undefined || param == "") {
        param = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
    }
    var isChrome = !!window.chrome && !!window.chrome.webstore;
    if (isChrome) {
        return window.open(url, "_blank", param);
    } else {
        return window.showModalDialog(url, window.self, param);
    }
    //window.showModalDialog(url, window.self, param);
}

function FilterAll(gridName) {
    var tbl = document.getElementById(gridName + "_tblFilter");
    if (tbl) {
        var inputs = tbl.getElementsByTagName("input");
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].type != "button") {
                inputs[i].value = "";
            }
        }

        inputs = tbl.getElementsByTagName("select");
        for (var i = 0; i < inputs.length; i++) {
            inputs[i].value = "";
        }

        SubmitForm(gridName);
    }
}
function SubmitForm(gridName) {
    var btn_hdd = document.getElementById(gridName + "_submitButton");
    if (btn_hdd != null) btn_hdd.click();
}

function Nav(page, gridName) {
    //alert(page);
    var pageNumber_hdd = document.getElementById(gridName + "_pageNumber");
    if (pageNumber_hdd != null) pageNumber_hdd.value = page;
    //alert(pageNumber_hdd.value);

    SubmitForm(gridName);
}

function NewTableToggle(idTD, idImg, gridName) {
    var td = document.getElementById(gridName + "_" + idTD);
    var img = document.getElementById(gridName + "_" + idImg);

    if (td != null && img != null) {
        var isHidden = td.style.display == "none" ? true : false;
        img.src = isHidden ? "/images/icon_hide.gif" : "/images/icon_show.gif";
        img.alt = isHidden ? "Hide" : "Show";
        td.style.display = isHidden ? "" : "none";
    }
}

function NewTableToggle(idTD, idImg, gridName, url) {
    var td = document.getElementById(gridName + "_" + idTD);
    var img = document.getElementById(gridName + "_" + idImg);

    if (td != null && img != null) {
        var isHidden = td.style.display == "none" ? true : false;
        img.src = isHidden ? url + "/images/icon_hide.gif" : url + "/images/icon_show.gif";
        img.alt = isHidden ? "Hide" : "Show";
        td.style.display = isHidden ? "" : "none";
    }
}

function ToggleFieldset(el) {
    var fieldset = document.getElementById('filters');
    if (fieldset.className = "collapsible collapsed") {
        fieldset.className = "collapsible"
    }
    else {
        fieldset.className = "collapsed";
    }

    if (document.getElementById('divFilterForm').style.display == "" || document.getElementById('divFilterForm').style.display == "none") {
        document.getElementById('divFilterForm').style.display = 'block';
    }
    else {
        document.getElementById('divFilterForm').style.display = 'none';
    }
}

function SortGrid(gridName, sortBy, sortOrder) {
    var sortBy_hdd = document.getElementById(gridName + "_sortBy");
    if (sortBy_hdd != null) sortBy_hdd.value = sortBy;
    var sortOrder_hdd = document.getElementById(gridName + "_sortOrder");
    if (sortOrder_hdd != null) sortOrder_hdd.value = sortOrder;
    //alert(sortBy);
    SubmitForm(gridName);
}

function DownloadGrid(path) {
    url = path + "/Download.aspx?mode=grid";
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}

function DownloadGridRemit(path) {
    url = path + "/Download.aspx?mode=grid&type=remit";
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}
function DownloadPDFGrid(path) {
    url = path + "/DownloadPDF.aspx?mode=grid";
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}

function SetCheckBox(gridName, checkBoxName, me) {
    var checkboxes = document.getElementsByName(checkBoxName);
    var checkBoxStatus_hdd = document.getElementById(gridName + "_doCheck");

    var checkBoxStatus = checkBoxStatus_hdd.value == "N" ? "Y" : "N";
    var boolDoCheck = checkBoxStatus == "Y" ? true : false;

    me.innerText = (me.innerText == "[  ]" ? "[x]" : "[  ]");
    for (var i = 0; i < checkboxes.length; i++) {
        checkboxes[i].checked = boolDoCheck;
    }
    checkBoxStatus_hdd.value = checkBoxStatus;
}

//ShowChanges
function Approve(id, gridName, approveFunctionId) {
    var mode_hdd = document.getElementById(gridName + "_mode");
    mode_hdd.value = 'approve';

    var currentRowId_hdd = document.getElementById(gridName + "_currentRowId");
    currentRowId_hdd.value = id;

    SubmitForm(gridName);
}

function DeleteRow(id, gridName, mes) {
    if (mes == undefined || mes == null || mes == "")
        mes = "Are you sure to delete selected record?";

    if (confirm(mes)) {
        var currentRowId_hdd = document.getElementById(gridName + "_currentRowId");
        currentRowId_hdd.value = id;
        SubmitForm(gridName);
    }
}
function ManageSelection(me, gridName, allowMultiSelection) {
    var elements = document.getElementsByName(gridName + "_rowId");
    if (!allowMultiSelection) {
        for (var i = 0; i < elements.length; i++) {
            elements[i].checked = false;
        }
        me.checked = true;
    }
}

function SelectAll(me, gridName, allowMultiSelection) {
    var objMode = document.getElementById(gridName + "_mode");

    if (!allowMultiSelection) {
        objMode.value = "1"
    }

    var mode = objMode.value == "1" ? false : true;
    if (allowMultiSelection) {
        objMode.value = objMode.value == "1" ? "0" : "1";
    }

    if (allowMultiSelection)
        me.firstChild.data = (mode ? "×" : "√");
    else
        me.firstChild.data = "×";

    var elements = document.getElementsByName(gridName + "_rowId");
    for (var i = 0; i < elements.length; i++) {
        elements[i].checked = mode;
    }
}

function ClearAll(gridName) {
    var elements = document.getElementsByName(gridName + "_rowId");
    for (var i = 0; i < elements.length; i++) {
        elements[i].checked = false;
    }
}

function GetRowId(gridName) {
    var elements = document.getElementsByName(gridName + "_rowId");
    var idList = "";
    for (var i = 0; i < elements.length; i++) {
        if (elements[i].checked) {
            idList += (idList == "" ? "" : ",") + elements[i].value;
        }
    }
    return idList;
}
//Grid Field Edit
function ShowInEditableMode(me, gridName, data) {
    var pos = FindPos(me);
    var top = pos[1] + 20;

    RemoveFilterDiv();
    var newdiv = document.createElement('div');
    newdiv.setAttribute('id', "filterByColumn");

    newdiv.style.position = "absolute";

    newdiv.style.left = pos[0] + "px";
    newdiv.style.top = top + "px";

    newdiv.style.background = "#000000";
    newdiv.style.border = "1px solid black";
    var html = "<div style = \"width:155px;\">" +
        "<div style =\"float:left;font-family: verdana;margin:2px\"><b>Edit</b></div>" +
        "<div style =\"float:right\">" +
        "<span title = \"Close\" style = \"cursor:pointer;margin:2px\" onclick = \"RemoveFilterDiv();\"><b>x</b></span>" +
        "</div>" +
        "<div style=\"clear:both\">" +
        "<input type=\"text\" id=\"txtField\" value=\"" + data + "\" />" +
        "</div>" +
        "</div>";
    //    var html = "<div style = \"width:155px;\"><input type=\"text\" id=\"txtField\" /></div>";

    newdiv.innerHTML = html;
    document.body.appendChild(newdiv);
    document.getElementById("txtField").focus();
}
//GRID FILTER STARTS (JS)
function ShowFilter(me, gridName, colIndex) {
    var grid = document.getElementById(gridName + "_body");
    var colHeading = grid.rows[0].cells[colIndex].childNodes[0].firstChild.data;
    if (colHeading == undefined)
        colHeading = grid.rows[0].cells[colIndex].childNodes[0].firstChild.firstChild.data;

    var pos = FindPos(me);
    ShowFilterDiv(colHeading, gridName, colIndex, pos[0], pos[1]);
}

//List Grid Filter
function ShowFilterForListGrid(me, gridName, colIndex, colHeading) {
    var pos = FindPos(me);
    ShowFilterDiv(colHeading, gridName, colIndex, pos[0], pos[1]);
}
function ShowFilterDiv(caption, gridName, colIndex, left, top) {
    var filterObj = document.getElementById("filterBox");
    var filterValue = (filterObj != null && filterObj != undefined ? filterObj.value : "");

    RemoveFilterDiv();

    var newdiv = document.createElement('div');
    newdiv.setAttribute('id', "filterByColumn");

    newdiv.style.position = "absolute";

    newdiv.style.left = left + "px";
    newdiv.style.top = top + "px";

    newdiv.style.background = "#00CC00";
    newdiv.style.border = "1px solid black";
    var html = "<div style = \"width:155px;\">" +
        "<div style =\"float:left;font-family: verdana;margin:2px\"><b>" + caption + "</b></div>" +
        "<div style =\"float:right\">" +
        "<span title = \"Close\" style = \"cursor:pointer;margin:2px\" onclick = \"RemoveFilterDiv();\"><b>x</b></span>" +
        "</div>" +
        "<div style=\"clear:both\">" +
        "<input type=\"text\" id = \"filterBox\"  style = \"width:149px;\"" +
        "value = \"" + filterValue + "\"" +
        "onKeyDown=\"FilterGrid(event,'" + gridName + "'," + colIndex + ", this);\" " +
        "onKeyUp=\"FilterGrid(event,'" + gridName + "'," + colIndex + ", this);\" >" +
        "</div>" +
        "</div>";

    newdiv.innerHTML = html;
    document.body.appendChild(newdiv);
    document.getElementById("filterBox").focus();
}

function RemoveFilterDiv() {
    var olddiv = document.getElementById("filterByColumn");
    if (olddiv)
        document.body.removeChild(olddiv);
}

function FilterGrid(event, gridName, columnIndex, me) {
    try {
        var keyCode = (event.which) ? event.which : event.keyCode;

        if (keyCode == 27) {
            Filter("", gridName, columnIndex);
            RemoveFilterDiv();
            return;
        }

        Filter(me.value, gridName, columnIndex);
    }
    catch (ex) {
        //do nothing
    }
}

function Filter(filterText, gridName, columnIndex) {
    var grid = document.getElementById(gridName + "_body");
    var rows = grid.rows.length;
    for (var row = 1; row < rows; row++) {
        var value = "";
        try {
            value = grid.rows[row].cells[columnIndex].innerHTML;
        }
        catch (ex) {
            //do nothing
        }

        if (value.toUpperCase().indexOf(filterText.toUpperCase()) > -1) {
            grid.rows[row].style.display = "";
        }
        else {
            grid.rows[row].style.display = "none";
        }
    }
}

function FindPos(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
        curleft = obj.offsetLeft
        curtop = obj.offsetTop
        while (obj = obj.offsetParent) {
            curleft += obj.offsetLeft
            curtop += obj.offsetTop
        }
    }
    return [curleft, curtop];
}

//GRID FILTER ENDS