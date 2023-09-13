<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Receipt.aspx.cs" Inherits="Swift.web.AgentPanel.Bonus_Management.Receipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../../css/style.css" rel="stylesheet" type="text/css" />
	<script src="../../../js/functions.js" type="text/javascript"></script>
	<style>
		.mainTable {
			width: 600px;
			padding: 2px;
			font-size: 11px;
			vertical-align: top;
		}

		.innerTable {
			width: 300px;
			padding: 2px;
			font-size: 11px;
			vertical-align: top;
		}

			.innerTable td {
				text-align: left;
				width: 150px;
				vertical-align: top;
			}

		.innerTableHeader {
			width: 300px;
			padding: 2px;
		}

			.innerTableHeader td {
				text-align: right;
			}

		.highlightTextLeft {
			font-size: 11px;
			xcolor: #999999;
			color: Black;
			font-weight: bold;
			text-transform: uppercase;
			vertical-align: top;
			margin-left: 10px;
		}

		.highlightTextRight {
			font-size: 11px;
			xcolor: #999999;
			color: Black;
			font-weight: bold;
			text-transform: uppercase;
			vertical-align: top;
			margin-left: 10px;
			text-align: right;
		}

		.AmtCss {
			text-transform: uppercase;
			font-weight: bold;
			margin-left: 5px;
		}

		.hrRuller {
			text-align: left;
			width: 600px;
			margin-left: 5px;
		}

		.fontColor {
			color: Red;
			font-weight: bold;
			font-size: 13px;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div id="Printreceiptdetail" runat="server">
			<table class="mainTable" style="border: 1px solid #000;">
				<tr>
					<td valign="top">
						<span style="float: left">
							<img src="../../ui/images/receipt_logo.png" />
						</span>
						<div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;">
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="4" align="center">
						<div class="highlightTextLeft">
							GME Bonus point Receipt
						</div>
					</td>
				</tr>
				<tr>
					<td>&nbsp;
					</td>
				</tr>
				<tr>
					<td>
						<table class="innerTable">
							<tr>
								<td>Ref No:
								</td>
								<td class="formLabel">
									<asp:Label ID="lblRefNo" runat="server"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>Branch:
								</td>
								<td class="text">
									<asp:Label ID="lblBranch" runat="server"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>Date/Time:
								</td>
								<td class="text">
									<asp:Label ID="lblDateTime" runat="server"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>Customer Name:
								</td>
								<td class="text">
									<asp:Label ID="lblCustomerName" runat="server"></asp:Label>
							</tr>
							<tr>
								<td>PASSPORT/VISA:
								</td>
								<td class="text">
									<asp:Label ID="lblPassport" runat="server"></asp:Label>
							</tr>
							<tr>
								<td>&nbsp;
								</td>
								<td>&nbsp;
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2"></td>
				</tr>
				<tr>
					<td>
						<table class="innerTable">
							<tr>
								<td>Bonus Point:
								</td>
								<td>
									<asp:Label ID="lblBonusPoint" runat="server"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>Item Redeemed:
								</td>
								<td>
									<asp:Label ID="lblItemRedeemed" runat="server"></asp:Label>
								</td>
							</tr>
							<tr>
								<td>Bonus Point Remaining:
								</td>
								<td>
									<asp:Label ID="lblRemainingBonus" runat="server"></asp:Label>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;
					</td>
				</tr>
				<tr>
					<td colspan="2">Prepared By: <span>
						<asp:Label ID="lblPreparedBy" runat="server"></asp:Label></span>
					</td>
					<td colspan="2" align="center">___________________________<br />
						Customer Signature
					</td>
				</tr>
				<tr>
					<td>&nbsp;
					</td>
				</tr>
				<tr>
					<td colspan="4" align="center">
						<hr class="hrRuller" />
						<div id="commonMsg" runat="server" class="commonMsg">
							******* THANK YOU ********<br />
							<br />
							Send Money and WIN BONUS with PRIZES
						</div>
						<br />
					</td>
				</tr>
			</table>
		</div>
		<input type="button" value="Print" id="btnPrint" onclick="PrintReceipt(); " class="noprint" />
	</form>
	<script type="text/javascript">
		function PrintReceipt() {
			window.print();
		}
	</script>
</body>
</html>
