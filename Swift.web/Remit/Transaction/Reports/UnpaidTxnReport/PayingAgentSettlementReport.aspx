<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayingAgentSettlementReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.UnpaidTxnReport.PayingAgentSettlementReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="/ui/css/style.css" rel="stylesheet" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<script src="/ui/bootstrap/js/bootstrap.min.js"></script>
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

	<script type="text/javascript" src="/ui/js/jquery.min.js"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
	<script src="/js/swift_calendar.js"></script>
	<script src="/ui/js/pickers-init.js"></script>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

	<script src="/js/functions.js" type="text/javascript"></script>


</head>
<body>
	<form id="form1" runat="server">
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<ol class="breadcrumb">
							<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
							<li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
							<li class="active">Paying Agent Settlement Report</li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<div class="panel panel-default ">
						<div class="panel-heading">
							<h4 class="panel-title">Paying Agent Settlement Report</h4>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">
							<div class="form-group">
								<label class="control-label col-md-3">Paying Agent:</label>
								<div class="col-md-8">
									<asp:DropDownList runat="server" ID="PayingAgent" CssClass="form-control " autocomplete="off">
									</asp:DropDownList>
								</div>
							</div>
							<div class="form-group">
								<label class="control-label col-md-3">From Date:</label>
								<div class="col-md-8">
									<asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
								</div>
							</div>
							<div class="form-group">
								<label class="control-label col-md-3">To Date:</label>
								<div class="col-md-8">
									<asp:TextBox ID="ToDate" onchange="return DateValidation('ToDate','t')" MaxLength="10" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
								</div>
							</div>
							<label class="control-label col-md-3"></label>
							<div class="col-md-8">
								<asp:Button ID="unpaidTxn" runat="server" CssClass="btn btn-primary m-t-25" Text="Summary" OnClientClick="return showSummaryReport()" />
								<asp:Button ID="detailTxn" runat="server" CssClass="btn btn-primary m-t-25" Text="Detail" OnClientClick="return showDetailReport()" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</form>
</body>
</html>
<script language="javascript" type="text/javascript">
	$(document).ready(function () {
		ShowCalFromToUpToToday("#fromDate", "#ToDate");
		$('#fromDate').mask('0000-00-00');
		$('#ToDate').mask('0000-00-00');
	});
	function showSummaryReport() {
		var PayingAgent = document.getElementById("PayingAgent").value;
		var fromDate = document.getElementById("fromDate").value;
		var ToDate = document.getElementById("ToDate").value;
		var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20167600&flag=s&PayingAgent=" + PayingAgent + "&fromDate=" + fromDate + "&ToDate=" + ToDate;
		OpenInNewWindow(url);
		return false;
	}

	function showDetailReport() {
		var PayingAgent = document.getElementById("PayingAgent").value;
		var fromDate = document.getElementById("fromDate").value;
		var ToDate = document.getElementById("ToDate").value;
		var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20167600&flag=detail1&PayingAgent=" + PayingAgent + "&fromDate=" + fromDate + "&ToDate=" + ToDate;
		OpenInNewWindow(url);
		return false;
	}
</script>
