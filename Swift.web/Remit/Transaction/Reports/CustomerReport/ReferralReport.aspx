<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReferralReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CustomerReport.ReferralReport" %>

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
			ShowCalFromToUpToToday("#startDate", "#toDate");
			$('#startDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
        });
        function CheckFormValidation(flag) {
            var reqField = "startDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var url;
            var startDate = $("#startDate").val();
            var endDate = $("#toDate").val();
            var referralCode = $("#referralCode").val();
            var country = $("#ddlCountry").val();
            if (flag == "details-rpt") {
                url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=txnreportdrilldowntotalreferrerdetail&startDate=" + startDate + "&endDate=" + endDate + "&country=" + country + "&flag=detail-drilldown-report&referralCode=" + referralCode;
                OpenInNewWindow(url);
                return false;
            }
            else if (flag == 'Payable-rpt') {
                window.location.href = "ReferalPayable.aspx?s=" + startDate + "&e=" + endDate + "&r=" + referralCode;
                return false;
            }
            url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=referrerReport&startDate=" + startDate + "&endDate=" + endDate + "&referralCode=" + referralCode + "&flag=" + flag + "&country=" + country;
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
                            <li class="active"><a href="ReferralReport.aspx">Referral Report </a></li>
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
                            <h4 class="panel-title">Referral Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">


                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    From Date: <font color="red">*</font>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    To Date: <font color="red">*</font>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('startDate','t','toDate')" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    <label>
                                        Receiving Country:</label>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    <label>
                                        Referral Code:</label>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="referralCode" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <input type="button" value="Details Report" style="width: 165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('details-rpt');" />
                                    <input type="button" value="Summary Report" style="width: 165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('summary-rpt');" />
                                    <%--<input type="button" value="Transaction Payable" style="width: 165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('Payable-rpt');" />--%>
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
