<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrizeSetup.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.PrizeSetup.PrizeSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<script src="../../../js/functions.js" type="text/javascript"></script>
	<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
	<script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
	<script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
	<link href="../../../ui/css/style.css" rel="stylesheet" />
	<script type="text/javascript" language="javascript">
		function OpenInEditMode(id) {
			if (id != "") {
				SetValueById("<% =hddDetailId.ClientID%>", id);
				GetElement("<% =btnEdit.ClientID%>").click();

			}
		}
		function DeleteRow(id) {
			if (id != "") {
				if (confirm("Are you sure to delete selected record?")) {
					SetValueById("<% = hddDetailId.ClientID %>", id);
					GetElement("<% = btnDelete.ClientID %>").click();
				}
			}
		}

		function ResetForm() {
			SetValueById("<% = hddDetailId.ClientID%>", "0");
			SetValueById("<% = points.ClientID%>", "");
		}

		function NewRecord() {
			ResetForm();
		}

		function loadFile(event) {
			var output = document.getElementById('giftImageFile');
			output.src = URL.createObjectURL(event.target.files[0]);
		};

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
							<li class="active"><a href="Manage.aspx">Prize Setup</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-12">
					<div class="listtabs" style="margin-left: 8px;">
						<ul class="nav nav-tabs" role="tablist">
							<li><a href="../OperationStartSetup/List.aspx">Operation Bonus Setup List </a></li>
							<li class="active"><a href="#" class="selected">Prize Setup</a></li>
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

									<table class="table-condensed">
										<tr>
											<td colspan="2" class="frmTitle">Prize Setup </td>
										</tr>
										<tr>
											<td class="frmLable">Scheme Name:
											</td>
											<td>
												<asp:Label ID="schemeName" runat="server"></asp:Label>
											</td>
										</tr>
										<tr>
											<td class="frmLable">Points:
											</td>
											<td>
												<asp:TextBox ID="points" runat="server" Width="70%" CssClass="form-control"></asp:TextBox>
												<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
													ControlToValidate="points" Display="Dynamic" ErrorMessage="Required!"
													InitialValue="" SetFocusOnError="True" ValidationGroup="Save" ForeColor="Red">
												</asp:RequiredFieldValidator>
											</td>
										</tr>
										<tr>
											<td class="frmLable">Inventory Products:
											</td>
											<td>
												<asp:DropDownList ID="giftItem" runat="server" Width="70%" CssClass="form-control"></asp:DropDownList>
												<asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
													ControlToValidate="giftItem" Display="Dynamic" ErrorMessage="Required!"
													InitialValue="" SetFocusOnError="True" ValidationGroup="Save" ForeColor="Red">
												</asp:RequiredFieldValidator>
											</td>
										</tr>
										<tr>
											<td>Upload Gift Image:
											</td>
											<td>
												<asp:FileUpload ID="giftImage" runat="server" CssClass="form-control" onchange="loadFile(event);"/>
												<asp:Image runat="server" ID="giftImageFile" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;"/>
											</td>
										</tr>

										<tr>
											<td>
												<asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="Save" OnClick="btnSave_Click" CssClass="btn btn-primary" />
												<input type="button" id="btnNew" value="New" onclick="NewRecord();" style="margin-left: 12px" class="btn btn-primary" />
												<asp:HiddenField ID="hddDetailId" runat="server" />
												<asp:Button runat="server" ID="btnEdit" Text="Edit" Style="display: none" OnClick="btnEdit_Click" />
												<asp:Button runat="server" ID="btnDelete" Text="Delete" Style="display: none" OnClick="btnDelete_Click" />
											</td>
										</tr>
									</table>
								</div>
							<div></div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div id="rpt_grid" runat="server"></div>
		</div>
	</form>
</body>
</html>
