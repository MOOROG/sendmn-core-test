<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.MitatsuCheck.Search" %>

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
            //ShowCalFromToUpToToday("#from", "#to");
            From("#from");
            To("#to");
            ShowCalDefault("#fromDateCalculate");
            $('#from').mask('0000-00-00');
            $('#to').mask('0000-00-00');
            $('#fromDateCalculate').mask('0000-00-00');
        });
        function WeeklyMitasuReport() {

            var reqField = "from,to";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            var fromDate = $("#from");
            var toDate = $("#to");
            if (fromDate > toDate) {
                alert("From date cannot be greater than to date");
                return;
            }
            var from = GetValue("<% =from.ClientID %>");
            var to = GetValue("<% =to.ClientID %>");
            var url = "ViewReport.aspx?reportName=weeklymitasureport&from=" + from +
                "&to=" + to;
            OpenInNewWindow(url);
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Remittance</li>
                            <li class="active">Reports</li>
                            <li class="active">Weekly Mitasu Report</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Weekly Mitasu Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">From Date :  </label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <%--<asp:TextBox ID="from" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>--%>
                                        <asp:TextBox ID="from" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">To Date :  </label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <%--<asp:TextBox ID="to" runat="server" onchange="return DateValidation('from','t','to')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>--%>
                                        <asp:TextBox ID="to" runat="server" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3"></label>
                                <div class="col-md-9">
                                    <asp:Button runat="server" ID="Button1" Text="View Report" class="btn btn-primary m-t-25" OnClientClick="return WeeklyMitasuReport('WeeklyMitasuReport');" />
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
