<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Swift.web.AgentNew.Reports.ReferralReport.Search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Reports </a></li>
                        <li class="active"><a href="Manage.aspx">Cash Status Report (Referral) </a></li>
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
                        <h4 class="panel-title">Cash Status Report (Referral)
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
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalDefault("#ContentPlaceHolder1_asOfDate");
            $('#ContentPlaceHolder1_asOfDate').mask('0000-00-00');
        });
        function GetCashPositionReport(type) {
            var url = '';
            var reqField = "ContentPlaceHolder1_asOfDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var asOfDate = $("#ContentPlaceHolder1_asOfDate").val();

            url = "ReferralReport.aspx?reportName=cashstatusreferral&flag=cash-rpt&asOfDate=" + asOfDate;// + "&branch=" + branch + "&user=" + user;
            OpenInNewWindow(url);
        }
    </script>
</asp:Content>
