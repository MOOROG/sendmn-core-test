<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TransactionList.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.ApproveRedeem.TransactionList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../../ui/css/style.css" rel="stylesheet" />
	<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<script src="../../../js/jQuery/jquery.min.js"></script>
	<script src="../../../js/functions.js"></script>
	<script src="../../../js/Swift_grid.js"></script>
	<base id="b1" target="_self" />
</head>
<body>
	<form id="form1" runat="server">
		<div id="container" class="container">

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
							<li class="active"><a href="#" id="pending">Bonus</a></li>
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
									<h4 class="panel-title">Bonus Txn History</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
									</div>
								</div>
								<div class="panel-body">
									<div id="rpt_grid" runat="server" style="margin: 5px 10px!important;" class="gridDiv"></div>
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
