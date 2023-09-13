<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.ApproveRedeem.Manage" %>

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

	<script language="javascript" type="text/javascript">

		function PrintReceipt(refNo, customerId) {
			var url = "../RedeemProcess/Receipt.aspx?refNo=" + refNo + "&customerId=" + customerId;
			var pageSize = 'width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1';
			window.open(url, null, pageSize);
		}

		function ApproveRedeem(refNo, customerId) {
			var answer = confirm("Are you sure to approve selected record?");
			if (answer == true) {
				SetValueById("<%= hddRedeemId.ClientID %>", refNo);
				SetValueById("<%=hddCustomerId.ClientID %>", customerId);
				GetElement("<%=btnApprove.ClientID %>").click();
			}
		}
		function DeleteRedeem(refNo, customerId) {
			var answer = confirm("Are you sure to delete selected record?");
			if (answer == true) {
				SetValueById("<%= hddRedeemId.ClientID %>", refNo);
				SetValueById("<%= hddCustomerId.ClientID %>", customerId);
				GetElement("<%=btnDelete.ClientID %>").click();
			}
		}

		function openApprovedRemarks(refNo, customerId, redeemed, mobile) {
			document.getElementById("confirmTitle").innerHTML = "Confirm Approve";
			var newdiv = document.getElementById("RemarksDiv");
			newdiv.style.display = "none";

			SetValueById("<%= hdnFlag.ClientID %>", "approve");
			SetValueById("<%= hddRedeemId.ClientID %>", refNo);
			SetValueById("<%= hddCustomerId.ClientID %>", customerId);
			SetValueById("<%= hddRedeemedBonus.ClientID %>", redeemed);
			SetValueById("<%= hdnMobile.ClientID %>", mobile);
			newdiv.style.display = "";
		}

		function openRejectRemarks(refNo, customerId, redeemed, mobile) {

			document.getElementById("confirmTitle").innerHTML = "Confirm Reject";
			var newdiv = document.getElementById("RemarksDiv");
			newdiv.style.display = "none";
			SetValueById("<%= hdnFlag.ClientID %>", "reject");
			SetValueById("<%= hddRedeemId.ClientID %>", refNo);
			SetValueById("<%= hddCustomerId.ClientID %>", customerId);
			SetValueById("<%= hddRedeemedBonus.ClientID %>", redeemed);
			SetValueById("<%= hdnMobile.ClientID %>", mobile);
			newdiv.style.display = "";
		}


		function validateRemarks() {
			var remarks = document.getElementById("<%= txtremarks.ClientID %>").value;
			if (remarks == undefined || remarks == "") {
				alert("Remarks field is empty!");
				return false;
			}
			else {
				var co = confirm("Are you sure want to proceed?");
				if (co == true)
					return true;
				else
					return false;
			}
		}

		function Close() {
			SetValueById("<%= txtremarks.ClientID %>", "")
				var newdiv = document.getElementById("RemarksDiv");
				newdiv.style.display = "none";

			}

		function ShowBonusPointInNewWindow(userName) {
				if (userName == "") {
					alert("Please enter user email!");
					return false;
				}
				var url = "TransactionList.aspx?userName=" + userName;
				PopUpWindow(url, "dialogHeight:500px;dialogWidth:900px;titlbebar:no;dialogLeft:200;dialogTop:100;center:yes;");
			}

	</script>
	<style type="text/css">
		.style1 {
			width: 422px;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div id="container" class="page-wrapper">
			<asp:HiddenField runat="server" ID="hddRedeemId" />
			<asp:HiddenField runat="server" ID="hddCustomerId" />
			<asp:HiddenField runat="server" ID="hddRemarks" />

			<asp:HiddenField runat="server" ID="hddRedeemedBonus" />
			<asp:HiddenField runat="server" ID="hdnMobile" />
			<asp:HiddenField runat="server" ID="hdnFlag" />
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return LoadModule('adminstration')">Bonus Management</a></li>
							<li class="active"><a href="Manage.aspx">Approve Redeem</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-12">
					<div class="listtabs" style="margin-left: 8px;">
						<ul class="nav nav-tabs" role="tablist">
							<li class="active"><a href="Manage.aspx" id="pending">Pending</a></li>
							<li><a id="approved" href="ApprovedList.aspx">Approved/Reject List </a></li>
							<li><a id="a1" href="ViewTransaction.aspx">TXN History </a></li>
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
									<h4 class="panel-title">Approve Redeem Request</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
									</div>
								</div>
								<div class="panel-body">
									<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">

										<tr>
											<td height="524" valign="top">
												<div id="rpt_grid" align="left" runat="server" class="gridDiv">
												</div>
												<asp:Button runat="server" ID="btnApprove" Text="Approve"
													Style="display: none;" OnClick="btnApprove_Click" CssClass="btn btn-primary"/>
												<asp:Button runat="server" ID="btnReject" Text="Reject" OnClick="btnReject_Click"
													Style="display: none;" CssClass="btn btn-primary"/>

												<asp:Button runat="server" ID="btnDelete" Text="Delete"
													Style="display: none;" OnClick="btnDelete_Click" CssClass="btn btn-primary" />
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

		<div id="RemarksDiv" style="width: 400px; z-index: 999; display: none; position: absolute; top: 250px; right: 300px; border: 1px solid #999; background: white;">
			<div style="font-family: verdana; background: Grey; color: #fff; padding: 5px;">
				<b><span id="confirmTitle"></span><u><span id="spnICN" style="background-color: red;"></u></span></b><span title="Close" style="margin-right: 1px; position: absolute; top: 0; right: 0; float: right; padding: 3px; border: 1px solid #fff; cursor: pointer; color: White; background-color: Red; font-weight: 900"
					onclick="Close();">X </span>
			</div>
			<div style="padding: 5px;">
				<span style="padding: 5px; font-weight: 600;">Remarks:</span>
				<asp:TextBox ID="txtremarks" Style="margin-bottom: 10px;" TextMode="MultiLine" Rows="5" runat="server" Width="370px"></asp:TextBox>
				<asp:Button runat="server" ID="btnApproveReject" Text="Submit" Style="float: right; margin-right: 15px; margin-bottom: 10px;"
					OnClick="btnApproveReject_Click" OnClientClick="return validateRemarks()" CssClass="btn btn-primary"/>

			</div>
		</div>
	</form>
</body>
</html>
