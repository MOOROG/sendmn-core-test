<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.soalnt.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<link href="../../../../ui/css/style.css" rel="stylesheet" />
	<link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>

	<script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
	<link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
	<script src="../../../../ui/js/bootstrap-datepicker.js"></script>
	<script src="../../../../../ui/js/pickers-init.js"></script>
	<script src="../../../../ui/js/jquery-ui.min.js"></script>
	<script src="../../../../js/functions.js" type="text/javascript"></script>
</head>
<body>
	<form id="form1" runat="server">
		<asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
		<div class="page-wrapper">
			<div class="row">
				<div class="col-sm-12">
					<div class="page-title">
						<h1></h1>
						<ol class="breadcrumb">
							<li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
							<li><a href="#" onclick="return LoadModule('sub_account')">Int'l Report </a></li>
							<li class="active"><a href="List.aspx">Statement Of Account Report</a></li>
						</ol>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6" id="DivFrm" runat="server">
					<div class="panel panel-default recent-activites">
						<div class="panel-heading">
							<h4 class="panel-title">Statement Of Account
							</h4>
							<%-- <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>--%>
							<div class="panel-actions">
								<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
							</div>
						</div>
						<div class="panel-body">
							<div class="form-group">
								<label class="col-lg-2 col-md-3 control-label" for="">
									Country: <span class="errormsg">*</span></label>
								<div class="col-lg-10 col-md-9">
									<asp:DropDownList ID="sendCountry" runat="server" AutoPostBack="true"
										OnSelectedIndexChanged="sendCountry_SelectedIndexChanged" CssClass="form-control">
									</asp:DropDownList>
									<asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
										ControlToValidate="sendCountry" Display="Dynamic" ErrorMessage="Required!"
										ForeColor="Red" ValidationGroup="rpt">
									</asp:RequiredFieldValidator>
								</div>
							</div>
							<div class="form-group">
								<label class="col-lg-2 col-md-3 control-label" for="">
									Agent: <span class="errormsg">*</span></label>
								<div class="col-lg-10 col-md-9">
									<asp:DropDownList ID="sendAgent" runat="server" CssClass="form-control">
									</asp:DropDownList>
									<asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
										ControlToValidate="sendAgent" Display="Dynamic" ErrorMessage="Required!"
										ForeColor="Red" ValidationGroup="rpt">
									</asp:RequiredFieldValidator>
								</div>
							</div>
							<div class="form-group">
								<label class="col-lg-2 col-md-3 control-label" for="">
									From Date: <span class="errormsg">*</span></label>
								<div class="col-lg-10 col-md-9">
									<div class="input-group m-b">
										<span class="input-group-addon">
											<i class="fa fa-calendar" aria-hidden="true"></i>
										</span>
										<asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
										<asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
											ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
										</asp:RequiredFieldValidator>
									</div>
								</div>
							</div>
							<div class="form-group">
								<label class="col-lg-2 col-md-3 control-label" for="">
									To Date: <span class="errormsg">*</span></label>
								<div class="col-lg-10 col-md-9">
									<div class="input-group m-b">
										<span class="input-group-addon">
											<i class="fa fa-calendar" aria-hidden="true"></i>
										</span>
										<asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
										<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
											ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
										</asp:RequiredFieldValidator>
									</div>
								</div>
							</div>
							<div class="form-group">
								<div class="col-md-2 col-md-offset-3">
									<asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25"
										Text="Search" ValidationGroup="rpt" OnClick="BtnSave_Click" />
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-12">
					<div id="DivRptHead" runat="server">
						<div id="head" style="width: 80%" class="reportHead">Statement Of Account</div>
						<div id="filters" class="reportFilters">
							Filters Applied :<br />
							Country=<asp:Label runat="server" ID="lblCountry"></asp:Label>&nbsp;|
        Agent=<asp:Label runat="server" ID="lblAgentName"></asp:Label>&nbsp;|
        From Date=<asp:Label runat="server" ID="lblFrmDate"></asp:Label>
							&nbsp;To Date=<asp:Label runat="server" ID="lbltoDate"></asp:Label>&nbsp;|
        Generated On=
                            <asp:Label runat="server" ID="lblGeneratedDate"></asp:Label>
							&nbsp;|
        Generated By=
                            <asp:Label runat="server" ID="lblGeneratedBy"></asp:Label>
							&nbsp;|<br />
							Statement Currency=
                            <asp:Label runat="server" ID="lblCurr"></asp:Label>
						</div>
						<div id="rptDiv" runat="server"></div>
						<table width="412" border="1" cellspacing="0" cellpadding="3" class="TBL" style="margin-left: 10px;">
							<tr>
								<th>
									<div align="left">Opening Balance:</div>
								</th>
								<td>
									<asp:Label runat="server" ID="lblOpSing"></asp:Label></td>
								<td>
									<div align="right">
										<asp:Label runat="server" ID="lblOpAmt"></asp:Label>
									</div>
								</td>
							</tr>
							<tr>
								<th width="125">
									<div align="left">DR Total:</div>
								</th>
								<td width="33">&nbsp;</td>
								<td width="226">
									<div align="right">
										<asp:Label runat="server" ID="lblDrTotal"></asp:Label>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<div align="left">CR Total:</div>
								</th>
								<td>&nbsp;</td>
								<td>
									<div align="right">
										<asp:Label runat="server" ID="lblCrTotal"></asp:Label>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<div align="left">Closing Balance:</div>
								</th>
								<td>
									<asp:Label runat="server" ID="lblCloSign"></asp:Label>
								</td>
								<td>
									<div align="right">
										<asp:Label runat="server" ID="lblCloAmt"></asp:Label>
									</div>
								</td>
							</tr>
							<tr>
								<td colspan="3">
									<div align="right">
										<asp:Label runat="server" ID="lblAmtMsg" Style="font-weight: 700; color: Red;"></asp:Label>
									</div>
								</td>
							</tr>
						</table>
					</div>
				</div>
			</div>
		</div>
	</form>
</body>
</html>
