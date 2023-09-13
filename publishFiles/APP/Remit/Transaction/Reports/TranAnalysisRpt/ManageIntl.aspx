<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageIntl.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.TranAnalysisRpt.ManageIntl" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/swift_autocomplete.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/swift_calendar.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript" language="javascript">
         $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
        });
        function GetSendCountry() {
            return GetItem("<% = sendCountry.ClientID %>")[0];
        }

        function GetRecCountry() {
            return "151";
        }

        function GetRecZone() {
            return GetItem("<% = recZone.ClientID %>")[0];
        }

        function GetRecDistrict() {
            return GetItem("<% = recDistrict.ClientID %>")[0];
        }

        function GetRecLocation() {
            return GetItem("<% = recLocation.ClientID %>")[0];
        }

        function GetSendAgent() {
            return GetItem("<% = sendAgent.ClientID %>")[0];
        }

        function GetRecAgent() {
            return GetItem("<% = recAgent.ClientID %>")[0];
        }
        function GetSendBranch() {
            return GetItem("<% = sendBranch.ClientID %>")[0];
        }

        function GetRecBranch() {
            return GetItem("<% = recBranch.ClientID %>")[0];
        }


        function CallBackAutocomplete(id) {
            var d = ["", ""];
            if (id == "#<% = sendCountry.ClientID%>") {
                SetItem("<% =sendAgent.ClientID%>", d);
                     <% = sendAgent.InitFunction() %>;

            } else if (id == "#<% = sendAgent.ClientID%>") {
                SetItem("<% =sendBranch.ClientID%>", d);
                     <% = sendBranch.InitFunction() %>;

            } else if (id == "#<% = recZone.ClientID%>") {
                SetItem("<% =recDistrict.ClientID%>", d);
                     <% = recDistrict.InitFunction() %>;

            } else if (id == "#<% = recDistrict.ClientID%>") {
                SetItem("<% =recLocation.ClientID%>", d);
                     <% = recLocation.InitFunction() %>;

            } else if (id == "#<% = recLocation.ClientID%>") {
                SetItem("<% =recAgent.ClientID%>", d);
                     <% = recAgent.InitFunction() %>;

            } else if (id == "#<% = recAgent.ClientID%>") {
                SetItem("<% =recBranch.ClientID%>", d);
                     <% = recBranch.InitFunction() %>;
            }
        }

        $(function () {
            $(".calendar2").datepicker({
                changeMonth: true,
                changeYear: true,
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });


        $(function () {
            $(".calendar1").datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });

        $(function () {
            $(".fromDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".toDatePicker").datepicker("option", "minDate", selectedDate);
                }
            });

            $(".toDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                }
            });
        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="ManageIntl.aspx">Transaction Analysis Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs hidden">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="ManageDomestic.aspx" target="_self">Transaction Analysis - Domestic  </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Transaction Analysis - International </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Transaction Analysis Report - International</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Date Type :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="dateType" runat="server" CssClass=" form-control">
                                                    <asp:ListItem Value="t" Text="TXN Date"></asp:ListItem>
                                                    <asp:ListItem Value="S" Text="Confirm Date"></asp:ListItem>
                                                    <asp:ListItem Value="P" Text="Paid Date" Selected="true"></asp:ListItem>
                                                    <asp:ListItem Value="C" Text="Cancel Date"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="col-md-3 control-label">From Date :</label>
                                            <div class="col-md-6">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <asp:TextBox ID="fromTime"  runat="server" Text="00:00:00" Width="75px"></asp:TextBox>
                                            </div>
                                            <div class="col-md-1">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromTime" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="fromTime"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />

                                                <cc1:MaskedEditValidator ID="MaskedEditValidator2" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="fromTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="rpt"
                                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Tran Type :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="tranType" runat="server" CssClass=" form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Transaction Status :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="status" runat="server" CssClass=" form-control">
                                                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                                                    <asp:ListItem Value="Unpaid" Text="Unpaid"></asp:ListItem>
                                                    <asp:ListItem Value="Paid" Text="Paid"></asp:ListItem>
                                                    <asp:ListItem Value="Cancel" Text="Cancel"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">To Date :</label>
                                            <div class="col-md-6">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <asp:TextBox ID="toTime" runat="server" Text="00:00:00" Width="75px"></asp:TextBox>
                                            </div>
                                            <div class="col-md-1">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="fromTime" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="toTime"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />

                                                <cc1:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="toTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="report"
                                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Search By :</label>
                                            <div class="col-md-4">
                                                <asp:TextBox ID="searchByText" runat="server" CssClass=" form-control">
                                                </asp:TextBox>

                                            </div>
                                            <div class="col-md-5">
                                                <asp:DropDownList ID="searchBy" runat="server" CssClass=" form-control">
                                                    <asp:ListItem Value="sender">Sender</asp:ListItem>
                                                    <asp:ListItem Value="receiver">Receiver</asp:ListItem>
                                                    <asp:ListItem Value="cAmt">Coll. Amount</asp:ListItem>
                                                    <asp:ListItem Value="pAmt">Pay Amount</asp:ListItem>
                                                    <asp:ListItem Value="extCustomerId">Customer ID</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                                <!-- 2econd Panel Body -->
                                <div class="panel-body">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-md-5 col-md-offset-3 control-label"><b>Sending </b></label>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Agent Group :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="sAgentGrp" runat="server" CssClass=" form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group" style="display: none;">
                                            <label class="col-md-3 control-label">Country :</label>
                                            <div class="col-md-8">
                                                <uc1:SwiftTextBox ID="sendCountry" runat="server" CssClass=" form-control" Category="countryRptInt" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Agent :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="sendAgent" runat="server" CssClass=" form-control" Category="remit-agentRptInt" Param1="@GetSendCountry()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Branch  :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="sendBranch" runat="server" CssClass=" form-control" Category="remit-branchRptInt" Param1="@GetSendAgent()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Group By  :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="DdlGroupReport" runat="server" CssClass=" form-control">
                                                    <asp:ListItem Value="detail" Text="Detail Report"></asp:ListItem>
                                                    <asp:ListItem Value="sc" Text="Sending Country"></asp:ListItem>
                                                    <asp:ListItem Value="sa" Text="Sending Agent"></asp:ListItem>
                                                    <asp:ListItem Value="sb" Text="Sending Branch"></asp:ListItem>
                                                    <asp:ListItem Value="rz" Text="Receiving Zone"></asp:ListItem>
                                                    <asp:ListItem Value="rd" Text="Receiving District"></asp:ListItem>
                                                    <asp:ListItem Value="rl" Text="Receiving Location"></asp:ListItem>
                                                    <asp:ListItem Value="ra" Text="Receiving Agent"></asp:ListItem>
                                                    <asp:ListItem Value="rb" Text="Receiving Branch"></asp:ListItem>
                                                    <asp:ListItem Value="datewise" Text="Date Wise" Selected="true"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label"><%=GetStatic.GetTranNoName()%> :</label>
                                            <div class="col-md-9">
                                                <asp:TextBox ID="controlNo" runat="server" CssClass=" form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-md-5 col-md-offset-3">
                                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " ValidationGroup="rpt"
                                                    OnClientClick="return ShowReport('old');" />
                                                <asp:Button ID="btnNew" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search New " ValidationGroup="rpt" Visible="false"
                                                    OnClientClick="return ShowReport('new');" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-md-5 col-md-offset-3 control-label"><b>Receiving </b></label>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Agent Group :</label>
                                            <div class="col-md-9">
                                                <asp:DropDownList ID="rAgentGrp" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <div class="form-group" style="display: none;">
                                            <label class="col-md-3 control-label">Zone :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="recZone" runat="server" CssClass="form-control" Category="zoneRpt" Param1="@GetRecCountry()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group" style="display: none;">
                                            <label class="col-md-3 control-label">District  :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="recDistrict" runat="server" Category="districtRpt" CssClass="form-control" Param1="@GetRecZone()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group" style="display: none;">
                                            <label class="col-md-3 control-label">Location  :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="recLocation" runat="server" CssClass="form-control" Category="locationRpt" Param1="@GetRecDistrict()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Agent  :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="recAgent" runat="server" CssClass="form-control" Category="remit-agentRptInt" Param1="@GetRecLocation()" Title="Blank for All" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Branch :</label>
                                            <div class="col-md-9">
                                                <uc1:SwiftTextBox ID="recBranch" runat="server" CssClass="form-control" Category="remit-branchRptInt" Param1="@GetRecAgent()" Title="Blank for All" />
                                            </div>
                                        </div>
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

<script language="javascript" type="text/javascript">

    function ShowReport(rptType) {
        if (!Page_ClientValidate('rpt'))
            return false;
        var controlNo = GetValue("<% = controlNo.ClientID %>");
        var url = "";
        if (controlNo != "") {
            url = "../../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=trananalysisintl&groupBy=detail" +
                "&controlNo=" + controlNo;
            OpenInNewWindow(url);
            return false;
        }
        if (rptType == "old") {
            url = "../../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=trananalysisintl";
        }
        if (rptType == "new") {
            url = "../../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=20162310";
        }

        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var fromTime = GetValue("<%=fromTime.ClientID %>");
        var toTime = GetValue("<%=toTime.ClientID %>");
        var dateType = GetValue("<% =dateType.ClientID%>");
        var tranType = GetValue("<% =tranType.ClientID%>");
        var sCountry = GetItem("<% = sendCountry.ClientID %>")[1];
        var sAgent = GetItem("<% = sendAgent.ClientID %>")[0];
        var sBranch = GetItem("<% = sendBranch.ClientID %>")[0];
        var rCountry = "";
        var rZone = GetItem("<% = recZone.ClientID %>")[1];
        var rDistrict = GetItem("<% = recDistrict.ClientID %>")[1];
        var rLocation = GetItem("<% = recLocation.ClientID %>")[0];
        var rAgent = GetItem("<% = recAgent.ClientID %>")[0];
        var rBranch = GetItem("<% = recBranch.ClientID %>")[0];
        var groupBy = GetValue("<% = DdlGroupReport.ClientID %>");
        var status = GetValue("<% = status.ClientID %>");
        var searchBy = GetValue("<% = searchBy.ClientID %>");
        var searchByText = GetValue("<% = searchByText.ClientID %>");
        var sAgentGrp = GetValue("<%=sAgentGrp.ClientID %>");
        var rAgentGrp = GetValue("<%=rAgentGrp.ClientID %>");

        url = url + "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&fromTime=" + fromTime +
            "&toTime=" + toTime +
            "&dateType=" + dateType +
            "&status=" + status +
            "&sCountry=" + sCountry +
            "&sAgent=" + sAgent +
            "&sBranch=" + sBranch +
            "&rCountry=" + rCountry +
            "&rZone=" + rZone +
            "&rDistrict=" + rDistrict +
            "&rAgent=" + rAgent +
            "&rBranch=" + rBranch +
            "&rLocation=" + rLocation +
            "&tranType=" + tranType +
            "&groupBy=" + groupBy +
            "&searchBy=" + searchBy +
            "&searchByText=" + searchByText +
            "&sAgentGrp=" + sAgentGrp +
            "&rAgentGrp=" + rAgentGrp;
        OpenInNewWindow(url);
        return false;
    }
</script>
