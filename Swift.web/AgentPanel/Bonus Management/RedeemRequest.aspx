<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RedeemRequest.aspx.cs" Inherits="Swift.web.AgentPanel.Bonus_Management.RedeemRequest" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../ui/css/style.css" rel="stylesheet" />
	<link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
	<script src="../../js/jQuery/jquery.min.js"></script>
	<script src="../../js/Swift_grid.js"></script>
	<script src="../../js/functions.js"></script>
	<script type="text/javascript">

		var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
		$(document).ready(function () {
			<%--$("#<%=userName.ClientID %>").bind('keypress', function (e) {
				e = e || window.event;
				var charCode = (typeof e.which == "number") ? e.which : e.keyCode;

				if ((charCode != 13) && (/[^\d]/.test(String.fromCharCode(charCode)))) {
					return false;
				}
			});--%>

		});

		function ShowProgressBar() {
			if ($.trim($("#<%=userName.ClientID %>").val()) == "")
				return false;

			Process();
			return true;
		}

		function ShowBonusPointInNewWindow() {
			var customerId = GetValue("<%=hdnCustomerId.ClientID%>");
			//if (custUserName == "") {
			//	alert("Please enter Membership Id!");
			//	return false;
			//}
			var url = "List.aspx?customerId=" + customerId;

			PopUpWindow(url, "dialogHeight:500px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes;");
		}



		function Close() {
			var newdiv = document.getElementById("OTPDiv");
			newdiv.style.display = "none";
		}


		function ShowSenderCustomerNewWindow() {
			var customerId = GetValue("<%=hdnCustomerId.ClientID %>");
			//if (customerCardNumber == "") {
			//	alert("Please enter customer user name!");
			//	return false;
			//}
			var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?customerId=" + customerId + "";
			OpenDialog(url, 650, 620);
		}
	</script>
	<style type="text/css">
		#productIno {
			position: absolute;
			background: #fff;
			padding: 10px;
			border: 1px solid #ccc;
			z-index: 100;
		}

			#productIno table .TBLData TH {
				font-size: 12px;
				font-weight: normal;
			}

		.style1 {
			width: 154px;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="#" class="selected">Bonus Management </a></li>
							<li><a href="RedeemRequestList.aspx">Bonus Redeem Request </a></li>
						</ol>
					</div>
				</div>
			</div>

			<div class="listtabs" style="margin-left: 8px;">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Redeem Request </a></li>
					<li><a href="RedeemRequestList.aspx">Redeem History</a></li>
				</ul>
			</div>

			<div class="row">
				<div class="col-md-12">
					<div class="panel panel-default ">
						<div class="panel-heading">
							<h4 class="panel-title">Redeem Request List</h4>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">

							<div style="clear: both;">
								<table border="0" cellspacing="0" cellpadding="0" class="table-condensed" style="width: 750px; padding: 0em;">
									<tr>
										<td>
											<div class="form-group form-inline col-md-9">
												<b>Customer User Name (Email)</b><br />
												<asp:TextBox runat="server" ID="userName" Width="250px" CssClass="form-control"></asp:TextBox>
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
														<%--<asp:Button runat="server" ID="btnReddem" Text="Redeem" Enabled="False"
															OnClientClick="return DoSend();" OnClick="btnReddem_Click" CssClass="btn btn-primary" />--%>
														<asp:Button runat="server" ID="btnFinalRedeem" Text="Redeem"
															OnClick="btnFinalRedeem_Click"
															OnClientClick="return confirm('Are you sure want to proceed?')" CssClass="btn btn-primary" />
														<asp:Button runat="server" ID="btnTxnHistory" OnClientClick="return ShowBonusPointInNewWindow();" Text="TXN History" CssClass="btn btn-primary" />

														<%--<input type="button" name="ViewProfile" id="btnViewProfile" value="View Profile" onclick="ShowSenderCustomerNewWindow()" class="btn btn-primary" />--%>
													</td>
												</tr>
												<%--<tr>
													<td colspan="2">&nbsp;</td>
													<td>
														<asp:LinkButton ID="hlRedeem" Enabled="False" runat="server" OnClick="hlRedeem_Click">Already have OTP?</asp:LinkButton>
													</td>
												</tr>--%>
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
													</td>
												</tr>

											</table>
										</td>
									</tr>
								</table>
							</div>


							<div id="productIno" runat="server" style="display: none;"></div>
							<asp:HiddenField ID="hdnCustomerId" runat="server" />
							<asp:HiddenField ID="hdnRedeemId" runat="server" />

							<%--<asp:TextBox ID="txtpin" runat="server"
								TextMode="SingleLine" Width="215px"></asp:TextBox>--%>
							<%--<asp:Button runat="server" ID="btnFinalRedeem" Text="Redeem"
								OnClick="btnFinalRedeem_Click"
								OnClientClick="return confirm('Are you sure want to proceed?')" Height="21px" CssClass="btn btn-primary" />--%>
						</div>
						<%--<div id="OTPDiv" runat="server" visible="true" style="width: 320px; z-index: 999; position: absolute; top: 250px; right: 500px; border: 1px solid #999; background: white; padding-bottom: 10px;">
							<%--<div style="font-family: verdana; background: Grey; color: #fff; padding: 5px;">
								<b>Confirm Redeem:<u><span id="spnICN" style="background-color: red;"></u></span></b><span title="Close" style="margin-right: 1px; position: absolute; top: 0; right: 0; float: right; padding: 3px; border: 1px solid #fff; cursor: pointer; color: White; background-color: Red; font-weight: 900"
									onclick="Close();">X </span>
							</div>--%>
						<%--<div style="padding: 5px;">
								<table border="1" cellpadding="3" cellspacing="2" style="width: 100%; font-size: 11px; font-weight: bold">
									<tr>
										<td class="style1">Customer ID:
										</td>
										<td>
											<asp:Label ID="oMemebershipId" runat="server" Text=""></asp:Label>
										</td>
									</tr>
									<tr>
										<td class="style1">Total Bonus Point:
										</td>
										<td>
											<asp:Label ID="oTotalBonus" runat="server" Text=""></asp:Label>
										</td>
									</tr>
									<tr>
										<td class="style1">Redeemed Bonus Point:
										</td>
										<td>
											<asp:Label ID="oRedeemed" runat="server" Text=""></asp:Label>
										</td>
									</tr>
									<tr>
										<td class="style1">Gift Item:
										</td>
										<td>
											<asp:Label ID="ogift" runat="server" Text=""></asp:Label>
										</td>
									</tr>

								</table>
								<br />
								<center>
                            <span style="padding: 5px; color:black;">नम्बर (OTP) एसएमएस मार्फत सेवाग्राहीको मोबाइल नम्बरमा पठाईसकिएको छ | कृपया सेवाग्राहीद्वारा प्राप्त नम्बर इन्ट्री गर्नुहोस् |</span>
                        </center>
								<br />
								&nbsp; <span style="font-weight: 600;">OTP Code:</span>
								<br />
								&nbsp;  
                          

							</div>--%>
						<%--</div>--%>
						<asp:HiddenField ID="hdnPin" runat="server" />
						<asp:HiddenField ID="hdnId" runat="server" />
						<asp:HiddenField ID="hdnMessage" runat="server" />
					</div>
				</div>
			</div>
		</div>
	</form>

	<script type="text/javascript">

		<%--function DoSend() {
			var resStat = confirm("Are you sure want to redeem request?");
			if (resStat == true) {
				var pin = generateOTP();
				$("#DivLoad").show();
				SetValueById("<%=hdnPin.ClientID %>", pin);
				GetElement("<%=btnReddem.ClientID %>").click();
				return true;
			}
			return false;
		}

		function generateOTP() {
			var pin = Math.floor(100000 + Math.random() * 900000)
			pin = pin.toString().substring(0, 4);

			pin = parseInt(pin);

			return pin;
		}--%>
	</script>
</body>
</html>
