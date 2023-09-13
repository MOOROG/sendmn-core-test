<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.AgentRateSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />

    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }

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
            overflow: auto;
        }
    </style>
    <script language="javascript" type="text/javascript">
        var errorImage = "../../../images/exclamation.png";
        function DeleteRow(id) {
            if (confirm("Sure to delete the selected row?")) {
            }
        }
        function ManageFactor(id) {
            var factor = getRadioCheckedValue("factor_" + id);
            CalcCollectionOffer(id, factor);
            CalcPaymentOffer(id, factor);
        }

        function ShowTreasuryRate(id, type) {
            window.location.href = "ExRateTreasury.aspx?defExRateId=" + id + "&rateType=" + type;
        }

        function checkRateCappingByMargin(obj, cost, currentMargin, rateType, min, max, value, id, errorImg) {
            if (isNaN(obj.value)) {
                alert("Please, Enter valid number !");
                setTimeout(function () { obj.focus(); }, 1);
                return 1;
            }
            value = roundNumber(value, 6);
            var currentValue = 0;
            if (rateType == "C")
                currentValue = cost + currentMargin;
            else if (rateType == "P") {
                currentValue = cost - currentMargin;
            }

            var msg = "";
            GetElement("status_" + id).innerHTML = "";
            EnableDisableBtn("btnUpdate_" + id, false);
            if (value > max) {
                msg = "Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max;
                alert(msg);
                obj.value = currentMargin;
                if (currentValue > max) {
                    GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\" />";
                    EnableDisableBtn("btnUpdate_" + id, true);
                }
                else if (currentValue < min) {
                    GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\" />";
                    EnableDisableBtn("btnUpdate_" + id, true);
                }
                else
                    setTimeout(function () { obj.focus(); }, 1);
                return 1;
            }
            if (value < min) {
                msg = "Calculated value = " + value + "\n\nRate must lie between " + min + " and " + max;
                alert(msg);
                obj.value = currentMargin;
                if (currentValue > max) {
                    GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\" />";
                    EnableDisableBtn("btnUpdate_" + id, true);
                }
                else if (currentValue < min) {
                    GetElement("status_" + id).innerHTML = "<img src=\"" + errorImg + "\" border=\"0\" onclick=\"alert('" + msg + "');\" />";
                    EnableDisableBtn("btnUpdate_" + id, true);
                }
                else
                    setTimeout(function () { obj.focus(); }, 1);
                return 1;
            }
            return 0;
        }

        function CalcOnCMarginChange(id, obj, mulBD, mulAD, divBD, divAD) {
            var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
            var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
            var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
            var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
            var factor = getRadioCheckedValue("factor_" + id);
            if (factor == "M") {
                if (checkRateMasking(obj, mulBD, mulAD) == 1)
                    return false;
            }

            if (factor == "D") {
                if (checkRateMasking(obj, divBD, divAD) == 1)
                    return false;
            }

            var cost = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
            var margin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));

            var currentValue = GetValue(obj.id + "_Cv") == "" ? 0 : parseFloat(GetValue(obj.id + "_Cv"));

            var offer;
            if (factor == "D") {
                offer = cost - margin;
                offer = roundNumber(offer, divAD);
            }
            else {
                offer = cost + margin;
                offer = roundNumber(offer, mulAD);
            }
            if (checkRateCapping(obj, currentValue, cMin, cMax, offer) == 1)
                return false;
            GetElement("cOffer_" + id).value = offer;
            return true;
        }

        function CalcCollectionOffer(id, obj, mulBD, mulAD, divBD, divAD) {
            var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
            var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
            var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
            var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
            var factor = getRadioCheckedValue("factor_" + id);
            if (factor == "M") {
                if (checkRateMasking(obj, mulBD, mulAD) == 1)
                    return false;
            }

            if (factor == "D") {
                if (checkRateMasking(obj, divBD, divAD) == 1)
                    return false;
            }

            var cost = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
            var margin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));

            var currentValue = GetValue(obj.id + "_Cv") == "" ? 0 : parseFloat(GetValue(obj.id + "_Cv"));

            var offer;
            if (factor == "D") {
                offer = cost - margin;
                offer = roundNumber(offer, divAD);
            }
            else {
                offer = cost + margin;
                offer = roundNumber(offer, mulAD);
            }
            if (obj.id == "cRate_" + id) {
                if (checkRateCapping2(obj, currentValue, cMin, cMax, offer, id, errorImage) == 1)
                    return false;
            }
            else if (obj.id == "cMargin_" + id) {
                if (checkRateCappingByMargin(obj, cost, currentValue, "C", cMin, cMax, offer, id, errorImage) == 1)
                    return false;
            }
            GetElement("cOffer_" + id).value = offer;
            return true;
        }
        function CalcPaymentOffer(id, obj, mulBD, mulAD, divBD, divAD) {

            var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
            var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
            var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
            var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
            var factor = getRadioCheckedValue("factor_" + id);
            if (factor == "M") {
                if (checkRateMasking(obj, mulBD, mulAD) == 1)
                    return false;
            }
            else if (factor == "D") {
                if (checkRateMasking(obj, divBD, divAD) == 1)
                    return false;
            }

            var cost = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
            var margin = GetValue("pMargin_" + id) == "" ? 0 : parseFloat(GetValue("pMargin_" + id));

            var currentValue = GetValue(obj.id + "_Cv") == "" ? 0 : parseFloat(GetValue(obj.id + "_Cv"));

            var offer;
            if (factor == "D") {
                offer = cost + margin;
                offer = roundNumber(offer, divAD);
            }
            else {
                offer = cost - margin;
                offer = roundNumber(offer, mulAD);
            }

            if (obj.id == "pRate_" + id) {
                if (checkRateCapping2(obj, currentValue, pMin, pMax, offer, id, errorImage) == 1)
                    return false;
            }
            else if (obj.id == "pMargin_" + id) {
                if (checkRateCappingByMargin(obj, cost, currentValue, "P", pMin, pMax, offer, id, errorImage) == 1)
                    return false;
            }
            GetElement("pOffer_" + id).value = offer;
            return true;
        }
        function UpdateRate(id) {
            var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
            var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
            var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
            var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
            var operationType = GetValue("operationType_" + id);

            var cCost = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
            var cMargin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));
            var cOffer = cCost + cMargin;
            cOffer = roundNumber(cOffer, 8);

            var pCost = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
            var pMargin = GetValue("pMargin_" + id) == "" ? 0 : parseFloat(GetValue("pMargin_" + id));
            var pOffer = pCost - pMargin;
            pOffer = roundNumber(pOffer, 8);

            if (operationType == "S" || operationType == "B") {
                if (cOffer < cMin) {
                    alert("Sending Offer Rate deceeds Min tolerance Rate. Rate must lie between " + cMin + " and " + cMax);
                    return;
                }
                else if (cOffer > cMax) {
                    alert("Sending Offer Rate exceeds Max tolerance Rate. Rate must lie between " + cMin + " and " + cMax);
                    return;
                }
            }

            if (operationType == "R" || operationType == "B") {
                if (pOffer < pMin) {
                    alert("Receiving Offer Rate deceeds Min tolerance Rate. Rate must lie between " + cMin + " and " + cMax);
                    return;
                }
                else if (pOffer > pMax) {
                    alert("Receiving Offer Rate exceeds Max tolerance Rate. Rate must lie between " + cMin + " and " + cMax);
                    return;
                }
            }

            if (confirm("Are you sure you want to update this record?")) {
                SetValueById("<%=defExRateId.ClientID %>", id, "");
                SetValueById("<%=factor.ClientID %>", getRadioCheckedValue("factor_" + id), "");
                SetValueById("<%=cRate.ClientID %>", GetValue("cRate_" + id), "");
                SetValueById("<%=cMargin.ClientID %>", GetValue("cMargin_" + id), "");
                SetValueById("<%=cMax.ClientID %>", GetValue("cMax_" + id), "");
                SetValueById("<%=cMin.ClientID %>", GetValue("cMin_" + id), "");
                SetValueById("<%=pRate.ClientID %>", GetValue("pRate_" + id), "");
                SetValueById("<%=pMargin.ClientID %>", GetValue("pMargin_" + id), "");
                SetValueById("<%=pMax.ClientID %>", GetValue("pMax_" + id), "");
                SetValueById("<%=pMin.ClientID %>", GetValue("pMin_" + id), "");
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
            document.getElementById("<%=currency.ClientID %>").value = "";
            document.getElementById("<%=country.ClientID %>").value = "";
            document.getElementById("<%=agent.ClientID %>").value = "";
            if (btn != null)
                btn.click();
        }

        function nav(page) {
            var hdd = document.getElementById("hdd_curr_page");
            if (hdd != null)
                hdd.value = page;

            submit_form();
        }

        function newTableToggle(idTD, idImg) {
            var td = document.getElementById(idTD);
            var img = document.getElementById(idImg);
            if (td != null && img != null) {
                var isHidden = td.style.display == "none" ? true : false;
                img.src = isHidden ? "../../../images/icon_hide.gif" : "../../../images/icon_show.gif";
                img.alt = isHidden ? "Hide" : "Show";
                td.style.display = isHidden ? "" : "none";
            }
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

        var oldId = 0;

        function KeepRowSelection(i, id, countryCode) {
            if (oldId != 0 && oldId != id) {
                var j = GetValue(oldId);
                if (j % 2 == 1)
                    GetElement("row_" + oldId).className = "oddbg";
                else
                    GetElement("row_" + oldId).className = "evenbg";
                EnableDisableBtn("btnUpdate_" + oldId, true);
            }
            GetElement("row_" + id).className = "selectedbg";
            EnableDisableBtn("btnUpdate_" + id, false);
            oldId = id;
        }
    </script>
    <style>
        .exTable tr td .inputBox {
            background-color: #fff;
            background-image: none;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
            color: #555;
            display: block;
            font-size: 14px;
            height: 25px;
            line-height: 1.42857;
            transition: border-color 0.15s ease-in-out 0s, box-shadow 0.15s ease-in-out 0s;
        }
    </style>
</head>

<body>
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
                            <li class="active"><a href="List.aspx">Cost Rate Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <div id="divTab" class="tabs" runat="server"></div>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Cost Rate Setup List
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td class="GridTextNormal"><b>Filtered results</b>&nbsp;&nbsp;&nbsp;
                                                               <a href="javascript:newTableToggle('td_Search', 'img_Search');">
                                                                   <img src="../../../images/icon_show.gif" border="0" alt="Show" id="img_Search"></a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="td_Search" style="display: none">
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td align="right" class="text_form" nowrap="nowrap">
                                                                <label>Currency : </label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="currency" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                            <td align="right" class="text_form" nowrap="nowrap">
                                                                <label>Country : </label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="country" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" class="text_form" nowrap="nowrap">
                                                                <label>Agent : </label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="agent" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                            <td>&nbsp;</td>
                                                            <td>&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" class="text_form">&nbsp;</td>
                                                            <td colspan="3">
                                                                <input type="button" value="Filter" class="btn btn-primary m-t-25" onclick="submit_form();" />
                                                                <input type="button" value="Clear Filter" class="btn btn-primary m-t-25" onclick="clearForm();" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        <div id="paginDiv" runat="server"></div>
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                        </div>
                                        <asp:Button ID="btnMarkInactive" runat="server" CssClass="btn btn-primary m-t-25" Text="Set Inactive" Visible="false"
                                            OnClick="btnMarkInactive_Click" />
                                        <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                        <asp:HiddenField ID="defExRateId" runat="server" />
                                        <asp:HiddenField ID="factor" runat="server" />
                                        <asp:HiddenField ID="cRate" runat="server" />
                                        <asp:HiddenField ID="cMargin" runat="server" />
                                        <asp:HiddenField ID="cMax" runat="server" />
                                        <asp:HiddenField ID="cMin" runat="server" />
                                        <asp:HiddenField ID="pRate" runat="server" />
                                        <asp:HiddenField ID="pMargin" runat="server" />
                                        <asp:HiddenField ID="pMax" runat="server" />
                                        <asp:HiddenField ID="pMin" runat="server" />
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
</html>