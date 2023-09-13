<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CashManagement.Manage" %>

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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalDefault("#asOfDate");
            $('#asOfDate').mask('0000-00-00');
        });
        function GetCashPositionReport(type) {
            var url = '';
            var reqField = "asOfDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var asOfDate = $("#asOfDate").val();
            var branch = $("#<%=ddlBranch.ClientID%>").val();
            var user = $("#<%=ddlUser.ClientID%>").val();

            url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=cashstatus&flag=cash-rpt&asOfDate=" + asOfDate;// + "&branch=" + branch + "&user=" + user;
            OpenInNewWindow(url);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <h1></h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#">Reports </a></li>
                                    <li class="active"><a href="Manage.aspx">Cash Status Report </a></li>
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
                                    <h4 class="panel-title">Cash Status Report
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <!-- End .form-group  -->
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                            Date (As Of): <font color="red">*</font>
                                        </label>
                                        <div class="col-lg-8 col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="asOfDate" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group" style="display:none;">
                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                            <label>
                                                Branch:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-8">
                                            <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group" style="display:none;">
                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                            <label>
                                                User:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-8">
                                            <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                        </label>
                                        <div class="col-lg-8 col-md-8">
                                            <input type="button" value="Show Report" class="btn btn-primary m-t-25" onclick="return GetCashPositionReport('d');" />
                                        </div>
                                    </div>
                                    <!-- End .form-group  -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
