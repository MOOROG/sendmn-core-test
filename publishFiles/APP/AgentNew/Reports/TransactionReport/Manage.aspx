<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Reports.TransactionReport.Manage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">

        function GetAgentId() {
            return GetValue("<%=pAgent.ClientID %>");
        }

        function LoadCalendars() {
            $('#<% =frmDate.ClientID%>').mask('0000-00-00');
            $('#<% =toDate.ClientID%>').mask('0000-00-00');
            ShowCalFromToUpToToday("#<% =frmDate.ClientID%>", "#<% =toDate.ClientID%>");
        }
        LoadCalendars();
    </script>
    <script type="text/javascript">
        function OpenReport(rptType) {
            var country = "";
            country = GetValue("<% =pCountry.ClientID %>");
            if (country != "") {
                country = GetElement("<% = pCountry.ClientID%>").options[GetElement("<% = pCountry.ClientID%>").selectedIndex].text;
            }
            var agent = GetValue("<% =pAgent.ClientID %>");
            var sBranch = GetValue("<% =Sbranch.ClientID %>");
         <%-- var depositType = GetValue("<% =depositType.ClientID %>");--%>
            var depositType = "";

            var orderBy = GetValue("<% =orderBy.ClientID %>");
            var status = GetValue("<% =status.ClientID %>");
            var paymentType = GetValue("<% =paymentType.ClientID %>");
            var dateField = GetValue("<% =dateField.ClientID %>");
            var from = GetValue("<% =frmDate.ClientID %>");
            var to = GetValue("<% =toDate.ClientID %>");
            var transType = GetValue("<% =tranType.ClientID %>");
            var searchBy = GetValue("<% =searchBy.ClientID %>");
            var searchByValue = GetValue("<% =searchByValue.ClientID %>");
            var displayTranNo = "";
            if ($('#displayTranNo:checkbox:checked').length > 0) {
                displayTranNo = "Y";
            }
            else {
                displayTranNo = "N";
            }

            var url = "../Reports.aspx?reportName=40111600&pCountry=" + country +
                "&pAgent=" + agent +
                "&sBranch=" + sBranch +
                "&depositType=" + depositType +
                "&searchBy=" + searchBy +
                "&searchByValue=" + searchByValue +
                "&orderBy=" + orderBy +
                "&status=" + status +
                "&paymentType=" + paymentType +
                "&dateField=" + dateField +
                "&from=" + from +
                "&to=" + to +
                "&transType=" + transType +
                "&rptType=" + rptType +
                "&displayTranNo=" + displayTranNo;

            OpenInNewWindow(url);
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
                        <li class="active"><a href="Manage.aspx">Transaction Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <!-- First Panel -->
            <div class="col-md-8">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Transaction Report</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-3 form-group" style="display: none;">
                                <label>
                                    Beneficiary:
                                </label>
                            </div>
                            <div class="col-md-9 form-group" style="display: none;">
                                <asp:DropDownList runat="server" CssClass="form-control" ID="pCountry" Width="300px"
                                    AutoPostBack="false">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group" style="display: none;">
                                <label>Agent Name:</label>
                            </div>
                            <div class="col-md-9 form-group" style="display: none;">
                                <asp:DropDownList runat="server" ID="pAgent" Width="300px" AutoPostBack="true" CssClass="form-control">
                                    <asp:ListItem Value="">All</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Branch Name:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList ID="Sbranch" runat="server" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Search By:</label>
                            </div>
                            <div class="col-md-4 form-group">
                                <asp:DropDownList runat="server" ID="searchBy" CssClass="form-control">
                                    <asp:ListItem Value="" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="sName">By Sender Name</asp:ListItem>
                                    <asp:ListItem Value="rName">By Receiver Name</asp:ListItem>
                                    <asp:ListItem Value="icn">By BRN</asp:ListItem>
                                    <asp:ListItem Value="cAmt">Collection Amount</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4 form-group">
                                <asp:TextBox runat="server" ID="searchByValue" placeholder="Search by Value" CssClass="form-control">
                                </asp:TextBox>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Order By:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList runat="server" ID="orderBy" CssClass="form-control">
                                    <asp:ListItem Value="sName">By Sender Name</asp:ListItem>
                                    <asp:ListItem Value="sCompany">By Sender Company</asp:ListItem>
                                    <asp:ListItem Value="rName">By Receiver Name</asp:ListItem>
                                    <asp:ListItem Value="rAmnt">By Receive Amt</asp:ListItem>
                                    <asp:ListItem Value="empId">By Emp Id</asp:ListItem>
                                    <asp:ListItem Value="dot" Selected="True">By Date Of Transaction(DOT)</asp:ListItem>
                                    <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Status:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList runat="server" ID="status" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="status_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Tran Type:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList runat="server" ID="tranType" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Payment Type:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList runat="server" ID="paymentType" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Date Type:</label>
                            </div>
                            <div class="col-md-9 form-group">
                                <asp:DropDownList runat="server" ID="dateField" CssClass="form-control">
                                    <asp:ListItem Value="trnDate">By TRN Date</asp:ListItem>
                                    <asp:ListItem Value="confirmDate" Selected="true">By Confirm Date</asp:ListItem>
                                    <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 form-group">
                                <label>Date:</label>
                            </div>
                            <div class="col-md-4 form-group">
                                <label>From</label>
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="frmDate" onchange="return DateValidation('frmDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4 form-group">
                                <label>To</label>
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="toDate" onchange="return DateValidation('frmDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-12 form-group" style="display: none;">
                                <asp:CheckBox runat="server" ID="displayTranNo" Text="Display Tran No" />
                            </div>
                            <div class="col-md-12 col-md-offset-3 form-group">
                                <input type="button" class="btn btn-primary m-t-25" value="View Send Details" onclick="return OpenReport('s');" />&nbsp;
                                <input type="button" class="btn btn-primary m-t-25" value="View Pay Details" onclick="return OpenReport('p');" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>