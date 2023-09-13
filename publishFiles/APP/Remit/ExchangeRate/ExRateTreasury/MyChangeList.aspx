<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyChangeList.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.MyChangeList" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        var p = 1;

        function EnableDisableButton() {
            var cBoxes = document.getElementsByName("chkId");

            var j = 0;
            for (var i = 0; i < cBoxes.length; i++) {
                if (cBoxes[i].checked == true) {
                    j++;
                }
            }
            if (j == 0) {
                EnableDisableBtn("<%=btnReject.ClientID %>", true);
            }
            else {
                EnableDisableBtn("<%=btnReject.ClientID %>", false);
            }
        }

        function LoadWindow() {
            EnableDisableButton();
        }

        function ShowAgentFxCol() {
            var cookiename = "showhideagentfxcol";
            $('.exTable th:nth-col(19),.exTable th:nth-col(20), .exTable td:nth-col(19), .exTable td:nth-col(20)').show();
            GetElement("agentfxh").style.display = "block";
            GetElement("agentfxs").style.display = "none";
            setCookie(cookiename, "show", 365);
        }

        function HideAgentFxCol() {
            var cookiename = "showhideagentfxcol";
            $('.exTable th:nth-col(19),.exTable th:nth-col(20), .exTable td:nth-col(19), .exTable td:nth-col(20)').hide();
            GetElement("agentfxh").style.display = "none";
            GetElement("agentfxs").style.display = "block";
            setCookie(cookiename, "hide", 365);
        }

        function ShowToleranceCol() {
            var cookiename = "showhidetolerancecol";
            $('.exTable th:nth-col(21),.exTable th:nth-col(22),.exTable th:nth-col(23), .exTable td:nth-col(21), .exTable td:nth-col(22), .exTable td:nth-col(23)').show();
            GetElement("toleranceh").style.display = "block";
            GetElement("tolerances").style.display = "none";
            setCookie(cookiename, "show", 365);
        }

        function HideToleranceCol() {
            var cookiename = "showhidetolerancecol";
            $('.exTable th:nth-col(21),.exTable th:nth-col(22),.exTable th:nth-col(23), .exTable td:nth-col(21), .exTable td:nth-col(22), .exTable td:nth-col(23)').hide();
            GetElement("toleranceh").style.display = "none";
            GetElement("tolerances").style.display = "block";
            setCookie(cookiename, "hide", 365);
        }

        function ShowSendingAgentCol() {
            var cookiename = "showhidesendingagentcol";
            $('.exTable th:nth-col(24),.exTable th:nth-col(25),.exTable th:nth-col(26),.exTable th:nth-col(27),.exTable th:nth-col(28),.exTable th:nth-col(29), .exTable td:nth-col(24), .exTable td:nth-col(25), .exTable td:nth-col(26), .exTable td:nth-col(27), .exTable td:nth-col(28), .exTable td:nth-col(29)').show();
            GetElement("sendingagenth").style.display = "block";
            GetElement("sendingagents").style.display = "none";
            setCookie(cookiename, "show", 365);
        }

        function HideSendingAgentCol() {
            var cookiename = "showhidesendingagentcol";
            $('.exTable th:nth-col(24),.exTable th:nth-col(25),.exTable th:nth-col(26),.exTable th:nth-col(27),.exTable th:nth-col(28),.exTable th:nth-col(29), .exTable td:nth-col(24), .exTable td:nth-col(25), .exTable td:nth-col(26), .exTable td:nth-col(27), .exTable td:nth-col(28), .exTable td:nth-col(29)').hide();
            GetElement("sendingagenth").style.display = "none";
            GetElement("sendingagents").style.display = "block";
            setCookie(cookiename, "hide", 365);
        }

        function ShowCustomerTolCol() {
            var cookiename = "showhidecustomertolcol";
            $('.exTable th:nth-col(30),.exTable th:nth-col(31), .exTable td:nth-col(30), .exTable td:nth-col(31)').show();
            GetElement("customertolh").style.display = "block";
            GetElement("customertols").style.display = "none";
            setCookie(cookiename, "show", 365);
        }

        function HideCustomerTolCol() {
            var cookiename = "showhidecustomertolcol";
            $('.exTable th:nth-col(30),.exTable th:nth-col(31), .exTable td:nth-col(30), .exTable td:nth-col(31)').hide();
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

            var cBoxes = document.getElementsByName("chkId");

            for (var i = 0; i < cBoxes.length; i++) {
                if (cBoxes[i].checked == true) {
                    cBoxes[i].checked = false;
                }
                else {
                    cBoxes[i].checked = true;
                }
            }
            EnableDisableButton();
        }
        function UncheckAll(obj) {
            var cBoxes = document.getElementsByName("chkId");

            for (var i = 0; i < cBoxes.length; i++) {
                cBoxes[i].checked = false;
            }
        }
        function submit_form() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
            if (btn != null)
                btn.click();
        }
        function clearForm() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
                document.getElementById("<%=cCountry.ClientID %>").value = "";
                document.getElementById("<%=cAgent.ClientID %>").value = "";
                document.getElementById("<%=cCurrency.ClientID %>").value = "";
                document.getElementById("<%=pCountry.ClientID %>").value = "";
                document.getElementById("<%=pAgent.ClientID %>").value = "";
                document.getElementById("<%=pCurrency.ClientID %>").value = "";
                document.getElementById("<%=tranType.ClientID %>").value = "";
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
    </script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
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
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
                            <li class="active"><a href="MyChangeList.aspx">Exchange Rate Treasury-My changes</a></li>
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
                                    <h4 class="panel-title">Exchange Rate Treasury-My changes List
                                    </h4>
                                </div>

                                <div class="panel-body">
                                    <div class="form-group">
                                        <span class="headingRate">Base Currency = [USD]</span>
                                        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td class="GridTextNormal"><span id="spnFilter"><b>Filtered results</b></span>&nbsp;&nbsp;&nbsp;
                                                                        <asp:ImageButton ID="btnFilterShowHide" runat="server" Style="border: 0;"
                                                                            ImageUrl="../../../images/icon_hide.gif" OnClick="btnFilterShowHide_Click" />&nbsp;&nbsp;&nbsp;
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="td_Search" runat="server" visible="true">
                                                            <table class="fieldsetcss" style="margin-left: 0px; width: 1134px;">
                                                                <tr>
                                                                    <td valign="top">
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <th></th>
                                                                                <th align="left">
                                                                                    <label>Send</label></th>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Country</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cCountry" runat="server" CssClass="form-control" Width="180px" AutoPostBack="true"
                                                                                        OnSelectedIndexChanged="cCountry_SelectedIndexChanged">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Agent</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cAgent" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Currency</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cCurrency" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td></td>
                                                                    <td valign="top">
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <th></th>
                                                                                <th align="left">
                                                                                    <label></label>
                                                                                    Receive</th>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Country</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control" Width="180px" AutoPostBack="true"
                                                                                        OnSelectedIndexChanged="pCountry_SelectedIndexChanged">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Agent</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Currency</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="pCurrency" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td>
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <td align="left">
                                                                                    <label>Tran Type</label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" Width="135px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td nowrap="nowrap">
                                                                                    <label>Order By</label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="countryOrderBy" runat="server" CssClass="form-control" Width="135px">
                                                                                        <asp:ListItem Value="sendingCountry">Sending Country</asp:ListItem>
                                                                                        <asp:ListItem Value="receivingCountry">Receiving Country</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="4">
                                                                        <input type="button" value="Search" class="btn btn-primary m-t-25" onclick="submit_form();">
                                                                        <input type="button" value="Clear Filter" class="btn btn-primary m-t-25" onclick="clearForm();">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                        <input type="button" id="btnShowAllColumns" value="Show All Columns" class="btn btn-primary m-t25" onclick="ShowAllColumns();" />
                                        <div id="paginDiv" runat="server"></div>
                                        <div id="rpt_grid" runat="server" enableviewstate="false">
                                        </div>

                                        <asp:Button runat="server" ID="btnReject" Text="Reject" CssClass="btn btn-primary m-t25"
                                            OnClick="btnReject_Click" />
                                        <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                            ConfirmText="Are you sure to reject selected record(s) ?" Enabled="True" TargetControlID="btnReject">
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