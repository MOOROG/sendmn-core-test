<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Compliance.AMLReport.Manage" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/js/Swift_grid.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>

    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        var selectedTabId = "sbc";
        var mrTypeSelectedValue = "ssmt";
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =frmDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        $(document).ready(function () {
            LoadCalendars();
        });
    </script>

    <script type="text/javascript" language="javascript">
        function SCountryCallBack() {
            var d = ["", ""];
            <% = sBranch.InitFunction() %>
            SetItem("<% =sBranch.ClientID%>", d);
        }
        function RCountryCallBack() {
            var d = ["", ""];
            <% = rBranch.InitFunction() %>
            SetItem("<% =rBranch.ClientID%>", d);
        }

        function SAgentCallBack() {
            var d = ["", ""];
            <% = sBranch.InitFunction() %>
            SetItem("<% =sBranch.ClientID%>", d);
        }
        function RAgentCallBack() {
            var d = ["", ""];
            <% = rBranch.InitFunction() %>
            SetItem("<% =rBranch.ClientID%>", d);
        }

        function GetSenderCountryId() {
            return GetValue("<% =sCountry.ClientID%>");
        }

        function GetReceiverCountryId() {
            return GetValue("<% =rCountry.ClientID%>");
        }

        function GetSenderAgentId() {
            return GetValue("<% = sAgent.ClientID %>");
        }

        function GetReceiverAgentId() {
            return GetValue("<% = rAgent.ClientID %>");
        }

        function ShowReport() {
            debugger
            var checkSCountry = GetValue("<% = sCountry.ClientID %>");
            var checkRCountry = GetValue("<% = rCountry.ClientID %>");
            var sCountry = checkSCountry == "" || checkSCountry == undefined ? "" : GetElement("<% = sCountry.ClientID%>").options[GetElement("<% = sCountry.ClientID%>").selectedIndex].text;
            var rCountry = checkRCountry == "" || checkRCountry == undefined ? "" : GetElement("<% = rCountry.ClientID%>").options[GetElement("<% = rCountry.ClientID%>").selectedIndex].text;
            var sAgent = GetValue("<% = sAgent.ClientID %>");
            var rAgent = GetValue("<% = rAgent.ClientID %>");
            var dateType = GetValue("<% = dateType.ClientID%>");
            var rMode = GetValue("<% = rMode.ClientID%>");
            var frmDate = $('#frmDate').val();
            var toDate = $('#toDate').val();

            if (frmDate == "") {
                window.parent.SetMessageBox("Date FROM can not be empty.", "1");
                return false;
            }

            if (toDate == "") {
                window.parent.SetMessageBox("Date TO can not be empty.", "1");
                return false;
            }

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=amlreport&isAdmin=Y" +
                    "&sCountry=" + sCountry +
                    "&rCountry=" + rCountry +
                    "&sAgent=" + sAgent +
                    "&rAgent=" + rAgent +
                    "&rMode=" + rMode +
                    "&dateType=" + dateType +
                    "&frmDate=" + frmDate +
                    "&toDate=" + toDate +
                    "&flag=" + selectedTabId;

            if (selectedTabId == "sbc") {
                var searchBy = GetValue("<% = searchBy.ClientID%>");
                var saerchType = GetValue("<% = saerchType.ClientID%>");
                var searchValue = GetValue("<%=searchValue.ClientID %>");
                if (saerchType == "" || saerchType == "0") {
                    window.parent.SetMessageBox("Please enter valid ID Number.", "1");
                    return false;
                }
                if (searchValue.length == 0) {
                    window.parent.SetMessageBox("Search value is Mandatory.", "1");
                    return false;
                }
                url = url + "&searchBy=" + searchBy +
                        "&searchValue=" + searchValue +
                        "&saerchType=" + saerchType;

                OpenInNewWindow(url);
                return false;
            }

            else if (selectedTabId == "tc") {
                var rptBy = GetValue("<% = rptBy.ClientID%>");
                var rptFor = GetValue("<% = rptFor.ClientID%>");
                var tcNo = GetValue("<% = tcNo.ClientID%>");
                if (tcNo == "" || tcNo == "0") {
                    window.parent.SetMessageBox("Please Enter Valid Top Customer No.", "1");
                    return false;
                }

                url = url + "&rptBy=" + rptBy +
                        "&rptFor=" + rptFor +
                        "&tcNo=" + tcNo;

                OpenInNewWindow(url);
            }
            else if (selectedTabId == "cr") {
                var chkid = $("#form1 input:checked").attr("id");

                var fromAmt = GetValue("<% = fromAmt.ClientID%>");
                var toAmt = GetValue("<% = toAmt.ClientID%>");
                var orderBy = GetValue("<% = orderBy.ClientID%>");
                var isd = (GetElement("<% = isd.ClientID%>").checked ? "Y" : "N");
                if (fromAmt == "" || toAmt == "") {
                    window.parent.SetMessageBox("Please enter from amount & to amount.", "1");
                    return false;
                }
                var fromAmtNum = new Number(fromAmt);
                var toAmtNum = new Number(toAmt);
                if (fromAmtNum > toAmtNum) {
                    window.parent.SetMessageBox("Amount To Must Be Greater Or Equals to Amount From.", "1");
                    return false;
                }

                url = url + "&fromAmt=" + fromAmt +
                        "&toAmt=" + toAmt +
                        "&isd=" + isd +
                        "&amtType=" + chkid +
                        "&orderBy=" + orderBy;

                OpenInNewWindow(url);
            }
            else if (selectedTabId == "cd") {
                var fromAmt = GetValue("<% = fromAmtNew.ClientID%>");
                var toAmt = GetValue("<% = toAmtNew.ClientID%>");
                var orderBy = GetValue("<% = orderByNew.ClientID%>");
                var isd = (GetElement("<% = includeSenderDetails.ClientID%>").checked ? "Y" : "N");
                if (fromAmt == "" || toAmt == "") {
                    window.parent.SetMessageBox("Please enter from amount & to amount.", "1");
                    return false;
                }
                var fromAmtNum = new Number(fromAmt);
                var toAmtNum = new Number(toAmt);
                if (fromAmtNum > toAmtNum) {
                    window.parent.SetMessageBox("Amount To Must Be Greater Or Equals to Amount From.", "1");
                    return false;
                }

                url = url + "&fromAmt=" + fromAmt +
                        "&toAmt=" + toAmt +
                        "&isd=" + isd +
                        "&orderBy=" + orderBy;

                OpenInNewWindow(url);
            }
            else if (selectedTabId == "mr") {
                var mrType = mrTypeSelectedValue;
                url = url + "&mrType=" + mrType;
                OpenInNewWindow(url);
            }
            else if (selectedTabId == "oc") {
                var ocRptType = GetValue("<% = ocRptType.ClientID%>");
                var ocDateType = GetValue("<% = ocDateType.ClientID%>");
                url = url + "&ocDateType=" + ocDateType;
                url = url + "&ocRptType=" + ocRptType;
                OpenInNewWindow(url);
            }
}
    </script>

    <style>
        .formTable tr .frmLable {
            font: 12px Arial,Helvetica,sans-serif;
        }

        .ui-autocomplete-input {
            background-color: #E2EDFF !important;
        }

        .tabs {
            margin-bottom: 10px;
        }

        #sbcForm, #tcForm, #crForm, #mrForm, #ocForm {
            float: left;
            width: 100%;
            min-height: 140px;
        }

        .style1 {
            height: 29px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('compliance')">Compliance </a></li>
                            <li class="active"><a href="Manage.aspx">AML Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">AML Filter
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upd1" runat="server">
                                <ContentTemplate>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <div class="col-md-offset-6" style="font-size: 15px;">
                                                    <b>Sender</b>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Country:  </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Agent:  </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display: none;">
                                                <label class="control-label col-md-4">Branch:  </label>
                                                <div class="col-md-8">
                                                    <uc1:SwiftTextBox ID="sBranch" runat="server" Category="remit-branch" Param1="@GetSenderAgentId()" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Receiving Mode:  </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="rMode" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display: none">
                                                <label class="control-label col-md-4">Tran Type: 	</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="">All</asp:ListItem>
                                                        <%--  <asp:ListItem Value="D">Domestic</asp:ListItem>--%>
                                                        <asp:ListItem Value="I">International</asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <div class="col-md-offset-3" style="font-size: 15px;">
                                                    <b>Receiver</b>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="rCountry" runat="server" AutoPostBack="true"
                                                        CssClass="form-control" OnSelectedIndexChanged="rCountry_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display: none;">
                                                <div class="col-md-8">
                                                    <uc1:SwiftTextBox ID="rBranch" runat="server" Category="remit-branch" Param1="@GetReceiverAgentId()" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-10">
                                            <div class="form-group">
                                                <div class="col-md-4">
                                                    Date Type </br>
                                                 <asp:DropDownList runat="server" ID="dateType" CssClass="form-control">
                                                     <asp:ListItem Value="txnDate">TXN Date</asp:ListItem>
                                                     <asp:ListItem Value="confirmDate">Confirm Date</asp:ListItem>
                                                     <asp:ListItem Value="paidDate">Paid Date</asp:ListItem>
                                                 </asp:DropDownList>
                                                </div>
                                                <div class="col-md-4">
                                                    From<span class="errormsg">*</span></br>
                                                 <asp:TextBox ID="frmDate" runat="server" onchange="return DateValidation('frmDate','t','toDate')" MaxLength="10" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    To<span class="errormsg">*</span> </br>
                                                 <asp:TextBox ID="toDate" onchange="return DateValidation('frmDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>
            </div>

            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li id="sbcTab_li" class="active"><a href="#" id="sbcTab" onclick="LoadTab('sbc');" target="_self">Search By Customer</a></li>
                    <li id="tcTab_li"><a href="#" id="tcTab" onclick="LoadTab('tc');" target="_self">Top Customer</a></li>
                    <li id="crTab_li"><a href="#" id="crTab" onclick="LoadTab('cr');" target="_self">Customer Report</a></li>
                    <li id="mrTab_li"><a href="#" id="mrTab" onclick="LoadTab('mr');" target="_self">MIS Report</a></li>
                    <li id="ocTab_li"><a href="#" id="ocTab" onclick="LoadTab('oc');" target="_self">OFAC & Compliance</a></li>
                    <li id="cdTab_li"><a href="#" id="cdTab" onclick="LoadTab('cd');" target="_self">Customer Report Daily</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <div class="panel-body">
                                    <div class="row">
                                        <div id="sbcForm" style="display: block;">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Search By:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="searchBy_SelectedIndexChanged">
                                                            <asp:ListItem Value="">Select</asp:ListItem>
                                                            <asp:ListItem Value="sender">Sender</asp:ListItem>
                                                            <asp:ListItem Value="receiver">Receiver</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Search Type:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList runat="server" ID="saerchType" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Search Value:<span class="errormsg">*</span></label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="searchValue" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="tcForm" style="display: none;">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Report By:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="rptBy" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="amount">Amount</asp:ListItem>
                                                            <asp:ListItem Value="volume">Volume</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Report For:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="rptFor" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="sender">Sender</asp:ListItem>
                                                            <asp:ListItem Value="receiver">Receiver</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Top Customer No.:<span class="errormsg">*</span></label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="tcNo" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="crForm" style="display: none;">
                                            <div class="col-md-6">
                                                <div class="form-group" id="checkBoxes">
                                                    <label class="control-label col-md-4">Search By</label>
                                                    <div class="col-md-4">
                                                        <asp:CheckBox ID="chkBoxcAmt" Text="Collect Amount" runat="server" />
                                                    </div>
                                                    <div class="col-md-4">
                                                        <asp:CheckBox ID="chkBoxpAmt" Text="Payout Amount" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Amount To:</label>
                                                    <div class="col-md-4">
                                                        From </br>
                                                             <asp:TextBox ID="fromAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <div class="col-md-4">
                                                        To </br>
                                                              <asp:TextBox ID="toAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Order By:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="orderBy" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="cName">Customer Name</asp:ListItem>
                                                            <asp:ListItem Value="pAmt">Payout Amount</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4"></label>
                                                    <div class="col-md-8">
                                                        <asp:CheckBox ID="isd" Text="Include Sender Detail" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="mrForm" style="display: none;">
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label class="control-label col-md-2">Search By :</label>
                                                    <div class="col-md-8">
                                                        <input id="Radio1" type="radio" checked="checked" name="mrType" value="ssmt" onclick="SetMrTypeValue(this);" /><label for="Radio1">Same Sender Multiple TXN Summary</label>
                                                        <input id="Radio5" type="radio" name="mrType" value="ssmtd" onclick="SetMrTypeValue(this);" /><label for="Radio5">Same Sender Multiple TXN Detail</label>
                                                        <br />
                                                        <input id="Radio2" type="radio" name="mrType" value="sbmt" onclick="SetMrTypeValue(this);" /><label for="Radio2">Same Beneficiary Multiple TXN Summary</label>
                                                        <input id="Radio6" type="radio" name="mrType" value="sbmtd" onclick="SetMrTypeValue(this);" /><label for="Radio6">Same Beneficiary Multiple TXN Detail</label><br />
                                                        <div style="display: none;">
                                                            <input id="Radio3" type="radio" name="mrType" value="sssb" onclick="SetMrTypeValue(this);" /><label for="Radio3">Same Sender to Same Beneficiary Txns</label><br />
                                                        </div>
                                                        <input id="Radio4" type="radio" name="mrType" value="sncrc" onclick="SetMrTypeValue(this);" /><label for="Radio4">Do Not Have Same Sender Native Country & Receiver Country</label><br />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="ocForm" style="display: none;">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Date Type:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="ocDateType" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="1">TXN Date</asp:ListItem>
                                                            <asp:ListItem Value="2">Released Date</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Report Type:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="ocRptType" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="2">Black List</asp:ListItem>
                                                            <asp:ListItem Value="3">Compliance</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="cdForm" style="display: none;">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Amount To:</label>
                                                    <div class="col-md-4">
                                                        From </br>
                                                             <asp:TextBox ID="fromAmtNew" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <div class="col-md-4">
                                                        To </br>
                                                              <asp:TextBox ID="toAmtNew" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4">Order By:</label>
                                                    <div class="col-md-8">
                                                        <asp:DropDownList ID="orderByNew" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="cName">Customer Name</asp:ListItem>
                                                            <asp:ListItem Value="cAmt">Collect Amount</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-4"></label>
                                                    <div class="col-md-8">
                                                        <asp:CheckBox ID="includeSenderDetails" Text="Include Sender Detail" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="control-label col-md-4"></label>
                                                <div class="col-md-8">
                                                    <input type="button" value="Search" id="btn" class="btn btn-primary m-t-25" onclick="return ShowReport();" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <table class="table table-responsive">
                                        <tr style="display: none">
                                            <td class="frmLable">Currency:
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="sCurr" runat="server" Width="160px"></asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="rCurr" runat="server" Width="160px"></asp:DropDownList>
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
    </form>
</body>
</html>
<script type="text/javascript">
    $(document).ready(function () {
        $("#checkBoxes input:checkbox").click(function () {
            checkState = $(this).attr('checked');
            $('#checkBoxes input:checkbox').each(function () {
                $(this).attr('checked', false);
            });
            $(this).attr('checked', true);
        });
    });
</script>
<script language="javascript" type="text/javascript">
    function HideAllTab() {
        GetElement('sbcForm').style.display = "none";
        GetElement('tcForm').style.display = "none";
        GetElement('crForm').style.display = "none";
        GetElement('mrForm').style.display = "none";
        GetElement('ocForm').style.display = "none";
        GetElement('cdForm').style.display = "none";

        GetElement('sbcTab_li').className = "";
        GetElement('tcTab_li').className = "";
        GetElement('crTab_li').className = "";
        GetElement('mrTab_li').className = "";
        GetElement('ocTab_li').className = "";
        GetElement('cdTab_li').className = "";
    }

    function LoadTab(id) {
        selectedTabId = id;
        HideAllTab();
        GetElement(id + "Form").style.display = "block";
        GetElement(id + "Tab_li").className = "active";
    }

    function SetMrTypeValue(obj) {
        mrTypeSelectedValue = obj.value;
    }
</script>

<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
            <% = sBranch.InitFunction() %>
            <% = rBranch.InitFunction() %>
        }
    }
</script>