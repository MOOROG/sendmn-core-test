<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PopUpforState.aspx.cs" Inherits="Swift.web.Remit.TPSetup.PopUps.PopUpforState" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<base id="Base1" target="_self" runat="server" />
	<script src="/js/swift_grid.js" type="text/javascript"> </script>
	<script src="/js/functions.js" type="text/javascript"> </script>
	<link href="/css/style.css" rel="stylesheet" type="text/css" />
	<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/ui/css/style.css" rel="stylesheet" />
	 <script type="text/javascript">
		var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
		function CallBack(res) {
            window.returnValue = res;
            if (isChrome) {
                window.opener.PostMessageToParent();
            }
            window.close();
        }
	</script>
</head>
<body>
    <form id="form2" runat="server">
		<asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
		<div class="Container-fluid">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#">Partner State List</a></li>
							<li class="active"><a href="#">Sync Partner State</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="report-tab" runat="server" id="Div1">
				<!-- Nav tabs -->
				<div class="listtabs">
					<ul class="nav nav-tabs" role="tablist">
						<li role="presentation" class="active"><a href="#">Sync Partner State</a></li>
					</ul>
				</div>

				<div class="tab-content">
					<div role="tabpanel" class="tab-pane" id="List">
					</div>
					<div role="tabpanel" id="Manage">
						<div class="row">
							<div class="col-sm-12 col-md-12">
								<div class="register-form">
									<div class="panel panel-default clearfix m-b-20">
										<div class="panel-heading">Sync Partner State</div>
										<div class="panel-body row">
											<div class="col-md-6">
												<div class="col-md-12" id="Div2" runat="server" visible="false" style="background-color: red;">
													<asp:Label ID="Label1" runat="server" ForeColor="White"></asp:Label>
												</div>
												<div class="col-sm-6">
													<div class="form-group">
														<label>API partner <span class="errormsg">*</span></label>
														<asp:DropDownList runat="server" ID="ddlApiPartner" CssClass="form-control"></asp:DropDownList>
													</div>
												</div>
												<div class="col-sm-6">
													<div class="form-group">
														<label>Country Name <span class="errormsg">*</span></label>
														<asp:DropDownList runat="server" ID="ddlcountryName" Name="ddlStatus" CssClass="form-control"></asp:DropDownList>
													</div>
												</div>
												<div class="col-sm-6">
													<div class="form-group">
													<asp:Button ID="btnDownload" runat="server" Text="DownLoad" OnClick="btnDownload_Click"  CssClass="btn btn-primary" />	</div>
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

		</div>
	</form>
</body>
</html>
