<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.TranCancel.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<base id="Base2" runat="server" target="_self" />
	<link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
	<link href="../../../../ui/css/style.css" rel="stylesheet" />
	<link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link rel="stylesheet" type="text/css" href="../../../../js/jQuery/jquery-ui.css" />
	<script type="text/javascript" src="/js/functions.js"></script>
	<script type="text/javascript" src="/ui/js/jquery.min.js"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
	<script type="text/javascript" language="javascript">
		function LoadCalendars() {
			ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
			$('#fromDate').mask('0000-00-00');
			$('#toDate').mask('0000-00-00');
		}
		LoadCalendars();
	</script>
	<style type="text/css">
		.table .table {
			background-color: #F5F5F5 !important;
		}
	</style>
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
							<li class="active"><a href="Manage.aspx">Cancel Transaction Report</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-8">
					<div class="panel panel-default recent-activites">
						<div class="panel-heading">
							<h4 class="panel-title">Cancel Transaction Report
							</h4>
							<%-- <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>--%>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">
							<div class="form-group table table-responsive">
								<table cellspacing="0" cellpadding="0" class="table table-responsive" width="100%">
									<tr>
										<td width="20%"></td>
										<td width="40%">
											<span style="font-weight: 600; font-size: 14px; text-decoration: underline;">Sender </span>
										</td>
										<td width="40%">
											<span style="font-weight: 600; font-size: 14px; text-decoration: underline;">Receiver</span>
										</td>
									</tr>
									<tr>
										<td class="frmLable" nowrap="nowrap">Country:</td>
										<td>
											<asp:DropDownList ID="sCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
											</asp:DropDownList>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Required!"
												ForeColor="red" ControlToValidate="sCountry" ValidationGroup="report">
											</asp:RequiredFieldValidator>
										</td>
										<td>
											<asp:DropDownList ID="rCountry" runat="server" AutoPostBack="true"
												CssClass="form-control" OnSelectedIndexChanged="rCountry_SelectedIndexChanged">
											</asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="frmLable" nowrap="nowrap">Agent:</td>
										<td nowrap="nowrap">
											<asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="true"
												OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
											</asp:DropDownList>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Required!"
												ForeColor="red" ControlToValidate="sAgent" ValidationGroup="report">
											</asp:RequiredFieldValidator>
										</td>
										<td>
											<asp:DropDownList ID="rAgent" runat="server" CssClass="form-control"></asp:DropDownList></td>
									</tr>
									<tr>
										<td nowrap="nowrap" class="frmLable">Sending Branch:</td>
										<td nowrap="nowrap" colspan="2">
											<asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList></td>
									</tr>
									<tr>
										<td nowrap="nowrap" class="frmLable">Date From:</td>
										<td colspan="2">
											<table class="table table-responsive">
												<tr>
													<td>From:<span class="ErrMsg">*</span>
														<asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" class="dateField" CssClass="form-control"></asp:TextBox><b>yyyy-MM-dd</b>
														<asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
															ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
														</asp:RequiredFieldValidator>
													</td>
													<td>To:<span class="ErrMsg">*</span>
														<asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" class="dateField" CssClass="form-control"></asp:TextBox><b>yyyy-MM-dd</b>
														<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
															ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
														</asp:RequiredFieldValidator>
													</td>
												</tr>
											</table>
										</td>
									</tr>

									<tr>
										<td nowrap="nowrap" class="frmLable">Cancel Type:</td>
										<td nowrap="nowrap" colspan="2">
											<asp:DropDownList ID="cancelType" runat="server" CssClass="form-control">
												<asp:ListItem Value="">All</asp:ListItem>
												<asp:ListItem Value="denied">Hold Cancel</asp:ListItem>
												<asp:ListItem Value="Approved">Unpaid Cancel</asp:ListItem>
												<asp:ListItem Value="Rejected">Rejected</asp:ListItem>
											</asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td>&nbsp;</td>
										<td>
											<asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary"
												Text=" Search " ValidationGroup="rpt"
												OnClientClick="return showReport();" />
											&nbsp;&nbsp;
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
<script type='text/javascript' language='javascript'>
			function showReport() {
				// sCountry = $('#sCountry option:selected').text();
				var sCountry = GetValue("<% =sCountry.ClientID%>");
		var sAgent = GetValue("<% =sAgent.ClientID%>");
		var sBranch = GetValue("<% =sBranch.ClientID%>");
		var rCountry = GetValue("<% =rCountry.ClientID%>");
		var rAgent = GetValue("<% =rAgent.ClientID%>");
		var fromDate = GetValue("<% =fromDate.ClientID%>");
		var toDate = GetValue("<% =toDate.ClientID%>");
		var ctype = GetValue("<% =cancelType.ClientID%>");
		var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20163300" +
			"&fromDate=" + fromDate +
			"&toDate=" + toDate +
			"&sCountry=" + sCountry +
			"&sAgent=" + sAgent +
			"&sBranch=" + sBranch +
			"&rCountry=" + rCountry +
			"&rAgent=" + rAgent +
			"&ctype=" + ctype;
		OpenInNewWindow(url);
		return false;
			}
</script>
