<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AgentPanel.Bonus_Management.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../ui/css/style.css" rel="stylesheet" />
	<link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<script src="../../js/Swift_grid.js"></script>
	<script src="../../js/functions.js"></script>
	<base id="b1" target="_self" />
</head>
<body>
	<form id="form1" runat="server">
		<div class="container">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="RedeemRequest.aspx">Redeem Request</a></li>
							<li><a href="#" class="selected">Bonus Txn History</a></li>
						</ol>
					</div>
				</div>
			</div>

			<div class="listtabs" style="margin-left: 8px;">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Bonus Txn History</a></li>
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
							<div id="rpt_grid" runat="server" style="margin: 5px 10px!important;" class="gridDiv"></div>
						</div>
					</div>
				</div>
			</div>
		</div>

	</form>
</body>
</html>
