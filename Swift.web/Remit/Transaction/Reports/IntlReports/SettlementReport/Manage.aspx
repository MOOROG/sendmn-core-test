<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.IntlReports.SettlementReport.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>

    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>");
        });
        function SettlementReport() {

            //var reqField = "sCountry,";
            //if (ValidRequiredField(reqField) === false) {
            //    return false;
            //}
            var sPayStatus = GetValue("<% =sPayStatus.ClientID %>");

            var fromDate = $('#fromDate').val();
            var toDate = $('#toDate').val();

            var sCountry = GetValue("<% = sendCountry.ClientID %>");
            var rAgent = GetValue("<% = recAgent.ClientID %>");

            var rCountry = GetValue("<% = recCountry.ClientID %>");
            var sAgent = GetValue("<% = sendAgent.ClientID %>");

            var sendZone = GetElement("<%=sendZone.ClientID %>");

            var recZone = GetElement("<%=recZone.ClientID %>");

            var recDistrict = GetElement("<%=recDistrict.ClientID %>");

            var rLocation = GetValue("<% = recLocation.ClientID %>");
            //var url = "../../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=settlementint&pCountry=" + scountry +
            //  "&sAgent=" + sagent +
            //  "&sCurrency=" + sCurrency +
            //  "&sPayStatus=" + sPayStatus +
            //  "&sCountryVal=" + sCountryVal +
            //    "&from=" + from +<a href="http://localhost:55555/Remit/Transaction/Reports/IntlReports/SettlementReport/">http://localhost:55555/Remit/Transaction/Reports/IntlReports/SettlementReport/</a>
            //    "&to=" + to;
            var url = "../../../../../RemittanceSystem/RemittanceReports/Reports.aspx?" +
                "reportName=irhSettDrilDwn" +
                "&pCountry=" + rCountry +
                "&pAgent=" + rAgent +
                "&sCountry=" + sCountry +
                "&sAgent=" + sAgent +
                "&sPayStatus=" + sPayStatus +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&flag=Universal";

            OpenInNewWindow(url);
            return false;
        }
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
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li class="active"><a href="Manage.aspx">Intl Settlement Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">PAID INTERNATIONAL SETTLEMENT REPORT  </h4>
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
                                            <div class="form-group" style="display: none;">
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
                                                        AutoPostBack="True">
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
                                            <div class="form-group" style="display: none;">
                                                <label class="control-label col-md-3">Zone :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recZone" CssClass="form-control" runat="server"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recZone_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display: none;">
                                                <label class="control-label col-md-3">District :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="recDistrict" CssClass="form-control" runat="server"
                                                        AutoPostBack="True" OnSelectedIndexChanged="recDistrict_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group" style="display: none;">
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
                                                        AutoPostBack="True">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Pay Status: </label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="sPayStatus" runat="server" AutoPostBack="true" CssClass="form-control">
                                                        <asp:ListItem Text="Paid" Value="Paid" Selected="true"></asp:ListItem>
                                                        <asp:ListItem Text="Unpaid" Value="Unpaid"></asp:ListItem>
                                                    </asp:DropDownList>
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
                                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25" Text=" Detail " OnClientClick="return SettlementReport();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>
