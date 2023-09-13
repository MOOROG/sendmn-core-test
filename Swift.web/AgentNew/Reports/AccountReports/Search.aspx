<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Swift.web.AgentNew.Reports.AccountReports.Search" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
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
                        <li class="active"><a href="Search.aspx">Statement Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab">
            <div class="tab-content">
                <div class="register-form">
                    <div class="col-md-6">
                        <div class="panel panel-default clearfix m-b-20">
                            <div class="panel-heading">Statement Report</div>
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
                                            <label>Narration:</label>
                                        </div>
                                        <div class="col-md-9">
                                            <asp:TextBox ID="toDate" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-offset-3 col-md-12">
                                            <input type="button" id="btnViewTellerRpt" onclick="ViewReport('v')" value="Vault Statement" class="btn btn-primary m-t-25" />
                                            &nbsp;&nbsp;<input type="button" id="btnViewVaultRpt" onclick="ViewReport('t')" value="User Statement" class="btn btn-primary m-t-25" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel panel-default clearfix m-b-20">
                            <div class="panel-heading">Agent Statement Report</div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-3">
                                            <label>Agent Name:<span class="errormsg">*</span></label>
                                        </div>
                                        <div class="col-md-9">
                                            <uc1:SwiftTextBox ID="acInfo" runat="server" Category="acInfo-agent" cssclass="form-control" title="Blank for All" />
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-3">
                                            <label>From Date:<span class="errormsg">*</span></label>
                                        </div>
                                        <div class="col-md-9">
                                            <asp:TextBox ID="fromDateAgent" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-3">
                                            <label>Narration:</label>
                                        </div>
                                        <div class="col-md-9">
                                            <asp:TextBox ID="toDateAgent" runat="server" MaxLength="10" placeholder="yyyy-MM-dd" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-md-offset-3 col-md-12">
                                            <input type="button" id="btnAgentStatement" onclick="ViewReport('a')" value="Agent Statement" class="btn btn-primary m-t-25" />
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

            ShowCalFromTo("#ContentPlaceHolder1_fromDateAgent", "#ContentPlaceHolder1_toDateAgent");
            $('#ContentPlaceHolder1_fromDateAgent').mask('0000-00-00');
            $('#ContentPlaceHolder1_toDateAgent').mask('0000-00-00');
        });
        function ViewReport(type) {
            var url = '';
            var reqField = '';
            var fromDate = '';
            var toDate = '';
            var accNum = '';
            var accName = '';

            if (type == 'a') {
                fromDate = $("#ContentPlaceHolder1_fromDateAgent").val();
                toDate = $("#ContentPlaceHolder1_toDateAgent").val();
                accName = $('#ContentPlaceHolder1_acInfo_aText').val();
                accNum = $('#ContentPlaceHolder1_acInfo_aValue').val();

                reqField = "ContentPlaceHolder1_fromDateAgent,ContentPlaceHolder1_toDateAgent,ContentPlaceHolder1_acInfo_aText,";
            }
            else {
                fromDate = $("#ContentPlaceHolder1_fromDate").val();
                toDate = $("#ContentPlaceHolder1_toDate").val();

                reqField = "ContentPlaceHolder1_fromDate,ContentPlaceHolder1_toDate,";
            }

            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            url = "ViewStatement.aspx?type=" + type + "&startDate=" + fromDate + "&endDate=" + toDate + "&acNum=" + accNum + "&acName=" + accName;// + "&branch=" + branch + "&user=" + user;
            window.location.href = url;//window.location.replace(url);
        }
    </script>
</asp:Content>
