<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="DrillDownCash.aspx.cs" Inherits="Swift.web.AgentNew.Reports.CashCollectedReport.DrillDownCash" %>

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
                        <li class="active"><a href="ReferralReport.aspx">Cash Collected List </a></li>
                    </ol>
                </div>
            </div>
        </div>
        <!-- end .page title-->
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default recent-activites">
                    <!-- Start .panel -->
                    <div class="panel-heading">
                        <h4 class="panel-title">Cash Collected List<b><label runat="server" id="agentName"></label></b>
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12 form-group">
                                <b>Filters Applied:</b>&nbsp;&nbsp;From Date: <%=GetFromDate() %>&nbsp;&nbsp;&nbsp;&nbsp;To Date: <%=GetToDate() %>
                            </div>
                        </div>
                        <div id="main">
                            <div class="row" id="main1" runat="server">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="table-responsive">
                                            <table class="table table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>S. No.</th>
                                                        <th>Branch Name</th>
                                                        <th>Referral Name</th>
                                                        <th>Cash Collected</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="cashCollectedList" runat="server">
                                                    <tr>
                                                        <td colspan="4" align="center"><b>No record found</b></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row" id="drillDown" runat="server">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="table-responsive">
                                            <table class="table table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>S. No.</th>
                                                        <th>Narration</th>
                                                        <th>Date</th>
                                                        <th>Cash Collected</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="drillDownBody" runat="server">
                                                    <tr>
                                                        <td colspan="4" align="center"><b>No record found</b></td>
                                                    </tr>
                                                </tbody>
                                            </table>
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
</asp:Content>
