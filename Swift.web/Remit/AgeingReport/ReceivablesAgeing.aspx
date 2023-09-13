<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceivablesAgeing.aspx.cs" Inherits="Swift.web.Remit.AgeingReport.ReceivablesAgeing" %>

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
            var html = document.getElementById("ageningrpttbl").innerHTML;
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
                            <li class="active"><a href="ReferralReport.aspx">Receivables Ageing Report </a></li>
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
                            <h4 class="panel-title">Agent Outstanding Ageing Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="row">
                                    <div class="col-md-12 form-group" align="right">
                                        <a onclick="ExportToExcel();" class="btn printExcel" title="Export to Excel"><i class="fa fa-file-excel-o"></i></a>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12 form-group">
                                        <div class="table-responsive" id="ageningrpttbl">
                                            <table class="table table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>S. No.</th>
                                                        <th>Agent Name</th>
                                                        <th>Total Outstanding</th>
                                                        <th>Below 4 Days</th>
                                                        <th>Over 4 Days</th>
                                                        <th>Over 1 Month</th>
                                                        <th>Over 3 Month</th>
                                                        <th>Over 6 Month</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="ageingRptBody" runat="server">
                                                    <tr>
                                                        <td colspan="7" align="center"><b>No record found</b></td>
                                                    </tr>
                                                </tbody>
                                            </table>
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
