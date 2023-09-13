<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageBranchCustomer.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.NewBranchCustomer" %>

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
									<li><a onclick="return LoadModule('adminstration')">Administration</a></li>
									<li><a href="BranchCustomer.aspx">Branch Customer</a></li>
									<li class="active"><a href="#">Manage Branch Customer</a></li>
								</ol>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default recent-activites">
								<div class="panel-heading">
									<h4 class="panel-title">Branch Customer</h4>
								</div>
								<div class="panel-body">
									<asp:UpdatePanel ID="UpdatePanel1" runat="server">
										<Triggers>
											<asp:PostBackTrigger ControlID="btnRegister" /> 
										</Triggers>
										<ContentTemplate>
										<div class="row">
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="lastname">
													Овог:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="lastname" runat="server" CssClass="form-control"></asp:TextBox>
												<asp:RequiredFieldValidator ID="lastnameValidator" runat="server" ControlToValidate="lastname" ErrorMessage="Овог оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="firstname">
													Нэр:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="firstname" runat="server" CssClass="form-control"></asp:TextBox>
												<asp:RequiredFieldValidator ID="firstnameValidator" runat="server" ControlToValidate="firstname" ErrorMessage="Нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="regNum">
													Регистрийн дугаар:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="regNum" runat="server" CssClass="form-control"></asp:TextBox>
												<asp:RequiredFieldValidator ID="regNumValidator" runat="server" ControlToValidate="regNum" ErrorMessage="Регистрийн дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="mobileNum">
													Утас:<span style="color: red;">*</span>
												</label>
												<asp:TextBox ID="mobileNum" runat="server" CssClass="form-control"></asp:TextBox>
												<asp:RequiredFieldValidator ID="mobileNumValidator" runat="server" ControlToValidate="mobileNum" ErrorMessage="Утасны дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="gender">
													Хүйс:
												</label>
												<br />
												<asp:RadioButtonList ID="gender" runat="server" RepeatLayout="Flow" RepeatDirection="Horizontal">
													<asp:ListItem Value="Эр">Эр</asp:ListItem>
													<asp:ListItem Value="Эм">Эм</asp:ListItem>
												</asp:RadioButtonList>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="email">
													Email:
												</label>
												<asp:TextBox ID="email" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="addressProvince">
													Аймаг/Хот:
												</label>
												<asp:DropDownList ID="addressProvince" runat="server" CssClass="form-control">
													<asp:ListItem Text="Аймаг/Хот" Value="" Selected="True">Аймаг/Хот сонгох</asp:ListItem>
													<asp:ListItem Text="Улаанбаатар">Улаанбаатар</asp:ListItem>
													<asp:ListItem Text="Архангай">Архангай</asp:ListItem>
													<asp:ListItem Text="Баянхонгор">Баянхонгор</asp:ListItem>
													<asp:ListItem Text="Баян-Өлгий">Баян-Өлгий</asp:ListItem>
													<asp:ListItem Text="Булган">Булган</asp:ListItem>
													<asp:ListItem Text="Говьсүмбэр">Говьсүмбэр</asp:ListItem>
													<asp:ListItem Text="Говь-Алтай">Говь-Алтай</asp:ListItem>
													<asp:ListItem Text="Дархан-Уул">Дархан-Уул</asp:ListItem>
													<asp:ListItem Text="Дорноговь">Дорноговь</asp:ListItem>
													<asp:ListItem Text="Дорнод">Дорнод</asp:ListItem>
													<asp:ListItem Text="Дундговь">Дундговь</asp:ListItem>
													<asp:ListItem Text="Завхан">Завхан</asp:ListItem>
													<asp:ListItem Text="Орхон">Орхон</asp:ListItem>
													<asp:ListItem Text="Өвөрхангай">Өвөрхангай</asp:ListItem>
													<asp:ListItem Text="Өмнөговь">Өмнөговь</asp:ListItem>
													<asp:ListItem Text="Сэлэнгэ">Сэлэнгэ</asp:ListItem>
													<asp:ListItem Text="Сүхбаатар">Сүхбаатар</asp:ListItem>
													<asp:ListItem Text="Төв">Төв</asp:ListItem>
													<asp:ListItem Text="Увс">Увс</asp:ListItem>
													<asp:ListItem Text="Ховд">Ховд</asp:ListItem>
													<asp:ListItem Text="Хөвсгөл">Хөвсгөл</asp:ListItem>
													<asp:ListItem Text="Хэнтий">Хэнтий</asp:ListItem>
												</asp:DropDownList>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="addressDistrict">
													Сум/Дүүрэг:
												</label>
												<asp:TextBox ID="addressDistrict" runat="server" CssClass="form-control"></asp:TextBox>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="address">
													Хаяг:
												</label>
												<asp:TextBox ID="address" runat="server" CssClass="form-control"></asp:TextBox>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="dateofbirth">
													Төрсөн огноо:
												</label>
												<asp:TextBox ID="dateofbirth" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
											</div>
											<div class="col-lg-3 col-md-6 form-group">
												<label class="control-label" for="occupationType">
													Ажилладаг салбар:
												</label>
												<asp:DropDownList ID="occupationType" runat="server" CssClass="form-control">
													<asp:ListItem Enabled="true" Text="Ажилладаг салбар сонгох" Value="" Selected="True"></asp:ListItem>
												</asp:DropDownList>
											</div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="occupationType">
                          Иргэншил:
                        </label>
                        <asp:DropDownList ID="nationalityDdl" runat="server" CssClass="form-control">
                          <asp:ListItem Enabled="true" Text="Иргэншил сонгох" Value="" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                      </div>
										</div>
											<div class="row">
												<div class="col-lg-2 col-md-4 form-group">
													<label class="control-label" for="photo1">Photo 1:</label>
													<asp:FileUpload ID="photo1" runat="server" CssClass="form-control" accept="image/*" />
													<%= photoPreview[0] %>
												</div>
												<div class="col-lg-2 col-md-4 form-group">
													<label class="control-label" for="photo2">Photo 2:</label>
													<asp:FileUpload ID="photo2" runat="server" CssClass="form-control" accept="image/*" />
													<%= photoPreview[1] %>
												</div>
												<div class="col-lg-2 col-md-4 form-group">
													<label class="control-label" for="photo3">Photo 3:</label>
													<asp:FileUpload ID="photo3" runat="server" CssClass="form-control" accept="image/*" />
													<%= photoPreview[2] %>
												</div>
												<div class="col-lg-2 col-md-4 form-group">
													<label class="control-label" for="photo4">Photo 4:</label>
													<asp:FileUpload ID="photo4" runat="server" CssClass="form-control" accept="image/*" />
													<%= photoPreview[3] %>
												</div>
												<div class="col-lg-2 col-md-4 form-group">
													<label class="control-label" for="photo5">Photo 5:</label>
													<asp:FileUpload ID="photo5" runat="server" CssClass="form-control" accept="image/*" />
													<%= photoPreview[4] %>
												</div>
											</div>
										</ContentTemplate>
									</asp:UpdatePanel>
									<div class="row">
										<div class="col-lg-12 form-group">
											<asp:Button ID="btnRegister" runat="server" Text="Register Customer" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click"/>
										</div>
										<Triggers>
											<asp:PostBackTrigger ControlID="btnRegister" /> 
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
