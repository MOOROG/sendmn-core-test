<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="DailyCashReportTransactionWise.aspx.cs" Inherits="Swift.web.AgentNew.Reports.DailyCashReport.DailyCashReportTransactionWise" %>
<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            $('#<%=fromDate.ClientID%>').mask('0000-00-00');
            $('#<%=toDate.ClientID%>').mask('0000-00-00');
        }
        LoadCalendars();
    </script>

    <script>
        function ViewTranDetail(tranId) {
            var url = "/agentnew/SearchTxnReport/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=" + tranId;
            OpenInNewWindow(url);
        }

    </script>
    <style>
        @media print {
            .dateDiv {
                display: none;
            }

            .footer {
                display: none;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Agent Report</a></li>
                        <li class="active"><a href="DailyCashReportTransactionWise.aspx">Daily Cash Transcation Wise</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div id="DivFrm" class="col-md-7" runat="server">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <i class="fa fa-file-text"></i>
                    <label>Daily Cash Transaction Report</label>
                </div>
                <div class="panel-body">
                    <div class="form-group dateDiv">
                        <div class="col-md-3">
                            <label>
                               Referal Code:
                            <span class="errormsg">*</span>
                            </label>
                        </div>
                        <div class="col-md-9">
                             <uc1:swifttextbox id="introducerTxt" runat="server" category="remit-CASHRPT" cssclass="form-control" title="Blank for All" />
                        </div>
                    </div>

                    <div class="form-group dateDiv">
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
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="form-group dateDiv">
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
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="form-group dateDiv">
                        <div class="col-md-offset-3 col-md-3 ">
                            <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                Text="Search" ValidationGroup="rpt" OnClick="BtnSave_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="mainDiv" runat="server" class="row">
            <div class="col-md-12">
                <div class="table-responsive">
                    <div class="col-md-12 form-group" align="center">
                        <%=Swift.web.Library.GetStatic.getCompanyHead() %>
                    </div>
                    <div class="col-md-6 col-xs-6" align="left">
                        <label>Daily Cash Report Transaction Wise: <%=Swift.web.Library.GetStatic.GetUser() %></label>
                    </div>
                    <div class="col-md-3 col-xs-3" align="right">
                        <label runat="server">From Date:</label>
                        <label id="fDate" runat="server">From Date:</label>
                    </div>
                    <div class="col-md-3 col-xs-3" align="right">
                        <label runat="server">To Date:</label>
                        <label id="tDate" runat="server">To Date:</label>
                    </div>
                    <div class="table table-responsive">
                        <table class="table table-bordered table-condensed table-hover">
                            <thead>
                                <tr>
                                    <th>S.No.</th>
                                    <th>Date</th>
                                    <th><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> No.</th>
                                    <th>Sender Name</th>
                                    <th>Amount (Yen)</th>
                                </tr>
                            </thead>
                            <tbody id="cashRport" runat="server">
                                <tr>
                                    <td colspan="4" align="center">No Data to Display!</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-md-6 col-xs-6" align="left">
                        ---------------------<br />
                        <label>Submitted By: <%=Swift.web.Library.GetStatic.GetUser() %></label>
                    </div>
                    <div class="col-md-6 col-xs-6" align="right">
                        ---------------------<br />
                        <label>Approved By:</label>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
