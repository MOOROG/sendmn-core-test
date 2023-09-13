<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.OperationStartSetup.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Src="../../../Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<base id="Base1" target="_self" runat="server" />
	<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
	<script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
	<script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
	<script src="../../../js/swift_calendar.js" type="text/javascript"></script>
	<script src="../../../js/swift_grid.js" type="text/javascript"> </script>
	<script src="../../../js/functions.js" type="text/javascript"> </script>
	<link href="../../../ui/css/style.css" rel="stylesheet" />
	<script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
	<script type="text/javascript" language="javascript">
		function GetCountryId() {
			return GetItem("<% = sendingCountry.ClientID%>")[0];
		}
		function GetAgentId() {
			return GetItem("<% = sendingAgent.ClientID%>")[0];
		}

		function GetReceivingCountryId() {
			return GetItem("<% = receivingCountry.ClientID%>")[0];
		}

		function CallBackAutocomplete(id) {
			var d = ["", ""];
			if (id == "#<% = sendingCountry.ClientID%>") {
				SetItem("<% =sendingAgent.ClientID%>", d);
				SetItem("<% =sendingBranch.ClientID%>", d);

				<% = sendingAgent.InitFunction()%>;
				<% = sendingBranch.InitFunction()%>;

			}
			else if (id == "#<% = sendingAgent.ClientID%>") {
				SetItem("<% =sendingBranch.ClientID%>", d);
				<% = sendingBranch.InitFunction()%>;

			}
			else if (id == "#<% = receivingCountry.ClientID%>") {
				SetItem("<% =receivingAgent.ClientID%>", d);
				<% = receivingAgent.InitFunction()%>;
			}
		}
	</script>
	<script type="text/javascript">
		function LoadCalendars() {
			ShowCalFromTo("#<% =schemeStartDate.ClientID%>", "#<% =schemeEndDate.ClientID%>", 1);
		}
		LoadCalendars();
	</script>
	<style type="text/css">
		.style1 {
			width: 252px;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div class="page-wrapper">
			<div id="toggleText" style="display: none">Required</div>
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="#" class="selected">List </a></li>
							<li><a href="Manage.aspx">Bonus Setup</a></li>
						</ol>
					</div>
				</div>
			</div>
			<table style="width: 100%">
				<tr>
					<td height="10">
						<div class="listtabs" style="margin-left: 8px;">
							<ul class="nav nav-tabs" role="tablist">
								<li><a href="list.aspx">User List </a></li>
								<li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Bonus Setup</a></li>
							</ul>
						</div>
					</td>
				</tr>
				<tr>
					<td>
						<div class="tab-content">
							<div role="tabpanel" class="tab-pane active" id="list">
								<div class="row">
									<div class="col-md-12">
										<div class="panel panel-default">
											<div class="panel-heading">
												<h4 class="panel-title">User Information</h4>
												<div class="panel-actions">
													<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
												</div>
											</div>
											<div class="panel-body">
												<table class="table-condensed">
													<tr>
														<th colspan="4" class="frmTitle">Operation Scheme Setup</th>
													</tr>
													<tr>
														<td colspan="4" class="fromHeadMessage"></td>
													</tr>
													<tr>
														<td class="frmLable" style="width: 132px;">Scheme Name:</td>
														<td colspan="3">
															<asp:TextBox ID="schemeName" runat="server" Width="192px" CssClass="form-control"></asp:TextBox>
															<asp:RequiredFieldValidator runat="server" ID="rfv1" Display="Dynamic" ControlToValidate="schemeName"
																ErrorMessage="Required" ValidationGroup="scheme" ForeColor="red"></asp:RequiredFieldValidator>
															<%--<asp:RegularExpressionValidator
																ID="RegularExpressionValidator1" runat="server" ForeColor="Red"
																ControlToValidate="schemeName" Display="Dynamic"
																ErrorMessage="Numbers are not allowed" ValidationGroup="scheme"
																ValidationExpression="^[a-zA-Z\s]*$"></asp:RegularExpressionValidator>--%>
														</td>
													</tr>
													<tr>
														<td class="frmLable" style="width: 132px">Sending Country:</td>
														<td nowrap="nowrap">
															<uc1:SwiftTextBox ID="sendingCountry" Category="remit-countrySend" runat="server" Width="192px" />

															<asp:Label runat="server" ID="lblSendingCountry" ForeColor="red"></asp:Label>
														</td>
														<td style="width: 131px;" class="frmLable">Receiving Country:</td>
														<td nowrap="nowrap" class="style1">
															<uc1:SwiftTextBox ID="receivingCountry" Category="remit-countryPay" runat="server" Width="192px" />
														</td>
													</tr>
													<tr>
														<td style="width: 132px;" class="frmLable">Sending Agent:</td>
														<td nowrap="nowrap">
															<uc1:SwiftTextBox ID="sendingAgent" Category="remit-s-r-agent" Param1="@GetCountryId()"
																runat="server" Width="192px" />
														</td>
														<td class="frmLable" style="width: 131px">Receiving Agent:
														</td>
														<td nowrap="nowrap" class="style1">
															<uc1:SwiftTextBox ID="receivingAgent" Category="remit-s-r-agent" Param1="@GetReceivingCountryId()"
																runat="server" Width="192px" />
														</td>
													</tr>
													<tr>
														<td class="frmLable" style="width: 132px">Sending Branch:</td>
														<td nowrap="nowrap">
															<uc1:SwiftTextBox ID="sendingBranch" Category="remit-branch" Param1="@GetAgentId()" runat="server"
																Width="192px" />
														</td>
													</tr>
													<tr>

														<td class="frmLable" style="width: 132px">Start Date:</td>


														<td nowrap="nowrap">

															<asp:TextBox runat="server" ID="schemeStartDate" Width="100%" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>

															<asp:RequiredFieldValidator runat="server" ID="rfv2" ControlToValidate="schemeStartDate"
																ErrorMessage="Required" ForeColor="red" ValidationGroup="scheme"></asp:RequiredFieldValidator>
														</td>
														<td class="frmLable" style="width: 131px">End Date:</td>
														<td nowrap="nowrap" class="style1">
															<asp:TextBox runat="server" ID="schemeEndDate" Width="100%" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
															<asp:RequiredFieldValidator runat="server" ID="rfv3" ControlToValidate="schemeEndDate"
																ErrorMessage="Required" ForeColor="red" ValidationGroup="scheme"></asp:RequiredFieldValidator>
														</td>
													</tr>
													<tr style="display: none;">
														<td class="frmLable" style="width: 132px">Basis:</td>
														<td nowrap="nowrap">
															<asp:DropDownList ID="basis" runat="server" Width="200px">
															</asp:DropDownList>
														</td>
													</tr>
													<tr runat="server" style="display: none;">
														<td class="frmLable" style="width: 132px">Unit:</td>
														<td nowrap="nowrap">
															<asp:TextBox ID="unit" runat="server" Width="192px"></asp:TextBox><span class="ErrMsg">*</span>
														</td>
														<td class="frmLable" style="width: 131px">Points:</td>
														<td nowrap="nowrap" class="style1">
															<asp:TextBox ID="points" runat="server" Width="192px"></asp:TextBox><span class="ErrMsg">*</span>
														</td>
													</tr>
													<tr style="display: none;">
														<td class="frmLable" nowrap="nowrap" style="width: 132px">Max Points
									<br />
															Per TXN:</td>
														<td nowrap="nowrap">
															<asp:TextBox ID="maxPointPerTxn" runat="server" Width="192px"></asp:TextBox><span class="ErrMsg">*</span>
														</td>
														<td class="frmLable" nowrap="nowrap" style="width: 131px">Min No. of
									<br />
															TXN For Redeem:
														</td>
														<td nowrap="nowrap" class="style1">
															<asp:TextBox ID="minTxnForRedeem" runat="server" Width="192px"></asp:TextBox><span class="ErrMsg">*</span>
														</td>
													</tr>

													<tr>
														<td class="frmLable" style="width: 132px">Is Active:</td>
														<td>
															<asp:DropDownList ID="isActive" runat="server" Width="100px" CssClass="form-control">
																<asp:ListItem Value="Y">Yes</asp:ListItem>
																<asp:ListItem Value="N">No</asp:ListItem>
															</asp:DropDownList>
															<asp:RequiredFieldValidator ID="rfv7" runat="server" ControlToValidate="isActive" ForeColor="red"
																ErrorMessage="Required" ValidationGroup="scheme"></asp:RequiredFieldValidator>
														</td>
													</tr>
													<tr>
														<td colspan="4">&nbsp;</td>
													</tr>
													<tr>
														<td style="width: 132px"></td>
														<td colspan="3">
															<asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" ValidationGroup="scheme" CssClass="btn btn-primary" />
															<%Misc.SwiftBackButton(); %>
														</td>
													</tr>
												</table>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</td>
				</tr>
			</table>
		</div>
	</form>
</body>

<script type="text/javascript">
	$(document).ready(function () {
		var element = document.getElementsByClassName('button');
		$(element).addClass('btn btn-primary');
	})
</script>
</html>
