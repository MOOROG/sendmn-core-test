<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Reports.TransactionSummaryReport.Manage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript" language="javascript">
        function OpenReport(rType) {
            //if (!window.Page_ClientValidate('report'))
            //    return false;

            var country = $('#<%=beneficiary.ClientID%> option:selected').text();
            var agent = GetValue("<% =agentName.ClientID %>");
            var branch = GetValue("<% =branch.ClientID %>");
            var status = GetValue("<% =status.ClientID %>");
            var dateType = GetValue("<% =dateType.ClientID %>");
            var from = GetValue("<% =from.ClientID %>");
            var to = GetValue("<% =to.ClientID %>");

            var url = "../Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary=" + country +
                "&agentName=" + agent +
                "&branch=" + branch +
                "&status=" + status +
                "&date=" + dateType +
                "&from=" + from +
                "&to=" + to +
                "&rType=" + rType;

            OpenInNewWindow(url);
            return false;
        }

        function LoadCalendars() {
            $('#<% =from.ClientID%>').mask('0000-00-00');
            $('#<% =to.ClientID%>').mask('0000-00-00');
            ShowCalFromToUpToToday("#<% =from.ClientID%>", "#<% =to.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
    <script type="text/javascript" language="javascript">
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
        function EndRequest(sender, args) {
            if (args.get_error() == undefined) {
                LoadCalendars();
            }
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
                        <li class="active"><a href="Manage.aspx">Transaction Summary Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-9">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Transaction Summary Report</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>

                    <div class="panel-body">
                        <asp:UpdatePanel ID="up" runat="server">
                            <ContentTemplate>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">
                                        Beneficiary :
                                    </label>
                                    <div class="col-md-9">
                                        <asp:DropDownList ID="beneficiary" runat="server" CssClass="form-control" AutoPostBack="false"></asp:DropDownList>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-md-3 control-label">
                                        Agent Name :
                                    </label>
                                    <div class="col-md-9">
                                        <asp:DropDownList ID="agentName" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="">ALL</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">
                                        Sending Branch :
                                    </label>
                                    <div class="col-md-9">
                                        <asp:DropDownList ID="branch" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">
                                        Status :
                                    </label>
                                    <div class="col-md-9">
                                        <asp:DropDownList ID="status" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="">All</asp:ListItem>
                                            <asp:ListItem Value="Paid">Paid-Only</asp:ListItem>
                                            <asp:ListItem Value="Unpaid">Unpaid-Only</asp:ListItem>
                                            <asp:ListItem Value="Post">Post-Only</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group form-inline">
                                    <div class="col-sm-3">
                                        <label class="control-label">
                                            Date :
                                        </label>
                                    </div>
                                    <div class="col-sm-3">
                                        <label class="control-label">
                                            Date Type:
                                        </label>
                                        <asp:DropDownList ID="dateType" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="createdDate">By TRN Date</asp:ListItem>
                                            <asp:ListItem Value="approvedDate" Selected="true">By Confirm Date</asp:ListItem>
                                            <asp:ListItem Value="PaidDate">By Paid Date</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-3">
                                        <label class="control-label">
                                            From Date :
                                        </label>
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="from" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-sm-3">
                                        <label class="control-label">
                                            To Date :
                                        </label>
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="to" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" placeholder="To Date" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group form-inline">
                                    <label class="col-md-3 control-label">
                                        &nbsp;
                                    </label>
                                    <div class="col-md-9">
                                        <input type="button" id="btnDetail" value="View Detail" class="btn btn-primary m-t-25 form-group" onclick="OpenReport('Detail');" onclick="    return btnDetail_onclick()" onclick="    return btnDetail_onclick()" />
                                        <input type="button" id="Button1" value="View BranchWise Report" class="btn btn-primary m-t-25 form-group" onclick="OpenReport('BranchWise');" />
                                        <input type="button" id="Button3" value="View Rec.CountryWise Report" class="btn btn-primary m-t-25 form-group" onclick="OpenReport('ReceivingAgentCountryWise');" />
                                    </div>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="beneficiary" EventName="SelectedIndexChanged" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>