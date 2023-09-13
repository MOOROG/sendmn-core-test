<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.TroubleTicket.Manage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" language="javascript">
         $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
        });
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('system_security')">System Security</a></li>
                            <li class="active"><a href="Manage.aspx">Trouble Ticket (Complain) Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Trouble Ticket (Complain) Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-4 control-label">From Date:  <span class="errormsg">*</span> </label>
                                <div class="col-md-7">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">To Date:  <span class="errormsg">*</span> </label>
                                <div class="col-md-7">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">TXN Type:</label>
                                <div class="col-md-7">
                                    <asp:DropDownList ID="txnType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">All</asp:ListItem>
                                        <asp:ListItem Value="D">Domestic</asp:ListItem>
                                        <asp:ListItem Value="I">International</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">TXN Payment Method :</label>
                                <div class="col-md-7">
                                    <asp:DropDownList ID="paymentMethod" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">All</asp:ListItem>
                                        <asp:ListItem Value="Cash Payment">Cash Payment</asp:ListItem>
                                        <asp:ListItem Value="Bank Deposit">Bank Deposit</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Ticket By :</label>
                                <div class="col-md-7">
                                    <asp:DropDownList ID="ticketBy" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">All</asp:ListItem>
                                        <asp:ListItem Value="Head Office">Head Office</asp:ListItem>
                                        <asp:ListItem Value="Agent">Agent</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Type :</label>
                                <div class="col-md-7">
                                    <asp:DropDownList ID="msgType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="C">Complain/Trouble Ticket</asp:ListItem>
                                        <asp:ListItem Value="M">Modify</asp:ListItem>
                                        <asp:ListItem Value="O">Other</asp:ListItem>
                                        <asp:ListItem Value="">All</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Status:</label>
                                <div class="col-md-7">
                                    <asp:DropDownList ID="status" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">All</asp:ListItem>
                                        <asp:ListItem Value="Not Resolved">Not Resolved</asp:ListItem>
                                        <asp:ListItem Value="Resolved">Resolved</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label"></label>
                                <div class="col-md-7">
                                    <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary m-t-25" ValidationGroup="rpt" Text="Search"
                                        OnClientClick="return showReport();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%--  <table border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%"> 
                <table width="100%">
                    <tr>
                        <td height="26" class="bredCrom"> <div > Reports » Trouble Ticket (Complain) Report </div> </td>
                    </tr>
                    <tr>
                        <td height="10" class="welcome"></td>
                    </tr>
                </table>	
            </td>
        </tr>
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0" class="formTable">
                    <tr>
                        <th class="frmTitle" colspan="4">Trouble Ticket (Complain) Report</th>
                    </tr>                   
                    <tr>
                        <td nowrap="nowrap" valign="top"> <div align="right" class="formLabel" > From Date: </div> </td>
                        <td nowrap="nowrap">
                            <asp:TextBox ID= "fromDate" runat = "server" class="fromDatePicker"  size="12" Width="120px"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>


                        </td>
                        <td nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> To Date:</div>
                        </td>
                        <td nowrap="nowrap">--%>
        <%--   <asp:TextBox ID="toDate" runat="server" class="toDatePicker" size="12" Width="120px"></asp:TextBox>
        <span class="errormsg">*</span>
        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
            ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
        </asp:RequiredFieldValidator>


        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" valign="top">
                            <div align="right" class="formLabel">TXN Type:</div>
                        </td>
                        <td nowrap="nowrap" colspan="3">
                            <asp:DropDownList ID="txnType" runat="server" CssClass="input" Width="350px">
                                <asp:ListItem Value="">All</asp:ListItem>
                                <asp:ListItem Value="D">Domestic</asp:ListItem>
                                <asp:ListItem Value="I">International</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>

        <tr>
            <td nowrap="nowrap" valign="top">--%>
        <%--      <div align="right" class="formLabel">TXN Payment Method:</div>
            </td>
            <td nowrap="nowrap" colspan="3">
                <asp:DropDownList ID="paymentMethod" runat="server" CssClass="input" Width="300px">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="Cash Payment">Cash Payment</asp:ListItem>
                    <asp:ListItem Value="Bank Deposit">Bank Deposit</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td nowrap="nowrap" valign="top">
                <div align="right" class="formLabel">Ticket By:</div>
            </td>
            <td nowrap="nowrap" colspan="3">
                <asp:DropDownList ID="ticketBy" runat="server" CssClass="input" Width="300px">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="Head Office">Head Office</asp:ListItem>
                    <asp:ListItem Value="Agent">Agent</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>--%>
        <%--   <td nowrap="nowrap" valign="top">
                <div align="right" class="formLabel">Type:</div>
            </td>
            <td nowrap="nowrap" colspan="3">
                <asp:DropDownList ID="msgType" runat="server" CssClass="input" Width="300px">
                    <asp:ListItem Value="C">Complain/Trouble Ticket</asp:ListItem>
                    <asp:ListItem Value="M">Modify</asp:ListItem>
                    <asp:ListItem Value="O">Other</asp:ListItem>
                    <asp:ListItem Value="">All</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>--%>
        <%--   <td nowrap="nowrap" valign="top">
                <div align="right" class="formLabel">Status:</div>
            </td>
            <td nowrap="nowrap" colspan="3">
                <asp:DropDownList ID="status" runat="server" CssClass="input" Width="150px">
                    <asp:ListItem Value="">All</asp:ListItem>
                    <asp:ListItem Value="Not Resolved">Not Resolved</asp:ListItem>
                    <asp:ListItem Value="Resolved">Resolved</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>--%>
        <%--       <td>&nbsp;</td>
            <td>
                <asp:Button ID="Button1" runat="server" CssClass="button" ValidationGroup="rpt" Text="Search"
                    OnClientClick="return showReport();" />
            </td>
        </tr>
        </table>
            </td>
        </tr>
    </table>--%>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {
        //if (!Page_ClientValidate('rpt'))
        //    return false;
        var fromDate = $('#fromDate').val();
        var toDate = $('#toDate').val();
        var ticketBy = GetValue("<% =ticketBy.ClientID%>");
        var msgType = GetValue("<% =msgType.ClientID%>");
        var txnType = GetValue("<% =txnType.ClientID%>");
        var status = GetValue("<% =status.ClientID%>");
        var paymentMethod = GetValue("<% =paymentMethod.ClientID%>");

        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=troublerpt" +
                 "&fromDate=" + fromDate +
                 "&toDate=" + toDate +
                 "&msgType=" + msgType +
                 "&txnType=" + txnType +
                 "&paymentMethod=" + paymentMethod +
                 "&status=" + status +
                 "&ticketBy=" + ticketBy;

        OpenInNewWindow(url);

        return false;

    }

</script>
