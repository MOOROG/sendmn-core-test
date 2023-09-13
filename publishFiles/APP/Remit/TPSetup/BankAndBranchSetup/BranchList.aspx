<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BranchList.aspx.cs" Inherits="Swift.web.Remit.TPSetup.BankAndBranchSetup.BranchList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="/ui/css/style.css" rel="stylesheet" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script src="/ui/js/jquery.min.js"></script>
	<script src="/ui/bootstrap/js/bootstrap.min.js"></script>
	<script src="/js/Swift_grid.js" type="text/javascript"> </script>
	<script src="/js/functions.js" type="text/javascript"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<script type="text/javascript">
		function EnableDisable(id, branchName, isActive) {
			var verifyText = 'Are you sure to enable for branch ' + branchName + '?';
			if (id != '') {
				$('#isActive').val(isActive);
				$('#rowId').val(id);
				if (isActive == 'YES') {
					verifyText = 'Are you sure to disable for branch ' + branchName + '?';
				}
				if (confirm(verifyText)) {
					$('#btnUpdate').click();
				}
			}
		}
	</script>
</head>
<body>
	<form id="form1" runat="server">
		<asp:HiddenField ID="isActive" runat="server" />
		<asp:HiddenField ID="rowId" runat="server" />
		<asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />

		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#">Partner Bank Setup</a></li>
							<li><a href="#">Partner Bank List</a></li>
							<li class="active"><a href="#">Partner Branch List</a></li>
						</ol>
					</div>
				</div>
			</div>

			<!-- Nav tabs -->
			<div class="listtabs">
				<ul class="nav nav-tabs" role="tablist">
					<li class="selected"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Partner Branch List</a></li>
					<%--      <li><a href="ManagePartnerBranch.aspx">Manage Partner Branch</a></li>--%>
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
									<div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
								</div>
								<div class="panel-body">
									<div class="col-sm-12" runat="server">
										<div class="form-group">

											<asp:Button ID="btnSyncBank" runat="server" Text="Sync Branch"
												OnClick="btnSyncBank_Click" CssClass="btn btn-primary" />
											<%-- <asp:Button ID="Print" runat="server" CssClass="btn btn-primary m-t-25" Text="Print"  OnClick="Print_Click" />--%>
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
