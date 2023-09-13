<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewTransaction.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.ApproveRedeem.ViewTransaction" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<script src="../../../js/functions.js" type="text/javascript"></script>
	<script src="../../../ajax_func.js" type="text/javascript"></script>
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
	<script type="text/javascript">

		var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
		$(document).ready(function () {
			$("#<%=usrName.ClientID %>").bind('keypress', function (e) {
				e = e || window.event;
				var charCode = (typeof e.which == "number") ? e.which : e.keyCode;

				if ((charCode != 13) && (/[^\d]/.test(String.fromCharCode(charCode)))) {
					return false;
				}
			});

		});

		function ShowProgressBar() {
			if ($.trim($("#<%=usrName.ClientID %>").val()) == "")
				return false;

			Process();
			return true;
		}

		function ShowBonusPointInNewWindow() {
			var userName = GetValue("<%=usrName.ClientID%>");
			if (userName == "") {
        		alert("Please enter user email!");
        		return false;
        	}
			var url = "TransactionList.aspx?userName=" + userName;

        	PopUpWindow(url, "dialogHeight:500px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes;");
        }

        function ShowSenderCustomerNewWindow() {
        	var userName = GetValue("<%=usrName.ClientID %>");
        	if (userName == "") {
        		alert("Please enter user email!");
        		return false;
        	}
        	var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?userName=" + userName + "";
        	OpenDialog(url, 650, 620);
        }


	</script>
</head>
<body>
	<form id="form1" runat="server">
		<div id="container" class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return LoadModule('adminstration')">Bonus Management</a></li>
							<li class="active"><a href="ViewTransaction.aspx">TXN History</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-12">
					<div class="listtabs" style="margin-left: 8px;">
						<ul class="nav nav-tabs" role="tablist">
							<li><a href="Manage.aspx" id="pending" class="selected">Pending</a></li>
							<li><a id="approved" href="ApprovedList.aspx">Approved/Reject List </a></li>
							<li class="active"><a id="a1" href="ViewTransaction.aspx">TXN History </a></li>
						</ul>
					</div>
				</div>
			</div>
			<div class="tab-content">
				<div role="tabpanel" class="tab-pane active" id="list">
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default">
								<div class="panel-heading">
									<h4 class="panel-title">Bonus Points Report</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
									</div>
								</div>
								<div class="panel-body">
									<div style="clear: both;">
										<table border="0" cellspacing="0" cellpadding="0" class="formTable" style="width: 750px; padding: 0em;">
											<tr>
												<td colspan="3">
													<div>
														<b>Customer UserName</b><br />
														<asp:TextBox runat="server" ID="usrName" Width="250px" CssClass="form-control"></asp:TextBox>
														<br />
														<asp:Button runat="server" ID="btnSearchCustomer" Text="Search"
															OnClientClick="return ShowProgressBar();" OnClick="btnSearchCustomer_Click" CssClass="btn btn-primary" />
														<span style="cursor: pointer;">
															<asp:Image runat="server" ID="infoImg"
																AlternateText="info" Width="16px" Style="display: none;" /></span>
													</div>
												</td>
											</tr>
											<tr>
												<td colspan="2">
													<br />
													<table class="DbResult" runat="server" id="TBLData" visible="false" align="left" style="width: 750px; padding: 0em; margin-right: 50px">
														<tr>
															<th colspan="5" style="text-align: left; font-size: small">Customer Detail
															</th>
														</tr>
														<tr>
															<td nowrap="nowrap">Full Name:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="fullName" Style="font-weight: bold; color: Red;"></asp:Label>
															</td>
															<td nowrap="nowrap">DOB:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="dob" Style="font-weight: bold; color: Red;"></asp:Label>
															</td>

														</tr>
														<tr>
															<td nowrap="nowrap">Gender:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="gender" Style="font-weight: bold;"></asp:Label>
															</td>
															<td nowrap="nowrap">Native Country:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="nativeCountry" Style="font-weight: bold;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td nowrap="nowrap">ID Type:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="idType" Style="font-weight: bold; color: Red;"></asp:Label>
															</td>
															<td nowrap="nowrap">ID Number:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="idNumber" Style="font-weight: bold; color: Red;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td nowrap="nowrap">Country:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="country" Style="font-weight: bold;"></asp:Label>
															</td>
															<td nowrap="nowrap">State:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="state" Style="font-weight: bold;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td nowrap="nowrap">City:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="city" Style="font-weight: bold;"></asp:Label>
															</td>
															<td nowrap="nowrap">Address:
															</td>
															<td width="200px">
																<asp:Label runat="server" ID="address" Style="font-weight: bold;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td nowrap="nowrap">Mobile No:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="mobileNo" Style="font-weight: bold;"></asp:Label>
															</td>
															<td nowrap="nowrap">E-mail:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="email" Style="font-weight: bold;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td>Member Id Issued Date:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="memberIDissuedDate" Style="font-weight: bold;"></asp:Label>
															</td>
															<td nowrap="nowrap">Total Bonus Point:
															</td>
															<td nowrap="nowrap">
																<asp:Label runat="server" ID="bonusPoint" Style="font-weight: bold; color: Red;"></asp:Label>
															</td>
														</tr>

														<tr>
															<td colspan="5">
																<hr />
															</td>
														</tr>
														<tr>
															<td nowrap="nowrap">Redeemable available Products
															</td>
															<td nowrap="nowrap" class="text-amount" style="text-align: center;">
																<asp:Label runat="server" ID="redeemAvailableProducts" Style="font-weight: bold;"></asp:Label>
															</td>
															<td colspan="3">

																<asp:Button runat="server" ID="btnTxnHistory" OnClientClick="return ShowBonusPointInNewWindow();" Text="TXN History" />

																<input type="button" name="ViewProfile" id="btnViewProfile" value="View Profile" onclick="ShowSenderCustomerNewWindow()" />
															</td>
														</tr>
														<tr>
															<td>
																<div id="DivLoad" style="height: 20px; width: 220px; background-color: #333333; display: none; float: left">
																	<img src="../../../../images/progressBar.gif" border="0" alt="Loading..." />
																</div>
															</td>
															<td colspan="2">
																<asp:Label runat="server" ID="pendingStatus" Style="font-weight: bold; color: Green;"></asp:Label>
															</td>
														</tr>
														<tr>
															<td colspan="2">
																<div runat="server" id="productList">
																</div>
															</td>
														</tr>
														<tr>
															<td colspan="3">
																<asp:HiddenField runat="server" ID="hdnPrizeId" />
																<asp:HiddenField runat="server" ID="hdnAgentId" />
																<asp:HiddenField runat="server" ID="hdnProductBonusPoint" />
																<asp:HiddenField runat="server" ID="hdnGiftItem" />
																<asp:HiddenField ID="hdnCustomerId" runat="server" />
															</td>

														</tr>

													</table>
												</td>
											</tr>
										</table>
									</div>
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
