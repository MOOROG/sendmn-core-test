<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CashCollectedList.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.ChashCollected.CashCollectedList" %>

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
                            <li class="active"><a href="ReferralReport.aspx">Cash Collected List </a></li>
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
                            <h4 class="panel-title">Cash Collected List<b><label runat="server" id="agentName"></label></b>
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12 form-group">
                                    <b>Filters Applied:</b>&nbsp;&nbsp;From Date: <%=GetFromDate() %>&nbsp;&nbsp;&nbsp;&nbsp;To Date: <%=GetToDate() %>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 form-group" align="right">
                                    <a onclick="ExportToExcel();" class="btn printExcel" title="Export to Excel"><i class="fa fa-file-excel-o"></i></a>
                                </div>
                            </div>
                            <div id="main">
                                <div class="row" id="main1" runat="server">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <div class="table-responsive">
                                                <table class="table table-bordered">
                                                    <thead>
                                                        <tr>
                                                            <th>S. No.</th>
                                                            <th>Branch Name</th>
                                                            <th>Referral Name</th>
                                                            <th>Cash Collected</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="cashCollectedList" runat="server">
                                                        <tr>
                                                            <td colspan="4" align="center"><b>No record found</b></td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row" id="drillDown" runat="server">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <div class="table-responsive">
                                                <table class="table table-bordered">
                                                    <thead>
                                                        <tr>
                                                            <th>S. No.</th>
                                                            <th>Narration</th>
                                                            <th>Date</th>
                                                            <th>Cash Collected</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="drillDownBody" runat="server">
                                                        <tr>
                                                            <td colspan="4" align="center"><b>No record found</b></td>
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
        </div>
    </form>
</body>
</html>
