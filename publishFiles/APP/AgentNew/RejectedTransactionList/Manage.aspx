<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.RejectedTransactionList.Manage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
     <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            $('#<%=fromDate.ClientID%>').mask('0000-00-00');
            $('#<%=toDate.ClientID%>').mask('0000-00-00');
        }
        LoadCalendars();
    </script>
    <style>
        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }
    </style>
    <script language="javascript" type="text/javascript">
        function showReport() {

            if (!Page_ClientValidate('rpt'))
                return false;

            var fromDate = GetValue("<% =fromDate.ClientID%>");
            var toDate = GetValue("<% =toDate.ClientID%>");
            var agent = "<%=AgentId %>";

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=rejectedReport" +
                "&from=" + fromDate +
                "&to=" + toDate +
                "&sAgent=" + agent;

            OpenInNewWindow(url);
            return false;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
      <asp:HiddenField ID="hdnIsBranch" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">Rejected Transaction Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivFrm" class="col-md-7" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <i class="fa fa-file-text"></i>
                        <label>Rejected Transaction Report</label>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    From Date:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <div class="input-group m-b10 ">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    To Date:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <div class="input-group m-b10">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox autocomplete="off" ID="toDate" runat="server" class="dateField form-control"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-3 ">
                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                    Text="Search" ValidationGroup="rpt" OnClientClick="return showReport();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
