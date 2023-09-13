<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.BalanceSheet.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!-- <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="/ui/js/custom.js"></script>

    <!--page plugins-->
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
			CalUpToToday("#onDate");
			$('#onDate').mask('0000-00-00');

        });
        function goBack() {
            window.history.back();
        }
        <%--function LoadCalendars() {
            ShowCalFromTo("#<% =onDate.ClientID %>", 1);
        }
        LoadCalendars();--%>

        function CheckFormValidation() {
            var reportDate = $("#onDate").val();
            window.location.href = "BalanceSheet.aspx?reportDate=" + reportDate;
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
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="List.aspx">Balance Sheet</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Balance Sheet
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    As On Date:
                                </label>
                                <div class="col-lg-9 col-md-9">
                                    <%-- <asp:TextBox ID="onDate" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="onDate" onchange="return DateValidation('onDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" class="button"
                                        onclick="CheckFormValidation();" />
                                    <button class="btn btn-primary m-t-25" onclick="goBack()" type="button">
                                        Back</button>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%-- <div id="main-page-wrapper">
        <div class="breadCrumb">
            Account Reports » Balance Sheet</div>
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Balance Sheet
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-2">
                            <label>
                                As On Date:</label>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group form-inline">
                                <asp:TextBox ID="onDate" runat="server" Width="95%" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" class="button"
                                    onclick="CheckFormValidation();" />
                                <button class="btn btn-primary m-t-25" onclick="goBack()" type="submit">
                                    Back</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>--%>
    </form>
</body>
</html>