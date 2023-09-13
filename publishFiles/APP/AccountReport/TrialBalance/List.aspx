<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.TrialBalance.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
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
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="/ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
			ShowCalFromToUpToToday("#fromDate", "#toDate");
			$('#fromDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
        });
        function goBack() {
            history.back();
        }
        <%--function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID %>", "#<% =toDate.ClientID %>", 1);
        }
        LoadCalendars();--%>

        function CheckFormValidation() {
            var reqField = "fromDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var fromDate = GetValue("fromDate");
            var toDate = GetValue("toDate");
            var reportType = GetValue("reportType");
            window.location.href = "TrialBalance.aspx?fromDate=" + fromDate + "&toDate=" + toDate + "&report_Type=" + reportType;

            //            GetElement("search").click();
            //            return true;
        }
    </script>
</head>
<body>
    <form id="from1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="List.aspx">Trial Balance</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Trial Balance
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
                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    To Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <%--  <asp:TextBox ID="toDate" runat="server"  CssClass="form-control"></asp:TextBox> --%>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Report Type:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="reportType" runat="server" CssClass="form-control" Width="100%">
                                        <asp:ListItem Value="a" Text="Group Wise"></asp:ListItem>
                                        <asp:ListItem Value="d" Text="Account Wise"></asp:ListItem>
                                    </asp:DropDownList>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                    <input type="button" value="Back" class="btn btn-primary m-t-25" onclick="goBack()" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- end .page title-->
        <%-- <div id="main-page-wrapper">
        <div class="breadCrumb">
            Account Report » Trial Balance</div>
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Trial Balance
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    From Date:</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group form-inline">
                                <asp:TextBox ID="fromDate" runat="server" Width="95%" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    To Date:</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group form-inline">
                                <asp:TextBox ID="toDate" runat="server" Width="95%" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    Report Type:</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:DropDownList ID="reportType" runat="server" CssClass="form-control" Width="100%">
                                    <asp:ListItem Value="a" Text="Group Wise"></asp:ListItem>
                                    <asp:ListItem Value="d" Text="Account Wise"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
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