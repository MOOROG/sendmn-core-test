<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.Reports.SOADomestic.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/functions.js"></script>

    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
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
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h4 class="panel-title"></h4>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">Statement of Account</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivFrm" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">Statement Of Account </h4>

                    </div>
                    <div class="panel-body">

                        <table>
                            <tr>
                                <td>Agent:</td>
                                <td>
                                    <asp:Label ID="lblAgent" runat="server" ></asp:Label></td>
                            </tr>
                            <tr>
                                <td>From Date:</td>
                                <td>
                                    <asp:TextBox ID="fromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>To Date:</td>
                                <td>
                                    <asp:TextBox ID="toDate" runat="server" ReadOnly="true" Width="100%"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>Report For:</td>
                                <td>
                                    <asp:DropDownList ID="reportFor" runat="server"  Width="100%">
                                        <asp:ListItem Value="soa">Principle</asp:ListItem>
                                        <asp:ListItem Value="dcom">Domistic Commission</asp:ListItem>
                                        <asp:ListItem Value="icom">International Commission</asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                        Text="Search" ValidationGroup="rpt" OnClientClick="return showSOA();" />
                                </td>
                            </tr>
                        </table>

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showSOA() {
        if (!Page_ClientValidate('rpt'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var agent = "<% =AgentId %>";
        var reportFor = GetValue("<% =reportFor.ClientID%>");
        if (reportFor == "soa" || reportFor == "dcom" || reportFor == "icom") {
            var url = "soa.aspx?reportName=soadomestic" +
            "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                    "&agent=" + agent +
                        "&reportFor=" + reportFor +
                        "&test=" + reportFor;

            OpenInNewWindow(url);
            return false;
        }
        else {

            alert("Invalid Input Report For, Please try again.");
            return false;
        }
    }
</script>

