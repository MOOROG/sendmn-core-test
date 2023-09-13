<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Swift.web.AgentNew.Reports.CashCollectedReport.Search" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-md-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Cash Management</a></li>
                        <li class="active"><a href="Search.aspx">Cash Collected Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab">
            <div class="tab-content">
                <div class="register-form">
                    <div class="col-md-6">
                        <div class="panel panel-default clearfix m-b-20">
                            <div class="panel-heading">Cash Collected Report</div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-3">
                                            <label>From Date:<span class="errormsg">*</span></label>
                                        </div>
                                        <div class="col-md-9">
                                            <asp:TextBox ID="fromDate" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-3">
                                            <label>To Date:</label>
                                        </div>
                                        <div class="col-md-9">
                                            <asp:TextBox ID="toDate" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-offset-3 col-md-12">
                                            <input type="button" id="btnViewTellerRpt" onclick="ViewReport()" value="View Report" class="btn btn-primary m-t-25" />
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
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromTo("#ContentPlaceHolder1_fromDate", "#ContentPlaceHolder1_toDate");
            $('#ContentPlaceHolder1_fromDate').mask('0000-00-00');
            $('#ContentPlaceHolder1_toDate').mask('0000-00-00');
        });
        function ViewReport() {
            var fromDate = $("#ContentPlaceHolder1_fromDate").val();
            var toDate = $("#ContentPlaceHolder1_toDate").val();

            var reqField = "ContentPlaceHolder1_fromDate,ContentPlaceHolder1_toDate,";

            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            url = "DrillDownCash.aspx?flag=search&fromDate=" + fromDate + "&toDate=" + toDate;// + "&branch=" + branch + "&user=" + user;
            window.location.href = url;//window.location.replace(url);
        }
    </script>
</asp:Content>
