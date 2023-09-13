<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.customerSetup.Manage" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Customer Operation</title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <script src="../../../js/jQuery/jquery.min.js"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/functions.js"> </script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script>

        $(document).ready(function () {

            CalTillToday("#<%=txtDateOfIncorporation.ClientID%>");
            CalTillToday("#<%=IssueDate.ClientID%>");
            CalTillToday("#<%=dob.ClientID%>");
			AllowFutureDate("#<%=ExpireDate.ClientID%>");
			$('.date-field').mask('0000-00-00');

            //$(".date-field").attr("readonly", "readonly");
            ShowCalDefault(".date-field");

            $("#<% =VerificationDoc1.ClientID %>").change(function () {
                readURL(this, "verfDoc1");
            });

            $("#<% =VerificationDoc2.ClientID%>").change(function () {
                readURL(this, "verfDoc2");
            });
            $("#<% =VerificationDoc3.ClientID%>").change(function () {
                readURL(this, "verfDoc3");
            });
            $("#<% =VerificationDoc4.ClientID%>").change(function () {
                readURL(this, "verfDoc4");
            });
            ChangeOrganisationType();
        });
        function ChangeOrganisationType() {
            var customerType = $("#<% =ddlCustomerType.ClientID%>").val();
            var clearInputFields = [];

            if (customerType === '4701') {
                $('.usedForOrganisation').show();
                $('.hideForOrganisation').hide();
                clearInputFields = ['.clearOnOrganisation'];
            } else {
                $('.usedForOrganisation').hide();
                $('.hideForOrganisation').show();
                clearInputFields = ['.clearOnIndividual'];
            }

            clearInputFields.forEach(function (item) {
                $(item).val('');
            });
        }
        function CheckFormValidation() {
            var reqField = "";
            var val = $("#<% =hdnCustomerId.ClientID%>").val();
            var customerType = $("#<% =ddlCustomerType.ClientID%>").val();
            if (customerType === '4701') {
                reqField = "txtCompanyName,txtRegistrationNo,txtNameofAuthoPerson,mobile,nativeCountry,countryList,city,txtStreet,ddlState,ddlBankName,accountNumber,ddlPosition,zipCode,idType,verificationTypeNo,";
            } else {
                if (val !== "") {
                    reqField = "firstName,countryList,city,nativeCountry,mobile,txtStreet,ddlState,genderList,ddlVisaStatus,ddlEmployeeBusType,verificationTypeNo,zipCode,idType,verificationTypeNo,";
                } else {
                    reqField = "firstName,countryList,city,nativeCountry,mobile,txtStreet,ddlState,genderList,ddlVisaStatus,ddlEmployeeBusType,verificationTypeNo,zipCode,idType,verificationTypeNo,";
                }

            }
            ChangeOrganisationType();
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }

        function loadImage(filePath, id) {
            $('#' + id).attr('src', path);
        }

        function readURL(input, id) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#' + id).attr('src', e.target.result);
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };
        function ManageDivs() {
            if ($('#idType').val() == '8008') {
                $('#expiryDiv').hide();
            }
            else {
                $('#expiryDiv').show();
            }
        }
        function CheckCustomerId() {
            customerId = $("#<%=hdnCustomerId.ClientID%>").val();
            if (customerId !== null && customerId !== "") {
                return true;
            }
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Online Agent</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer Setup</a></li>
                            <li class="active"><a href="Manage.aspx?customerId=<%=hdnCustomerId.Value %>">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Customer List</a></li>
                        <li role="presentation" class="active"><a href="javascript:void(0);">Customer Operation</a></li>
                    </ul>
                </div>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default">
                                    </div>
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Customer Information</div>
                                        <div class="panel-body row">
                                            <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Customer Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="ddlCustomerType" onchange="ChangeOrganisationType(this)" name="customerList" CssClass="form-control clearOnIndividual">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>

                                            <div class="col-sm-4" id="membershipDiv" runat="server" visible="false">
                                                <div class="form-group">
                                                    <label>Membership No:</label>
                                                    <asp:TextBox ID="txtMembershipId" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>

                                            <div class="col-sm-4" hidden>
                                                <div class="form-group">
                                                    <label>Confirm E-Mail ID:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="emailConfirm" runat="server" placeholder="Confirm Email" data-match="#email" CssClass="form-control clearOnIndividual" />
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="emailConfirm"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Personal Information</div>
                                        <div class="panel-body row">
                                            <div class="usedForOrganisation col-md-12" hidden>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Name of Company:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="txtCompanyName" runat="server" placeholder="Name of Company" CssClass="form-control clearOnIndividual" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Company Reg. No:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="txtRegistrationNo" runat="server" placeholder="Company Reg. No" CssClass="form-control clearOnIndividual" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Organization Type:<%--<span class="errormsg">*</span>--%></label>
                                                        <asp:DropDownList runat="server" ID="ddlOrganizationType" name="ddlOrganizationType" CssClass="form-control clearOnIndividual">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div id="Div1" runat="server" nowrap="nowrap" class="showHideIDExpDate" >
                                                    </div>
                                                    <div class="form-group">
                                                        <label>Date Of Incorporation: <%--<span class="errormsg">*</span>--%></label>
                                                        <div class="form-inline">
                                                            <div class="input-group input-append date dpYears">
                                                                <asp:TextBox runat="server" ID="txtDateOfIncorporation"   placeholder="MM/DD/YYYY" CssClass="form-control date-field clearOnIndividual"></asp:TextBox>
                                                                <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="txtDateOfIncorporation"
                                                                    Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                                                    ErrorTooltipEnabled="True" />
                                                                <asp:RangeValidator ID="RangeValidator3" runat="server"
                                                                    ControlToValidate="dob"
                                                                    MaximumValue="12/31/2100"
                                                                    MinimumValue="01/01/1900"
                                                                    Type="Date"
                                                                    ForeColor="Red"
                                                                    ErrorMessage="Invalid date!"
                                                                    ValidationGroup="customer"
                                                                    CssClass="inv"
                                                                    SetFocusOnError="true"
                                                                    Display="Dynamic"> </asp:RangeValidator>
                                                                <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Nature Of Company:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="ddlnatureOfCompany" name="ddlnatureOfCompany" CssClass="form-control clearOnIndividual">
                                                            <asp:ListItem Text="Sole Proprietor" Value="Sole Proprietor"></asp:ListItem>
                                                            <asp:ListItem Text="Partnership" Value="Partnership"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Bank Name :<span class="errormsg">*</span></label>
                                                    </div>
                                                    <div class="form-group">
                                                        <asp:DropDownList ID="ddlBankName" runat="server" CssClass="form-control clearOnIndividual">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Account Number:<span class="errormsg">*</span></label>
                                                    </div>
                                                    <div class="form-group">
                                                        <asp:TextBox ID="accountNumber" runat="server" CssClass="form-control clearOnIndividual"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Name Of Authorized Person:<span class="errormsg">*</span></label>
                                                    </div>
                                                    <div class="form-group">
                                                        <asp:TextBox ID="txtNameofAuthoPerson" runat="server" CssClass="form-control clearOnIndividual"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Position:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="ddlPosition" name="ddlnatureOfCompany" CssClass="form-control clearOnIndividual">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="hideForOrganisation">
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>First Name:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="firstName" runat="server" placeholder="First Name" CssClass="form-control clearOnOrganisation" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Middle Name:</label>
                                                        <asp:TextBox ID="middleName" runat="server" placeholder="Middle Name" CssClass="form-control clearOnOrganisation" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>Last Name:</label>
                                                        <asp:TextBox ID="lastName" runat="server" placeholder="Last Name" CssClass="form-control clearOnOrganisation" />
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Country:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="countryList" name="countryList" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Zip Code:<span class="errormsg">*</span> </label>
                                                    <asp:TextBox ID="zipCode" runat="server" placeholder="Zip Code" CssClass="form-control" AutoPostBack="True" OnTextChanged="zipCode_TextChanged" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>State:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="ddlState" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Street:<span class="errormsg">*</span> </label>
                                                    <asp:TextBox ID="txtStreet" runat="server" placeholder="Street" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>City:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="city" runat="server" placeholder="City" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Sender City-Japan:</label>
                                                    <asp:TextBox ID="txtsenderCityjapan" runat="server" placeholder="Sender City Japan" CssClass="form-control clearOnOrganisation" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Street[Japanese]:</label>
                                                    <asp:TextBox ID="txtstreetJapanese" runat="server" placeholder="City" CssClass="form-control clearOnOrganisation" />
                                                </div>
                                            </div>

                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Gender:<span class="errormsg">*</span> </label>
                                                    <asp:DropDownList runat="server" ID="genderList" name="genderList" CssClass="form-control clearOnOrganisation">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Native Country:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="nativeCountry" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div id="tdSenExpDateTxt" runat="server" nowrap="nowrap" class="showHideIDExpDate">
                                                </div>
                                                <div class="form-group">
                                                    <label>Date of Birth:</label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date dpYears">
                                                            <asp:TextBox runat="server" ID="dob" placeholder="MM/DD/YYYY" CssClass="form-control date-field clearOnOrganisation"></asp:TextBox>
                                                            <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="dob"
                                                                Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                                                ErrorTooltipEnabled="True" />
                                                            <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                                ControlToValidate="dob"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ForeColor="Red"
                                                                ErrorMessage="Invalid date!"
                                                                ValidationGroup="customer"
                                                                CssClass="inv"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>E-Mail ID:</label>
                                                    <asp:TextBox ID="email" runat="server" placeholder="Email" CssClass="form-control" />
                                                    <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="email"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                            <div class="col-sm-4" hidden>
                                                <div class="form-group">
                                                    <label>Address:</label>
                                                    <asp:TextBox ID="addressLine1" runat="server" placeholder="Address" CssClass="form-control" />
                                                </div>
                                            </div>

                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Telephone No.:</label>
                                                    <asp:TextBox ID="phoneNumber" runat="server" placeholder="Phone Number" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Mobile No.: <span class="errormsg">*</span></label>
                                                    <asp:TextBox runat="server" MaxLength="15" ID="mobile" placeholder="Mobile No" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Mobile Number');" />
                                                </div>
                                            </div>

                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Visa Status<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="ddlVisaStatus" name="genderList" CssClass="form-control clearOnOrganisation">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Employement Business Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="ddlEmployeeBusType" name="genderList" CssClass="form-control clearOnOrganisation">
                                                        <%-- <asp:ListItem Text="Select.." Value="0"></asp:ListItem>
                                                        <asp:ListItem Text="Emplyeed" Value="Emplyeed"></asp:ListItem>
                                                        <asp:ListItem Text="Self-Employee" Value="Self-Employee"></asp:ListItem>
                                                        <asp:ListItem Text="Unemployee" Value="Unemployee"></asp:ListItem>--%>
                                                    </asp:DropDownList>
                                                    <%-- <asp:RadioButtonList ID="empBusinessType" runat="server"
                                                        RepeatDirection="Horizontal" RepeatLayout="Table">
                                                        <asp:ListItem Text="Employee" Value="Employee" />
                                                        <asp:ListItem Text="Self-Employee" Value="Self-Employee" />
                                                        <asp:ListItem Text="Unemployee" Value="Unemployee" />
                                                    </asp:RadioButtonList>--%>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Name of Employeer:</label>
                                                    <asp:TextBox runat="server" ID="txtNameofEmployeer" placeholder="Name Of Employeer" CssClass="form-control clearOnOrganisation" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>SSN No:</label>
                                                    <asp:TextBox runat="server" ID="txtSSnNo" placeholder="SSN No" CssClass="form-control clearOnOrganisation" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Occupation:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="occupation" CssClass="form-control clearOnOrganisation"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Source of Fund:</label>
                                                    <asp:DropDownList runat="server" ID="ddSourceOfFound" CssClass="form-control clearOnOrganisation"></asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Security Information</div>
                                        <div class="panel-body row">
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Verification Id Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="idType" CssClass="form-control" onchange="ManageDivs();"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label id="verificationType">Verification Type No.:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="verificationTypeNo" runat="server" placeholder="Verification Type Number" MaxLength="14" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Issue Date:<%--<span class="errormsg">*</span>--%></label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date">
                                                            <asp:TextBox runat="server" ID="IssueDate" placeholder="MM/DD/YYYY" CssClass="form-control date-field"></asp:TextBox>
                                                            <cc1:MaskedEditExtender ID="MaskedEditExtender4" runat="server" TargetControlID="IssueDate"
                                                                Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                                                ErrorTooltipEnabled="True" />
                                                            <asp:RangeValidator ID="RangeValidator4" runat="server"
                                                                ControlToValidate="dob"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ForeColor="Red"
                                                                ErrorMessage="Invalid date!"
                                                                ValidationGroup="customer"
                                                                CssClass="inv"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4" id="expiryDiv" runat="server">
                                                <div class="form-group">
                                                    <label>Valid Date:<%--<span class="errormsg">*</span>--%></label>
                                                    <div class="form-group">
                                                        <div class="input-group input-append date">
                                                            <asp:TextBox runat="server" ID="ExpireDate" placeholder="MM/DD/YYYY" CssClass="form-control date-field"></asp:TextBox>
                                                            <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="ExpireDate"
                                                                Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                                                ErrorTooltipEnabled="True" />
                                                            <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                                ControlToValidate="dob"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ForeColor="Red"
                                                                ErrorMessage="Invalid date!"
                                                                ValidationGroup="customer"
                                                                CssClass="inv"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Remitance Allowed:<span class="errormsg">*</span></label>
                                                    <asp:RadioButtonList ID="rbRemitanceAllowed" runat="server" CssClass="clearOnOrganisation"
                                                        RepeatDirection="Horizontal" RepeatLayout="Table">
                                                        <asp:ListItem Text="Enabled" Value="Enabled" Selected="True" />
                                                        <asp:ListItem Text="Disabled" Value="Disabled" />
                                                    </asp:RadioButtonList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Online Login Allowed:<span class="errormsg">*</span></label>
                                                    <asp:RadioButtonList ID="rbOnlineLogin" runat="server" CssClass="clearOnOrganisation"
                                                        RepeatDirection="Horizontal">
                                                        <asp:ListItem Text="Enabled" Value="Enabled" Selected="True" />
                                                        <asp:ListItem Text="Disabled" Value="Disabled" />
                                                    </asp:RadioButtonList>
                                                </div>
                                            </div>
                                            <div class="row"></div>
                                            <div class="col-sm-12 hideForOrganisation">
                                                <div class="form-group">
                                                    <label>Remarks:</label>
                                                    <asp:TextBox runat="server" ID="txtRemarks" TextMode="MultiLine" placeholder="Remarks" CssClass="form-control clearOnOrganisation" />
                                                </div>
                                            </div>

                                            <div class="col-sm-12" runat="server">
                                                <div class="form-group">
                                                    <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="register_Click" />
                                                </div>
                                            </div>
                                            <div id="showOnEdit" runat="server">
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <label>National/Alien Reg ID Front:<%--<span class="errormsg">*</span>--%></label>
                                                        <asp:FileUpload ID="VerificationDoc1" runat="server" CssClass="form-control" />
                                                        <asp:Image runat="server" ID="verfDoc1" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <%--<label>Visa Page:</label>--%>
                                                        <label>National/Alien Reg ID Back:</label>
                                                        <asp:FileUpload ID="VerificationDoc2" runat="server" CssClass="form-control" />
                                                        <asp:Image runat="server" ID="verfDoc2" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <%--<label>Passport:</label>--%>
                                                        <label>Passport (if available):</label>
                                                        <asp:FileUpload ID="VerificationDoc3" runat="server" CssClass="form-control" />
                                                        <asp:Image runat="server" ID="verfDoc3" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <%--<label>Passport:</label>--%>
                                                        <label>Passport (if available):</label>
                                                        <asp:FileUpload ID="VerificationDoc4" runat="server" CssClass="form-control" />
                                                        <asp:Image runat="server" ID="verfDoc4" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-12" runat="server">
                                                <div class="form-group">
                                                    <asp:Button ID="btnFileUpload" runat="server" CssClass="btn btn-primary m-t-25" Text="File Upload" OnClientClick="return CheckCustomerId()" OnClick="btnFileUpload_Click"/>
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
        </div>

        <asp:HiddenField runat="server" ID="hdnVerifyDoc1" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc2" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc4" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc3" />
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hddIdNumber" />
        <asp:HiddenField runat="server" ID="hdnMembershipNo" />
        <asp:HiddenField runat="server" ID="hddOldEmailValue" />
        <asp:HiddenField runat="server" ID="hddTxnsMade" />
    </form>
</body>
</html>
