<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TPRateAdd.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.TPRate.TPRateAdd" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<meta charset="utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<meta name="description" content="" />
	<meta name="author" content="" />
	<!--new css and js -->
	<%--    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
	<script src="/js/swift_calendar.js"></script>--%>

	<link href="/ui/css/style.css" rel="stylesheet" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
	<link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
	<link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
	<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script src="/ui/js/jquery.min.js"></script>
	<script src="/ui/bootstrap/js/bootstrap.min.js"></script>
	<script src="/js/Swift_grid.js" type="text/javascript"> </script>
	<script src="/js/functions.js" type="text/javascript"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<script src="/js/swift_autocomplete.js"></script>
	<script src="/js/swift_calendar.js"></script>
	<script src="/ui/js/pickers-init.js"></script>
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
		<asp:UpdatePanel ID="up" runat="server">
			<ContentTemplate>
				<div class="page-wrapper">
					<div class="row">
						<div class="col-sm-12">
							<div class="page-title">
								<ol class="breadcrumb">
									<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
									<li><a onclick="return LoadModule('adminstration')">Administration</a></li>
									<li class="active"><a href="#">Contact Rate Add</a></li>
								</ol>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default recent-activites">
								<div class="panel-heading">
									<h4 class="panel-title">Contact Rate Add</h4>
								</div>
								<div class="panel-body">
									<asp:UpdatePanel ID="UpdatePanel1" runat="server">
										<Triggers>
											<asp:PostBackTrigger ControlID="btnAdd" /> 
											<asp:PostBackTrigger ControlID="btnBulkAdd" /> 
										</Triggers>
										<ContentTemplate>
										<div class="row">
											<div class="col-lg-3 col-md-6 form-group hidden">
												<label class="control-label" for="fromCurr">
													Currency code (FROM):<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="fromCurr" runat="server" CssClass="form-control" required="required" Text="MNT"></asp:TextBox>
												<asp:RequiredFieldValidator ID="fromCurrValidator" runat="server" ControlToValidate="fromCurr" Display="Dynamic" ErrorMessage="Currency code (FROM) is required!" ForeColor="Red"></asp:RequiredFieldValidator>
												<asp:RegularExpressionValidator  Runat="server" ID="fromCurrRegexValidator" ControlToValidate="fromCurr" Display="Dynamic" ErrorMessage="Латин 3 үсгэн кодыг оруулна уу." ForeColor="Red" ValidationExpression="(^[A-Za-z]{3}$)"></asp:RegularExpressionValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group hidden">
												<label class="control-label" for="tuCurr">
													Currency code (TO):<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="toCurr" runat="server" CssClass="form-control" required="required" Text="USD"></asp:TextBox>
												<asp:RequiredFieldValidator ID="toCurrValidator" runat="server" ControlToValidate="toCurr" Display="Dynamic" ErrorMessage="Currency code (TO) is required!" ForeColor="Red"></asp:RequiredFieldValidator>
												<asp:RegularExpressionValidator  Runat="server" ID="toCurrRegexValidator" ControlToValidate="toCurr" Display="Dynamic" ErrorMessage="Латин 3 үсгэн кодыг оруулна уу." ForeColor="Red" ValidationExpression="(^[A-Za-z]{3}$)"></asp:RegularExpressionValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="rateDate" id="announcementDateFromLabel">Date:<span style="color: red;">*</span></label>
												<asp:TextBox ID="rateDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
												<asp:RequiredFieldValidator ID="rateDateValidator" runat="server" ControlToValidate="rateDate" Display="Dynamic" ErrorMessage="Date is required!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="multyValue">
													Multy:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="multyValue" runat="server" CssClass="form-control" required="required"></asp:TextBox>
												<asp:RequiredFieldValidator ID="multyValueValidator" runat="server" ControlToValidate="multyValue" Display="Dynamic" ErrorMessage="Multy is required!" ForeColor="Red"></asp:RequiredFieldValidator>
												<asp:RegularExpressionValidator  Runat="server" ID="multyValueNumbersOnly" ControlToValidate="multyValue" Display="Dynamic" ErrorMessage="Зөвхөн тоо оруулна уу." ForeColor="Red" ValidationExpression="(^[+-]?([0-9]*[.])?[0-9]+$)"></asp:RegularExpressionValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group hidden">
												<label class="control-label" for="ivValue">
													Div:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="divValue" runat="server" CssClass="form-control" required="required" Text="1"></asp:TextBox>
												<asp:RequiredFieldValidator ID="divValueValidator" runat="server" ControlToValidate="divValue" Display="Dynamic" ErrorMessage="Div is required!" ForeColor="Red"></asp:RequiredFieldValidator>
												<asp:RegularExpressionValidator  Runat="server" ID="divValueNumbersOnly" ControlToValidate="divValue" Display="Dynamic" ErrorMessage="Зөвхөн тоо оруулна уу." ForeColor="Red" ValidationExpression="(^[+-]?([0-9]*[.])?[0-9]+$)"></asp:RegularExpressionValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group hidden">
												<label class="control-label" for="rateType">
													Rate Type:<span style="color: red;">*</span>
												</label>
												<asp:DropDownList ID="rateType" runat="server" CssClass="form-control" required="required">
													<asp:ListItem Text="Rate Type" Value="">Rate Type</asp:ListItem>
													<asp:ListItem Text="RATE_BUY" Selected="True">RATE_BUY</asp:ListItem>
													<asp:ListItem Text="RATE_SELL">RATE_SELL</asp:ListItem>
												</asp:DropDownList>
												<asp:RequiredFieldValidator ID="rateTypeValidator" runat="server" ControlToValidate="rateType" ErrorMessage="Rate Type is required!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group hidden">
												<label class="control-label" for="actionType">
													Action:<span style="color: red;">*</span>
												</label>
												<asp:DropDownList ID="actionType" runat="server" CssClass="form-control" required="required">
													<asp:ListItem Text="Action" Value="">Action</asp:ListItem>
													<asp:ListItem Text="AddForBank">AddForBank</asp:ListItem>
													<asp:ListItem Text="AddForBranch" Selected="True">AddForBranch</asp:ListItem>
													<asp:ListItem Text="AddForOffice">AddForOffice</asp:ListItem>
												</asp:DropDownList>
												<asp:RequiredFieldValidator ID="actionTypeValidator" runat="server" ControlToValidate="actionType" ErrorMessage="Action is required!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="ratePoint">
													Rate Point:<span style="color: red;">*</span>
												</label>
												<asp:DropDownList ID="ratePoint" runat="server" CssClass="form-control" required="required">
													<%--<asp:ListItem Text="Rate Point" Value="" Selected="True">Rate Point</asp:ListItem>--%>
													<asp:ListItem Text="IUWA" Selected="True">IUWA</asp:ListItem>
													<asp:ListItem Text="KGWY">KGWY</asp:ListItem>
													<asp:ListItem Text="KGWZ">KGWZ</asp:ListItem>
													<asp:ListItem Text="KSQM">KSQM</asp:ListItem>
													<asp:ListItem Text="KSQN">KSQN</asp:ListItem>
													<asp:ListItem Text="KSQO">KSQO</asp:ListItem>
												</asp:DropDownList>
												<asp:RequiredFieldValidator ID="ratePointValidator" runat="server" ControlToValidate="ratePoint" ErrorMessage="Rate Point is required!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
										</div>
										</ContentTemplate>
									</asp:UpdatePanel>
									<div class="row">
										<div class="col-lg-12 form-group">
											<asp:Button ID="btnAdd" runat="server" Text="Add (Selected rate point)" CssClass="btn btn-primary m-t-25" OnClick="btnAdd_Click"/>
											<asp:Button ID="btnBulkAdd" runat="server" Text="Bulk Add (All rate point)" CssClass="btn btn-warning m-t-25" OnClick="btnBulkAdd_Click"/>
										</div>
										<Triggers>
											<asp:PostBackTrigger ControlID="btnAdd" /> 
											<asp:PostBackTrigger ControlID="btnBulkAdd" /> 
										</Triggers>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				</div>
			</ContentTemplate>
		</asp:UpdatePanel>
    </form>
</body>
</html>
