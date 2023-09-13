<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.RemittancePayableRpt.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/swift_autocomplete.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="Manage.aspx">Remittance Payble Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Remittance Payable Report  
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-4 control-label">From Date :</label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">To Date :</label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Sending Agent : </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                              <div class="form-group">
                                <label class="col-md-4 control-label">Report Type : </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="rptType" runat="server" CssClass="form-control">
                                         <asp:ListItem Value="s">Summary</asp:ListItem>
                                          <asp:ListItem Value="d">Detail</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-4">
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text="Search" ValidationGroup="rpt" OnClientClick="return ShowReport();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--   <div class="bredCrom">Reports » Remittance Payable Report </div>
        <table class="formTable">
            <tr>
                <th class="frmTitle" colspan="2">Remittance Payable Report </th>
            </tr>
            <tr>
                <td nowrap="nowrap">
                    <div align="left" class="formLabel">From Date: </div>
                </td>
                <td nowrap="nowrap">
                    <asp:TextBox ID="fromDate" runat="server" class="dateField" size="12" Width="75px"></asp:TextBox>
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                    </asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td nowrap="nowrap">
                    <div align="left" class="formLabel">To Date: </div>
                </td>
                <td nowrap="nowrap">
                    <asp:TextBox ID="toDate" runat="server" class="dateField" size="12" Width="75px"></asp:TextBox>
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                    </asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <div align="left" class="formLabel">Sending Agent: </div>
                </td>
                <td nowrap="nowrap">
                    <asp:DropDownList runat="server" ID="sAgent" Width="200px" /></td>
            </tr>
            <tr>
                <td>--%>
        <%--    <div align="left" class="formLabel">Report Type: </div>
                </td>
                <td nowrap="nowrap">
                    <asp:DropDownList runat="server" ID="rptType">
                        <asp:ListItem Value="s">Summary</asp:ListItem>
                        <asp:ListItem Value="d">Detail</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td nowrap="nowrap">&nbsp;</td>
                <td>
                    <asp:Button ID="BtnSave" runat="server" CssClass="button"
                        Text="Search" ValidationGroup="rpt" OnClientClick="return ShowReport();" />
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function ShowReport() {
        //if (!Page_ClientValidate('rpt'))
        //    return false;
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var sAgent = GetValue("<% =sAgent.ClientID%>");
        var rptType = GetValue("<% =rptType.ClientID%>");
        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20161200" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sAgent=" + sAgent +
                "&rptType=" + rptType;

        OpenInNewWindow(url);
        return false;

    }
</script>

<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
        }
    }
</script>

