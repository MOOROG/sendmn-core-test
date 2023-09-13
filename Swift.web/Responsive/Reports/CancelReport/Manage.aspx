<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.Reports.CancelReport.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/functions.js"></script>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/jQuery/jquery-1.4.1.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <script type="text/javascript">
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
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="List.aspx">Cancel Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-7">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Cancel Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3 control-label">
                                    Rec. Country :
                                </label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">
                                    Send Branch:
                                </label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">
                                    Cancel Date From :
                                </label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" runat="server" ReadOnly="true" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">
                                    Cancel Date  To:
                                </label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" ReadOnly="true" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">
                                    Cancel Type :
                                </label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="cancelType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">All</asp:ListItem>
                                        <asp:ListItem Value="deny">Hold Cancel</asp:ListItem>
                                        <asp:ListItem Value="Approved">Approve Cancel</asp:ListItem>
                                        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-3 col-md-offset-3">
                                    <asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " OnClientClick="return showReport();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type='text/javascript' language='javascript'>
    function showReport() {
        var branch = GetValue("<% =sBranch.ClientID%>");
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var coutry = GetValue("<% =pCountry.ClientID%>");
        var ctype = GetValue("<% =cancelType.ClientID%>");

        var url = "../../Reports.aspx?reportName=cancelreport" +
                            "&fromDate=" + fromDate +
                            "&toDate=" + toDate +
                            "&branchId=" + branch +
                            "&pcountry=" + coutry +
                            "&cancelType=" + ctype;
        OpenInNewWindow(url);
        return false;
    }
</script>
