<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TopupHistoryRpt.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.Reports.TopupHistoryRpt" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript" language="javascript">
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
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="TopuphistoryRpt.aspx">Credit Security Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="Javascript:void(0)" class="selected" target="_self">Balance Topup History Report </a></li>
                    <li class="active"><a href="CreditSecurityRPT.aspx" target="_self">Agent Credit Security Report</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Topup History</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">From Date :  </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Required!" ForeColor="red"
                                                ControlToValidate="fromDate" ValidationGroup="report">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">To Date :  </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                                ControlToValidate="toDate" ErrorMessage="Required!" ForeColor="red"
                                                ValidationGroup="report">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">Agent: </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="agent" runat="server" Category="remit-sAgent" CssClass="required" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">User :  </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="user" runat="server" Category="remit-adminUser" CssClass="required" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3 control-label"></label>
                                        <div class="col-md-8">
                                            <asp:Button ID="btn" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " OnClientClick="showReport();"></asp:Button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%--   <div class="bredCrom">Credit Security Management » Reports</div>
        <div>
            <table width="100%">
                <tr>
                    <td height="10">
                        <div class="tabs">
                            <ul>
                                <li><a href="#" class="selected">Balance Topup History Report </a></li>
                                <li><a href="CreditSecurityRPT.aspx">Agent Credit Security Report</a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="formTable">
                            <tr>
                                <th class="frmTitle" colspan="2">Topup History</th>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">From Date:</td>
                                <td>
                                    <asp:TextBox ID="fromDate" runat="server" class="dateField" Width="80px"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Required!" ForeColor="red"
                                        ControlToValidate="fromDate" ValidationGroup="report">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">To Date:</td>
                                <td>
                                    <asp:TextBox ID="toDate" runat="server" class="dateField" Width="80px"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                        ControlToValidate="toDate" ErrorMessage="Required!" ForeColor="red"
                                        ValidationGroup="report">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>Agent:</td>
                                <td>
                                    <uc1:SwiftTextBox ID="agent" runat="server" Width="400px" Category="sAgent" CssClass="required" />
                                </td>
                            </tr>
                            <tr>
                                <td>User:</td>
                                <td>
                                    <uc1:SwiftTextBox ID="user" runat="server" Width="300px" Category="adminUser" CssClass="required" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>--%>
        <%--           <td style="height: 50px;">
                                    <asp:Button ID="btn" runat="server" CssClass="button" Text=" Search " OnClientClick="showReport();"></asp:Button>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>--%>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {
        var fromDate = GetDateValue("<%=fromDate.ClientID%>");
        var toDate = GetDateValue("<%=toDate.ClientID%>");
        var agent = GetItem("<% = agent.ClientID %>")[0];
        var user = GetItem("<% = user.ClientID %>")[1];
        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20181800_1" +
            "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                    "&agent=" + agent +
                        "&userName=" + user;
        OpenInNewWindow(url);
        return false;
    }
</script>