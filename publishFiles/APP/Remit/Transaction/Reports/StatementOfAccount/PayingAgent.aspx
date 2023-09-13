<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayingAgent.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.StatementOfAccount.PayingAgent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="/ui/css/style.css" rel="stylesheet" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

	<script type="text/javascript" src="/ui/js/jquery.min.js"></script>
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script src="/ui/bootstrap/js/bootstrap.min.js"></script>
	<link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
	<script src="/ui/js/bootstrap-datepicker.js"></script>
	<script src="/ui/js/pickers-init.js"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<link href="/ui/css/style.css" rel="stylesheet" />

	<script src="/js/functions.js" type="text/javascript"></script>
	<script src="/js/swift_calendar.js"></script>

	<script type="text/javascript" language="javascript">
		$(document).ready(function () {
			ShowCalFromToUpToToday("#<% =fromDate.ClientID %>", "#<% =toDate.ClientID %>");
		});
		function StatementOfAccount() {
			var reqField = "sCountry,sAgent,";
			if (ValidRequiredField(reqField) === false) {
				return false;
			}

		<%--	var scountry = GetValue("<% =sCountry.ClientID %>")--%>
		    var scountry = $('#sCountry option:selected').text();
			var from = GetValue("<% =fromDate.ClientID %>");
			var to = GetValue("<% =toDate.ClientID %>");
			var sagent = GetValue("<% =sAgent.ClientID %>");
		    var reportFor = GetValue("<% =reportFor.ClientID %>");
		    var userId =  $('#<%=branchUser.ClientID %>').val();
  
			var url = "statementOfAccount.aspx?reportName=StatementOfAccountRec&pCountry=" + scountry +
				"&sAgent=" + sagent +
				"&reportFor=" + reportFor +
                "&user=" + userId +
				"&fromDate=" + from +
				"&toDate=" + to;

			OpenInNewWindow(url);
			return false;
		}
		function Button1_onclick() {

		}

	</script>
</head>
<body>
	<form id="form1" runat="server">
		  <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<ol class="breadcrumb">
							<li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
							<li class="active"><a href="Manage.aspx">Settlement Report - International </a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="listtabs">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation">
						<a href="Manage.aspx">Sending Agent</a></li>
					<li class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Receiving Agent </a></li>
				</ul>
			</div>
			<div class="row">
				<div class="col-md-6">
					<div class="panel panel-default ">
						<div class="panel-heading">
							<h4 class="panel-title">Receiving Agent Settlement Report</h4>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">
							<asp:UpdatePanel ID="upnl1" runat="server">
								<ContentTemplate>
									<div class="form-group">
										<label class="control-label col-md-4"> Receiving Country: </label>
										<div class="col-md-8">
											<asp:DropDownList ID="sCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
											</asp:DropDownList>
										</div>
									</div>
									<div class="form-group">
										<label class="control-label col-md-4"> Receiving Agent :</label>
										<div class="col-md-8">
											<asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"  AutoPostBack="true" OnSelectedIndexChanged="sAgent_SelectedIndexChanged"></asp:DropDownList>
										</div>
									</div>
                                      <div class="form-group">
										<label class="control-label col-md-4">Agent/Branch Users :</label>
										<div class="col-md-8">
											<asp:DropDownList ID="branchUser" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
									</div>
									<div class="form-group">
										<label class="control-label col-md-4" for="">
											Report For:</label>
										<div class="col-md-8">
											<asp:DropDownList ID="reportFor" runat="server" CssClass="form-control">
												<asp:ListItem Value="">All</asp:ListItem>
												<asp:ListItem Value="P">Principle</asp:ListItem>
												<asp:ListItem Value="COMM">Commission</asp:ListItem>
											</asp:DropDownList>
										</div>
									</div>
								</ContentTemplate>
							</asp:UpdatePanel>

							<div class="form-group">
								<label class="control-label col-md-4">From Date :  </label>
								<div class="col-md-8">
									<div class="input-group m-b">
										<span class="input-group-addon">
											<i class="fa fa-calendar" aria-hidden="true"></i>
										</span>
										<asp:TextBox ID="fromDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
									</div>
								</div>
							</div>
							<div class="form-group">
								<label class="control-label col-md-4">To Date :  </label>
								<div class="col-md-8">

									<div class="input-group m-b">
										<span class="input-group-addon">
											<i class="fa fa-calendar" aria-hidden="true"></i>
										</span>
										<asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('from','t','to')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
									</div>
								</div>
							</div>
							<div class="form-group">
								<label class="control-label col-md-4"></label>
								<div class="col-md-8">
									<asp:Button runat="server" ID="Button1" Text="Statement Of Account" class="btn btn-primary m-t-25" OnClientClick="return StatementOfAccount('StatementOfAccount');" />
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
