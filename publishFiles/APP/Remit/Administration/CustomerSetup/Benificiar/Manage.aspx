<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" EnableEventValidation="false" Inherits="Swift.web.Remit.Administration.CustomerSetup.Benificiar.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<title></title>
	<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/css/intlTelInput.css" />
	<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/ui/css/style.css" rel="stylesheet" />
	<link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
	<script src="/js/swift_grid.js" type="text/javascript"> </script>
	<script src="/js/functions.js"></script>
	<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
	<script src="/js/swift_calendar.js" type="text/javascript"></script>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
	<script src="/js/popper/popper.min.js"></script>
	<script src="/js/bootstrap/js/bootstrap.min.js"></script>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/intlTelInput.min.js"></script>
	<style>
		.table .table {
			background-color: #F5F5F5 !important;
		}
	</style>

	<script type="text/javascript">
		$(document).ready(function () {
			$("#txtSenderMobileNo").intlTelInput({
				nationalMode: true,
				utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/utils.js"
			})
			PopulateCountryFlagForMobileNumber();

			$("#txtSenderMobileNo").on("keyup change", function () {
				var input = $("#txtSenderMobileNo");
				var intlNumber = input.intlTelInput("getNumber", intlTelInputUtils.numberFormat.E164);
				$(this).val(intlNumber);
			});

			$('#ddlCountry').on('change', function () {
				$("#txtSenderMobileNo").val('');
				PopulateCountryFlagForMobileNumber();
				PopulatePaymentMethod();
				PopulatePayoutPartner();
			});
		});

		function PopulatePaymentMethod() {
			var data =
			{
				MethodName: "PopulatePaymentMode",
				country: $("#ddlCountry option:selected").text()
			};
			$.ajax({
				url: "",
				type: "post",
				data: data,
				dataType: "json",
				async: false,
				success: function (response) {
					PopulateDDL(response, 'ddlPaymentMode', "", "", "");
				},
				error: function (error) {
					alert("Something went wrong!!!")
				}
			})
		}

		function PopulatePayoutPartner() {
			var pmode = $("#ddlPaymentMode option:selected").val();
			if (pmode == "2")
				$("#receiverAccountNo").show();
			else
				$("#receiverAccountNo").hide();
			var data =
			{
				MethodName: "PopulatePayoutPartner",
				country: $("#ddlCountry option:selected").val(),
				paymentMode: $("#ddlPaymentMode option:selected").text()
			};
			$.ajax({
				url: "",
				type: "post",
				data: data,
				dataType: "json",
				success: function (response) {
					PopulateDDL(response, 'ddlPayoutPatner', "", "", "");
				},
				error: function (error) {
					alert("Something went wrong!!!")
				}
			})
		}

		function PopulateDDL(populateData, ddlId, selectedId, selectedText, defaultText) {
			var myDDL = document.getElementById(ddlId);
			$(myDDL).empty();
			var option;
			if (defaultText != '') {
				option = document.createElement('option');
				option.text = defaultText;
				option.value = '';

				myDDL.options.add(option);
			}
			for (var i = 0; i < populateData.length; i++) {
				option = document.createElement('option');
				if (ddlId == 'ddlPaymentMode') {
					option.text = populateData[i].Value;
					option.value = populateData[i].Key;

				} else {
					option.text = populateData[i].AGENTNAME;
					option.value = populateData[i].AGENTID;
				}

				if (selectedId != '' && selectedId == populateData[i].value) {
					option.selected = true;
				} else if (selectedText != '' && selectedText.toUpperCase() == populateData[i].Key.toUpperCase()) {
					option.selected = true;
				}

				try {
					myDDL.options.add(option);
				} catch (e) {
					alert(e.message);

				}
			}
		}

		function getUrlVars() {
			var vars = [], hash;
			var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
			for (var i = 0; i < hashes.length; i++) {
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
			return vars;
		}

		function showTextBox() {
			var res = $("#<% =ddlRelationship.ClientID%>").val();
			if (res.toUpperCase() == "11065") {
				$("#otherRelationDiv").show();
			}
			else {
				$("#otherRelationDiv").hide();
			}
		}

		function CheckFormValidation() {
			paymentMode = $("#<% =ddlPaymentMode.ClientID%>").val();
			var reqField = "";
			var requiredElement = document.getElementsByClassName('required');
			for (var i = 0; i < requiredElement.length; ++i) {
				var item = requiredElement[i].id;
				reqField += item + ",";
			}
			if (ValidRequiredField(reqField) === false) {
				return false;
			}
			save();
		}

		function save() {
			var addType ='<%=GetReceiverAddType()%>';
			var data =
			{
				MethodName: "SaveReceiverDetails",
				nativeCountry: $("#ddlNativeCountry").val(),
				paymentMode: $("#ddlPaymentMode option:selected").val(),
				PayoutPatner: $("#ddlPayoutPatner option:selected").val(),
				Country: $("#ddlCountry option:selected").text(),
				BenificiaryType: $("#ddlBenificiaryType option:selected").val(),
				Email: $("#txtEmail").val(),
				ReceiverFName: $("#txtReceiverFName").val(),
				ReceiverMName: $("#txtReceiverMName").val(),
				ReceiverLName: $("#txtReceiverLName").val(),
				ReceiverAddress: $("#txtReceiverAddress").val(),
				ReceiverCity: $("#txtReceiverCity").val(),
				ContactNo: $("#txtContactNo").val(),
				SenderMobileNo: $("#txtSenderMobileNo").val(),
				Relationship: $("#ddlRelationship option:selected").val(),
				PlaceOfIssue: $("#txtPlaceOfIssue").val(),
				TypeId: $("#ddlIdType option:selected").val(),
				TypeValue: $("#txtIdValue").val(),
				BenificaryAc: $("#receiverAccountNo").val(),
				PurposeOfRemitance: $("#ddlPurposeOfRemitance").val(),
				BankLocation: $("#txtBankLocation").val(),
				BankName: $("#txtBankName").val(),
				BenificaryAc: $("#txtBenificaryAc").val(),
				Remarks: $("#txtRemarks").val(),
				OtherRelationDescription: $("#otherRelationshipTextBox").val(),
				membershipId: $("#hideMembershipId").val(),
				ReceiverId: $("#hideBenificialId").val(),
				hideCustomerId: $("#hideCustomerId").val(),
				hideBenificialId: $("#hideBenificialId").val()
			};
			$.ajax({
				url: "",
				type: "post",
				data: data,
				dataType: "json",
				success: function (response) {
					if (response.ErrorCode == "1") {
						alert(response.Msg);
						return false;
					} else {
						if (addType.toLowerCase() == "s") {
							CallBack(response.Id);
						}
						else {
							window.location.href = "List.aspx?customerId=" + $("#hideCustomerId").val();
							return;
						}
						return true;
					}
				},
				error: function (error) {
					alert("Something went wrong!!!");
					return false;
				}
			})

		}

		var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;

		function CallBack(res) {
			window.returnValue = res;
			if (isChrome) {
				window.opener.PostMessageToParentAddReceiver(window.returnValue);
			}
			window.close();
		}

		function PopulateCountryFlagForMobileNumber() {
			var getCountry = $("#ddlCountry option:selected").text();
			var code = getCountry.split('(');
			if (code.length > 1) {
				code = code[1].split(')')[0];
				$("#txtSenderMobileNo").intlTelInput('setCountry', code);

			}
		}
	</script>
</head>
<body>
	<form id="form1" runat="server" class="col-md-12">
		<asp:ScriptManager runat="server" ID="sc">
		</asp:ScriptManager>
		<asp:UpdatePanel ID="up1" runat="server">
			<ContentTemplate>
				<div class="page-wrapper">
					<div class="row">
						<div class="col-sm-12">
							<div class="page-title">
								<h1></h1>
							</div>
						</div>
					</div>
					<div class="report-tab" runat="server" id="regUp">
						<!-- Nav tabs -->
						<div class="listtabs">
							<ul class="nav nav-tabs" role="tablist">
								<li role="presentation" runat="server" id="receiverList"><a href="List.aspx?customerId=<%=hideCustomerId.Value %>">Beneficiary List</a></li>
								<li class="active"><a href="Manage.aspx?receiverId=<%=hideBenificialId.Value %>&customerId=<%=hideCustomerId.Value %>">Beneficiary Setup </a></li>
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
												<div class="panel-heading">
													<h4 class="panel-title">Beneficiary Setup:
												<label id="txtCustomerName" runat="server"></label>
														(<label><%=hideMembershipId.Value %></label>) </h4>
												</div>
												<div class="panel-body row">
													<div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
														<asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
													</div>
													<p class="col-md-12"><b>Receiver Details</b></p>
													<%--body part--%>
													<asp:HiddenField ID="hideCustomerId" runat="server" />
													<asp:HiddenField ID="hideBenificialId" runat="server" />
													<asp:HiddenField ID="hideMembershipId" runat="server" />
													<div class="col-md-4">
														<div class="form-group">
															<label>Country:<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlCountry" CssClass="form-control required" runat="server">
																<asp:ListItem Text="Select.."></asp:ListItem>
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Beneficiary Type:<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlBenificiaryType" CssClass="form-control" disabled="disabled" runat="server">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Email:</label>
															<asp:TextBox ID="txtEmail" TextMode="Email" runat="server" CssClass="form-control"></asp:TextBox>
															<asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
																ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
																ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
																ControlToValidate="txtEmail"></asp:RegularExpressionValidator>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>First Name:<span class="errormsg">*</span></label>
															<asp:TextBox runat="server" ID="txtReceiverFName" CssClass="form-control required" placeholder="Receiver First Name"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Mid Name:</label>
															<asp:TextBox runat="server" ID="txtReceiverMName" CssClass="form-control" placeholder="Receiver Mid Name"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Last Name:<span class="errormsg">*</span></label>
															<asp:TextBox runat="server" ID="txtReceiverLName" CssClass="form-control required" placeholder="Receiver Last Name"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Native Country :<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlNativeCountry" CssClass="form-control required" runat="server">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Receiver Address:<span class="errormsg">*</span></label>
															<asp:TextBox runat="server" ID="txtReceiverAddress" CssClass="form-control required" placeholder="Receiver Address"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Receiver City:<span class="errormsg">*</span></label>
															<asp:TextBox runat="server" ID="txtReceiverCity" CssClass="form-control required" placeholder="Receiver City"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Contact No:</label>
															<asp:TextBox runat="server" ID="txtContactNo" CssClass="form-control" placeholder="Receiver Contact No" MaxLength="13"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group" style="overflow: initial;">
															<label>Mobile No.: <span class="errormsg">*</span></label><br />
															<asp:TextBox runat="server" MaxLength="16" ID="txtSenderMobileNo" placeholder="Mobile No" CssClass="form-control required" />
														</div>
													</div>

													<div class="col-md-4">
														<div class="form-group">
															<label>Place of Issue:</label>
															<asp:TextBox runat="server" ID="txtPlaceOfIssue" CssClass="form-control" placeholder="Place Of Issue"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Id Type:</label>
															<asp:DropDownList ID="ddlIdType" CssClass="form-control" runat="server">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<label>Id Value:</label>
														<div class="form-group">
															<asp:TextBox runat="server" ID="txtIdValue" CssClass="form-control" placeholder="Any Photo Id"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Relationship To Beneficiary:<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlRelationship" onChange="showTextBox()" CssClass="form-control required" runat="server">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group" id="otherRelationDiv" runat="server">
															<label>Description of other relationship:</label>
															<asp:TextBox runat="server" ID="otherRelationshipTextBox" CssClass="form-control" placeholder="Other Relation Description"></asp:TextBox>
														</div>
													</div>

													<div class="clearfix"></div>
													<p class="col-md-12">
														<label class="">Transaction Information</label>
													</p>
													<div class="col-md-4">
														<div class="form-group">
															<label>Purpose of Remitance:<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlPurposeOfRemitance" runat="server" CssClass="form-control required">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Payment Mode:<span class="errormsg">*</span></label>
															<asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control required" onchange="PopulatePayoutPartner()">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4">
														<div class="form-group">
															<label>Payout Partner/Bank:</label>
															<asp:DropDownList ID="ddlPayoutPatner" runat="server" CssClass="form-control">
															</asp:DropDownList>
														</div>
													</div>
													<div class="col-md-4" hidden="hidden">
														<div class="form-group">
															<label>Payout Partner/Bank:<span><i>Type if Not Found</i></span></label>
															<asp:TextBox ID="txtBankName" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4 showOnBankMethod" id="receiverAccountNo" runat="server">
														<div class="form-group">
															<label>Beneficiary A/c #:</label>
															<asp:TextBox ID="txtBenificaryAc" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
														</div>
													</div>
													<div class="col-md-4" style="display: none">
														<div class="form-group">
															<label>Location:(used for webAgent)</label>
															<asp:TextBox ID="txtBankLocation" runat="server" CssClass="form-control">
															</asp:TextBox>
														</div>
													</div>
													<div class="col-md-12">
														<div class="form-group">
															<label>Remarks:</label>
															<asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control"></asp:TextBox>
														</div>
													</div>
													<div class="col-sm-12" runat="server">
														<div class="form-group">
															<asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" />
														</div>
													</div>
													<%--End body part--%>
												</div>
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
</html>