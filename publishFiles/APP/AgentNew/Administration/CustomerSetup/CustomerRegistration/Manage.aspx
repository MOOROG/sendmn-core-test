<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.CustomerRegistration.Manage" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%--<link href="../../../css/signature-pad.css" rel="stylesheet" />--%>
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/css/intlTelInput.css" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <%--<link href="/js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />--%>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="/AgentNew/css/signature-pad.css" rel="stylesheet" />--%>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <style>
        .intl-tel-input {
            width: 100% !important;
        }

        input, textarea {
            text-transform: uppercase;
        }

        table#ContentPlaceHolder1_rbRemitanceAllowed tbody tr td {
            padding-left: 10px;
        }

        table#ContentPlaceHolder1_rbOnlineLogin tbody tr td {
            padding-left: 10px;
        }
    </style>
    <script>
        $(document).ready(function () {
            var isEdit =<%=CheckAddOrEdit().ToString().ToLower()%>;
            if (isEdit) {
                $("#<%=addEditPanel.ClientID%>").hide();
            }
            //date to age conversion
            $("#ContentPlaceHolder1_dob").on("change", function () {
                IdTypeValidity();
            });

            // mobile country code added
            $("#<%=mobile.ClientID%>").intlTelInput({
                nationalMode: true,
                onlyCountries: ["mn"],
                utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/utils.js" // just for formatting/placeholders etc
            });

            $("#<%=mobile.ClientID%>").on("change", function () {
                var input = $("#<%=mobile.ClientID%>");
                var countryCode = $('.dial-code').text();
                var mobileNo = input.val();
                var maxLength = input.attr('maxLength');
                if (mobileNo.indexOf(countryCode) < 0) {
                    mobileNo = countryCode + mobileNo;
                }
                if (mobileNo.length > maxLength) {
                    alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                    return $(this).val('');
                }
                $(this).val(mobileNo);
            });

            $('#<%=countryList.ClientID%>').on('change', function () {
                $("#<%=mobile.ClientID%>").val('');
                var country = $("#<%=countryList.ClientID%> option:selected").text();
                if (country.toLowerCase() == 'japan') {
                    $("#<%=mobile.ClientID%>").intlTelInput('setCountry', 'jp');
                }
            });

            CalSenderDOB("#<%=dob.ClientID%>");
            CalIDIssueDate("#<%=IssueDate.ClientID%>");
            CalFromToday("#<%=ExpireDate.ClientID%>");
            $("#<%=IssueDate.ClientID%>").mask('0000-00-00');
            $("#<%=ExpireDate.ClientID%>").mask('0000-00-00');
            $("#<%=IssueDate.ClientID%>").mask('0000-00-00');
            $("#<%=ExpireDate.ClientID %>").mask('0000-00-00');
            $("#<%=dob.ClientID%>").mask('0000-00-00');

            IdTypeValidity();
            <%--$("#searchCustomer").change(function () {
                var customerId = $("#txtSearchData_aText").val();
                if (customerId != undefined && (customerId == "" || customerId == null)) {
                    $("#<%=addEditPanel.ClientID%>").hide();
                }
            });--%>
        });

        function GetAge() {
            var inputDate = $("#ContentPlaceHolder1_dob").val();
            age = 0;
            if (inputDate != "") {
                var currentYear = inputDate.substring(0, 4);
                var today = new Date();
                age = today.getFullYear() - currentYear;

            }
            return age;
        }

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

        function EmailValidation() {
            $('#ContentPlaceHolder1_rev1').hide();
            var pattern = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
            var emailData = $("#<%=email.ClientID%>");
            if (emailData.hasClass('required')) {
                var isValid = pattern.test(String(emailData.val()).toLowerCase());
                if (!isValid)
                    $('#ContentPlaceHolder1_rev1').show();
                return isValid;

            }
            return true;
        }

        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        }

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hdnCustomerId.ClientID%>').val(d[0]);
            LoadcustomerData();
            $('#<%=addEditPanel.ClientID%>').removeAttr('style');
            $('#<%=register.ClientID%>').removeAttr('disabled');
        }

        function LoadcustomerData() {
            var eid = $('#<%=hdnCustomerId.ClientID%>').val();
            dataToSend = { MethodName: 'GetCustomerDetails', Id: eid };
            $.post('/AgentNew/Administration/CustomerSetup/CustomerRegistration/Manage.aspx', dataToSend, function (response) {
                ParseCustomerData(response);
            }).fail(function () {
                alert('Oops!!! something went wrong, please try again.');
            });
        }

        function changeNativeCountry() {
            var ddl = document.getElementById("<%=district.ClientID%>");
            $(ddl).empty();
            var ddl = document.getElementById("<%=ddlCity.ClientID%>");
            $(ddl).empty();
            PopulateProvince($('#<%=nativeCountry.ClientID%>').val(), "");
            PopulateIdType($('#<%=nativeCountry.ClientID%>').val(), "");
        }

        function changeProvince() {
            PopulateCity($('#<%=district.ClientID%>').val(), "");
        }

        function PopulateIdType(nativeId) {
            debugger;
            var dataToSend = { nativeId: nativeId, MethodName: "PopulateIdType" };
            $.post('Manage.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
                populateIdTypeResponse(response, nativeId);
            }).fail(function () {
                alert("Error from populate branch user");
            });
        }

        function populateIdTypeResponse(response, nativeId) {
            var data = jQuery.parseJSON(response);
            var ddl = document.getElementById("<%=idType.ClientID%>");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'Select Verification ID';
            option.value = '';

            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].detailTitle;
                option.value = data[i].valueId;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }

            if (nativeId = '142') {
                $('#<%=idType.ClientID%>').val('8008|National ID|N');
            }

        }

        function PopulateProvince(nativeId, provinceId) {

            var dataToSend = { nativeId: nativeId, MethodName: "PopulateProvince" };
            $.post('Manage.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
                populatecProvinceResponse(response, provinceId);
            }).fail(function () {
                alert("Error from populate branch user");
            });

        }

        function populatecProvinceResponse(response, provinceId) {
            var data = jQuery.parseJSON(response);
            var ddl = document.getElementById("<%=district.ClientID%>");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'Select Province';
            option.value = '';

            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].PROVINCE_NAME;
                option.value = data[i].id;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
            $('#<%=district.ClientID%>').val(provinceId);
        }

        function PopulateCity(provinceId, cityId) {

            var dataToSend = { provinceId: provinceId, MethodName: "PopulateCity" };
            $.post('Manage.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
                populatecCityResponse(response, cityId);
                debugger;
            }).fail(function () {
                alert("Error from populate branch user");
            });
        }

        function populatecCityResponse(response, cityId) {
            var data = jQuery.parseJSON(response);
            var ddl = document.getElementById("<%=ddlCity.ClientID%>");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'Select City';
            option.value = '';

            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].CITY_NAME;
                option.value = data[i].id;

                if (data[i].id == cityId) {
                    option.selected = data[i].id;
                }

                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function ParseCustomerData(response) {
            debugger;
            var dr = jQuery.parseJSON(response);
            if (dr != null) {
                $("#<%=addEditPanel.ClientID%>").show();
                $('#<%=hdnCustomerId.ClientID%>').val(dr[0].customerId);
                $('#<%=firstName.ClientID%>').val(dr[0].firstName);
                $('#<%=lastName.ClientID%>').val(dr[0].lastName1);
                $('#<%=genderList.ClientID%>').val(dr[0].gender);
                $('#<%=countryList.ClientID%>').val(dr[0].country);
                $('#<%=district.ClientID%>').val(dr[0].district);
                $('#<%=email.ClientID%>').val(dr[0].email);
                $('#<%=hddOldEmailValue.ClientID%>').val(dr[0].email);
                $('#<%=mobile.ClientID%>').val(dr[0].mobile);
                $('#<%=nativeCountry.ClientID%>').val(dr[0].nativeCountry);
                $('#<%=nativeCountry.ClientID%>').val(dr[0].nativeCountryId);
                $('#<%=dob.ClientID%>').val(dr[0].dob);
                $('#<%=occupation.ClientID%>').val(dr[0].occupation);
                $('#<%=IssueDate.ClientID%>').val(dr[0].idIssueDate);
                $('#<%=ExpireDate.ClientID%>').val(dr[0].idExpiryDate);
                $('#<%=idType.ClientID%>').val(dr[0].idType);
                $('#<%=verificationTypeNo.ClientID%>').val(dr[0].idNumber);
                $('#<%=hddIdNumber.ClientID%>').val(dr[0].homePhone);
                $('#<%=hdnMembershipNo.ClientID%>').val(dr[0].membershipId);
                $('#<%=txtAdditionalAddress.ClientID%>').val(dr[0].additionalAddress);
                $('#<%=bankName.ClientID%>').val(dr[0].bankName);
                $('#<%=bankAccountNo.ClientID%>').val(dr[0].bankAccountNo);
                $('#<%=ddlVisaStatus.ClientID%>').val(dr[0].visaStatus);
                $('#<%=ddSourceOfFound.ClientID%>').val(dr[0].sourceOfFund);
                <%--$('#<%=ddlStateHidden.ClientID%>').val(dr[0].state);
                $('#<%=cityHidden.ClientID%>').val(dr[0].city);--%>

                $('#<%=email.ClientID%>').Enabled = (dr[0].isTxnMade == "Y") ? false : true;
                $('#<%=hddTxnsMade.ClientID%>').val(dr[0].isTxnMade);

                PopulateCity(dr[0].district, dr[0].city);
                var senIdTypeArr = dr[0].idType.split('|');
                ManageImageDiv(senIdTypeArr[0]);
                $("#<%=selfieImageFile.ClientID%>").removeClass('required');
                $('#selfieReq').hide();
                $("#<%=passImageFile.ClientID%>").removeClass('required');
                $('#passReq').hide();
                $("#<%=frontIdImageFile.ClientID%>").removeClass('required');
                $('#fontReq').hide();
                $("#<%=backIdImageFile.ClientID%>").removeClass('required');
                $('#backReq').hide();
                $("#<%=imageDisplayDiv.ClientID%>").show();
                $('#req1').hide();
                $("#<%=passDisplay.ClientID%>").attr('src', dr[0].verifyDoc1);
                $("#<%=frontIdDisplay.ClientID%>").attr('src', dr[0].verifyDoc2);
                $("#<%=backIdDisplay.ClientID%>").attr('src', dr[0].verifyDoc3);
                $("#<%=selfieDisplay.ClientID%>").attr('src', dr[0].verifyDoc4);
            }
        }

        function CheckFormValidation() {
            var reqField = "";
            var val = $("#<% =hdnCustomerId.ClientID%>").val();
            var input = $("#<%=mobile.ClientID%>");
            var mobileNo = input.val();
            if (mobileNo != null && mobileNo != "") {
                var countryCode = $('.dial-code').text();
                var maxLength = input.attr('maxLength');
                if (mobileNo.indexOf(countryCode) < 0) {
                    mobileNo = countryCode + mobileNo;
                }
                if (mobileNo.length > maxLength) {
                    alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                    return $(this).val('');
                }
                $("#<%=mobile.ClientID%>").val(mobileNo);

            }
            var requiredElement = document.getElementsByClassName('required');
            for (var i = 0; i < requiredElement.length; ++i) {
                var item = requiredElement[i].id;
                reqField += item + ",";
            }

            if ($('#<%=expiryDiv.ClientID%>').hasClass("hidden")) {
                reqField = reqField.replace(",<%=ExpireDate.ClientID%>,", ",");
            }


            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            if (!EmailValidation())
                return false;
            if (!$('#<%=expiryDiv.ClientID%>').hasClass("hidden")) {
                var issueDate = $('#<%=IssueDate.ClientID%>').val();
                var exipreDate = $('#<%=ExpireDate.ClientID%>').val();
                if (issueDate != '' && exipreDate != '') {
                    if (issueDate > exipreDate) {
                        alert("Issue Date cannot be greater than Valid date");
                        return false;
                    }
                }
            }
            return true;
        }

        function readURL(input, id) {
            var file = input.files[0];
            if (file == null) {
                if (id === "selfieDisplay") {
                    $("#<%=selfieImageDiv.ClientID%>").hide();
                    $("#<%=selfieDisplay.ClientID%>").attr('src', '');
                }

                if (id === "frontIdDisplay") {
                    $("#<%=forntIdImageDiv.ClientID%>").hide();
                    $("#<%=frontIdDisplay.ClientID%>").attr('src', '');
                }

                if (id === "backIdDisplay") {
                    $("#<%=backIdImageDiv.ClientID%>").hide();
                    $("#<%=backIdDisplay.ClientID%>").attr('src', '');
                }

                if (id === "passDisplay") {
                    $("#<%=passImageDiv.ClientID%>").hide();
                    $("#<%=passDisplay.ClientID%>").attr('src', '');
                }
                return;
            }
            var imageType = ['jpeg', 'jpg', 'png', 'gif', 'bmp'];
            if (-1 == $.inArray(file.type.split('/')[1], imageType)) {
                alert("Please Choose Image File Only");
                input.value = '';
                return false;
            }
            var reader = new FileReader();
            reader.onload = function (e) {
                $('#' + ContentPlaceHolderId + id).attr('src', e.target.result);
            }
            reader.readAsDataURL(input.files[0]);
            $("#<%=imageDisplayDiv.ClientID%>").show();
            if (id === "selfieDisplay") {
                $("#<%=selfieImageDiv.ClientID%>").show();
            }

            if (id === "frontIdDisplay") {
                $("#<%=forntIdImageDiv.ClientID%>").show();
            }

            if (id === "backIdDisplay") {
                $("#<%=backIdImageDiv.ClientID%>").show();
            }

            if (id === "passDisplay") {
                $("#<%=passImageDiv.ClientID%>").show();
            }
        }

        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        }

        function IdTypeValidity() {
            debugger;
            var senIdType = $("#<%=idType.ClientID%>").val();
            if (senIdType == "") {
                $("#<%=expiryDiv.ClientID%>").removeClass('hidden');
            }
            else {
                var age = Number(GetAge());
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
                var nCountry = $("#ContentPlaceHolder1_nativeCountry").val();
                if (nCountry == "142" && senIdTypeArr[0] === "8008" && age >= 43) {
                    $("#<%=expiryDiv.ClientID%>").addClass("hidden");
                    $("#<%=ExpireDate.ClientID%>").removeClass("required");
                }
                ManageImageDiv(senIdTypeArr[0])
            }
        }

        function ManageImageDiv(idNumber) {
            $("#<%=selfieImageFile.ClientID%>").addClass("required");
            $("#<%=passImageFile.ClientID%>").addClass("required");
            $("#<%=backIdImageFile.ClientID%>").addClass("required");
            $("#<%=frontIdImageFile.ClientID%>").addClass("required");
            $("#<%=selfieImage.ClientID%>").show();
            $("#<%=passImage.ClientID%>").show();
            $("#<%=frontImage.ClientID%>").show();
            $("#<%=backImage.ClientID%>").show();
            $("#<%=selfieImageFile.ClientID%>").val('');
            $("#<%=passImageFile.ClientID%>").val('');
            $("#<%=frontIdImageFile.ClientID%>").val('');
            $("#<%=backIdImageFile.ClientID%>").val('');
            var customerId = Number($("#<%=hdnCustomerId.ClientID%>").val());
            if (customerId <= 0) {
                $('#<%=selfieImageFile.ClientID%>').attr('src', '');
                $('#<%=passImageFile.ClientID%>').attr('src', '');
                $('#<%=frontIdImageFile.ClientID%>').attr('src', '');
                $('#<%=backIdImageFile.ClientID%>').attr('src', '');
                $('#<%=selfieDisplay.ClientID%>').attr('src', '');
                $('#<%=passDisplay.ClientID%>').attr('src', '');
                $('#<%=frontIdDisplay.ClientID%>').attr('src', '');
                $('#<%=backIdDisplay.ClientID%>').attr('src', '');
                $("#<%=imageDisplayDiv.ClientID%>").hide();
            }
            $("#<%=forntIdImageDiv.ClientID%>").show();
            $("#<%=backIdImageDiv.ClientID%>").show();
            $('#<%=passImageDiv.ClientID%>').show();

            $("#selfieReq").show();
            $("#passReq").show();
            $("#fontReq").show();
            $("#backReq").show();
            if (idNumber != "8008") { /////////// if id type is not national id
                $("#<%=frontImage.ClientID%>").hide();
                $("#<%=backImage.ClientID%>").hide();
                $('#<%=backIdImageDiv.ClientID%>').hide();
                $('#<%=forntIdImageDiv.ClientID%>').hide();
                $("#<%=backIdImageFile.ClientID%>").removeClass("required");
                $("#<%=frontIdImageFile.ClientID%>").removeClass("required");
            }
            else {
                $("#<%=passImage.ClientID%>").hide();
                $('#<%=passImageDiv.ClientID%>').hide();
                $("#<%=passImageFile.ClientID%>").removeClass("required");
            }
            if (customerId > 0) {
                $("#selfieReq").hide();
                $("#passReq").hide();
                $("#fontReq").hide();
                $("#backReq").hide();
                $("#<%=selfieImageFile.ClientID%>").removeClass("required");
                $("#<%=passImageFile.ClientID%>").removeClass("required");
                $("#<%=backIdImageFile.ClientID%>").removeClass("required");
                $("#<%=frontIdImageFile.ClientID%>").removeClass("required");
            }
        }

        function CheckCustomerId() {
            customerId = $("#<%=hdnCustomerId.ClientID%>").val();
            if (customerId !== null && customerId !== "") {
                return true;
            }
            return false;
        }
        function SetMessageBox(msg, id) {
            alert(msg);
        }

        function ShowIdTypeInfo() {
            var idInfo = $('#<%=idType.ClientID%>').val();
            if (idInfo == '' || idInfo == null) {
                alert('Please select id type first!')
            }
            else {
                alert(idInfo.split("|")[1]);
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <%-- <asp:HiddenField ID="cityHidden" runat="server" />
    <asp:HiddenField ID="ddlStateHidden" runat="server" />--%>
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('account')">Online Agent</a></li>
                        <li><a href="#" onclick="return LoadModule('account')">Customer Registration</a></li>
                        <li class="active"><a href="Manage.aspx?customerId=<%=hdnCustomerId.Value %>">Manage</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab" runat="server" id="regUp">
            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation" class="active"><a href="Manage.aspx">Customer Operation</a></li>
            </ul>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="List">
                </div>
                <div role="tabpanel" id="Manage">
                    <div class="">
                        <div class="register-form">
                            <div class="panel panel-default clearfix m-b-20" id="displayOnlyOnEdit" visible="false" runat="server">
                                <div class="panel-heading">Customer Information</div>
                                <div class="panel-body">
                                    <div class="col-sm-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                        <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                    </div>
                                    <div>
                                        <div class="col-sm-3">
                                            <label class="control-label">Search By</label>
                                            <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-sm-3">
                                            <div class="form-group" id="searchCustomer">
                                                <label>Choose Customer :<span class="errormsg">*</span></label>
                                                <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" CssClass="form-control required" Param1="@GetCustomerSearchType()" Title="Blank for All" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div id="addEditPanel" runat="server">

                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading">Personal Information</div>
                                    <div class="panel-body">
                                        <div class="">
                                            <div class="col-md-4  col-sm-4">
                                                <div class="form-group">
                                                    <label>First Name:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="firstName" runat="server" placeholder="First Name" CssClass="form-control required" />
                                                </div>
                                            </div>
                                            <div class="col-md-4  col-sm-4">
                                                <div class="form-group">
                                                    <label>Last Name:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="lastName" runat="server" placeholder="Last Name" CssClass="form-control required" />
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
                                                <label>Native Country:<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="nativeCountry" CssClass="form-control required" AutoPostBack="false" onChange="changeNativeCountry()"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group">
                                                <label>Province:<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="district" CssClass="form-control required" AutoPostBack="false" onChange="changeProvince()">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group">
                                                <label>City:<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="ddlCity" CssClass="form-control required" AutoPostBack="false">
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group">
                                                <label>Additional Address:</label>
                                                <asp:TextBox ID="txtAdditionalAddress" runat="server" placeholder="Additional address" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="col-md-4 col-sm-4 ">
                                            <div class="form-group">
                                                <label>Gender:<span class="errormsg">*</span> </label>
                                                <asp:DropDownList runat="server" ID="genderList" name="genderList" CssClass="form-control  required">
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <div class="col-md-4 col-sm-4 ">
                                            <div id="tdSenExpDateTxt" runat="server" nowrap="nowrap" class="showHideIDExpDate">
                                            </div>
                                            <div class="form-group">
                                                <label>Date of Birth:<span class="errormsg">*</span></label>
                                                <div class="input-group input-append date dpYears">

                                                    <asp:TextBox runat="server" ID="dob" placeholder="YYYY/MM/DD" onchange="return DateValidation('dob','dob')" MaxLength="10" AutoComplete="off" CssClass="form-control  required"></asp:TextBox>
                                                    <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group">
                                                <label>E-Mail ID:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="email" runat="server" placeholder="Email" CssClass="form-control required" />
                                                <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                    ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                    ControlToValidate="email"></asp:RegularExpressionValidator>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group" style="overflow: initial;">
                                                <label>Mobile No.:<span class="errormsg">*</span></label><br />
                                                <asp:TextBox runat="server" MaxLength="16" ID="mobile" placeholder="Mobile No" CssClass="form-control required" />
                                            </div>
                                        </div>

                                        <div class="col-md-4 col-sm-4 ">
                                            <div class="form-group">
                                                <label>Visa Status</label>
                                                <asp:DropDownList runat="server" ID="ddlVisaStatus" name="ddlVisaStatus" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4 ">
                                            <div class="form-group">
                                                <label>Occupation:<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="occupation" CssClass="form-control  required"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4 col-sm-4">
                                            <div class="form-group">
                                                <label>Source of Fund:</label>
                                                <asp:DropDownList runat="server" ID="ddSourceOfFound" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading">Bank & Security Information</div>
                                    <div class="panel-body">
                                        <div style="margin-left: 15px">
                                            <div class="row">
                                                <div class="col-md-4 col-sm-4">
                                                    <div class="form-group">
                                                        <label>Bank Name:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="bankName" CssClass="form-control required"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-4 col-sm-4">
                                                    <div class="form-group">
                                                        <label>Account Number:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="bankAccountNo" runat="server" CssClass="form-control required" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-3 col-sm-3">
                                                    <div class="form-group">
                                                        <label>Verification Id Type:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="idType" CssClass="form-control required" onchange="IdTypeValidity();"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-3 col-sm-3">
                                                    <div class="form-group">
                                                        <label id="verificationType">Verification Type No.:<span class="errormsg">*</span></label>
                                                        <div class="input-group input-append date dpYears">
                                                            <asp:TextBox ID="verificationTypeNo" runat="server" placeholder="Verification Type Number" MaxLength="14" CssClass="form-control required" />
                                                            <div class="input-group-addon" onclick="ShowIdTypeInfo();"><i class="fa fa-info"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-3 col-sm-3">
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

                                                <div class="col-md-3 col-sm-3" id="expiryDiv" runat="server">
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
                                            </div>
                                           <div class="row">
                                                    <div class="col-md-4" id="selfieImage" runat="server">
                                                        <div class="form-group">
                                                            <label>Selfie Image :</label><span id="selfieReq" class="errormsg">*</span>
                                                            <asp:FileUpload ID="selfieImageFile" runat="server" onChange="readURL(this, 'selfieDisplay')" CssClass="form-control-plaintext form-control required" accept="image/*" />
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="passImage" runat="server">
                                                        <div class="form-group">
                                                            <label>Front/Back Image :</label><span id="passReq" class="errormsg">*</span>
                                                            <asp:FileUpload ID="passImageFile" runat="server" onChange="readURL(this, 'passDisplay')" CssClass="form-control-plaintext form-control required" accept="image/*" />
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="frontImage" runat="server">
                                                        <div class="form-group">
                                                            <label>ID Front Image :</label><span id="fontReq" class="errormsg">*</span>
                                                            <asp:FileUpload ID="frontIdImageFile" runat="server" onChange="readURL(this, 'frontIdDisplay')" CssClass="form-control-plaintext form-control required" accept="image/*" />
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="backImage" runat="server">
                                                        <div class="form-group">
                                                            <label>ID Back Image :</label><span id="backReq" class="errormsg">*</span>
                                                            <asp:FileUpload ID="backIdImageFile" runat="server" onChange="readURL(this, 'backIdDisplay')" CssClass="form-control-plaintext form-control required" accept="image/*" />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row" id="imageDisplayDiv" runat="server">
                                                    <div class="col-md-4" id="selfieImageDiv" runat="server">
                                                        <div class="form-group">
                                                            <div class="col-md-12">
                                                                <label>&nbsp;</label><br />
                                                                <asp:Image runat="server" ID="selfieDisplay" CssClass="img-fluid" Style="height: 200px; object-fit: contain;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="passImageDiv" runat="server">
                                                        <div class="form-group">
                                                            <div class="col-md-12">
                                                                <label>&nbsp;</label><br />
                                                                <asp:Image runat="server" ID="passDisplay" CssClass="img-fluid" Style="height: 200px; object-fit: contain;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="forntIdImageDiv" runat="server">
                                                        <div class="form-group">
                                                            <div class="col-md-12">
                                                                <label>&nbsp;</label><br />
                                                                <asp:Image runat="server" ID="frontIdDisplay" CssClass="img-fluid" Style="height: 200px; object-fit: contain;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="backIdImageDiv" runat="server">
                                                        <div class="form-group">
                                                            <div class="col-md-12">
                                                                <label>&nbsp;</label><br />
                                                                <asp:Image runat="server" ID="backIdDisplay" CssClass="img-fluid" Style="height: 200px; object-fit: contain;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                        </div>
                                        <div class="row" runat="server">
                                            <div class="form-group">
                                                <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="register_Click" />
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
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hddIdNumber" />
        <asp:HiddenField runat="server" ID="hdnMembershipNo" />
        <asp:HiddenField runat="server" ID="hddOldEmailValue" />
        <asp:HiddenField runat="server" ID="hddTxnsMade" />
    </div>
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/ui/js/jquery.validate.js" type="text/javascript"></script>

    <script src="/js/popper/popper.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/intlTelInput.min.js"></script>

    <script src="/AgentNew/js/swift_calender.js"></script>
</asp:Content>