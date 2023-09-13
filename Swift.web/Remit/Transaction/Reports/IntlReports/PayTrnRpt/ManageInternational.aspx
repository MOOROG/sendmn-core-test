<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageInternational.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.PaidTXN_Int_Rpt.ManageInternational" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li class="active"><a href="ManageInternational.aspx">Paid Intl Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">PAID INTERNATIONAL TRANSACTION REPORT  </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group form-inline col-md-12">
                                    <label class="control-label col-md-2">From Date :</label>
                                    <div class="col-md-4">
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="fromDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                    <label class="control-label col-md-2">To Date :</label>
                                    <div class="col-md-4">
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <asp:UpdatePanel ID="upd1" runat="server">
                                    <ContentTemplate>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="control-label col-md-3"></label>
                                                <div class="col-md-8">
                                                    SENDING INFORMATION
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Country :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sendCountry" runat="server" CssClass="form-control"
                                                        OnSelectedIndexChanged="sendCountry_SelectedIndexChanged"
                                                        AutoPostBack="True">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display:none;">
                                                <label class="control-label col-md-3">State :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sendZone" runat="server"
                                                        CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Agent :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sendAgent" runat="server" CssClass="form-control"
                                                        AutoPostBack="True" OnSelectedIndexChanged="sendAgent_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Branch :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sendBranch" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="control-label col-md-3"></label>
                                                <div class="col-md-8">
                                                    RECEIVING  INFORMATION
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Country : </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recCountry" runat="server" CssClass="form-control"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recCountry_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display:none;">
                                                <label class="control-label col-md-3">Zone :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recZone" CssClass="form-control" runat="server"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recZone_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display:none;">
                                                <label class="control-label col-md-3">District :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recDistrict" CssClass="form-control" runat="server"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recDistrict_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display:none;">
                                                <label class="control-label col-md-3">Location : </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recLocation" CssClass="form-control" runat="server"
                                                        OnSelectedIndexChanged="recLocation_SelectedIndexChanged" AutoPostBack="True">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Agent : </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recAgent" runat="server" CssClass="form-control"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recAgent_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-3">Branch :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="sendAgent" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="recZone" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="recDistrict" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="recLocation" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="recAgent" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="row col-md-offset-1">
                                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25" Text=" Detail " OnClientClick="return showReport();" />
                                <asp:Button ID="btnSearch1" runat="server" CssClass="btn btn-primary m-t-25" Text=" Summary " OnClientClick="return showReportSummary();" />
                                <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary m-t-25" Text=" Summary With Commission " OnClientClick="return showReportSummary1();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(document).ready(function () {
        ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>");
    });
    function showReport() {
        var reqField = "<%=fromDate.ClientID%>,<%=toDate.ClientID%>,";
        if (!ValidRequiredField(reqField)) {
            return false;
        }
        var fromDate = $('#fromDate').val();
        var toDate = $('#toDate').val();
        var sCountry = GetValue("<% = sendCountry.ClientID %>");

        var sendZone = GetElement("<%=sendZone.ClientID %>");
        var sZone = sendZone.options[sendZone.selectedIndex].text;

        var sAgent = GetValue("<% = sendAgent.ClientID %>");
        var sBranch = GetValue("<% = sendBranch.ClientID %>");
        var rCountry = GetValue("<% = recCountry.ClientID %>");

        var recZone = GetElement("<%=recZone.ClientID %>");
        var rZone = recZone.options[recZone.selectedIndex].text;

        var recDistrict = GetElement("<%=recDistrict.ClientID %>");
        var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

        var rLocation = GetValue("<% = recLocation.ClientID %>");
        var rAgent = GetValue("<% = recAgent.ClientID %>");
        var rBranch = GetValue("<% = recBranch.ClientID %>");

        var url = "ShowReport.aspx?reportName=paidtranint" +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&sCountry=" + sCountry +
            "&sZone=" + sZone +
            "&sAgent=" + sAgent +
            "&sBranch=" + sBranch +
            "&rCountry=" + rCountry +
            "&rZone=" + rZone +
            "&rDistrict=" + rDistrict +
            "&rLocation=" + rLocation;
        "&rAgent=" + rAgent +
            "&rBranch=" + rBranch +

            OpenInNewWindow(url);
        return false;
    }
    function showReportSummary() {
        var fromDate = $('#fromDate').val();
        var toDate = $('#toDate').val();
        var sCountry = GetValue("<% = sendCountry.ClientID %>");

        var sendZone = GetElement("<%=sendZone.ClientID %>");
        var sZone = sendZone.options[sendZone.selectedIndex].text;

        var sAgent = GetValue("<% = sendAgent.ClientID %>");
        var sBranch = GetValue("<% = sendBranch.ClientID %>");
        var rCountry = GetValue("<% = recCountry.ClientID %>");

        var recZone = GetElement("<%=recZone.ClientID %>");
        var rZone = recZone.options[recZone.selectedIndex].text;

        var recDistrict = GetElement("<%=recDistrict.ClientID %>");
        var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

        var rLocation = GetValue("<% = recLocation.ClientID %>");
        var rAgent = GetValue("<% = recAgent.ClientID %>");
        var rBranch = GetValue("<% = recBranch.ClientID %>");

        var url = "ShowReport.aspx?reportName=paidtransummaryint" +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&sCountry=" + sCountry +
            "&sZone=" + sZone +
            "&sAgent=" + sAgent +
            "&sBranch=" + sBranch +
            "&rCountry=" + rCountry +
            "&rZone=" + rZone +
            "&rDistrict=" + rDistrict +
            "&rLocation=" + rLocation;
        "&rAgent=" + rAgent +
            "&rBranch=" + rBranch +

            OpenInNewWindow(url);
        return false;
    }
    function showReportSummary1() {
        var fromDate = $('#fromDate').val();
        var toDate = $('#toDate').val();
        var sCountry = GetValue("<% = sendCountry.ClientID %>");

        var sendZone = GetElement("<%=sendZone.ClientID %>");
        var sZone = sendZone.options[sendZone.selectedIndex].text;

        var sAgent = GetValue("<% = sendAgent.ClientID %>");
        var sBranch = GetValue("<% = sendBranch.ClientID %>");
        var rCountry = GetValue("<% = recCountry.ClientID %>");

        var recZone = GetElement("<%=recZone.ClientID %>");
        var rZone = recZone.options[recZone.selectedIndex].text;

        var recDistrict = GetElement("<%=recDistrict.ClientID %>");
        var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

        var rLocation = GetValue("<% = recLocation.ClientID %>");
        var rAgent = GetValue("<% = recAgent.ClientID %>");
        var rBranch = GetValue("<% = recBranch.ClientID %>");

        var url = "ShowReport.aspx?reportName=paidtransummary1int" +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&sCountry=" + sCountry +
            "&sZone=" + sZone +
            "&sAgent=" + sAgent +
            "&sBranch=" + sBranch +
            "&rCountry=" + rCountry +
            "&rZone=" + rZone +
            "&rDistrict=" + rDistrict +
            "&rLocation=" + rLocation;
        "&rAgent=" + rAgent +
            "&rBranch=" + rBranch +

            OpenInNewWindow(url);

        return false;

    }
</script>