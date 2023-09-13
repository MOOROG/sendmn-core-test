<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CustomerReport.Manage" %>

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
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromTo("#startDate", "#toDate");
            $('#startDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
        });
        function CheckFormValidation(flag) {
            var reqField = "startDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var startDate = $("#startDate").val();
            var endDate = $("#toDate").val();
            var country = $("#countryDDL").val();
            var countryName = $("#countryDDL option:selected").text();
            var branch = $("#branchDDL").val();
            var branchName = $("#branchDDL option:selected").text();
            
            var url;
            url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerReport&startDate=" + startDate + "&endDate=" + endDate + "&country=" + country + "&branch=" + branch + "&flag=" + flag;
            if (flag == 'register-matrix' || flag == 'trn-matrix') {
                url = "MatrixReport.aspx?startDate=" + startDate + "&endDate=" + endDate + "&country=" + country + "&branch=" + branch + "&flag=" + flag + "&countryName=" + countryName + "&branchName=" + branchName;
            }

            OpenInNewWindow(url);
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
                            <li class="active"><a href="Manage.aspx"> Customer Report </a></li>
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
                            <h4 class="panel-title">Customer Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Country:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="countryDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Branch:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="branchDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
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
                            <div class="form-group">
                                <div class="col-md-12 col-md-offset-2">
                                    <input type="button" value="Registration Report" style="width:165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('registration-rpt');" />
                                    <input type="button" value="Transaction Report" style="width:165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('transaction-rpt');" />
                                </div>
                                <div class="col-md-12 col-md-offset-2" style="margin-top:10px;">
                                    <input type="button" value="Registration Matrix" style="width:165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('register-matrix');" />
                                    <input type="button" value="Transaction Matrix" style="width:165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('trn-matrix');" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
