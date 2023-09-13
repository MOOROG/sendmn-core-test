<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AgentSetup.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
			ShowCalDefault("#contractExpiryDate");
			ShowCalDefault("#renewalFollowupDate");
			//ShowCalFromToUpToToday("#contractExpiryDate", "#renewalFollowupDate");
		});

		$(document).ready(function () {
			$('.collMode-chk').click(function () {
				$('.collMode-chk').not(this).propAttr('checked', false);
			});
		});
	</script>
</head>
<body>
	<form id="form1" runat="server" class="col-md-12">
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
									<li class="active"><a href="Manage.aspx?aType=<%=GetAgentType() %>&parent_id=<%=GetParentId() %>&sParentId=<%=GetSParentId() %>&actAsBranch=<%=GetActAsBranchFlag() %>&mode=<%=GetMode() %>">Agent Management</a></li>
								</ol>
							</div>
						</div>
					</div>
					<asp:Panel ID="pnl1" runat="server">
						<div class="listtabs">
							<ul class="nav nav-tabs" role="tablist">
								<li><a href="Functions/ListAgent.aspx">Agent List</a></li>
								<li role="presentation" class="active"><a href="#" class="selected" href="#list" aria-controls="home" role="tab" data-toggle="tab">Manage </a></li>
							</ul>
						</div>
					</asp:Panel>
					<div class="row ">
						<div class="tabs " id="divTab" runat="server" visible="false"></div>
						<div class="col-md-5">
							<asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<div class="panel panel-default recent-activites">
								<div class="panel-heading">
									<h4 class="panel-title">Agent Setup
									</h4>
									<div class="panel-actions">
										<a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
											class="panel-action panel-action-dismiss" data-panel-dismiss></a>
									</div>
								</div>
								<div class="panel-body">
									<div class="row" id="branchCodeField" runat="server">
										<div class="col-lg-3 col-md-12 form-group">
											<label class="control-label" for="">
												Branch Code:<span style="color: red;">*</span>
											</label>
											<asp:TextBox ID="branchCode" runat="server" CssClass="form-control" MaxLength="3"></asp:TextBox>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="branchCode"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Name:<span style="color: red;">*</span>
											</label>
											<asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="agentName"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:TextBox ID="agentName" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Business License:<span style="color: red;">*</span>
											</label>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="businessLicense"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:TextBox ID="businessLicense" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Registration Type:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="businessOrgType"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:DropDownList ID="businessOrgType" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
										<div class="col-lg-3 col-md-3 form-group" hidden>
											<label class="control-label" for="">
												Agent Type:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfd22" runat="server" ControlToValidate="agentType"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:DropDownList ID="agentType" runat="server" CssClass="form-control">
											</asp:DropDownList>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Is Settling Agent:
											</label>
											<asp:DropDownList ID="isSettlingAgent" runat="server" CssClass="form-control">
												<asp:ListItem Value="N">No</asp:ListItem>
												<asp:ListItem Value="Y" Selected="True">Yes</asp:ListItem>
											</asp:DropDownList>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Business Type:<span class="errormsg">*</span>

											</label>
											<asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="businessType"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:DropDownList ID="businessType" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Contract Expiry Date:
											</label>
											<asp:TextBox ID="contractExpiryDate" runat="server" CssClass="form-control form-control-inline "></asp:TextBox>
											<asp:RangeValidator ID="rv1" runat="server"
												ControlToValidate="contractExpiryDate" MaximumValue="12/31/2100" MinimumValue="01/01/1900" Type="Date" ErrorMessage="* Invalid date"
												ValidationGroup="agent" CssClass="errormsg" SetFocusOnError="true" Display="Dynamic"> </asp:RangeValidator>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Renewal Follow-up Date:
											</label>
											<asp:TextBox ID="renewalFollowupDate" runat="server" CssClass="form-control form-control-inline "></asp:TextBox>
											<asp:RangeValidator ID="rv2" runat="server" ControlToValidate="renewalFollowupDate" MaximumValue="12/31/2100" MinimumValue="01/01/1900"
												Type="Date" ErrorMessage="* Invalid date" ValidationGroup="agent" CssClass="errormsg" SetFocusOnError="true" Display="Dynamic"> </asp:RangeValidator>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Agent Group:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfv" runat="server" ControlToValidate="agentGroup"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:DropDownList ID="agentGroup" runat="server" CssClass="form-control">
											</asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Agent Settlement Currency:
											</label>
											<asp:DropDownList ID="agentSettCurr" runat="server" CssClass="form-control">
											</asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Is Head Office:
											</label>
											<asp:DropDownList ID="isHeadOffice" runat="server" CssClass="form-control">
												<asp:ListItem Value="N">No</asp:ListItem>
												<asp:ListItem Value="Y">Yes</asp:ListItem>
											</asp:DropDownList>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Country:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfd9" runat="server" ControlToValidate="agentCountry"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:DropDownList ID="agentCountry" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="agentCountry_SelectedIndexChanged">
											</asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												<asp:Label ID="lblRegionType" runat="server" Text="State"></asp:Label>:
											</label>
											<asp:DropDownList ID="agentState" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="agentState_SelectedIndexChanged">
											</asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												District:
											</label>
											<asp:DropDownList ID="agentDistrict" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-4 col-md-4 form-group" style="display: none">
											<label class="control-label" for="">
												City:
											</label>
											<asp:TextBox ID="agentCity" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-4 col-md-4 form-group" style="display: none">
											<label class="control-label" for="">
												Location:<span class="errormsg" id="spnAgentLocation" runat="server">*</span>

											</label>
											<asp:DropDownList ID="agentLocation" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Address:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfd5" runat="server" ControlToValidate="agentAddress"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:TextBox ID="agentAddress" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Mapcode Domestic:
											</label>
											<asp:TextBox ID="mapCodeDom" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-4 col-md-4 form-group">
											<label class="control-label" for="">
												Partner Bankcode:
											</label>
											<asp:TextBox ID="partnerBankcode" runat="server" CssClass="form-control"></asp:TextBox>
										</div>

									</div>
									<asp:UpdatePanel ID="upd2" runat="server">
										<ContentTemplate>
											<div class="row">
											</div>

										</ContentTemplate>
									</asp:UpdatePanel>
									<div class="row">
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Phone1:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfd11" runat="server" ControlToValidate="agentPhone1"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:TextBox ID="agentPhone1" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="AGENT_PHONE1_FilteredTextBoxExtender"
												runat="server" Enabled="True" FilterType="Numbers" TargetControlID="agentPhone1">
											</cc1:FilteredTextBoxExtender>
										</div>
										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Phone2:
											</label>
											<asp:TextBox ID="agentPhone2" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtende"
												runat="server" Enabled="True" FilterType="Numbers" TargetControlID="agentPhone2">
											</cc1:FilteredTextBoxExtender>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Mobile1:
											</label>
											<asp:TextBox ID="agentMobile1" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender6"
												runat="server" Enabled="True" FilterType="Numbers" TargetControlID="agentMobile1">
											</cc1:FilteredTextBoxExtender>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Fax1:
											</label>
											<asp:TextBox ID="agentFax1" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender5"
												runat="server" Enabled="True" FilterType="Numbers" TargetControlID="agentFax1">
											</cc1:FilteredTextBoxExtender>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Contact Person1:<span class="errormsg">*</span>
											</label>
											<asp:RequiredFieldValidator ID="rfv12443" runat="server" ControlToValidate="contactPerson1"
												Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
												SetFocusOnError="True"></asp:RequiredFieldValidator>
											<asp:TextBox ID="contactPerson1" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Mobile2:
											</label>
											<asp:TextBox ID="agentMobile2" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender8" runat="server" Enabled="True"
												FilterType="Numbers" TargetControlID="agentMobile2">
											</cc1:FilteredTextBoxExtender>
										</div>
									</div>
									<div class="row">

										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Fax2:
                                                     
											</label>
											<asp:TextBox ID="agentFax2" runat="server" CssClass="form-control"></asp:TextBox>
											<cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1"
												runat="server" Enabled="True" FilterType="Numbers" TargetControlID="agentFax2">
											</cc1:FilteredTextBoxExtender>
										</div>

										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Contact Person2:
											</label>
											<asp:TextBox ID="contactPerson2" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Email1:
											</label>
											<asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server" ValidationGroup="agent"
												ControlToValidate="agentEmail1" ErrorMessage="Invalid Email!" SetFocusOnError="True" ForeColor="Red"
												ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">
											</asp:RegularExpressionValidator>
											<asp:TextBox ID="agentEmail1" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Email2:
											</label>
											<asp:RegularExpressionValidator ID="RegularExpressionValidator6" runat="server"
												ControlToValidate="agentEmail2" ErrorMessage="Invalid Email!" SetFocusOnError="True" ForeColor="Red"
												ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">
											</asp:RegularExpressionValidator>
											<asp:TextBox ID="agentEmail2" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Is Block:
											</label>
											<asp:DropDownList ID="agentBlock" runat="server"
												CssClass="form-control">
												<asp:ListItem Selected="True" Value="">Select...</asp:ListItem>
												<asp:ListItem Value="B">Block</asp:ListItem>
												<asp:ListItem Value="U">Unblock</asp:ListItem>
											</asp:DropDownList>
										</div>
										<div class="col-lg-3 col-md-3 form-group" style="display: none">
											<label class="control-label" for="">
												Is Active:
											</label>
											<asp:DropDownList ID="isActive" runat="server"
												CssClass="form-control">
												<asp:ListItem Value="Y">Yes</asp:ListItem>
												<asp:ListItem Value="N">No</asp:ListItem>
											</asp:DropDownList>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Bank Code:
											</label>
											<asp:TextBox ID="bankCode" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Bank Branch:
											</label>
											<asp:TextBox ID="bankBranch" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Account Holder's Name:
											</label>
											<asp:TextBox ID="accHolderName" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
									</div>
									<div class="row">


										<div class="col-lg-3 col-md-3 form-group">
											<label class="control-label" for="">
												Account Number:
											</label>
											<asp:TextBox ID="accNumber" runat="server" CssClass="form-control"></asp:TextBox>
										</div>
										<div class="col-lg-3 col-md-3 form-group">
											<br />
											<label class="control-label" for="isApiPartner">
												Is API Partner:&nbsp;
											</label>
											<asp:CheckBox ID="isApiPartner" runat="server"></asp:CheckBox>
											<label class="control-label" for="intlCheck">
												&nbsp;&nbsp;&nbsp;&nbsp;Is Ext Agent:&nbsp;
											</label>
											<asp:CheckBox ID="intlCheck" runat="server"></asp:CheckBox>
										</div>
									</div>

									<div class="row">
									</div>
									<div class="row">
										<div class="col-lg-12 col-md-12 form-group">
											<label class="control-label" for="">
												Agent Details:
											</label>
											<asp:TextBox ID="agentDetails" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
										</div>
									</div>
									<div class="row" id="headMsgShow" runat="server" visible="false">
										<div class="col-lg-12 col-md-12 form-group">
											<label class="control-label" for="">
												Head Message:
											</label>
											<asp:TextBox ID="headMessage" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-12 col-md-3 form-group">
											<div id="divAuditLog" runat="server"></div>
										</div>
									</div>
									<div class="row">
										<div class="col-lg-12 col-md-3 form-group">
											<asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25" ValidationGroup="agent"
												OnClick="bntSubmit_Click" />
											<cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
												ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
											</cc1:ConfirmButtonExtender>
											&nbsp;<asp:Button ID="btnDelete" runat="server" Text="Delete"
												CssClass="btn btn-danger m-t-25" OnClick="btnDelete_Click" />
											<cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
												ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
											</cc1:ConfirmButtonExtender>
										</div>
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
<script type="text/javascript">
		$("#branchCode").change(function () {
			branchCode = $("#branchCode").val();
			if (branchCode.length !== 3) {
				alert("Branch code must be three characters");
				$(this).focus();
				return false;
			}
			return true;
		});
    <%--function CheckBranchCode() {
        alert("HJGH");
        var agentType = $("#<%=hdnAType.ClientID%>").val();
        if (agentType === "2904") {
            branchCode = $(this).val();
            if (branchCode.length !== 3) {
                alert("Branch Code Must Be Three characters");
                $(this).focus();
                return false;
            }
        }
        return true
    }--%>
		function CallBack(mes) {
			var resultList = ParseMessageToArray(mes);
			alert(resultList[1]);

			if (resultList[0] != 0) {
				return;
			}

			window.returnValue = resultList[0];
			window.close();
		}

    //$(document).ready(function () {
    //    $("#agentCountry").change(function () {
    //        var agentCountry = $("#agentCountry").val();
    //        if (agentCountry == "151") {
    //            // $("#agentLocation").removeAttr("disabled");
    //            $("#agentLocation").prop("disabled", false);
    //            // $("#agentLocation").removeProp("disabled");
    //        }

    //    });
    //});

    //
    //i

    <%--function GoogleMap() {
        var lat = GetValue("<%=latitude.ClientID%>");
        var lon = GetValue("<%=longitude.ClientID%>");
        var url = "http://maps.google.com/maps";
        if (lat == "" && lon == "")
            url += "?q=nepal";
        else
            url += "?ll=" + lat + "," + lon;
        url += "&z=16";
        var param = "dialogHeight:1500px;dialogWidth:1500px;dialogLeft:0;dialogTop:0;center:yes";
        this.PopUpWindow(url, param);
    }--%>
</script>
</html>
