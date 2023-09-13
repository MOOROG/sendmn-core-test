<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.Reports.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
 
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>



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

        function ShowHeadOfficeCol() {
            var cookiename = "showhideheadofficecol";
            $('#rateTable th:nth-col(9),#rateTable th:nth-col(10),#rateTable th:nth-col(11),#rateTable th:nth-col(12),#rateTable th:nth-col(13),#rateTable th:nth-col(14),#rateTable th:nth-col(15),#rateTable th:nth-col(16), #rateTable td:nth-col(9), #rateTable td:nth-col(10), #rateTable td:nth-col(11), #rateTable td:nth-col(12), #rateTable td:nth-col(13), #rateTable td:nth-col(14), #rateTable td:nth-col(15), #rateTable td:nth-col(16)').show();
            GetElement("headofficeh").style.display = "block";
            GetElement("headoffices").style.display = "none";
            setCookie(cookiename, "show", 365);
        }

        function HideHeadOfficeCol() {
            var cookiename = "showhideheadofficecol";
            $('#rateTable th:nth-col(9),#rateTable th:nth-col(10),#rateTable th:nth-col(11),#rateTable th:nth-col(12),#rateTable th:nth-col(13),#rateTable th:nth-col(14),#rateTable th:nth-col(15),#rateTable th:nth-col(16), #rateTable td:nth-col(9), #rateTable td:nth-col(10), #rateTable td:nth-col(11), #rateTable td:nth-col(12), #rateTable td:nth-col(13), #rateTable td:nth-col(14), #rateTable td:nth-col(15), #rateTable td:nth-col(16)').hide();
            GetElement("headofficeh").style.display = "none";
            GetElement("headoffices").style.display = "block";
            setCookie(cookiename, "hide", 365);
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
            var cookieValue = getCookie("showhideheadofficecol");
            if (cookieValue == "show") {
                ShowHeadOfficeCol();
            }
            else {
                HideHeadOfficeCol();
            }
            cookieValue = getCookie("showhideagentfxcol");
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
            ShowHeadOfficeCol();
            ShowAgentFxCol();
            ShowToleranceCol();
            ShowSendingAgentCol();
            ShowCustomerTolCol();
        }

        function ShowOnlyForRSP() {
            HideHeadOfficeCol();
            HideAgentFxCol();
            HideToleranceCol();
            HideSendingAgentCol();
            HideCustomerTolCol();
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
        }
    </script>

    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }

        .borderless td, .borderless th {
            border: none !important;
        }
        /*.table>tbody>tr>td, .table>tbody>tr>th, .table>tfoot>tr>td, .table>tfoot>tr>th, .table>thead>tr>td, .table>thead>tr>th{
            border-top:none !important;
        }*/
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
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('exchange_rate')">Exchange Rate </a></li>
                            <li class="active"><a href="List.aspx">Reports</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Exchange Rate Treasury
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upnl1" runat="server">
                                <ContentTemplate>

                                    <table class="table table-responsive borderless">
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
                                                            <asp:DropDownList ID="cAgent" runat="server" CssClass="form-control" Width="180px" AutoPostBack="true"
                                                                OnSelectedIndexChanged="cAgent_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Branch</label></td>
                                                        <td>
                                                            <asp:DropDownList ID="cBranch" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
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
                                            <td>&nbsp;</td>
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
                                                        <td></td>
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
                                                        <td align="left" nowrap="nowrap">
                                                            <label>Tran Type</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" Width="135px"></asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="left">
                                                            <label>Order By</label></td>
                                                        <td>
                                                            <asp:DropDownList ID="countryOrderBy" runat="server" CssClass="form-control" Width="135px">
                                                                <asp:ListItem Value="cCountryName">Sending Country</asp:ListItem>
                                                                <asp:ListItem Value="pCountryName">Receiving Country</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" colspan="2">
                                                            <asp:CheckBox ID="showInactive" runat="server" Text="Show Inactive records"></asp:CheckBox>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="200" colspan="2">
                                                <input type="button" value="Filter" class="btn btn-primary m-t-25" onclick="submit_form();">
                                                <input type="button" value="Clear Filter" class="btn btn-primary m-t-25" onclick="clearForm();">
                                            </td>
                                        </tr>
                                    </table>

                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <table class="table table-responsive">
                                    <tr>
                                        <td valign="top">
                                            <input type="button" id="btnShowAllColumns" value="Show All Columns" class="btn btn-primary m-t-25" onclick="ShowAllColumns();" />
                                            <div id="paginDiv" runat="server"></div>
                                            <div id="rpt_grid" runat="server" enableviewstate="false">
                                            </div>
                                            <asp:HiddenField ID="hdnIsFw" runat="server" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
