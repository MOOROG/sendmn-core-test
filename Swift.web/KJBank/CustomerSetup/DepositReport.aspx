<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DepositReport.aspx.cs" Inherits="Swift.web.KJBank.CustomerSetup.DepositReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js"></script>
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/pickers-init.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
			ShowCalFromToUpToToday("#startDate", "#toDate");
			$('#startDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
        });
        function CheckFormValidation() {

            var reqField = "startDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var startDate = $("#startDate").val();
            var endDate = $("#toDate").val();
            var ReportType = $("#ReportType").val();
            var url = "";

			url = "../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=funddepositrpt&startDate=" + startDate + "&endDate=" + endDate + "&ReportType=" + ReportType;

            OpenInNewWindow(url);
            //alert(url);
            //window.location.href = url;

        }
    </script>
</head>
<body>
    <form id="Form1" name="repform" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer Management</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Fund Deposit Report </a></li>
                            <li class="active"><a href="DepositReport.aspx">Fund Deposit Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="Javascript:void(0)" aria-controls="home" role="tab" data-toggle="tab">FUND DEPOSIT REPORT</a></li>
                    <li><a href="FundStatement_Customer.aspx">Fund Summary Customer Wise</a></li>
                    <%--      <li ><a href="../AutoDebitTransaction.aspx">Auto Debit Transaction Report </a></li>--%>
                </ul>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Fund Deposit Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    From Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    To Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Report Type:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="ReportType" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Summary Report" Value="s" />
                                        <asp:ListItem Text="Detail Report" Value="d" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-2">
                                    <input type="button" value="Search" class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <!--script--->
</body>
</html>