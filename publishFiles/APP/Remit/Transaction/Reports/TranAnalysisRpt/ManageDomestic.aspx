<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageDomestic.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.TranAnalysisRpt.ManageDomestic" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript" language="javascript">
         $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
        });
        function GetCountryName() {
            return "151";
        }

        function GetSendGroup() {
            return GetValue("<%=sAgentGrp.ClientID %>");
        }

        function GetReceiveGroup() {
            return GetValue("<%=rAgentGrp.ClientID %>");
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
            if (id == "#<% = sendAgent.ClientID%>") {
                SetItem("<% =sendBranch.ClientID%>", d);
                <% = sendBranch.InitFunction() %>;

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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="ManageDomestic.aspx">Transaction Analysis Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li  class="active"><a  target="_self" href="Javascript:void(0)" class="selected">Transaction Analysis - Domestic  </a></li>
                    <li><a href="ManageIntl.aspx"  target="_self">Transaction Analysis - International </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Transaction Analysis Report - Domestic</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">

                                    <table>
                                        <tr>
                                            <td>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td>
                                                            <label class=" control-label">Date Type:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="dateType" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="S" Text="Sending Date"></asp:ListItem>
                                                                <asp:ListItem Value="P" Text="Paid Date" Selected="true"></asp:ListItem>
                                                                <asp:ListItem Value="C" Text="Cancel Date"></asp:ListItem>
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td>
                                                            <label class="control-label">Transaction Status:</label>

                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="status" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="" Text="All"></asp:ListItem>
                                                                <asp:ListItem Value="Unpaid" Text="Unpaid"></asp:ListItem>
                                                                <asp:ListItem Value="Paid" Text="Paid"></asp:ListItem>
                                                                <asp:ListItem Value="Cancel" Text="Cancel"></asp:ListItem>
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">From Date:</label>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="row">
                                                                <div class="form-group col-md-7">
                                                                    <div class="input-group m-b">
                                                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                                        <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-5">
                                                                    <asp:TextBox ID="fromTime" runat="server" Text="00:00:00" Width="75px"></asp:TextBox>

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

                                                                    <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="fromTime" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">To Date:</label>
                                                        </td>
                                                        <td nowrap="nowrap" colspan="3">
                                                            <div class="row">
                                                                <div class="form-group col-md-7">
                                                                    <div class="input-group m-b">
                                                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group col-md-5">
                                                                    <asp:TextBox ID="toTime" runat="server" Text="23:59:59" Width="75px"></asp:TextBox>
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

                                                                    <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>

                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="toTime" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Tran Type:</label>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="tranType" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Search By:</label>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="row">
                                                                <div class="col-md-6 form-group">
                                                                    <asp:TextBox ID="searchByText" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </div>

                                                                <div class="col-md-6 form-group">
                                                                    <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                                                        <asp:ListItem Value="sender">Sender</asp:ListItem>
                                                                        <asp:ListItem Value="receiver">Receiver</asp:ListItem>
                                                                        <asp:ListItem Value="cAmt">Coll. Amount</asp:ListItem>
                                                                        <asp:ListItem Value="pAmt">Pay Amount</asp:ListItem>
                                                                        <asp:ListItem Value="extCustomerId">Customer ID</asp:ListItem>
                                                                    </asp:DropDownList>
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr style="display: none">
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Remit Product: </label>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="remitProduct" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td></td>
                                                        <td></td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td><span class="subHeading">Sending</span></td>
                                                        <td>&nbsp;</td>
                                                        <td><span class="subHeading">Receiving</span></td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Agent Group:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="sAgentGrp" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Agent Group</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="rAgentGrp" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <%--<tr>
                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">Zone:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="sendZone" runat="server" Width="250px" Category="remit-zoneRpt" CssClass="required" Param1="@GetCountryName()" Title="Blank for All" />
                                                </td>

                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">Zone:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="recZone" runat="server" Width="250px" Category="remit-zoneRpt" CssClass="required" Param1="@GetCountryName()" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">District:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="sendDistrict" runat="server" Width="250px" Category="remit-districtRpt" CssClass="required" Param1="@GetSendZone()" Title="Blank for All" />
                                                </td>

                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">District:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="recDistrict" runat="server" Width="250px" Category="remit-districtRpt" CssClass="required" Param1="@GetRecZone()" Title="Blank for All" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">Location:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="sendLocation" runat="server" Width="250px" Category="remit-locationRpt" CssClass="required" Param1="@GetSendDistrict()" Title="Blank for All" />
                                                </td>

                                                <td nowrap="nowrap" valign="top">
                                                   <label class="control-label">Location:</label>
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="recLocation" runat="server" Width="250px" Category="remit-locationRpt" CssClass="required" Param1="@GetRecDistrict()" Title="Blank for All" />
                                                </td>
                                            </tr>--%>
                                                    <tr>

                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Agent:</label>
                                                        </td>
                                                        <td>
                                                            <uc1:SwiftTextBox ID="sendAgent" runat="server" Width="250px" Category="remit-agentRpt" CssClass="required" Param1="@GetSendGroup()" Title="Blank for All" />
                                                        </td>

                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Agent:</label>
                                                        </td>
                                                        <td>
                                                            <uc1:SwiftTextBox ID="recAgent" runat="server" Width="250px" Category="remit-agentRpt" CssClass="required" Param1="@GetReceiveGroup()" Title="Blank for All" />
                                                        </td>

                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Branch:</label>
                                                        </td>
                                                        <td>
                                                            <uc1:SwiftTextBox ID="sendBranch" runat="server" Width="250px" Category="remit-branchRpt" CssClass="required" Param1="@GetSendAgent()" Title="Blank for All" />
                                                        </td>

                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Branch:</label>
                                                        </td>
                                                        <td>
                                                            <uc1:SwiftTextBox ID="recBranch" runat="server" Width="250px" Category="remit-branchRpt" CssClass="required" Param1="@GetRecAgent()" Title="Blank for All" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" valign="top">
                                                            <label class="control-label">Group By:</label>
                                                        </td>
                                                        <td colspan="2">
                                                            <div class="row">
                                                                <div class="col-md-9">
                                                                    <asp:DropDownList ID="DdlGroupReport" runat="server" CssClass="form-control">

                                                                        <asp:ListItem Value="detail" Text="Detail Report"></asp:ListItem>

                                                                        <asp:ListItem Value="sz" Text="Sending Zone"></asp:ListItem>
                                                                        <asp:ListItem Value="sd" Text="Sending District"></asp:ListItem>
                                                                        <asp:ListItem Value="sl" Text="Sending Location"></asp:ListItem>

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
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label class="control-label"><%=GetStatic.GetTranNoName()%> :</label>
                                                        </td>
                                                        <td colspan="2">
                                                            <div class="row">
                                                                <div class="col-md-9">
                                                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control">
                                                                    </asp:TextBox>
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td colspan="2">
                                                            <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " ValidationGroup="rpt"
                                                                OnClientClick="return ShowReport();" />
                                                        </td>
                                                    </tr>
                                                </table>
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

<script language="javascript" type="text/javascript">
    function ShowReport() {
        var dateType = GetValue("<% =dateType.ClientID%>");
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var fromTime = GetValue("<%=fromTime.ClientID %>");
        var toTime = GetValue("<%=toTime.ClientID %>");
        var controlNo = GetValue("<% = controlNo.ClientID %>");
        var groupBy = GetValue("<% = DdlGroupReport.ClientID %>");
        var url = "";
        if (controlNo != "") {
            url = "../../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=trananalysisdom&groupBy=detail" +
                "&controlNo=" + controlNo;
            OpenInNewWindow(url);
            return false;
        }
        if (!Page_ClientValidate('rpt'))
            return false;

        var tranType = GetValue("<% =tranType.ClientID%>");
        var sCountry = "Nepal";
        <%--var sZone = GetItem("<% = sendZone.ClientID %>")[1];
        var sDistrict = GetItem("<% = sendDistrict.ClientID %>")[1];
        var sLocation = GetItem("<% = sendLocation.ClientID %>")[0];--%>
        var sAgent = GetItem("<% = sendAgent.ClientID %>")[0];
        var sBranch = GetItem("<% = sendBranch.ClientID %>")[0];
        var rCountry = "Nepal";
        <%--var rZone = GetItem("<% = recZone.ClientID %>")[1];
        var rDistrict = GetItem("<% = recDistrict.ClientID %>")[1];
        var rLocation = GetItem("<% = recLocation.ClientID %>")[0];--%>
        var rAgent = GetItem("<% = recAgent.ClientID %>")[0];
        var rBranch = GetItem("<% = recBranch.ClientID %>")[0];
        <%--var remitProduct = GetValue("<% =remitProduct.ClientID%>");--%>
        var status = GetValue("<% = status.ClientID %>");
        var searchBy = GetValue("<% = searchBy.ClientID %>");
        var searchByText = GetValue("<% = searchByText.ClientID %>");
        var sAgentGrp = GetValue("<%=sAgentGrp.ClientID %>");
        var rAgentGrp = GetValue("<%=rAgentGrp.ClientID %>");

        url = "../../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=trananalysisdom" +
        "&fromDate=" + fromDate +
        "&toDate=" + toDate +
        "&fromTime=" + fromTime +
        "&toTime=" + toTime +
        "&dateType=" + dateType +
        "&status=" + status +
        "&sCountry=" + sCountry +
        "&sAgent=" + sAgent +
        "&sBranch=" + sBranch +
        "&rCountry=" + rCountry +
        "&rAgent=" + rAgent +
        "&rBranch=" + rBranch +
        "&controlNo=" + controlNo +
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
