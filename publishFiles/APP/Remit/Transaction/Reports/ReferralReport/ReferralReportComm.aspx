<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReferralReportComm.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.ReferralReport.ReferralReportComm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function ExportToExcel() {
            var html = document.getElementById("main").innerHTML;
            //alert(html);
            if (html == null || html == "" || html == undefined) {
                return false;
            }
            window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Reports </a></li>
                            <li class="active"><a href="ReferralReport.aspx">Referral Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Referral Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12 form-group" align="right">
                                    <a onclick="ExportToExcel();" class="btn printExcel" title="Export to Excel"><i class="fa fa-file-excel-o"></i></a>
                                </div>
                            </div>
                            <div class="row table-responsive" id="main">
                                <table class="table table-bordered">
                                    <thead>
                                        <tr>
                                            <th rowspan="2">S. No.</th>
                                            <th rowspan="2" style="text-align: center;">Referral Name</th>
                                            <th rowspan="2" style="text-align: center;">JME No</th>
                                            <th rowspan="2" style="text-align: center;">Sc Charge</th>
                                            <th rowspan="2" style="text-align: center;">Date</th>
                                            <th colspan="4" style="text-align: center;">Nepal Commission</th>
                                            <th colspan="4" style="text-align: center;">TF Commission</th>
                                            <th colspan="2" style="text-align: center;">Flat Commission</th>
                                            <th colspan="2" style="text-align: center;">New Customer Registration</th>
                                            <th rowspan="2" style="text-align: center;">Tax Deduction</th>
                                            <%--<th rowspan="2" style="text-align: center;">Total Txn</th>--%>
                                            <th rowspan="2" style="text-align: center;">Total Incentive Payable</th>
                                        </tr>
                                        <tr>
                                            <th>FX Rate</th>
                                            <th>FX Amount</th>
                                            <th>Comm Rate</th>
                                            <th>Comm Amount</th>
                                            <th>FX Rate</th>
                                            <th>FX Amount</th>
                                            <th>Comm Rate</th>
                                            <th>Comm Amount</th>
                                            <th>Rate</th>
                                            <th>Amount</th>
                                            <th>Rate</th>
                                            <th>Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody id="referralCommTbl" runat="server">
                                        <tr>
                                            <td colspan="16" align="center"><b>No record found</b></td>
                                        </tr>
                                    </tbody>
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
