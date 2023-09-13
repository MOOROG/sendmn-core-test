<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.OperationStartSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
	<base id="Base1" target="_self" runat="server" />
	<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<script src="../../../js/swift_grid.js" type="text/javascript"> </script>
	<script src="../../../js/functions.js" type="text/javascript"> </script>
	<link href="../../../ui/css/style.css" rel="stylesheet" />
</head>
<body>
	<form id="form1" runat="server">
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="#" class="selected">List </a></li>
							<li><a href="Manage.aspx">Bonus Setup</a></li>
						</ol>
					</div>
				</div>
			</div>

			<div class="listtabs" style="margin-left: 8px;">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">User List </a></li>
					<li><a href="Manage.aspx">Bonus Setup</a></li>
				</ul>
			</div>

			<div class="row">
				<div class="col-md-12">
					<div class="panel panel-default ">
						<div class="panel-heading">
							<h4 class="panel-title">Bonus Setup List</h4>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">
							<div id="rpt_grid" runat="server" class="gridDiv"></div>
						</div>
					</div>
				</div>
			</div>
		</div>

	</form>
</body>

</html>
