<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Reports.UserwiseTransactionReport.Manage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            $('#<% =fromDate.ClientID%>').mask('0000-00-00');
            $('#<% =toDate.ClientID%>').mask('0000-00-00');
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
    <script language="javascript" type="text/javascript">
        function showReport() {
            var fromDate = GetValue("<% =fromDate.ClientID%>");
            var toDate = GetValue("<% =toDate.ClientID%>");
            var branch = GetValue("<% =branch.ClientID%>");
            var userName = GetValue("<% =userName.ClientID%>");
            var rCountry = GetValue("<% =recCountry.ClientID%>");

            var url = "View.aspx?reportName=uwdetail" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&branch=" + branch +
                "&userName=" + userName +
                "&rCountry=" + rCountry;

            OpenInNewWindow(url);

            return false;

        }

        function showReportSummary() {
            var fromDate = GetValue("<% =fromDate.ClientID%>");
            var toDate = GetValue("<% =toDate.ClientID%>");
            var branch = GetValue("<% =branch.ClientID%>");
            var userName = GetValue("<% =userName.ClientID%>");
            var rCountry = GetValue("<% =recCountry.ClientID%>");

            var url = "View.aspx?reportName=uwsummary" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&branch=" + branch +
                "&userName=" + userName +
                "&rCountry=" + rCountry;

            OpenInNewWindow(url);

            return false;

        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <ol class="breadcrumb">
                        <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                        <li class="active"><a href="Manage.aspx">User Wise Transaction Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <!-- First Panel -->

            <div class="col-md-6">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">User Wise Transaction Report</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="form-group">
                                <label class="col-md-3">Branch:</label>
                                <div class="col-md-9 ">
                                    <asp:DropDownList ID="branch" runat="server" CssClass="form-control" AutoPostBack="true"
                                        OnSelectedIndexChanged="branch_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">User Name:</label>

                                <div class="col-md-9">
                                    <asp:DropDownList ID="userName" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group ">
                                <label class="col-md-3">From Date:</label>

                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">To Date:</label>

                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">Rec. Country:</label>

                                <div class="col-md-9">
                                    <asp:DropDownList ID="recCountry" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group ">
                                <label class="col-md-3">&nbsp;</label>

                                <div class="form-group col-md-9">
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search Detail " OnClientClick="return showReport();" />
                                    <asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search Summary " OnClientClick="return showReportSummary();" />
                                    <label></label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>