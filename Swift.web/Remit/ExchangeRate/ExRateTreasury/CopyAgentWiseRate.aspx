<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CopyAgentWiseRate.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.CopyAgentWiseRate" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        var p = 1;

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
            if (obj.checked == true)
                GetElement("row_" + id).className = "selectedbg";
            else {
                if (i % 2 == 1)
                    GetElement("row_" + id).className = "oddbg";
                else
                    GetElement("row_" + id).className = "evenbg";
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
    </script>
    <style type="text/css">
        .table .table {
            background-color: #F5F5F5 !important;
        }

        legend {
            background-color: rgb(3, 169, 244);
            color: white;
            margin-bottom: 0 !important;
        }

        fieldset {
            padding: 10px !important;
            margin: 5px !important;
            border: 1px solid rgba(158, 158, 158, 0.21) !important;
        }

        input[readonly="readonly"] {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
            text-transform: capitalize;
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
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
                            <li class="active"><a href="CopyAgentWiseRate.aspx">Exchange Rate Treasury-Copy Rate</a></li>
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
                                    <h4 class="panel-title">Exchange Rate Treasury-Copy Rate
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td valign="top">
                                                            <fieldset>
                                                                <legend>Send</legend>
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <lable>Country</lable>
                                                                        </td>
                                                                        <td>
                                                                            <asp:DropDownList ID="cCountry" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                OnSelectedIndexChanged="cCountry_SelectedIndexChanged">
                                                                            </asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <label>Agent</label></td>
                                                                        <td>
                                                                            <asp:DropDownList ID="cAgent" runat="server" CssClass="form-control" Width="200px"></asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <label>Apply to</label></td>
                                                                        <td>
                                                                            <asp:DropDownList ID="applyToSendAgent" runat="server" CssClass="form-control" Width="200px"></asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </fieldset>
                                                        </td>
                                                        <td valign="top">
                                                            <fieldset>
                                                                <legend>Receive</legend>
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <label>Country</label></td>
                                                                        <td>
                                                                            <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                OnSelectedIndexChanged="pCountry_SelectedIndexChanged">
                                                                            </asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <label>Agent</label></td>
                                                                        <td>
                                                                            <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control" Width="200px"></asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td class="frmLable">
                                                                            <label>Apply to</label></td>
                                                                        <td>
                                                                            <asp:DropDownList ID="applyToReceiveAgent" runat="server" CssClass="form-control" Width="200px"></asp:DropDownList>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </fieldset>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-primary m-t-25"
                                                                ValidationGroup="cur" Display="Dynamic"
                                                                OnClick="btnFilter_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:PostBackTrigger ControlID="btnFilter" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </div>
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" enableviewstate="false"></div>
                                    </div>
                                    <asp:Button ID="btnCopy" runat="server" Text="Copy" CssClass="btn btn-primary m-t-25" Visible="false" OnClick="btnCopy_Click" />
                                    <cc1:ConfirmButtonExtender ID="btnCopycc" runat="server"
                                        ConfirmText="Are you sure to copy the selected record(s)?" Enabled="True" TargetControlID="btnCopy">
                                    </cc1:ConfirmButtonExtender>
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