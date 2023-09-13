<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.OnlineRemit.WalletManager.List" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

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
	<script src="../../js/swift_autocomplete.js"></script>
	<script src="../../ui/js/custom.js"></script>
	<script src="../../js/swift_calendar.js"></script>	
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

			<!-- Nav tabs -->
			<div class="listtabs">
				<ul class="nav nav-tabs" role="tablist">
					<li class="selected"><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Wallet Statement</a></li>
					<li><a href="Manage.aspx">Approve/Reject</a></li>
				</ul>
			</div>
			<!-- Tab panes -->
			<div class="tab-content">
				<div role="tabpanel" class="tab-pane active" id="list">
					<!--end .row-->
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default">
								<div class="panel-body">
									<div class="row">
										<div class="form-group col-md-4">
											<label>Customer:</label>
											<uc1:SwiftTextBox ID="customer" runat="server" Width="210px" Category="remit-customer" />

										</div>
									</div>
									<div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
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
