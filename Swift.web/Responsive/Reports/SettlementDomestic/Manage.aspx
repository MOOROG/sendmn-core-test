<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.Reports.SettlementDomestic.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/functions.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
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
        <asp:HiddenField ID="hdnIsBranch" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">Settlement Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivFrm" runat="server">

                <div class="panel panel-default">
                    <div class="panel-heading">
                        <i class="fa fa-file-text"></i>
                        <label>Settlement Report</label>
                    </div>
                    <div class="panel-body">
                        <div class="row panels">
                            <div class="col-sm-2">
                                <label>
                                    From Date:
                            <span class="errormsg">*</span>

                                </label>
                            </div>
                            <div class="col-sm-4">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="fromDate" runat="server" class="dateField form-control" Width="100%"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="row panels">
                            <div class="col-sm-2">
                                <label>
                                    To Date:
                            <span class="errormsg">*</span>

                                </label>
                            </div>
                            <div class="col-sm-4">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="toDate" runat="server" class="dateField form-control" Width="100%"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="row panels" id="trBranch" runat="server" visible="false">
                            <div class="col-sm-2">Branch:</div>
                            <div class="col-sm-4">
                                <asp:DropDownList ID="branch" runat="server" Width="100%" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="row panels">
                            <div class="col-sm-2"></div>
                            <div class="col-sm-4">
                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                    Text="Search" ValidationGroup="rpt" OnClientClick="return showReport();" />
                            </div>
                        </div>
                    </div>
                </div>



            </div>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {
        if (!Page_ClientValidate('rpt'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var agent = "<%=AgentId %>";
        var flag = "<%=Flag %>";
        var branch = "";
        if (flag == "Y")
            branch = GetValue("<% =branch.ClientID%>");
        else
            branch = "<%=BranchId %>";

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=settlementint&FLAG=m2" +
                "&from=" + fromDate +
                "&to=" + toDate +
                "&sAgent=" + agent +
                "&sBranch=" + branch;

        OpenInNewWindow(url);
        return false;
    }
</script>

