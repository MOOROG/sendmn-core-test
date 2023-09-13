<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.OnlineRemit.WalletManager.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../ui/css/style.css" rel="stylesheet" />
	<link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
	<link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
	<link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
	<link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script src="../../ui/js/jquery.min.js"></script>
	<script src="../../ui/bootstrap/js/bootstrap.min.js"></script>
	<script src="../../js/Swift_grid.js" type="text/javascript"> </script>
	<script src="../../js/functions.js" type="text/javascript"></script>
	<script src="../../ui/js/jquery-ui.min.js"></script>
	<script src="../../ui/js/custom.js"></script>
</head>
<body>
	<form id="form1" runat="server">
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../front.aspx" target="mainframe"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return loadmodule('adminstration')">administration</a></li>
							<li><a href="#">Customer WalletManager</a></li>
							<li class="active"><a href="List.aspx">Wallet Statement</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="report-tab" runat="server" id="regUp">
				<!-- Nav tabs -->
				<div class="listtabs">
					<ul class="nav nav-tabs" role="tablist">
					<li><a href="List.aspx">Wallet Statement</a></li>
					<li class="selected"><a href="Manage.aspx" aria-controls="home" role="tab" data-toggle="tab">Approve/Reject</a></li>

				</ul>
				</div>

				<div class="tab-content">
					<div role="tabpanel" class="tab-pane" id="List">
					</div>
					<div role="tabpanel" id="Manage">
						<div class="row">
							<div class="col-sm-12 col-md-12">
								<div class="register-form">
									<div class="panel panel-default clearfix m-b-20">
										<div class="panel-heading">Customer Wallet Information</div>
										<div class="panel-body">
											<div class="col-sm-4">
												<div class="form-group">
													<label>Customer:</label>
													<asp:TextBox ID="customer" runat="server" CssClass="form-control" />
												</div>
											</div>
											<div class="col-sm-4">
												<div class="form-group">
													<label>Remarks</label>
													<asp:TextBox ID="remarks" runat="server" CssClass="form-control" />
												</div>
											</div>
											<div class="col-sm-4">
												<div class="form-group">
													<label>Amount</label>
													<asp:TextBox ID="amount" runat="server" CssClass="form-control" />
												</div>
											</div>
											<div class="col-sm-4">
												<div class="form-group">													
													<asp:Button Text="Approve" ID="btnApprove" OnClick="btnApprove_Click" runat="server" Visible="false" CssClass="btn btn-success m-t-25"/>
													<asp:Button Text="Reject" ID="btnReject" OnClick="btnReject_Click" runat="server" Visible="false" CssClass="btn btn-danger m-t-25"/>
												</div>
											</div>
										</div>
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
