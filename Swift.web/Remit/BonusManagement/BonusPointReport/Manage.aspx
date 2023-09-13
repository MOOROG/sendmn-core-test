<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.BonusPointReport.Manage" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
							<li class="active"><a href="Manage.aspx">Bonus Points Report</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="tab-content">
				<div role="tabpanel" class="tab-pane active" id="list">
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default">
								<div class="panel-heading">
									<h4 class="panel-title">Bonus Points Report</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
									</div>
								</div>
								<div class="panel-body">

									<div class="row">
										<div class="col-md-6">
											<div class="form-group">
												<label>
													Agent Name:</label>
												<uc1:SwiftTextBox ID="sAgent" runat="server" Width="250px" Category="remit-sAgent" cssclass="required" />
											</div>
										</div>
									</div>
									<div class="row">
										<div class="col-md-6">
											<div class="form-group">
												<label>
													Customer UserName (Email):</label>
												<asp:TextBox runat="server" ID="senderId" Width="150px" CssClass="form-control"></asp:TextBox>
											</div>
										</div>
									</div>

									<div class="row">
										<div class="col-md-6">
											<div class="form-group">
												<label>
													Order By:</label>
												<asp:DropDownList runat="server" ID="orderBy" Width="150px" CssClass="form-control">
													<asp:ListItem Value="CustomerName">Customer Name</asp:ListItem>
													<asp:ListItem Value="BonusEarned">Bonus Earned</asp:ListItem>
													<asp:ListItem Value="Branch">Branch</asp:ListItem>
												</asp:DropDownList>
											</div>
										</div>
									</div>
									<div class="row">
										<div class="col-md-12">
											<div class="form-group">
												<input type="button" id="bonusPointReport" runat="server" value=" Search " class="btn btn-primary"
													onclick="ShowReportBonusPoints();" />
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

<script type="text/javascript">
	function ShowReportBonusPoints() {
		var agent = GetItem("<% = sAgent.ClientID %>")[0];
		var orderBy = GetValue("<%=orderBy.ClientID %>");
		var senderId = GetValue("<% =senderId.ClientID %>");
		if (agent == "" && senderId == "") {
			alert("Agent or Customer User Name is required !");
			return false;
		}
		var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=20822300" +
				"&agent=" + agent +
				"&userName=" + senderId +
				"&orderBy=" + orderBy;
		OpenInNewWindow(url);
		return false;
	}
</script>
</html>
