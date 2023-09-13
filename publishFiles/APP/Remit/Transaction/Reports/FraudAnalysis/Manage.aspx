<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.FraudAnalysis.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>

    <script language="javascript" type="text/javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =fromTxnDate.ClientID%>", "#<% =toTxnDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('system_security')">System Security</a></li>
                            <li class="active"><a href="manage.aspx">Fraud Analysis</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Fraud Analysis Report (Login)    
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">Agent Country : </label>
                                <div class="col-md-5">
                                    <asp:DropDownList ID="country" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">From Date :</label>
                                <div class="col-md-5">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="fromDate" ErrorMessage="Required!"
                                        ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">To Date :</label>
                                <div class="col-md-5">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator2" ControlToValidate="toDate" ErrorMessage="Required!"
                                        ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Report by :</label>
                                <div class="col-md-5">
                                    <asp:DropDownList runat="server" ID="rptBy" CssClass="form-control">
                                        <asp:ListItem Text="Same User Vs Multiple IP" Value="MIP"></asp:ListItem>
                                        <asp:ListItem Text="Same User Vs Multiple Certificate" Value="MCert"></asp:ListItem>
                                        <asp:ListItem Text="Multiple Fail Login Attempts" Value="FLogin"></asp:ListItem>
                                        <asp:ListItem Text="Login Frequency" Value="LoginFreq"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Operator :</label>
                                <div class="col-md-5">
                                    <asp:DropDownList runat="server" ID="Operator" CssClass="form-control">
                                        <asp:ListItem Text="Equals" Value="="></asp:ListItem>
                                        <asp:ListItem Text="Less Than" Value="<"></asp:ListItem>
                                        <asp:ListItem Text="Greater Than" Value=">" Selected="True"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">Count :</label>
                                <div class="col-md-5">
                                    <asp:TextBox runat="server" ID="count" CssClass="form-control" Text="2"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator runat="server" ID="rqCount" ControlToValidate="count"
                                        ErrorMessage="Required!" ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 "></label>
                                <div class="col-md-5">
                                    <asp:Button runat="server" Text="Login Report" ID="Button2" ValidationGroup="login" CssClass="btn btn-primary m-t-25"
                                        OnClientClick="return showReportLogin();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- second panel -->

                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Fraud Analysis Report(Transaction)  
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-4 control-label">Sending Country: </label>
                                <div class="col-md-5">
                                    <asp:DropDownList ID="sTxnCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Receiving Country: </label>
                                <div class="col-md-5">
                                    <asp:DropDownList ID="rTxnCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">From Date :</label>
                                <div class="col-md-5">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="fromTxnDate" runat="server" onchange="return DateValidation('fromTxnDate','t','toTxnDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <asp:RequiredFieldValidator runat="server" ID="rqfromTxnDate" ControlToValidate="fromTxnDate" ErrorMessage="Required!"
                                        ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">To Date :</label>
                                <div class="col-md-5">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="toTxnDate" onchange="return DateValidation('fromTxnDate','t','toTxnDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <asp:RequiredFieldValidator runat="server" ID="rqtoTxnDate" ControlToValidate="toTxnDate" ErrorMessage="Required!"
                                        ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>
                                </div>
                            </div>



                            <div class="form-group">
                                <label class="col-md-4 control-label">Report by : </label>
                                <div class="col-md-5">
                                    <asp:DropDownList runat="server" ID="ddlReportByTxn" CssClass="form-control">
                                        <asp:ListItem Text="Same User Vs Multiple IP" Value="Same User Vs Multiple IP"></asp:ListItem>
                                        <asp:ListItem Text="Same User Vs Multiple Certificate" Value="Same User Vs Multiple Certificate"></asp:ListItem>
                                        <asp:ListItem Text="Odd Hour Txn Report" Value="OffHour"></asp:ListItem>
                                        <asp:ListItem Text="Same Day User Created and Txn Generated" Value="samedayuserTXN"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Operator : </label>
                                <div class="col-md-5">
                                    <asp:DropDownList runat="server" ID="ddlOperatorTxn" CssClass="form-control">
                                        <asp:ListItem Text="LessThan" Value="<"></asp:ListItem>
                                        <asp:ListItem Text="Greater Than" Value=">" Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="Equals" Value="="></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label">Count: </label>
                                <div class="col-md-5">
                                    <asp:TextBox runat="server" ID="ipcount" CssClass="form-control" Text="2"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <asp:RequiredFieldValidator runat="server" ID="ipcountReqValidator" ControlToValidate="ipcount"
                                        ErrorMessage="Required!" ForeColor="Red" ValidationGroup="txnReport"></asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-md-4"></label>
                                <div class="col-md-5">
                                    <asp:Button runat="server" CssClass="btn btn-primary m-t-25" Text="Txn Report" ID="Button1" ValidationGroup="txnReport" OnClientClick="return showReportTxn();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- <div class="breadCrumb"> Report » Fraud Analysis</div>
    <div>
        <table>
            <tr>
                <td>
                    <table border="0" cellspacing="0" cellpadding="0" class="formTable" width="500">
                        <tr>
                            <th class="frmTitle" colspan="4">
                                Fraud Analysis Report (Login)                           </th>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" class="formLabel">
                                Agent Country:                            </td>
                            <td nowrap="nowrap">
                                <asp:DropDownList ID="country" runat="server" Style="width: 200px;">                                </asp:DropDownList>                            </td>
                            <td nowrap="nowrap" class="formLabel">                            </td>
                            <td nowrap="nowrap">                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" class="formLabel">--%>
        <%--                                From Date:                            </td>
                            <td nowrap="nowrap">
                                <asp:TextBox runat="server" ID="fromDate" Width="110px"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ID="rqFromDate" ControlToValidate="fromDate" ErrorMessage="Required!"
                                    ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>                            </td>
                            <td nowrap="nowrap" class="formLabel">
                                To Date:                            </td>
                            <td nowrap="nowrap">
                                <asp:TextBox runat="server" ID="toDate" Width="110px"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ID="rqtoDate" ControlToValidate="toDate"
                                    ErrorMessage="Required!" ForeColor="Red" ValidationGroup="login"></asp:RequiredFieldValidator>                            </td>
                        </tr>
                        <tr>--%>
        <%--        <td>Report by:</td>
                            <td>
                                <asp:DropDownList runat="server" ID="rptBy" Width="250px">
                                  <asp:ListItem Text="Same User Vs Multiple IP" Value="MIP"></asp:ListItem>
                                  <asp:ListItem Text="Same User Vs Multiple Certificate" Value="MCert"></asp:ListItem>
                                  <asp:ListItem Text="Multiple Fail Login Attempts" Value="FLogin"></asp:ListItem>
                                  <asp:ListItem Text="Login Frequency" Value="LoginFreq"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
							<td>&nbsp;</td>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>--%>
        <%--      <td>Operator:</td>
                          <td><asp:DropDownList runat="server" ID="Operator" Width="150px">
                              <asp:ListItem Text="Equals" Value="=" ></asp:ListItem>
                              <asp:ListItem Text="Less Than" Value="<"></asp:ListItem>
                              <asp:ListItem Text="Greater Than" Value=">" Selected="True"></asp:ListItem>
                            </asp:DropDownList></td>--%>
        <%--                     <td>Count:</td>
                          <td><asp:TextBox runat="server" ID="count" Width="100px" Text="2"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ID="rqCount" ControlToValidate="count"
                                            ErrorMessage="Required!" ForeColor="Red" validationgroup="login"></asp:RequiredFieldValidator></td>
                        </tr>
                        <tr>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                        </tr>
                        <tr>
                          <td>&nbsp;</td>--%>
        <%-- <td><asp:Button runat="server" Text="Login Report" ID="Button2" validationgroup="login"
                       onclientclick="return showReportLogin();"/></td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                        </tr>
                    </table>
                </td>
            </tr>            
        </table>
    </div>
        <div>
        <table>
            <tr>
                <td>
                     <table border="0" cellspacing="0" cellpadding="0" class="formTable"  width="500">
                        <tr>--%>
        <%--     <th class="frmTitle" colspan="4">Fraud Analysis Report(Transaction)</th>
        </tr>   
                        <tr>
                            <td nowrap="nowrap" class="formLabel">Sending Country:</td>
                            <td nowrap="nowrap">
                                <asp:DropDownList ID="sTxnCountry" runat="server" Style="width: 150px;">
                                </asp:DropDownList>
                            </td>
                            <td nowrap="nowrap" class="formLabel" style="display: none;">Receiving Country:</td>
                            <td nowrap="nowrap" style="display: none;">
                                <asp:DropDownList ID="rTxnCountry" runat="server" Style="width: 150px;">
                                </asp:DropDownList>
                            </td>
                        </tr>

        <tr>
            <td nowrap="nowrap" class="formLabel">From Date:</td>
            <td nowrap="nowrap">
                <asp:TextBox runat="server" ID="fromTxnDate" Width="110px"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ID="rqfromTxnDate" ControlToValidate="fromTxnDate" ErrorMessage="Required!"
                    ForeColor="Red" ValidationGroup="txnReport"></asp:RequiredFieldValidator>
            </td>
            <td nowrap="nowrap" class="formLabel">From Date:</td>
            <td nowrap="nowrap">
                <asp:TextBox runat="server" ID="toTxnDate" Width="110px"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ID="rqtoTxnDate" ControlToValidate="toTxnDate" ErrorMessage="Required!"
                    ForeColor="Red" ValidationGroup="txnReport"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>Report by:</td>
            <td>
                <asp:DropDownList runat="server" ID="ddlReportByTxn" Width="250px">
                    <asp:ListItem Text="Same User Vs Multiple IP" Value="Same User Vs Multiple IP"></asp:ListItem>
                    <asp:ListItem Text="Same User Vs Multiple Certificate" Value="Same User Vs Multiple Certificate"></asp:ListItem>
                    <asp:ListItem Text="Odd Hour Txn Report" Value="OffHour"></asp:ListItem>
                    <asp:ListItem Text="Same Day User Created and Txn Generated" Value="samedayuserTXN"></asp:ListItem>
                </asp:DropDownList></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>--%>
        <%--  <td>Operator:</td>
            <td>
                <asp:DropDownList runat="server" ID="ddlOperatorTxn">
                    <asp:ListItem Text="LessThan" Value="<"></asp:ListItem>
                    <asp:ListItem Text="Greater Than" Value=">" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Equals" Value="="></asp:ListItem>
                </asp:DropDownList>
            </td>--%>
        <%--         <td>Count:</td>
            <td>
                <asp:TextBox runat="server" ID="ipcount" Width="100px" Text="2"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ID="ipcountReqValidator" ControlToValidate="ipcount"
                    ErrorMessage="Required!" ForeColor="Red" ValidationGroup="txnReport"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>
                <asp:Button runat="server" Text="Txn Report" ID="Button1" ValidationGroup="txnReport"
                    OnClientClick=" showReportTxn();" /></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        </table>
                </td>
            </tr>           
        </table>
    </div>--%>
    </form>
</body>
</html>
<script type="text/javascript">
    function showReportLogin() {
        var sCountry = GetValue("<%=country.ClientID %>");
        var reportBy = GetValue("<%=rptBy.ClientID %>");
        var fromDate = GetValue("<%=fromDate.ClientID%>");
        var toDate = GetValue("<%=toDate.ClientID%>");
        var Operator = GetValue("<%=Operator.ClientID%>");
        var count = GetValue("<%=count.ClientID%>");

        var url = "../../../../../SwiftSystem/Reports/Reports.aspx?reportName=10122200_login" +
         "&sCountry=" + sCountry +
        "&reportBy=" + reportBy +
        "&fromDate=" + fromDate +
        "&toDate=" + toDate +
        "&Operator=" + Operator +
        "&count=" + count;

        OpenInNewWindow(url);
        return false;
    }
    function showReportTxn() {
        var sCountry = GetValue("<% =sTxnCountry.ClientID %>");
        var rCountry = GetValue("<% =rTxnCountry.ClientID %>");
        var reportByTxn = GetValue("<% =ddlReportByTxn.ClientID %>");
        var fromTxnDate = GetValue("<% =fromTxnDate.ClientID%>");
        var toTxnDate = GetValue("<% =toTxnDate.ClientID%>");
        var OperatorTxn = GetValue("<% =ddlOperatorTxn.ClientID%>");
        var count = GetValue("<% =ipcount.ClientID%>");
        var url = "../../../../../SwiftSystem/Reports/Reports.aspx?reportName=10122200_txn" +
            "&sCountry=" + sCountry +
            "&rCountry=" + rCountry +
            "&reportByTxn=" + reportByTxn +
            "&fromTxnDate=" + fromTxnDate +
            "&toTxnDate=" + toTxnDate +
            "&OperatorTxn=" + OperatorTxn +
            "&count=" + count;
        OpenInNewWindow(url);
        return false;
    }

</script>
