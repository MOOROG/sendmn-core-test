<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Compliance.ComplianceRpt.List" %>

<!DOCTYPE html>

<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />

<script src="../../../js/functions.js"></script>
<script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
<link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

<link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
<script src="../../../ui/js/bootstrap-datepicker.js"></script>
<script src="../../../ui/js/pickers-init.js"></script>
<script src="../../../ui/js/jquery-ui.min.js"></script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" language="javascript">
        function showComplianceReport() {
            if (!window.Page_ClientValidate('report'))
                return false;
            var fromDate = GetDateValue("<% =fromDate.ClientID %>");
            var toDate = GetDateValue("<% =toDate.ClientID %>");
            var transactionType = GetValue("<% =transactionType.ClientID %>");
            var reportBy = $('#reportBy option:selected').val();

            var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=20601200" +
                    "&fromDate=" + fromDate +
                        "&toDate=" + toDate +
                            "&transactionType=" + transactionType +
                                "&reportBy=" + reportBy;
            OpenInNewWindow(url);
            return false;
        }
        function LoadCalendars() {
            ShowCalFromTo("#<%=fromDate.ClientID%>", "#<%=toDate.ClientID %>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance</a></li>
                            <li class="active"><a href="ComplianceRelease.aspx">Compliance  Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Compliance Report- Multiple Transaction Analysis Rpt
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <table border="0" align="left" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td nowrap="nowrap">
                                                        <div align="left">Date Range:</div>
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <div align="left">From:</div>
                                                        <div class="input-group m-b">
                                                            <span class="input-group-addon">
                                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                                            </span>
                                                            <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                        </div>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Required!" ForeColor="red"
                                                            ControlToValidate="fromDate" ValidationGroup="report">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <div align="left">To:</div>
                                                        <div class="input-group m-b">
                                                            <span class="input-group-addon">
                                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                                            </span>
                                                            <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                        </div>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Required!" ForeColor="red"
                                                            ControlToValidate="toDate" ValidationGroup="report">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <div align="left">Transaction Type:</div>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList ID="transactionType" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="I" Text="International"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Required!" ForeColor="red"
                                                            ControlToValidate="transactionType" ValidationGroup="report">
                                                        </asp:RequiredFieldValidator>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <div align="left">Report By:</div>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList ID="reportBy" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="ssmr" Text="Same Sender/Multiple Receiver"></asp:ListItem>
                                                            <asp:ListItem Value="srms" Text="Same Receiver/Multiple Sender"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ErrorMessage="Required!" ForeColor="red"
                                                            ControlToValidate="reportBy" ValidationGroup="report">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td colspan="3">&nbsp;<input type="button" id="Button1" value=" Search " class="btn btn-primary m-t-25" onclick="showComplianceReport();" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>