<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.UnpaidTxnReport.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate");
            $('#fromDate').mask('0000-00-00');
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active">Unpaid Report</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Unpaid Transaction</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">As on Date :  </label>
                                <div class="col-md-4">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox autocomplete="off" ID="fromDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                    
                            <div class="form-group">
                                <label class="control-label col-md-3">Transaction Type:</label>
                                <div class="col-md-8">
                                    <asp:DropDownList runat="server" ID="TranType" CssClass="form-control">
                                        <asp:ListItem Text="International" Value="i"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">Payout Country:</label>
                                <div class="col-md-8">
                                    <asp:DropDownList runat="server" ID="countryDDL" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <label class="control-label col-md-3"></label>
                            <div class="col-md-8">
                                <asp:Button ID="unpaidTxn" runat="server" CssClass="btn btn-primary m-t-25" Text="Summary" OnClientClick="showSummaryReport()" />
                                <asp:Button ID="detailTxn" runat="server" CssClass="btn btn-primary m-t-25" Text="Detail" OnClientClick="showDetailReport()" />
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
    function showSummaryReport() {
        var TranType = document.getElementById("TranType").value;
        var Country = document.getElementById("countryDDL").value;
        var fromDate = document.getElementById("fromDate").value;
        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20167500&flag=s&TranType=" + TranType + "&country=" + Country  + "&fromDate=" + fromDate;
        OpenInNewWindow(url);
        return false;
    }

    function showDetailReport() {
        var Country = document.getElementById("countryDDL").value;
        var TranType = document.getElementById("TranType").value;
        var fromDate = document.getElementById("fromDate").value;
        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20167500&flag=detail1&TranType=" + TranType + "&country=" + Country + "&fromDate=" + fromDate;
        OpenInNewWindow(url);
        return false;
    }
</script>
