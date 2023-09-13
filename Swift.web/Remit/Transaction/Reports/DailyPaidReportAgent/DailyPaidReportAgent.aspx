<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyPaidReportAgent.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.DailyPaidReportAgent.DailyPaidReportAgent" %>

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
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />

    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
        });
        function DailyPaidReport() {

            var payoutPartner = $('#payoutPartner option:selected').text();
            var payoutPartnerId = $('#payoutPartner').val();
            var sAgent = GetValue("<% =sAgent.ClientID %>");
            var from = GetValue("<% =fromDate.ClientID %>");
            var to = GetValue("<% =toDate.ClientID %>");


            var url = url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=dailyPaidReport" +
                "&payoutPartner=" + payoutPartner +
                "&payoutPartnerId=" + payoutPartnerId +
                "&sAgent=" + sAgent +
                "&fromDate=" + from +
                "&toDate=" + to;


            OpenInNewWindow(url);
            return false;
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">

                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="DailyPaidReportAgent.aspx">Daily Paid Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Daily Paid Report Agent</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upnl1" runat="server">
                                <ContentTemplate>
                                    <div class="form-group">
                                        <label class="control-label col-md-4">Payout Partner :</label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="payoutPartner" runat="server" CssClass="form-control" AutoPostBack="true"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-4">Sending Agent :</label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date :  </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">To Date :  </label>
                                <div class="col-md-8">

                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('from','t','to')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="btnDailyPaidReport" Text="Daily Paid Report" class="btn btn-primary m-t-25" OnClientClick="return DailyPaidReport();" />
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
