<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Reports.CancelReport.Manage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function LoadCalendars() {
			ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
			$('#<% =fromDate.ClientID%>').mask('0000-00-00');
			$('#<% =toDate.ClientID%>').mask('0000-00-00');
        }
        LoadCalendars();
    </script>
    <script type='text/javascript' language='javascript'>
    function showReport() {
        var branch = GetValue("<% =sBranch.ClientID%>");
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var coutry = GetValue("<% =pCountry.ClientID%>");
        var ctype = GetValue("<% =cancelType.ClientID%>");

        var url = "../Reports.aspx?reportName=cancelreport" +
                            "&fromDate=" + fromDate +
                            "&toDate=" + toDate +
                            "&branchId=" + branch +
                            "&pcountry=" + coutry +
                            "&cancelType=" + ctype;
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
                        <li class="active"><a href="Manage.aspx">Cancel Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-7">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Transaction Cancel Report</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <label class="col-md-3 control-label">
                                Rec. Country :
                            </label>
                            <div class="col-md-9">
                                <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-3 control-label">
                                Send Branch:
                            </label>
                            <div class="col-md-9">
                                <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-3 control-label">
                                Cancel Date From :
                            </label>
                            <div class="col-md-9">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-3 control-label">
                                Cancel Date  To:
                            </label>
                            <div class="col-md-9">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-3 control-label">
                                Cancel Type :
                            </label>
                            <div class="col-md-9">
                                <asp:DropDownList ID="cancelType" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="">All</asp:ListItem>
                                    <asp:ListItem Value="deny">Hold Cancel</asp:ListItem>
                                    <asp:ListItem Value="Approved">Approve Cancel</asp:ListItem>
                                    <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3 col-md-offset-3">
                                <asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " OnClientClick="return showReport();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>