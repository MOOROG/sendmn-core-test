function ShowAgentFxCol() {
    var cookiename = "showhideagentfxcol";
    $('#rateTable th:nth-col(17),#rateTable th:nth-col(18), #rateTable td:nth-col(17), #rateTable td:nth-col(18)').show();
    GetElement("agentfxh").style.display = "block";
    GetElement("agentfxs").style.display = "none";
    setCookie(cookiename, "show", 365);
}

function HideAgentFxCol() {
    var cookiename = "showhideagentfxcol";
    $('#rateTable th:nth-col(17),#rateTable th:nth-col(18), #rateTable td:nth-col(17), #rateTable td:nth-col(18)').hide();
    GetElement("agentfxh").style.display = "none";
    GetElement("agentfxs").style.display = "block";
    setCookie(cookiename, "hide", 365);
}

function ShowToleranceCol() {
    var cookiename = "showhidetolerancecol";
    $('#rateTable th:nth-col(19),#rateTable th:nth-col(20),#rateTable th:nth-col(21), #rateTable td:nth-col(19), #rateTable td:nth-col(20), #rateTable td:nth-col(21)').show();
    GetElement("toleranceh").style.display = "block";
    GetElement("tolerances").style.display = "none";
    setCookie(cookiename, "show", 365);
}

function HideToleranceCol() {
    var cookiename = "showhidetolerancecol";
    $('#rateTable th:nth-col(19),#rateTable th:nth-col(20),#rateTable th:nth-col(21), #rateTable td:nth-col(19), #rateTable td:nth-col(20), #rateTable td:nth-col(21)').hide();
    GetElement("toleranceh").style.display = "none";
    GetElement("tolerances").style.display = "block";
    setCookie(cookiename, "hide", 365);
}

function ShowSendingAgentCol() {
    var cookiename = "showhidesendingagentcol";
    $('#rateTable th:nth-col(22),#rateTable th:nth-col(23),#rateTable th:nth-col(24),#rateTable th:nth-col(25),#rateTable th:nth-col(26),#rateTable th:nth-col(27), #rateTable td:nth-col(22), #rateTable td:nth-col(23), #rateTable td:nth-col(24), #rateTable td:nth-col(25), #rateTable td:nth-col(26), #rateTable td:nth-col(27)').show();
    GetElement("sendingagenth").style.display = "block";
    GetElement("sendingagents").style.display = "none";
    setCookie(cookiename, "show", 365);
}

function HideSendingAgentCol() {
    var cookiename = "showhidesendingagentcol";
    $('#rateTable th:nth-col(22),#rateTable th:nth-col(23),#rateTable th:nth-col(24),#rateTable th:nth-col(25),#rateTable th:nth-col(26),#rateTable th:nth-col(27), #rateTable td:nth-col(22), #rateTable td:nth-col(23), #rateTable td:nth-col(24), #rateTable td:nth-col(25), #rateTable td:nth-col(26), #rateTable td:nth-col(27)').hide();
    GetElement("sendingagenth").style.display = "none";
    GetElement("sendingagents").style.display = "block";
    setCookie(cookiename, "hide", 365);
}

function ShowCustomerTolCol() {
    var cookiename = "showhidecustomertolcol";
    $('#rateTable th:nth-col(28),#rateTable th:nth-col(29), #rateTable td:nth-col(28), #rateTable td:nth-col(29)').show();
    GetElement("customertolh").style.display = "block";
    GetElement("customertols").style.display = "none";
    setCookie(cookiename, "show", 365);
}

function HideCustomerTolCol() {
    var cookiename = "showhidecustomertolcol";
    $('#rateTable th:nth-col(28),#rateTable th:nth-col(29), #rateTable td:nth-col(28), #rateTable td:nth-col(29)').hide();
    GetElement("customertolh").style.display = "none";
    GetElement("customertols").style.display = "block";
    setCookie(cookiename, "hide", 365);
}

function ShowHideUpdateCol() {
    var j = 0;
    var cBoxes = document.getElementsByName("chkId");

    for (var i = 0; i < cBoxes.length; i++) {
        j++;
    }
    if (j > 0)
        $('#rateTable th:nth-col(37), #rateTable td:nth-col(37)').show();
    else
        $('#rateTable th:nth-col(37), #rateTable td:nth-col(37)').hide();
}

function ShowAllColumns() {
    ShowAgentFxCol();
    ShowToleranceCol();
    ShowSendingAgentCol();
    ShowCustomerTolCol();
}

function ShowOnlyForRSP() {
    HideAgentFxCol();
    HideToleranceCol();
    HideSendingAgentCol();
    HideCustomerTolCol();
}

function ShowOnlyForIRH() {
}

function CalcCOffers(obj, id, cRateMaskMulBd, cRateMaskMulAd, crossRateMaskAd) {
    checkRateMasking(obj, cRateMaskMulBd, cRateMaskMulAd);
    var objid = obj.id;
    var currentValue = GetValue(objid + "_current");
    var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
    var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
    var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
    var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
    var maxCrossRate = GetValue("maxCrossRate_" + id) == "" ? 0 : parseFloat(GetValue("maxCrossRate_" + id));

    var toleranceOn = GetValue("toleranceOn_" + id);
    var agentCrossRateMargin = GetValue("agentCrossRateMargin_" + id) == "" ? 0 : parseFloat(GetValue("agentCrossRateMargin_" + id));

    var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
    var cMargin = GetElement("cMargin_" + id).innerHTML == "" ? 0 : parseFloat(GetElement("cMargin_" + id).innerHTML);
    var cHoMargin = GetValue("cHoMargin_" + id) == "" ? 0 : parseFloat(GetValue("cHoMargin_" + id));
    var cAgentMargin = GetValue("cAgentMargin_" + id) == "" ? 0 : parseFloat(GetValue("cAgentMargin_" + id));
    var cOffer = cRate + cMargin + cHoMargin;
    var cCustomerOffer = cRate + cMargin + cHoMargin + cAgentMargin;

    if (checkRateCapping(obj, currentValue, cMin, cMax, cOffer) == 1)
        return false;
    if (checkRateCapping(obj, currentValue, cMin, cMax, cCustomerOffer) == 1)
        return false;

    var pOffer = GetElement("pOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("pOffer_" + id, "").innerHTML);
    var pCustomerOffer = GetElement("pCustomerOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("pCustomerOffer_" + id, "").innerHTML);
    var crossRate = pOffer / cOffer;
    crossRate = roundNumber(crossRate, crossRateMaskAd);
    var customerRate = pCustomerOffer / cCustomerOffer;
    customerRate = roundNumber(customerRate, crossRateMaskAd);

    cOffer = roundNumber(cOffer, cRateMaskMulAd);
    cCustomerOffer = roundNumber(cCustomerOffer, cRateMaskMulAd);

    if (toleranceOn == "C") {
        customerRate = crossRate - agentCrossRateMargin;
        customerRate = roundNumber(customerRate, 10);
    }

    SetValueById("crossRate_" + id, crossRate, "");
    SetValueById("customerRate_" + id, customerRate, "");

    SetValueById("cOffer_" + id, "", cOffer);
    SetValueById("cAgentOffer_" + id, "", cOffer);
    SetValueById("cCustomerOffer_" + id, "", cCustomerOffer);

    return true;
}

function CalcPOffers(obj, id, cRateMaskMulBd, cRateMaskMulAd, pRateMaskMulBd, pRateMaskMulAd, crossRateMaskAd) {
    checkRateMasking(obj, pRateMaskMulBd, pRateMaskMulAd);
    var objid = obj.id;
    var currentValue = GetValue(objid + "_current");
    var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
    var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
    var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
    var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
    var maxCrossRate = GetValue("maxCrossRate_" + id) == "" ? 0 : parseFloat(GetValue("maxCrossRate_" + id));

    var toleranceOn = GetValue("toleranceOn_" + id);
    var agentCrossRateMargin = GetValue("agentCrossRateMargin_" + id) == "" ? 0 : parseFloat(GetValue("agentCrossRateMargin_" + id));

    var pRate = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
    var pMargin = GetElement("pMargin_" + id).innerHTML == "" ? 0 : parseFloat(GetElement("pMargin_" + id).innerHTML);
    var pHoMargin = GetValue("pHoMargin_" + id) == "" ? 0 : parseFloat(GetValue("pHoMargin_" + id));
    var pAgentMargin = GetValue("pAgentMargin_" + id) == "" ? 0 : parseFloat(GetValue("pAgentMargin_" + id));
    var pOffer = pRate - pMargin - pHoMargin;
    var pCustomerOffer = pRate - pMargin - pHoMargin - pAgentMargin;

    if (checkRateCapping(obj, currentValue, pMin, pMax, pOffer) == 1)
        return false;
    if (checkRateCapping(obj, currentValue, pMin, pMax, pCustomerOffer) == 1)
        return false;

    var cOffer = GetElement("cOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("cOffer_" + id, "").innerHTML);
    var cCustomerOffer = GetElement("cCustomerOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("cCustomerOffer_" + id, "").innerHTML);
    var crossRate = pOffer / cOffer;
    crossRate = roundNumber(crossRate, crossRateMaskAd);
    var customerRate = pCustomerOffer / cCustomerOffer;
    crossRate = roundNumber(crossRate, crossRateMaskAd);
    customerRate = roundNumber(customerRate, crossRateMaskAd);

    pOffer = roundNumber(pOffer, pRateMaskMulAd);
    pCustomerOffer = roundNumber(pCustomerOffer, pRateMaskMulAd);

    if (toleranceOn == "C") {
        customerRate = crossRate - agentCrossRateMargin;
        customerRate = roundNumber(customerRate, 10);
    }

    SetValueById("crossRate_" + id, crossRate, "");
    SetValueById("customerRate_" + id, customerRate, "");

    SetValueById("pOffer_" + id, "", pOffer);
    SetValueById("pAgentOffer_" + id, "", pOffer);
    SetValueById("pCustomerOffer_" + id, "", pCustomerOffer);

    return true;
}

function OnBlurCrossMargin(obj, id) {
    var agentTolMin = GetValue("agentTolMin_" + id) == "" ? 0 : parseFloat(GetValue("agentTolMin_" + id));
    var agentTolMax = GetValue("agentTolMax_" + id) == "" ? 0 : parseFloat(GetValue("agentTolMax_" + id));
    var toleranceOn = GetValue("toleranceOn_" + id);
    var crossRate = GetValue("crossRate_" + id) == "" ? 0 : parseFloat(GetValue("crossRate_" + id));
    var agentCrossRateMargin = GetValue("agentCrossRateMargin_" + id) == "" ? 0 : parseFloat(GetValue("agentCrossRateMargin_" + id));
    if (toleranceOn == "C") {
        if (agentCrossRateMargin > agentTolMin) {
            alert("Invalid cross rate margin setup. Margin is allowed only upto " + agentTolMin);
            setTimeout(function () { obj.focus(); }, 1);
            return false;
        }
        else if (agentCrossRateMargin < (agentTolMax * -1)) {
            alert("Invalid cross rate margin setup. Margin is allowed only upto " + (agentTolMax * -1));
            setTimeout(function () { obj.focus(); }, 1);
            return false;
        }
        var customerRate = crossRate - agentCrossRateMargin;
        customerRate = roundNumber(customerRate, 10);
        SetValueById("customerRate_" + id, customerRate, "");
    }
    return true;
}

function Calc(id, obj, cRateMaskMulBd, cRateMaskMulAd) {
    //                checkRateMasking(obj, cRateMaskMulBd, cRateMaskMulAd);
    var objid = obj.id;
    var currentValue = GetValue(objid + "_current");
    if (CheckNumberWithMsg(obj) == 1)
        return false;
    if (obj.value < 0) {
        alert("Tolerance cannot be less than zero");
        setTimeout(function () { obj.focus(); }, 1);
        obj.value = currentValue;
        return false;
    }
    var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
    var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
    var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
    var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
    var crossRate = GetValue("crossRate_" + id) == "" ? 0 : parseFloat(GetValue("crossRate_" + id));
    var maxCrossRate = GetValue("maxCrossRate_" + id) == "" ? 0 : parseFloat(GetValue("maxCrossRate_" + id));
    var tolerance = GetValue("tolerance_" + id) == "" ? 0 : parseFloat(GetValue("tolerance_" + id));
    var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
    var pRate = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
    var cost = pRate / (crossRate + tolerance);
    cost = roundNumber(cost, cRateMaskMulAd);
    if (checkRateCapping(obj, currentValue, cMin, cMax, cost) == 1)
        return false;

    return true;
}

function CalcNewRate(id, obj, cRateMaskMulBd, cRateMaskMulAd) {
    //                checkRateMasking(obj, cRateMaskMulBd, cRateMaskMulAd);
    var crossRate = GetValue("crossRateNew_" + id) == "" ? 0 : parseFloat(GetValue("crossRateNew_" + id));
    var maxCrossRate = GetValue("maxCrossRateNew_" + id) == "" ? 0 : parseFloat(GetValue("maxCrossRateNew_" + id));
    var tolerance = GetValue("tolerance_" + id) == "" ? 0 : parseFloat(GetValue("tolerance_" + id));
    var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
    var pRate = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
    var cost = pRate / (crossRate + tolerance);
}

function getRadioCheckedValue(radioName) {
    var oRadio = document.forms[0].elements[radioName];

    for (var i = 0; i < oRadio.length; i++) {
        if (oRadio[i].checked) {
            return oRadio[i].value;
        }
    }

    return '';
}

function CheckAll(obj) {
    var i = 0;
    var cBoxes = document.getElementsByName("chkId");
    var value;
    var arr;
    var id;
    var j;
    var countryCode;
    if (obj.innerHTML == '×') {
        obj.innerHTML = '√';
        for (i = 0; i < cBoxes.length; i++) {
            cBoxes[i].checked = false;
            value = cBoxes[i].id;
            arr = value.split('_');
            countryCode = arr[0];
            id = arr[1];
            j = GetValue(id);
            KeepRowSelection(j, id, countryCode);
        }
    }
    else {
        obj.innerHTML = '×';
        for (i = 0; i < cBoxes.length; i++) {
            cBoxes[i].checked = true;
            value = cBoxes[i].id;
            arr = value.split('_');
            countryCode = arr[0];
            id = arr[1];
            j = GetValue(id);
            KeepRowSelection(j, id, countryCode);
        }
    }
}

function KeepRowSelection(i, id, countryCode) {
    var obj = GetElement(countryCode + "_" + id);
    if (obj.checked == true) {
        GetElement("row_" + id).className = "selectedbg";
        ShowHideUpdateChangeFunction(obj, id);
    }
    else {
        if (i % 2 == 1)
            GetElement("row_" + id).className = "oddbg";
        else
            GetElement("row_" + id).className = "evenbg";
    }
    EnableDisableButton();
}

function CheckGroup(obj, countryCode) {
    var elements = document.getElementsByName("chkId");

    var parentLength = countryCode.length;
    for (var i = 0; i < elements.length; i++) {
        if (!elements[i].disabled) {
            var value = elements[i].id;
            if (value.substr(0, parentLength) == countryCode) {
                if (elements[i].checked == true) {
                    elements[i].checked = false;
                }
                else {
                    elements[i].checked = true;
                }
                var id = value.split('_')[1];
                var j = GetValue(id);
                KeepRowSelection(j, id, countryCode);
            }
        }
    }
}

/*---Floating Divs---*/

var currentId = "";
function CopyValue() {
    var j = 0;
    var value = GetValue("txtCopyValue", "") == "" ? 0 : GetValue("txtCopyValue", "");
    var me = GetElement("txtCopyValue");
    var errorCode = checkRateMasking(me, 6, 6);
    if (errorCode == 1)
        return false;
    var cBoxes = document.getElementsByName("chkId");

    for (var i = 0; i < cBoxes.length; i++) {
        var id = cBoxes[i].value;
        if (cBoxes[i].checked == true) {
            j++;
            var cRateMaskBd = GetValue("cRateMaskBd_" + id);
            var cRateMaskAd = GetValue("cRateMaskAd_" + id);
            var pRateMaskBd = GetValue("pRateMaskBd_" + id);
            var pRateMaskAd = GetValue("pRateMaskAd_" + id);
            var crossRateMaskAd = GetValue("crossRateMaskAd_" + id);

            //                alert(cRateMaskAd);
            var obj = GetElement(currentId + "_" + id);
            var rowVal = parseFloat(value);

            if (currentId == "cHoMargin" || currentId == "cAgentMargin") {
                rowVal = roundNumber(rowVal, cRateMaskAd);
                SetValueById(currentId + "_" + id, rowVal, "");
                CalcCOffers(obj, id, cRateMaskBd, cRateMaskAd, crossRateMaskAd);
            }
            else if (currentId == "pHoMargin" || currentId == "pAgentMargin") {
                rowVal = roundNumber(rowVal, pRateMaskAd);
                SetValueById(currentId + "_" + id, rowVal, "");
                CalcPOffers(obj, id, cRateMaskBd, cRateMaskAd, pRateMaskBd, pRateMaskAd, crossRateMaskAd);
            }
        }
    }
    if (j == 0) {
        alert('Please select record(s) to copy');
        return false;
    }
    return true;
}

var currentIdForUpdate = "";
var currentIdForUpdateChange = "";

function ShowHideUpdateFunction(me, id) {
    var pos = FindPos(me);
    var left = pos[0];
    var top = pos[1] + 5;
    GetElement("divUpdate_" + id).style.left = left + "px";
    GetElement("divUpdate_" + id).style.top = top + "px";
    {
        if (currentIdForUpdate == "") {
            GetElement("divUpdate_" + id).style.display = "block";
        }
        else {
            if (id == currentIdForUpdate) {
                GetElement("divUpdate_" + id).style.display = "block";
                //                $("#btnUpdate_" + id).slideToggle("fast");
            }
            else {
                GetElement("divUpdate_" + id).style.display = "block";
                GetElement("divUpdate_" + currentIdForUpdate).style.display = "none";
                //                $("#btnUpdate_" + id).slideToggle("fast");
            }
        }
    }
    currentIdForUpdate = id;
}

function ShowHideUpdateChangeFunction(me, id) {
    var pos = FindPos(me);
    var left = pos[0] + 20;
    var top = pos[1] + 5;
    GetElement("divFixed").style.left = left + "px";
    GetElement("divFixed").style.top = top + "px";
    //        GetElement("newDiv").style.border = "1px solid black";
    if (GetElement("divFixed").style.display == "none" || GetElement("divFixed").style.display == "") {
        GetElement("divFixed").style.display = "block";
    }
    else {
        if (id == currentIdForUpdateChange) {
            GetElement("divFixed").style.display = "block";
        }
        else {
            GetElement("divFixed").style.display = "block";
        }
    }
    currentIdForUpdateChange = id;
}

function ShowHideSwapMargin(me, id) {
    var pos = FindPos(me);
    var left = pos[0] - 12;
    var top = pos[1] + 20;
    GetElement("divSwapMargin").style.left = left + "px";
    GetElement("divSwapMargin").style.top = top + "px";
    //        GetElement("divSwapMargin").style.border = "1px solid black";
    if (GetElement("divSwapMargin").style.display == "none" || GetElement("divSwapMargin").style.display == "") {
        $("#divSwapMargin").slideToggle("fast");
    }
    else {
        if (id == currentId) {
            $("#divSwapMargin").slideToggle("fast");
        }
        else {
            GetElement("divSwapMargin").style.display = "none";
            $("#divSwapMargin").slideToggle("fast");
        }
    }
    currentId = id;
}

function ShowHideCopyFunction(me, id) {
    //        var pos = FindPos(GetElement("showSlab_" + id));
    var pos = FindPos(me);
    var left = pos[0] - 12;
    var top = pos[1] + 20;
    GetElement("newDiv").style.left = left + "px";
    GetElement("newDiv").style.top = top + "px";
    //        GetElement("newDiv").style.border = "1px solid black";
    if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "") {
        $("#newDiv").slideToggle("fast");
        GetElement("txtCopyValue").focus();
        SetValueById("txtCopyValue", "", "");
    }
    else {
        if (id == currentId) {
            $("#newDiv").slideToggle("fast");
        }
        else {
            GetElement("newDiv").style.display = "none";
            $("#newDiv").slideToggle("fast");
            GetElement("txtCopyValue").focus();
            SetValueById("txtCopyValue", "", "");
        }
    }
    currentId = id;
}
function RemoveDiv() {
    $("#newDiv").slideToggle("fast");
}
function RemoveDivSwapMargin() {
    $("#divSwapMargin").slideToggle("fast");
}
function RemoveDivUpdate(id) {
    $("#divUpdate_" + id).slideToggle("fast");
}
function RemoveDivFixed() {
    $("#divFixed").slideToggle("fast");
}