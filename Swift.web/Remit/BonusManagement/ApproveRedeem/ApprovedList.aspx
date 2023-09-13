<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApprovedList.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.ApproveRedeem.ApprovedList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>

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
		function ApproveProcess(customerId, customerName, bonusPoint, idType, idNumber, country) {
			var url = "Manage.aspx?customerId=" + customerId + "&customerName=" + customerName + "&bonusPoint=" + bonusPoint;
			url += "&idType=" + idType + "&idNumber=" + idNumber + "&country=" + country;
			window.location.replace(url);
		}
		function RejectRedeem(redeemId) {
			if (confirm("Are you sure to reject this redeem?")) {
				SetValueById("<%=hdnRedeemId %>", redeemId, "");
    			GetElement("<%=btnRejectRedeem.ClientID %>").click();
    		}
		}

		function openReceipt(refNo, customerId) {
			var param = "dialogHeight:550px;dialogWidth:800px;dialogLeft:150;dialogTop:80;center:yes;";
			var res = PopUpWindow("Receipt.aspx?redeemId=" + refNo + "&customerId=" + customerId, param);
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
							<li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
							<li class="active"><a href="Manage.aspx">Bonus Setup</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-12">
					<div class="listtabs" style="margin-left: 8px;">
						<ul class="nav nav-tabs" role="tablist">
							<li><a href="Manage.aspx" id="pending">Pending</a></li>
							<li class="active"><a id="approved" href="ApprovedList.aspx">Approved/Reject List </a></li>
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
									<h4 class="panel-title">Bonus Management</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
									</div>
								</div>
								<div class="panel-body">
									<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
										<tr>
											<td valign="top">
												<div id="rpt_grid" runat="server" class="gridDiv">
												</div>
												<asp:Button ID="btnRejectRedeem" runat="server" Style="display: none;" OnClick="btnRejectRedeem_Click" />

												<asp:Button ID="btnReceipt" runat="server" Style="display: none;" OnClick="btnReceipt_Click" />

												<asp:HiddenField ID="hdnCustomerId" runat="server" />
												<asp:HiddenField ID="hdnRedeemId" runat="server" />
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


	</form>
</body>
</html>
