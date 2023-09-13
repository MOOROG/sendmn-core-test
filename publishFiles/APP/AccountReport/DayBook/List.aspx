<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.DayBook.List" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"></script>
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/metisMenu.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="/ui/js/custom.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-jvectormap-1.2.2.min.js" type="text/javascript"></script>
    <!-- Flot -->
    <script src="/ui/js/flot/jquery.flot.js" type="text/javascript"></script>
    <script src="/ui/js/flot/jquery.flot.tooltip.min.js" type="text/javascript"></script>
    <script src="/ui/js/flot/jquery.flot.resize.js" type="text/javascript"></script>
    <script src="/ui/js/flot/jquery.flot.pie.js" type="text/javascript"></script>
    <script src="/ui/js/chartjs/Chart.min.js" type="text/javascript"></script>
    <script src="/ui/js/pace.min.js" type="text/javascript"></script>
    <script src="/ui/js/waves.min.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-jvectormap-world-mill-en.js" type="text/javascript"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script type="text/javascript">
       <%-- function LoadCalendars() {
            ShowCalFromTo("#<% =startDate.ClientID %>", "#<% =toDate.ClientID %>", 1);
            ShowCalFromTo("#<% =startDate2.ClientID %>", "#<% =toDate2.ClientID %>", 1);
        }
        LoadCalendars();--%>
        $(document).ready(function () {
            //CalTillToday("#grid_list_fromDate");
            //CalTillToday("#grid_list_toDate");
            ShowCalFromToUpToToday("#startDate", "#toDate");
            ShowCalFromToUpToToday("#startDate2", "#toDate2");
            $('#startDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
            $('#startDate2').mask('0000-00-00');
            $('#toDate2').mask('0000-00-00');
        });

        function CheckFormValidation() {
            var reqField = "startDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var startDate = $("#startDate").val();
            var endDate = $("#toDate").val();
            var vType = $("#voucherType").val();
            var vName = $("#voucherType option:selected").text();
            var url = "";
            //if (vName == "All") {
            //    url = "dayBookReportAll.aspx?startDate=" + startDate + "&endDate=" + endDate + "&vType=" + vType + "&vName=" + vName;

            //}
            //else
            url = "dayBookReport.aspx?startDate=" + startDate + "&endDate=" + endDate + "&vType=" + vType + "&vName=" + vName;

            //alert(url);
            window.location.href = url;

        }
        function CheckFormValidation2() {
            var reqField = "startDate2,toDate2,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate2 = $("#startDate2").val();
            var endDate2 = $("#toDate2").val();
            var vType2 = $("#voucherType2").val();
            var vName = $("#voucherType2 option:selected").text();
            var userName2 = $("#userName option:selected").text();
            var url2 = "dayBookReportUser.aspx?startDate=" + startDate2 + "&endDate=" + endDate2 + "&vType=" + vType2 + "&userName=" + userName2 + "&vName=" + vName;
            //alert(url2);
            window.location.href = url2;
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
                            <li><a href="#">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="List.aspx">Day Book </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Day Book
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
                                        <asp:TextBox ID="startDate" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
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
                                        <asp:TextBox ID="toDate" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Voucher Type:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="voucherType" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="All" Value="" />
                                        <asp:ListItem Text="Journal Voucher" Value="j" />
                                        <asp:ListItem Text="Contra Voucher" Value="c" />
                                        <asp:ListItem Text="Payment Voucher" Value="y" />
                                        <asp:ListItem Text="Receipt Voucher" Value="r" />
                                        <asp:ListItem Text="Remittance Voucher" Value="s" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-3">
                                    <input type="button" value="Search" class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
                <div class="col-md-6" style="display: none;">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Day Book Userwise</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    From Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <%-- <asp:TextBox ID="startDate2" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate2" onchange="return DateValidation('startDate2','t','toDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    To Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <%-- <asp:TextBox ID="toDate2" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate2" onchange="return DateValidation('startDate2','t','toDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Voucher Type:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="voucherType2" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Journal Voucher" Value="j" />
                                        <asp:ListItem Text="Contra Voucher" Value="c" />
                                        <asp:ListItem Text="Payment Voucher" Value="y" />
                                        <asp:ListItem Text="Receipt Voucher" Value="r" />
                                        <asp:ListItem Text="Remittance Voucher" Value="s" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        User Name:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="userName" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="" Text="Select.."></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-3">
                                    <input type="button" value="Search" onclick="CheckFormValidation2();" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                    <!-- End .panel -->
                </div>
            </div>
        </div>
    </form>
    <!--script--->
</body>
</html>