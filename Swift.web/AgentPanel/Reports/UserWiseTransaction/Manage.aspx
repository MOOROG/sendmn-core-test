<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentPanel.Reports.UserWise.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../js/functions.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
		function LoadCalendars() {
			ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
			$('#fromDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
		}
		LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">User Wise Transaction Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- First Panel -->

                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">User Wise Transaction Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive">
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">
                                            Branch:
                                        </div>
                                    </td>
                                    <td nowrap="nowrap" colspan="3">
                                        <asp:DropDownList ID="branch" runat="server" Width="350px" CssClass="form-control" AutoPostBack="true"
                                            OnSelectedIndexChanged="branch_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">
                                            User Name:
                                        </div>
                                    </td>
                                    <td nowrap="nowrap" colspan="3">
                                        <asp:DropDownList ID="userName" runat="server" CssClass="form-control" Width="350px">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">
                                            From Date:
                                        </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="fromDate" runat="server" ReadOnly="true" Width="311px" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" valign="top">
                                        <div align="left" class="formLabel">
                                            To Date:
                                        </div>
                                        <td nowrap="nowrap">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="toDate" runat="server" ReadOnly="true" Width="311px" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">Rec. Country:</div>
                                    </td>
                                    <td nowrap="nowrap" colspan="3">
                                        <asp:DropDownList ID="recCountry" runat="server" CssClass="form-control" Width="350px">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;
                                    </td>
                                    <td colspan="3">
                                        <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search Detail " OnClientClick="return showReport();" />
                                        &nbsp;&nbsp;
                                    <asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search Summary " OnClientClick="return showReportSummary();" />
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                            </table>
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
			var fromDate = GetValue("<% =fromDate.ClientID%>");
		var toDate = GetValue("<% =toDate.ClientID%>");
		var branch = GetValue("<% =branch.ClientID%>");
		var userName = GetValue("<% =userName.ClientID%>");
		var rCountry = GetValue("<% =recCountry.ClientID%>");

		var url = "View.aspx?reportName=uwdetail" +
			"&fromDate=" + fromDate +
			"&toDate=" + toDate +
			"&branch=" + branch +
			"&userName=" + userName +
			"&rCountry=" + rCountry;

		OpenInNewWindow(url);

		return false;

		}

		function showReportSummary() {
			var fromDate = GetValue("<% =fromDate.ClientID%>");
		var toDate = GetValue("<% =toDate.ClientID%>");
		var branch = GetValue("<% =branch.ClientID%>");
		var userName = GetValue("<% =userName.ClientID%>");
		var rCountry = GetValue("<% =recCountry.ClientID%>");

		var url = "View.aspx?reportName=uwsummary" +
			"&fromDate=" + fromDate +
			"&toDate=" + toDate +
			"&branch=" + branch +
			"&userName=" + userName +
			"&rCountry=" + rCountry;

		OpenInNewWindow(url);

		return false;

	}
</script>