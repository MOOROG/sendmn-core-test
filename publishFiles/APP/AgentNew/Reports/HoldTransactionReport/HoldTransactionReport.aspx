<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="HoldTransactionReport.aspx.cs" Inherits="Swift.web.AgentNew.Reports.HoldTransactionReport.HoldTransactionReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#<% =startDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            $('#<% =startDate.ClientID%>').mask('0000-00-00');
            $('#<% =toDate.ClientID%>').mask('0000-00-00');
            if (<%=HasRight()%> == true) {
                $('#viewBranchUserReport').attr("style", "display:block");
            }
            else {
                $('#viewBranchUserReport').attr("style", "display:none");
            }
        });
        function GetHoldTxnReport(type) {
            var url = '';
            var reqField = "<%=startDate.ClientID%>,<%=toDate.ClientID%>,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#<%=startDate.ClientID%>").val();
            var endDate = $("#<%=toDate.ClientID%>").val();
            if (type == 'v') {
                url = "../Reports.aspx?reportName=holdTxnreport" + "&fromDate=" + startDate + "&toDate=" + endDate + "&reportType=view";
            }
            else if (type == 'vb') {
                url = "../Reports.aspx?reportName=holdTxnreport" + "&fromDate=" + startDate + "&toDate=" + endDate + "&reportType=viewBranch";
            }
            OpenInNewWindow(url);
        }
    </script>
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
                        <h4 class="panel-title">Hold Transaction Report
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
                            </label>
                            <div class="col-lg-8 col-md-12">
                                <div class="col-lg-5 col-md-4">
                                    <input id="view" type="button" value="View Report" class="btn btn-primary m-t-25" onclick="return GetHoldTxnReport('v');" />
                                </div>
                                <div class="col-lg-6 col-md-8">
                                    <input id="viewBranchUserReport" type="button" value="View Branch Report" class="btn btn-primary m-t-25" onclick="return GetHoldTxnReport('vb');" />
                                </div>
                            </div>
                        </div>
                        <!-- End .form-group  -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>