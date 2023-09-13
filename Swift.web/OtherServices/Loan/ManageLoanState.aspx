<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageLoanState.aspx.cs" Inherits="Swift.web.OtherServices.Loan.NewLoanState" %>

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
	<script type="text/javascript">
		$(document).ready(function () {
			$('.collMode-chk').click(function () {
				$('.collMode-chk').not(this).propAttr('checked', false);
			});
		});
    </script>
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
									<li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
									<li><a href="LoanState.aspx">Loan State</a></li>
									<li class="active"><a href="#">Manage Loan State</a></li>
								</ol>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default recent-activites">
								<div class="panel-heading">
									<h4 class="panel-title">Loan State</h4>
								</div>
								<div class="panel-body">
									<asp:UpdatePanel ID="UpdatePanel1" runat="server">
										<Triggers>
											<asp:PostBackTrigger ControlID="btnRegister" /> 
										</Triggers>
										<ContentTemplate>
										<div class="row">
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="stateName">
													Төлөв:
												</label>
												<asp:DropDownList ID="stateName" runat="server" CssClass="form-control" Enabled="false">
													<asp:ListItem Enabled="true" Text="Сонгох" Value="" Selected="True"></asp:ListItem>
												</asp:DropDownList>
												<asp:TextBox ID="stateNmBx" runat="server" CssClass="form-control" Visible="false"></asp:TextBox>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="isActive">
													Active:
												</label>
												<asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
													<asp:ListItem Value="1">Yes</asp:ListItem>
													<asp:ListItem Value="0">No</asp:ListItem>
												</asp:DropDownList>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="isDeleted">
													Deleted:
												</label>
												<asp:DropDownList ID="isDeleted" runat="server" CssClass="form-control">
													<asp:ListItem Value="1">Yes</asp:ListItem>
													<asp:ListItem Selected="True" Value="0">No</asp:ListItem>
													<asp:ListItem Value="0">No</asp:ListItem>
												</asp:DropDownList>
											</div>
										</div>
										</ContentTemplate>
									</asp:UpdatePanel>
									<div class="row">
										<div class="col-lg-12 form-group">
											<asp:Button ID="btnRegister" runat="server" Text="Add Loan" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click"/>
										</div> 
										<%--<Triggers>
											<asp:PostBackTrigger ControlID="btnRegister" /> 
										</Triggers>--%>
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
