<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.SOA.Manage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $('#<%=fromDate.ClientID%>').mask('0000-00-00');
            $('#<%=toDate.ClientID%>').mask('0000-00-00');
        });

        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);

        }
        LoadCalendars();
    </script>
    <script type="text/javascript">
        function OpenReport() {

            var fromDate = GetDateValue("<% =fromDate.ClientID %>");
            var toDate = GetDateValue("<% =toDate.ClientID %>");
            var url = "../../Reports.aspx?reportName=40121000&fromDate=" + fromDate +
                "&toDate=" + toDate;
            OpenInNewWindow(url);
        }
        function DownloadExcel(url) {
            OpenInNewWindow(url);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h4 class="panel-title"></h4>
                    <ol class="breadcrumb">
                        <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                        <li class="active"><a href="Manage.aspx">Statement Of Account Report</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div id="Div1" runat="server">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">Statement Of Account </h4>
                </div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            Confirm Date From:<span class="ErrMsg">*</span>
                        </label>
                        <div class="col-md-4">
                            <asp:TextBox autocomplete="off" ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" class="date-field" size="12" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate"
                                ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">
                            Confirm Date To :<span class="ErrMsg">*</span>
                        </label>
                        <div class="col-md-4">
                            <asp:TextBox autocomplete="off" ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" class="toDatePicker" size="12" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate"
                                ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">&nbsp;</label>
                        <div class="col-md-4">
                            <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary" Text="Show" ValidationGroup="rpt"
                                OnClick="BtnSave_Click" />
                        </div>
                    </div>
                    <div class="form-group table table-responsive" id="DivFrm" runat="server">
                        <table class="table table-responsive table-condensed table-bordered">
                        </table>
                    </div>
                    <div class="form-group" id="DivRptHead" runat="server">
                        <div id="head" style="width: 80%" class="reportHead">
                            Statement Of Account
                        </div>
                        <div id="filters" class="reportFilters">
                            <asp:Label runat="server" ID="lblAgentName"></asp:Label>
                            | From Date=<asp:Label runat="server" ID="lblFrmDate"></asp:Label>
                            &nbsp;To Date=<asp:Label runat="server" ID="lbltoDate"></asp:Label>&nbsp;| Generated On=
                                    <asp:Label runat="server" ID="lblGeneratedDate"></asp:Label>
                            &nbsp;| Generated By=
                                    <asp:Label runat="server" ID="lblGeneratedBy"></asp:Label>
                            &nbsp;| Statement Currency=
                                    <asp:Label runat="server" ID="lblCurr"></asp:Label>
                        </div>
                        <div id="rptDiv" runat="server">
                        </div>
                        <table class="table table-responsive table-condensed table-bordered">
                            <tr>
                                <th>
                                    <div align="left">
                                        Opening Balance:
                                    </div>
                                </th>
                                <td>
                                    <asp:Label runat="server" ID="lblOpSing"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        <asp:Label runat="server" ID="lblOpAmt"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th width="125">
                                    <div align="left">
                                        DR Total:
                                    </div>
                                </th>
                                <td width="33">&nbsp;
                                </td>
                                <td width="226">
                                    <div align="right">
                                        <asp:Label runat="server" ID="lblDrTotal"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div align="left">
                                        CR Total:
                                    </div>
                                </th>
                                <td>&nbsp;
                                </td>
                                <td>
                                    <div align="right">
                                        <asp:Label runat="server" ID="lblCrTotal"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div align="left">
                                        Closing Balance:
                                    </div>
                                </th>
                                <td>
                                    <asp:Label runat="server" ID="lblCloSign"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        <asp:Label runat="server" ID="lblCloAmt"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <div align="right">
                                        <asp:Label runat="server" ID="lblAmtMsg" Style="font-weight: 700; color: Red;"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>