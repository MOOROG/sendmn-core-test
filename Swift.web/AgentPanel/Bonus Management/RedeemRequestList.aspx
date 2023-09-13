<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RedeemRequestList.aspx.cs" Inherits="Swift.web.AgentPanel.Bonus_Management.RedeemRequestList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../ui/css/style.css" rel="stylesheet" />
	<link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<script src="../../js/jQuery/jquery.min.js"></script>
	<script src="../../js/functions.js"></script>
	<script src="../../js/Swift_grid.js"></script>
	<script type="text/javascript">
		function giftHandedOver(refNo, customerId) {
			SetValueById("<%=hdnRedeemId.ClientID%>", refNo);
			SetValueById("<%=hdnCustomerId.ClientID%>", customerId);
			var con = confirm("Are you sure want to handover the gift?");
			if (con == true) {
				GetElement("<%=btnHandedOver.ClientID%>").click();
				openReceipt(refNo, customerId);
			}
		}

		function openReceipt(refNo, customerId) {
			var param = "dialogHeight:550px;dialogWidth:800px;dialogLeft:150;dialogTop:80;center:yes;";
			var res = PopUpWindow("Receipt.aspx?redeemId=" + refNo + "&customerId=" + customerId, param);
		}
	</script>
</head>
<body>

	<form id="form2" runat="server">
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
					<li role="presentation"><a href="RedeemRequest.aspx">Redeem Request </a></li>
					<li class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Redeem History</a></li>
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



							<div id="rpt_grid" runat="server" class="gridDiv"></div>
							<asp:Button runat="server" Style="display: none;" ID="btnHandedOver" Text="Handed Over"
								OnClick="btnHandedOver_Click" />

							<asp:HiddenField ID="hdnCustomerId" runat="server" />
							<asp:HiddenField ID="hdnRedeemId" runat="server" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</form>
</body>
</html>
