<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.PLAccount.List" %>

<%@ Import Namespace="Swift.web.Library" %>
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
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="../../ui/js/pickers-init.js"></script>
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
			ShowCalFromToUpToToday("#fromDate", "#toDate");
			$('#fromDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
        });
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
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="List.aspx">Profit and Loss</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Profit And Loss Account
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
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    To Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <input type="button" id="btn" value=" Search " onclick="CheckFormValidation();" class="btn btn-primary m-t-25" class="button" />
                                    <button class="btn btn-primary m-t-25" type="button" onclick="goBack()">
                                        Back</button>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript" language="javascript">
        function goBack() {
            window.history.back();
        }
        function CheckFormValidation() {
            var toDate = $("#toDate").val();
            var fromDate = $("#fromDate").val();
            window.location.href = "PLAccount.aspx?toDate=" + toDate + "&fromDate=" + fromDate;
        }
    </script>
</body>
</html>