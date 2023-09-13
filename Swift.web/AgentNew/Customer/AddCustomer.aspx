<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="AddCustomer.aspx.cs" Inherits="Swift.web.AgentNew.Customer.AddCustomer" %>

<%--it uses wizard.js--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../css/signature-pad.css" rel="stylesheet" />
    <script>
        $(document).ready(function () {
            $('#<%=reg_front_id.ClientID%>').on('change', function (e) {
                $('.loadImg').remove();
                for (var i = 0; i < e.target.files.length; i++) {
                    var tmppath = URL.createObjectURL(e.target.files[i]);
                    $(this).after('<span class="loadImg"><img src="' + tmppath + '" alt=""></span>');
                    $(".loadImg img").fadeIn("fast");
                }
            });

            // Image upload for back id
            $('#<%=reg_back_id.ClientID%>').on('change', function (e) {
                $('.loadImg1').remove();
                for (var i = 0; i < e.target.files.length; i++) {
                    var tmppath = URL.createObjectURL(e.target.files[i]);
                    $(this).after('<span class="loadImg1"><img src="' + tmppath + '" alt=""></span>');
                    $(".loadImg1 img").fadeIn("fast");
                }
            });

            // mobile country code added
            $("#<%=mobile.ClientID%>").intlTelInput({
                nationalMode: true,
                onlyCountries: ["jp"],
                utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/utils.js" // just for formatting/placeholders etc
            });

            $("#<%=mobile.ClientID%>").on("change", function () {
                var input = $("#<%=mobile.ClientID%>");
                var countryCode = $('.dial-code').text();
                var maxLength = input.attr('maxLength');
                if ((input.val() + countryCode).length > maxLength) {
                    alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                    return $(this).val('');
                }
                var intlNumber = input.intlTelInput("getNumber", intlTelInputUtils.numberFormat.E164);
                if (CheckForMobileNumber(this, 'Mobile No.')) {
                    $(this).val(intlNumber);
                }
            });

            $('#<%=countryList.ClientID%>').on('change', function () {
                $("#<%=mobile.ClientID%>").val('');
                var country = $("#<%=countryList.ClientID%> option:selected").text();
                if (country.toLowerCase() == 'japan') {
                    $("#<%=mobile.ClientID%>").intlTelInput('setCountry', 'jp');
                }
                if (country.toLowerCase() == 'costa rica') {
                    $("#<%=mobile.ClientID%>").intlTelInput('setCountry', 'cr');
                }
            });

            $('#agreement').click(function () {
                if ($(this).is(':checked')) {
                    $('#<%=register.ClientID%>').removeAttr('disabled');

                } else {
                    $('#<%=register.ClientID%>').attr('disabled', 'disabled');
                }
            });

            $('#btnIAgree').on("click", function () {
                $('input[name=agreement]').prop("checked", true);
                $('#<%=register.ClientID%>').removeAttr('disabled');
            });

            $('#<% =txtDateOfIncorporation.ClientID%>').mask('0000-00-00');
            $('#<% =IssueDate.ClientID%>').mask('0000-00-00');
            $('#<% =dob.ClientID%>').mask('0000-00-00');
            $('#<% =ExpireDate.ClientID%>').mask('0000-00-00');
            CompanyRegisterDate("#<%=txtDateOfIncorporation.ClientID%>");
            CalIDIssueDate("#<%=IssueDate.ClientID%>");
            CalSenderDOB("#<%=dob.ClientID%>");
            CalFromToday("#<%=ExpireDate.ClientID%>");
            ChangeOrganisationType();
        });

        function CheckForMobileNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,16}$/;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid !');
                nField.value = '';
                return false
            }
            return true;
        }

        function CheckForPhoneNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,15}$/;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid !');
                nField.value = '';
                return false
            }
            return true;
        }

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

        function GetAddressByZipCode() {
            var zipCodeValue = $("#<%=zipCode.ClientID%>").val();
            $("#txtState").val('');
            $("#<%=txtStreet.ClientID%>").val('');
            $("#<%=city.ClientID%>").val('');
            $("#<%=txtsenderCityjapan.ClientID%>").val('');
            $("#<%=txtstreetJapanese.ClientID%>").val('');
            var zipCodePattern = /^\d{7}?$/;
            test = zipCodePattern.test(zipCodeValue);
            if (!test) {
                $("#<%=zipCode.ClientID%>").val('');
                $("#<%=zipCode.ClientID%>").focus();
                $("#<%=zipCode.ClientID%>").attr("style", "display:block; background:#FFCCD2");
                return alert("Please Enter Valid Zip Code(XXXXXXX)");
            }
            var dataToSend = { MethodName: 'GetAddressDetailsByZipCode', zipCode: zipCodeValue };
            $.post('/AgentNew/Customer/AddCustomer.aspx', dataToSend, function (erd) {
                if (erd !== null) {
                    if (erd == false) {
                        $("#<%=zipCode.ClientID%>").val('');
                        $("#<%=zipCode.ClientID%>").focus();
                        $("#<%=zipCode.ClientID%>").attr("style", "display:block; background:#FFCCD2");
                        return alert("Please Enter Valid Zip Code(XXXXXXX)");
                    }
                    $("#<%=zipCode.ClientID%>").removeAttr("style");
                    $("#tempAddress").html(erd);
                    var rows = document.getElementById("info").rows;
                    var stateData = rows[4].cells;
                    var streetData = rows[3].cells;
                    var cityData = rows[2].cells;
                    var stateName = stateData[0].innerText.split('-')[0];
                    var selectedValue = "";
                    $("#<%=ddlState.ClientID%> option").each(function () {
                        if (stateName.trim().toUpperCase().includes($(this).text())) {
                            selectedValue = $(this).val();
                            return;
                        }
                    });
                    $('#<%=ddlState.ClientID%>').val(selectedValue);
                    $("#<%=city.ClientID%>").val(cityData[0].innerText.trim());
                    $("#<%=txtsenderCityjapan.ClientID%>").val(cityData[1].innerText.trim());
                    $("#<%=txtStreet.ClientID%>").val(streetData[0].innerText);
                    $("#<%=txtstreetJapanese.ClientID%>").val(streetData[1].innerText);

                }
            }).fail(function () {
                alert('Oops!!! something went wrong, please try again.');
            });
        }

        function ManageDivs() {
            if ($('#<%=idType.ClientID%>').val() == '8008') {
                $('#<%=expiryDiv.ClientID%>').hide();
                $('#<%=ExpireDate.ClientID%>').removeClass("required");
            }
            else {
                $('#<%=ExpireDate.ClientID%>').addClass("required");
                $('#<%=expiryDiv.ClientID%>').show();
            }
            $("#<%=ExpireDate.ClientID%>").val('');
            IdTypeValidity();
        }

        function IdTypeValidity() {
            var senIdType = $("#<%=idType.ClientID%>").val();
            if (senIdType == "") {
                $("#<%=expiryDiv.ClientID%>").show();
            }
            else {
                var senIdTypeArr = senIdType.split('|');
                if (senIdTypeArr[2] == "E") {
                    $("#<%=expiryDiv.ClientID%>").removeClass("hidden");
                    $("#expireRequired").show();
                    $("#<%=ExpireDate.ClientID%>").addClass("required");
                }
                else {
                    $("#<%=expiryDiv.ClientID%>").addClass("hidden");
                    $("#<%=ExpireDate.ClientID%>").removeClass("required");
                }
            }
        }

        function previousClick() {
            $('#<%=ddlCustomerType.ClientID%>').attr("disabled", false);
        }
    </script>
    <style>
        .wizard .nav-tabs > li {
            width: 33%;
        }

        .wizard li.active.complete span.round-tab {
            background: #fff;
            border: 2px solid #2ea006;
        }

            .wizard li.active.complete span.round-tab i {
                color: #2ea006;
            }

        table#ContentPlaceHolder1_rbRemitanceAllowed tbody tr td {
            padding-left: 10px;
        }

        table#ContentPlaceHolder1_rbOnlineLogin tbody tr td {
            padding-left: 10px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Hidden Fields ---->
    <asp:HiddenField ID="isDisplaySignature" runat="server" />
    <asp:HiddenField ID="hddImgURL" runat="server" />
    <div id="tempAddress" hidden></div>
    <button type="button" id="hdnSave" class="next-step" hidden></button>
    <asp:HiddenField runat="server" ID="hdnCustomerId" />
    <asp:HiddenField runat="server" ID="hdnCustomerType" />
    <!-- Hidden Fields End---->

    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <asp:HiddenField ID="hideCustomerId" runat="server" />
                    <ol class="breadcrumb">
                        <li><a href="/AgentNew/Dashboard.aspx"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Online Agent</a></li>
                        <li><a href="#">Customer Registration</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <section>
            <div class="wizard" id="jme_wizard">
                <div class="wizard-inner">
                    <div class="connecting-line"></div>
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active">
                            <a href="#step1" data-toggle="tab" aria-controls="step1" onclick="ClickFirstTab()" role="tab" title="Personal Information">
                                <span class="round-tab">
                                    <i class="fa fa-user" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>

                        <li role="presentation" class="disabled" id="tab2">
                            <a href="#step2" data-toggle="tab" aria-controls="step2" role="tab" title="Security Information">
                                <span class="round-tab">
                                    <i class="fa fa-shield" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>

                        <li role="presentation" class="disabled complete" id="tab3">
                            <a href="#complete" data-toggle="tab" aria-controls="complete" role="tab" title="Complete">
                                <span class="round-tab">
                                    <i class="fa fa-check" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>
                    </ul>
                </div>
                <div style="margin: 10px 0;">
                    <div class="row">
                        <div class="col-sm-4 form-group">
                            <label>Customer Type:<span class="errormsg">*</span></label>
                            <asp:DropDownList runat="server" ID="ddlCustomerType" onchange="ChangeOrganisationType(this)" name="customerList" CssClass="form-control">
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="tab-content">
                    <div class="tab-pane active" role="tabpanel" id="step1">
                        <div class="panel panel-default">
                            <div class="panel-heading">Basic Information</div>
                            <div class="panel-body">
                                <div class="usedForOrganisation">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <label>Name of Company:<span class="errormsg">*</span></label>
                                            <asp:TextBox ID="txtCompanyName" runat="server" placeholder="Name of Company" CssClass="form-control clearOnIndividual required" />
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <label>Company Reg. No:<span class="errormsg">*</span></label>
                                            <asp:TextBox ID="txtRegistrationNo" runat="server" placeholder="Company Reg. No" CssClass="form-control clearOnIndividual required" />
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <label>Organization Type:<%--<span class="errormsg">*</span>--%></label>
                                            <asp:DropDownList runat="server" ID="ddlOrganizationType" name="ddlOrganizationType" CssClass="form-control clearOnIndividual">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div id="Div1" runat="server" nowrap="nowrap" class="showHideIDExpDate">
                                        </div>
                                        <div class="form-group">
                                            <label>Date Of Incorporation: <%--<span class="errormsg">*</span>--%></label>
                                            <div class="form-inline">
                                                <div class="input-group input-append date dpYears">
                                                    <asp:TextBox runat="server" ID="txtDateOfIncorporation" AutoComplete="off" placeholder="YYYY/MM/DD" onchange="return DateValidation('txtDateOfIncorporation')" MaxLength="10" CssClass="form-control date-field clearOnIndividual"></asp:TextBox>
                                                    <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label>Nature Of Company:<span class="errormsg">*</span></label>
                                            <asp:DropDownList runat="server" ID="ddlnatureOfCompany" name="ddlnatureOfCompany" CssClass="form-control clearOnIndividual required">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label>Name Of Authorized Person:<span class="errormsg">*</span></label>
                                            <asp:TextBox ID="txtNameofAuthoPerson" runat="server" CssClass="form-control clearOnIndividual required"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label>Position:<span class="errormsg">*</span></label>
                                            <asp:DropDownList runat="server" ID="ddlPosition" name="ddlnatureOfCompany" CssClass="form-control clearOnIndividual required">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="hideForOrganisation">
                                    <div class="col-md-4  col-sm-4">
                                        <div class="form-group">
                                            <label>First Name:<span class="errormsg">*</span></label>
                                            <asp:TextBox ID="firstName" runat="server" placeholder="First Name" CssClass="form-control clearOnOrganisation required" />
                                        </div>
                                    </div>
                                    <div class="col-md-4  col-sm-4">
                                        <div class="form-group">
                                            <label>Middle Name:</label>
                                            <asp:TextBox ID="middleName" runat="server" placeholder="Middle Name" CssClass="form-control clearOnOrganisation" />
                                        </div>
                                    </div>
                                    <div class="col-md-4  col-sm-4">
                                        <div class="form-group">
                                            <label>Last Name:</label>
                                            <asp:TextBox ID="lastName" runat="server" placeholder="Last Name" CssClass="form-control clearOnOrganisation" />
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Country:<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="countryList" name="countryList" CssClass="form-control required">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Zip Code:<span class="errormsg">*</span> </label>
                                        <asp:TextBox ID="zipCode" runat="server" placeholder="XXXXXXX" MaxLength="7" CssClass="form-control required" onchange="return GetAddressByZipCode();" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>State:<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="ddlState" CssClass="form-control required">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Street:<span class="errormsg">*</span> </label>
                                        <asp:TextBox ID="txtStreet" runat="server" placeholder="Street" CssClass="form-control required" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Street[Japanese]:</label>
                                        <asp:TextBox ID="txtstreetJapanese" runat="server" placeholder="Street[Japanese]" CssClass="form-control" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>City:<span class="errormsg">*</span></label>
                                        <asp:TextBox ID="city" runat="server" placeholder="City" CssClass="form-control required" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Sender City-Japan:</label>
                                        <asp:TextBox ID="txtsenderCityjapan" runat="server" placeholder="Sender City Japan" CssClass="form-control" />
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Gender:<span class="errormsg">*</span> </label>
                                        <asp:DropDownList runat="server" ID="genderList" name="genderList" CssClass="form-control clearOnOrganisation required">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Native Country:<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="nativeCountry" CssClass="form-control required"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div id="tdSenExpDateTxt" runat="server" nowrap="nowrap" class="showHideIDExpDate">
                                    </div>
                                    <div class="form-group">
                                        <label>Date of Birth:<span class="errormsg">*</span></label>
                                        <div class="form-inline">
                                            <div class="input-group input-append date dpYears">

                                                <asp:TextBox runat="server" ID="dob" placeholder="YYYY/MM/DD" onchange="return DateValidation('dob','dob')" MaxLength="10" AutoComplete="off" CssClass="form-control clearOnOrganisation required"></asp:TextBox>
                                                <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>E-Mail ID:</label>
                                        <asp:TextBox ID="email" runat="server" placeholder="Email" CssClass="form-control" />
                                        <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                            ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                            ControlToValidate="email"></asp:RegularExpressionValidator>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4" hidden>
                                    <div class="form-group">
                                        <label>Address:</label>
                                        <asp:TextBox ID="addressLine1" runat="server" placeholder="Address" CssClass="form-control" />
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Telephone No.:</label>
                                        <asp:TextBox ID="phoneNumber" runat="server" placeholder="Phone Number" MaxLength="15" CssClass="form-control" onchange="CheckForPhoneNumber(this, 'Phone No.');" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group" style="overflow: initial;">
                                        <label>Mobile No.: <span class="errormsg">*</span></label><br />
                                        <asp:TextBox runat="server" MaxLength="16" ID="mobile" placeholder="Mobile No" CssClass="form-control required" />
                                    </div>
                                </div>

                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Visa Status<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="ddlVisaStatus" name="ddlVisaStatus" CssClass="form-control clearOnOrganisation required">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Employment Business Type:</label>
                                        <asp:DropDownList runat="server" ID="ddlEmployeeBusType" name="genderList" CssClass="form-control clearOnOrganisation">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Name of Employer:</label>
                                        <asp:TextBox runat="server" ID="txtNameofEmployeer" placeholder="Name Of Employer" CssClass="form-control clearOnOrganisation" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>SSN No:</label>
                                        <asp:TextBox runat="server" ID="txtSSnNo" placeholder="SSN No" CssClass="form-control clearOnOrganisation" />
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Occupation:<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="occupation" CssClass="form-control clearOnOrganisation required"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4">
                                    <div class="form-group">
                                        <label>Source of Fund:<span class="errormsg">*</span></label>
                                        <asp:DropDownList runat="server" ID="ddSourceOfFound" CssClass="form-control required"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-4 col-sm-4 hideForOrganisation">
                                    <div class="form-group">
                                        <label>Monthly Income:</label>
                                        <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control clearOnOrganisation">
                                            <asp:ListItem>Select</asp:ListItem>
                                            <asp:ListItem>JPY0 - JPY1,700,000</asp:ListItem>
                                            <asp:ListItem>JPY1,700,000 - JPY3,400,000</asp:ListItem>
                                            <asp:ListItem>JPY3,400,000 - JPY6,800,000</asp:ListItem>
                                            <asp:ListItem>JPY6,800,000 - JPY13,000,000</asp:ListItem>
                                            <asp:ListItem>Above JPY13,000,000</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="btnStep1" class="btn btn-primary next-step">Save and continue</button>
                            </li>
                        </ul>
                    </div>

                    <div class="tab-pane" role="tabpanel" id="step2">
                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-heading">
                                Security Information
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label>Verification Id Type:<span class="errormsg">*</span></label>
                                            <asp:DropDownList runat="server" ID="idType" CssClass="form-control required" onchange="ManageDivs();"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label id="verificationType">Verification Type No.:<span class="errormsg">*</span></label>
                                            <div class="input-group input-append date dpYears">
                                                <asp:TextBox ID="verificationTypeNo" runat="server" placeholder="Verification Type Number" MaxLength="14" CssClass="form-control required" />
                                                <div class="input-group-addon" onclick="ShowIdTypeInfo();"><i class="fa fa-info"></i></div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4">
                                        <div class="form-group">
                                            <label>Issue Date:<span class="errormsg">*</span></label>
                                            <div class="form-inline">
                                                <div class="input-group input-append date">

                                                    <asp:TextBox runat="server" ID="IssueDate" onchange="return DateValidation('IssueDate','i')" MaxLength="10" AutoComplete="off" placeholder="YYYY/MM/DD" CssClass="form-control date-field required"></asp:TextBox>
                                                    <div class="input-group-addon "><i class="fa fa-calendar"></i></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-4 col-sm-4" id="expiryDiv" runat="server">
                                        <div class="form-group">
                                            <label>Valid Date:<span class="errormsg" id="expireRequired">*</span></label>
                                            <div class="form-inline">
                                                <div class="input-group input-append date">
                                                    <asp:TextBox runat="server" ID="ExpireDate" onchange="return DateValidation('ExpireDate','f')" MaxLength="10" AutoComplete="off" placeholder="YYYY/MM/DD" CssClass="form-control date-field required"></asp:TextBox>
                                                    <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4 hideForOrganisation">
                                        <div class="form-group">
                                            <label>Remitance Allowed:<span class="errormsg">*</span></label>
                                            <asp:RadioButtonList ID="rbRemitanceAllowed" runat="server" CssClass="clearOnOrganisation"
                                                RepeatDirection="Horizontal" RepeatLayout="Table">
                                                <asp:ListItem Text="Enabled" Value="Enabled" Selected="True" />
                                                <asp:ListItem Text="Disabled" Value="Disabled" />
                                            </asp:RadioButtonList>
                                        </div>
                                    </div>
                                    <div class="col-md-4 col-sm-4 hideForOrganisation">
                                        <div class="form-group">
                                            <label>Online Login Allowed:<span class="errormsg">*</span></label>
                                            <asp:RadioButtonList ID="rbOnlineLogin" runat="server" CssClass="clearOnOrganisation"
                                                RepeatDirection="Horizontal">
                                                <asp:ListItem Text="Enabled" Value="Enabled" Selected="True" />
                                                <asp:ListItem Text="Disabled" Value="Disabled" />
                                            </asp:RadioButtonList>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-12 hideForOrganisation">
                                        <div class="form-group">
                                            <label>Remarks:</label>
                                            <asp:TextBox runat="server" ID="txtRemarks" TextMode="MultiLine" placeholder="Remarks" CssClass="form-control clearOnOrganisation" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" class="btn btn-default prev-step">Previous</button>
                            </li>
                            <li>
                                <button type="button" id="jmeContinueSign" class="btn btn-primary btn-info-full next-step">Save and continue</button>
                            </li>
                        </ul>
                    </div>

                    <div class="tab-pane" role="tabpanel" id="complete">

                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-heading">
                                Customer Document
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-sm-3">
                                        <div class="form-group">

                                            <label id="lblreg_front_id">
                                                <asp:Localize runat="server" meta:resourcekey="Register_040" Text="National/Alien Reg ID Front :"></asp:Localize><span class="errormsg">*</span></label>
                                            <div class="img-sample">
                                                <label>
                                                    <asp:Localize runat="server" meta:resourcekey="Register_041" Text="Sample Image"></asp:Localize></label>
                                                <div class="samp-control">
                                                    <img src="/AgentNew/Img/alien-reg-front.jpg" alt="sample image" id="idImg1" />
                                                    <div class="enlarge">
                                                        <img src="/AgentNew/Img/alien-reg-front.jpg" alt="sample image" id="idImg2" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="file-upload">
                                                <asp:FileUpload ID="reg_front_id" type="file" runat="server" class="uploadbutton" accept="image/*" meta:resourcekey="reg_front_idResource1" />
                                                <span>
                                                    <asp:Localize runat="server" meta:resourcekey="Register_042" Text="Drag and drop your file here or "></asp:Localize><span class="primary-c"><asp:Localize runat="server" meta:resourcekey="Register_043" Text="Browse"></asp:Localize></span><asp:Localize runat="server" meta:resourcekey="Register_044" Text=" for a document to upload"></asp:Localize></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-sm-3" id="divreg_back_id">
                                        <div class="form-group">
                                            <label>
                                                <asp:Localize runat="server" meta:resourcekey="Register_045" Text="National/Alien Reg ID Back :"></asp:Localize><span class="errormsg">*</span></label>
                                            <div class="img-sample">
                                                <label>
                                                    <asp:Localize runat="server" meta:resourcekey="Register_041" Text="Sample Image"></asp:Localize></label>
                                                <div class="samp-control">
                                                    <img src="/AgentNew/Img/alien-reg-back.jpg" alt="sample image" />
                                                    <div class="enlarge">
                                                        <img src="/AgentNew/Img/alien-reg-back.jpg" alt="sample image" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="file-upload">
                                                <asp:FileUpload ID="reg_back_id" type="file" runat="server" class="uploadbutton" accept="image/*" meta:resourcekey="reg_back_idResource1" />
                                                <span>
                                                    <asp:Localize runat="server" meta:resourcekey="Register_042" Text="Drag and drop your file here or "></asp:Localize><span class="primary-c"><asp:Localize runat="server" meta:resourcekey="Register_043" Text="Browse"></asp:Localize></span><asp:Localize runat="server" meta:resourcekey="Register_044" Text=" for a document to upload"></asp:Localize></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%--<div class="row">
                                    <div class="form-group">
                                        <div class="col-md-4 col-sm-4" runat="server" id="displayCounterVisit">
                                            <div class="form-group">
                                                <label class="checkbox-ui">
                                                    <input type="checkbox" runat="server" data-names="" class="custom-control-input" id="customerCounterVisit" />
                                                    <small class="custom-control-label">Counter Visit</small>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>--%>
                                <div class="row">
                                    <div class="col-sm-12">
                                        <label class="checkbox-ui">
                                            <input type="checkbox" id="agreement" name="agreement" required="required" />
                                            <small>
                                                <asp:Localize runat="server" meta:resourcekey="Register_048" Text="By submitting of this form, I hereby understand and aggree the Terms & Condition with Japan Money Express Co. Ltd."></asp:Localize><br />
                                            </small>
                                        </label>
                                        <a data-toggle="modal" data-target="#termsAndCondition">
                                            <small><span class="primary-c">
                                                <asp:Localize runat="server" meta:resourcekey="Register_049" Text="User Agreement"></asp:Localize>
                                            </span></small>
                                        </a>
                                    </div>
                                </div>
                                <div class="col-md-12" id="signatureDiv" runat="server">
                                    <div class="form-group">
                                        <label class="control-label">
                                            Customer Signature:
                                        </label>
                                        <div id="signature-pad" class="signature-pad">
                                            <div class="signature-pad--body">
                                                <canvas></canvas>
                                            </div>
                                            <div class="signature-pad--footer">
                                                <div class="description">Sign above</div>
                                                <div class="signature-pad--actions">
                                                    <div class="form-group">
                                                        <button type="button" class="btn btn-primary clear" data-action="clear">Clear</button>
                                                        &nbsp;&nbsp;&nbsp;
                                                            <button type="button" class="btn btn-primary" data-action="undo">Undo</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-sm-5">
                                            <label class="control-label">Customer Password:</label>
                                            <asp:TextBox TextMode="Password" ID="customerPassword" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <ul class="list-inline pull-right">
                                    <li>
                                        <button type="button" class="btn btn-default prev-step">Previous</button>
                                    </li>
                                    <li>
                                        <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckImageValidation();" disabled="disabled" Text="Register" OnClick="register_Click" />
                                    </li>
                                </ul>
                            </div>
                            <div class="clearfix"></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!--Terms Modal -->
        <div class="modal fade" id="termsAndCondition" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title" id="exampleModalLongTitle"><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %>  小外国送金サービス 利用規約
                        <asp:Localize runat="server" meta:resourcekey="Terms_006" Text="(User Agreement)"></asp:Localize></h3>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="tc-pp-bg">
                            <ol>
                                <li>
                                    <!------------1-------------->
                                    <b>Customer Registration</b><br>
                                    Firstly, the customer shall make an agreement with <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> either
                                                    by in person visit, post, e-mail or fax.  The applicant is required to submit the
                                                    Application for Remittance as prescribed by <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> and place the applicant's signature or
                                                    affixing the applicant's name and seal.<br>
                                    <br>
                                </li>
                                <li>
                                    <!------------2-------------->
                                    <b>Identity verification documents</b><br>
                                    <ol type="i">
                                        <li>For Japanese:   Passport, Driver's License, Insurance Card, and Residence Certificate</li>
                                        <li>For Foreigner: Passport with visa information, Valid Alien Registration Card with Photo</li>
                                        <li>Provide My Numbers<br>
                                            <br>
                                        </li>
                                    </ol>
                                </li>
                                <li>
                                    <!------------3-------------->
                                    <b>Application for Remittance </b>
                                    <br>
                                    State the purpose for remittance and any other required
                                                     information in the Application for Remittance.<br>
                                    <br>
                                    How to remit money<br>
                                    Beneficially is able to receive money either following ways.
                                                     <ol type="i">
                                                         <li>Bank Transfer</li>
                                                         <li>Cash Pick-up</li>
                                                     </ol>
                                    Foreign remittance limit amount: JPY 1,000,000 (One Million per one transaction)
                                                    <br>
                                    <br>
                                </li>

                                <li>
                                    <!------------4-------------->
                                    <b>Bank Transfer</b><br>
                                    Once <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> confirms the money received, the fund shall be transferred
                                                    to the desired bank account.  After completing the transactions, the beneficially is
                                                    able to receive money on the same day.  However it depends on business hours in both countries.
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------5-------------->
                                    <b>Cash Pick-up</b><br>
                                    Once <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> confirms the money received, <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> inform the sender of the
                                                    reference number for each transaction by telephone after completing the transactions,
                                                    beneficially is able to receive money at the desired office.  However it depends on
                                                    business hours in both countries.  When the beneficially cash pick-up, they shall show
                                                    the reference number over the office counter.
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------6-------------->
                                    <b>Exchange Rate</b><br><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> publish the exchange rate between receiving country currency and
                                                    Japanese Yen every business day in <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %>'s office counter and home page.  When receiving
                                                    the request for remittance, <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> shall apply JME’s applicable foreign exchange rate at
                                                    the time when the actual calculation is made by <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %>.  Exchange rate is updated at 10:00,
                                                    11:00 14:00, and 16:00 every business day. <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> give out a receipt to the customer (sender).
                                    </br>
                                    <br>
                                </li>
                                <li>
                                    <!------------7-------------->
                                    <b>Remittance charge</b><br>
                                    please refer to our official web page link<br>
                                    <a href="http://www.japanremit.com">http://www.japanremit.com</a>
                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------8-------------->
                                    <b>How to remit to <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %>'s bank account?</b><br>
                                    The sender remits the fund in Japanese yen to <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> designated account.
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------9-------------->
                                    <b><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Business Hours</b><br>
                                    Everyday 9:00 AM - 18:00 PM
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------10-------------->
                                    <b>Contact for Notices and Inquiries</b><br>
                                    In the case <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> fives notices to or makes an inquiry
                                                    with the applicant in respect to this transaction, the address and telephone number stated
                                                    in the Application for Remittance shall be used.
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <!------------11-------------->
                                    <b>Force Majeure</b><br>
                                    <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> shall not be responsible for any losses or damages arising out of any of the following:
                                                     <ol type="A">
                                                         <li>An unavoidable event such as calamities, incidents, wars, accidents during transit, restrictions by
                                                             laws and regulations, and certain actions taken by the governments, courts or other public authorities;
                                                         </li>
                                                         <li>Any failure or malfunction of terminals, communication circuits, computers or other equipment;
                                                            or any mutilation, error or omission in the text resulting from such, which occurred despite
                                                            reasonable security measures taken by <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %>.
                                                         </li>
                                                     </ol>
                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <b>Prohibition of Transfer or Pledge</b><br>
                                    The applicant shall not be allowed to transfer or pledge
                                                    rights under the transactions made herein.
                                                    <br>
                                    <br>
                                </li>
                                <li>
                                    <b>Conflict</b><br>
                                    The problems caused by the meaning of terms used herein shall be judged by Japanese descriptive sentence.
                                                    If any conflict and controversy or claim aroused relating to any brochure, guide and agreement either in Nepali,
                                                    Japanese or English version, they shall be construed and governed by Japanese version.
                                                    <br>
                                    <br>
                                </li>
                                <li>Customer care department shall be in charge of safeguard for our customers.
                                                    If any opinions, inquiry and complains, please inform this department.
                                                    <br>
                                    <br>
                                </li>
                            </ol>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" id="btnIAgree" data-dismiss="modal" class="btn btn-primary">I agree</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../js/Customer/addCustomerTab.js"></script>
    <script src="../js/signature_pad.umd.js" type="text/javascript"></script>
    <script src="../js/SendTxnTab/CustomerSignature.js" type="text/javascript"></script>
</asp:Content>