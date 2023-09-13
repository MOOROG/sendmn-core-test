<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExRateTreasury.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.AgentRateSetup.ExRateTreasury" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script language="javascript" type="text/javascript">
        var p = 1;
        function LoadWindow() {
            var isFw = GetValue("<%=hdnIsFw.ClientID %>");
            if (isFw == "1") {
                GetElement("lnkManageWindow").innerHTML = "";
            }
            else {
                GetElement("lnkManageWindow").innerHTML = "Show In Full Window";
            }
            CheckForApplyFilter();
            EnableDisableButton();
        }

        function EnableDisableButton() {
            var cBoxes = document.getElementsByName("chkId");

            var j = 0;
            for (var i = 0; i < cBoxes.length; i++) {
                if (cBoxes[i].checked == true) {
                    j++;
                }
            }
            if (j == 0) {
                EnableButtons();
            }
            else {
                DisableButtons();
            }
        }

        function DisableButtons() {
            EnableDisableBtn("<%=btnMarkActive.ClientID %>", false);
            EnableDisableBtn("<%=btnMarkInactive.ClientID %>", false);
            EnableDisableBtn("<%=btnUpdateChanges.ClientID %>", false);
        }

        function EnableButtons() {
            EnableDisableBtn("<%=btnMarkActive.ClientID %>", true);
                EnableDisableBtn("<%=btnMarkInactive.ClientID %>", true);
                EnableDisableBtn("<%=btnUpdateChanges.ClientID %>", true);
            }

            function CheckForApplyFilter() {
                var isUpdated = document.getElementById("<%=isUpdated.ClientID %>").value;
                if (cCountry != "" || cAgent != "" || cCurrency != "" || pCountry != "" || pAgent != "" || pCurrency != "" || tranType != "" || isUpdated != "" || ishaschanged != "" || showInactiveRecords == true) {
                    GetElement("spnFilter").setAttribute('style', 'background-color: yellow !important;');
                }
                else {
                    GetElement("spnFilter").setAttribute('style', 'background-color: none !important;');
                }
            }

            function ManageWindow() {
                var isFw = GetValue("<%=hdnIsFw.ClientID %>");
                if (isFw == "1") {
                    window.close();
                }
                else {
                    var param = "dialogHeight:1400px;dialogWidth:1400px;dialogLeft:0;dialogTop:0;center:yes";
                    PopUpWindow("List.aspx?isFw=1", param);
                }
            }

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

            function ShowHideDetail() {
                var cookieValue = getCookie("showhideagentfxcol");
                if (cookieValue == "show") {
                    ShowAgentFxCol();
                }
                else {
                    HideAgentFxCol();
                }
                cookieValue = getCookie("showhidetolerancecol");
                if (cookieValue == "show") {
                    ShowToleranceCol();
                }
                else {
                    HideToleranceCol();
                }
                cookieValue = getCookie("showhidesendingagentcol");
                if (cookieValue == "show") {
                    ShowSendingAgentCol();
                }
                else {
                    HideSendingAgentCol();
                }

                cookieValue = getCookie("showhidecustomertolcol");
                if (cookieValue == "show") {
                    ShowCustomerTolCol();
                }
                else {
                    HideCustomerTolCol();
                }
                //                ShowHideUpdateCol();
                if (GetValue("<%=countryOrderBy.ClientID %>") == "sendingCountry")
                    $('#rateTable th:nth-col(2), #rateTable td:nth-col(2)').hide();
                else
                    $('#rateTable th:nth-col(4), #rateTable td:nth-col(4)').hide();
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

            function UpdateCheckedRecords() {
                if (confirm("Are you sure to update selected records?")) {
                    GetElement("<%=btnUpdateChanges.ClientID %>").click();
                }
            }

            function ManageFactor(id) {
                var factor = getRadioCheckedValue("factor_" + id);
                CalcCollectionOffer(id, factor);
                CalcPaymentOffer(id, factor);
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

                /*
                if (margin < 0) {
                GetElement("margin_" + id).setAttribute('style', 'color: red !important;');
                }
                else {
                GetElement("margin_" + id).setAttribute('style', 'color: green !important;');
                }
                */

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
                /*
                if (margin < 0) {
                GetElement("margin_" + id).setAttribute('style', 'color: red !important;');
                }
                else {
                GetElement("margin_" + id).setAttribute('style', 'color: green !important;');
                }
                */

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
                /*
                if (margin < 0) {
                GetElement("margin_" + id).setAttribute('style', 'color: red !important;');
                }
                else {
                GetElement("margin_" + id).setAttribute('style', 'color: green !important;');
                }
                */
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
                cost = roundNumber(cost, cRateMaskMulAd);
            }

            function CalcCollectionOffer(id, obj, mulBD, mulAD, divBD, divAD) {
                var factor = getRadioCheckedValue("factor_" + id);
                if (factor == "M") {
                    checkRateMasking(obj, mulBD, mulAD);
                }
                if (factor == "D") {
                    checkRateMasking(obj, divBD, divAD);
                }

                var cost = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
                var margin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));
                var offer;
                if (factor == "D") {
                    offer = cost - margin;
                    offer = roundNumber(offer, divAD);
                }
                else {
                    offer = cost + margin;
                    offer = roundNumber(offer, mulAD);
                }
                GetElement("cOffer_" + id).value = offer;
            }
            function CalcPaymentOffer(id, obj, mulBD, mulAD, divBD, divAD) {
                var factor = getRadioCheckedValue("factor_" + id);

                if (factor == "M") {
                    checkRateMasking(obj, mulBD, mulAD);
                }

                if (factor == "D") {
                    checkRateMasking(obj, divBD, divAD);
                }

                var cost = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
                var margin = GetValue("pMargin_" + id) == "" ? 0 : parseFloat(GetValue("pMargin_" + id));
                var offer;
                if (factor == "D") {
                    offer = cost + margin;
                    offer = roundNumber(offer, divAD);
                }
                else {
                    offer = cost - margin;
                    offer = roundNumber(offer, mulAD);
                }
                GetElement("pOffer_" + id).value = offer;
            }

            function UpdateRate(id, isUpdated) {
                if (confirm("Are you sure to update this record?")) {
                    SetValueById("<%=exRateTreasuryId.ClientID %>", id, "");
                    SetValueById("<%=hddCHoMargin.ClientID %>", GetValue("cHoMargin_" + id), "");
                    SetValueById("<%=hddCAgentMargin.ClientID %>", GetValue("cAgentMargin_" + id), "");
                    SetValueById("<%=hddPHoMargin.ClientID %>", GetValue("pHoMargin_" + id), "");
                    SetValueById("<%=hddPAgentMargin.ClientID %>", GetValue("pAgentMargin_" + id), "");
                    SetValueById("<%=sharingType.ClientID %>", GetValue("sharingType_" + id), "");
                    SetValueById("<%=sharingValue.ClientID %>", GetValue("sharingValue_" + id), "");
                    SetValueById("<%=toleranceOn.ClientID %>", GetValue("toleranceOn_" + id), "");
                    SetValueById("<%=agentTolMin.ClientID %>", GetValue("agentTolMin_" + id), "");
                    SetValueById("<%=agentTolMax.ClientID %>", GetValue("agentTolMax_" + id), "");
                    SetValueById("<%=customerTolMin.ClientID %>", GetValue("customerTolMin_" + id), "");
                    SetValueById("<%=customerTolMax.ClientID %>", GetValue("customerTolMax_" + id), "");
                    SetValueById("<%=crossRate.ClientID %>", GetValue("crossRate_" + id), "");
                    SetValueById("<%=agentCrossRateMargin.ClientID %>", GetValue("agentCrossRateMargin_" + id), "");
                    SetValueById("<%=customerRate.ClientID %>", GetValue("customerRate_" + id), "");
                    SetValueById("<%=isUpdated.ClientID %>", isUpdated, "");
                    GetElement("<%=btnUpdate.ClientID %>").click();
                }
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
            function submit_form() {
                var btn = document.getElementById("<%=btnHidden.ClientID %>");
                if (btn != null)
                    btn.click();
            }
            function clearForm() {
                var btn = document.getElementById("<%=btnHidden.ClientID %>");
                document.getElementById("<%=isUpdated.ClientID %>").value = "";
                if (btn != null)
                    btn.click();
            }

            function nav(page) {
                var hdd = document.getElementById("hdd_curr_page");
                if (hdd != null)
                    hdd.value = page;

                submit_form();
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
    </script>

    <style type="text/css">
        .exTable tr td .inputBox {
            width: 45px;
        }

        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
            text-transform: capitalize;
        }

            .page-title h1 {
                color: #656565;
                font-size: 20px;
                text-transform: uppercase;
                font-weight: 400;
            }

            .page-title .breadcrumb {
                background-color: transparent;
                margin: 0;
                padding: 0;
            }

        .breadcrumb > li {
            display: inline-block;
        }

            .breadcrumb > li a {
                color: #0E96EC;
            }

            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }

        .tabs > li > a {
            padding: 10px 15px;
            background-color: #444d58;
            border-radius: 5px 5px 0 0;
            color: #fff;
        }

        .responsive-table {
            width: 1134px;
            overflow-x: scroll;
        }
    </style>
</head>

<body onload="LoadWindow()">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
                            <li class="active"><a href="ExRateTreasury.aspx">ExRate Treasury- Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <div id="divTab" runat="server"></div>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">ExRate Treasury- Manage
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td>
                                                <div class="form-inline">
                                                    <input type="button" id="btnShowAllColumns" class="btn btn-primary m-t-25" value="Show All Columns" onclick="ShowAllColumns();" />
                                                </div>
                                                <div class="form-inline">
                                                    Order By:
                                                   <asp:DropDownList ID="countryOrderBy" runat="server" Width="135px" CssClass="form-control">
                                                       <asp:ListItem Value="sendingCountry">Sending Country</asp:ListItem>
                                                       <asp:ListItem Value="receivingCountry">Receiving Country</asp:ListItem>
                                                   </asp:DropDownList>
                                                </div>
                                                <input type="button" value="Filter" class="btn btn-primary m-t-25" onclick="submit_form();">
                                                <div id="paginDiv" runat="server"></div>
                                                <div id="rpt_grid" runat="server" enableviewstate="false" class="responsive-table ">
                                                </div>
                                                <div id="divFixed" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none; border: none;">
                                                    <asp:Button ID="btnUpdateChanges" CssClass="btn btn-primary m-t-25" runat="server" Text="Update Selected Records"
                                                        OnClick="btnUpdateChanges_Click" />
                                                    <img src="../../../Images/close-icon.png" border="0" class="showHand" onclick="RemoveDivFixed();" title="Close" />
                                                    <cc1:ConfirmButtonExtender ID="btnUpdateChangescc" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnUpdateChanges">
                                                    </cc1:ConfirmButtonExtender>
                                                </div>
                                                <asp:Button ID="btnMarkActive" CssClass="btn btn-primary m-t-25" runat="server" Visible="false" Style="float: right;"
                                                    Text="Set Active" OnClick="btnMarkActive_Click" />&nbsp;
                                               <asp:Button ID="btnMarkInactive" runat="server" Visible="false" Style="float: right;"
                                                   Text="Set Inactive" OnClick="btnMarkInactive_Click" CssClass="btn btn-primary" />
                                                <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                                <asp:HiddenField ID="exRateTreasuryId" runat="server" />
                                                <asp:HiddenField ID="tolerance" runat="server" />
                                                <asp:HiddenField ID="hddCHoMargin" runat="server" />
                                                <asp:HiddenField ID="hddCAgentMargin" runat="server" />
                                                <asp:HiddenField ID="hddPHoMargin" runat="server" />
                                                <asp:HiddenField ID="hddPAgentMargin" runat="server" />
                                                <asp:HiddenField ID="sharingType" runat="server" />
                                                <asp:HiddenField ID="sharingValue" runat="server" />
                                                <asp:HiddenField ID="toleranceOn" runat="server" />
                                                <asp:HiddenField ID="agentTolMin" runat="server" />
                                                <asp:HiddenField ID="agentTolMax" runat="server" />
                                                <asp:HiddenField ID="customerTolMin" runat="server" />
                                                <asp:HiddenField ID="customerTolMax" runat="server" />
                                                <asp:HiddenField ID="crossRate" runat="server" />
                                                <asp:HiddenField ID="agentCrossRateMargin" runat="server" />
                                                <asp:HiddenField ID="customerRate" runat="server" />
                                                <asp:HiddenField ID="isUpdated" runat="server" />
                                                <asp:HiddenField ID="hdnIsFw" runat="server" />
                                            </td>
                                        </tr>
                                    </table>

                                    <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none; border: none;">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td colspan="2" nowrap="nowrap">
                                                    <input type="text" id="txtCopyValue" style="width: 75px; text-align: right; float: left;" />
                                                    <input type="button" id="btnCopyValue" class="btn btn-primary" value="Apply" onclick="CopyValue();" />
                                                    <img src="../../../Images/close-icon.png" border="0" class="showHand" onclick="RemoveDiv();" title="Close" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
<script type="text/javascript">
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
             }
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
         function RemoveDivUpdate(id) {
             $("#divUpdate_" + id).slideToggle("fast");
         }
         function RemoveDivFixed() {
             $("#divFixed").slideToggle("fast");
         }
</script>
</html>