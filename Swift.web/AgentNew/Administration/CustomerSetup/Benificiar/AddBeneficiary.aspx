<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="AddBeneficiary.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.Benificiar.AddBeneficiary" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <%--    <script type="text/javascript" language="javascript">

        Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(BeginRequestHandler);
        function BeginRequestHandler(sender, args) { var oControl = args.get_postBackElement(); oControl.disabled = true; }
    </script>--%>
    <script type="text/javascript">

        $(document).ready(function () {
            $('#<%=regUp.ClientID%>').hide();
            $(document).on('change', '#<%=ddlSearchBy.ClientID%>', function () {
                $('#ContentPlaceHolder1_txtSearchData_aText').val('');
                ClearAllInputFields();
                $('#<%=regUp.ClientID%>').hide();
                <% = txtSearchData.InitFunction() %>
            });
            function addCountryCode() {
                $("#<%=txtSenderMobileNo.ClientID%>").intlTelInput({
                    nationalMode: true,
                    utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/utils.js" // just for formatting/placeholders etc
                });
            }

            $('#<%=register.ClientID%>').click(function () {
                return CheckFormValidation();
            });

            addCountryCode();

            $(document).on('change', '#<%=txtSenderMobileNo.ClientID%>', function () {
                var input = $("#<%=txtSenderMobileNo.ClientID%>");
                var mobileNo = input.val();
                var countryCode = $('.country.active .dial-code').text();
                var maxLength = input.attr('maxLength');
                if (mobileNo.indexOf(countryCode) < 0) {
                    mobileNo = countryCode + mobileNo;
                }
                if ((mobileNo).length > maxLength) {
                    alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                    return $(this).val('');
                }
                //var intlNumber = input.intlTelInput("getNumber", intlTelInputUtils.numberFormat.E164);

                $(this).val(mobileNo);
                CheckForMobileNumber(this, 'Mobile No.');
            });

            
            $(document).on('change', '#ContentPlaceHolder1_txtSearchData_aSearch', function () {
                searchValue = $(this).val();
                if (searchValue === null || searchValue === "") {
                    $('#ContentPlaceHolder1_txtSearchData_aText').val('');
                    ClearAllInputFields();
                    $('#<%=regUp.ClientID%>').hide();
                }
            });
        });

        function ClearAllInputFields() {
            $('#<%=ddlCountry.ClientID%>').val('');
            $('#<%=ddlBenificiaryType.ClientID%>').val('4700');
            $('#<%=txtEmail.ClientID%>').val('');
            $('#<%=txtReceiverFName.ClientID%>').val('');
            $('#<%=txtReceiverMName.ClientID%>').val('');
            $('#<%=txtReceiverLName.ClientID%>').val('');
            $('#<%=ddlNativeCountry.ClientID%>').val('');
            $('#<%=txtReceiverAddress.ClientID%>').val('');
            $('#<%=txtReceiverCity.ClientID%>').val('');
            $('#<%=txtContactNo.ClientID%>').val('');
            $('#<%=txtSenderMobileNo.ClientID%>').val('');
            $('#<%=txtSenderMobileNo.ClientID%>').attr('disabled', 'disabled');
            $('#<%=ddlIdType.ClientID%>').val('');
            $('#<%=txtIdValue.ClientID%>').val('');
            $('#<%=txtPlaceOfIssue.ClientID%>').val('');
            $('#<%=ddlRelationship.ClientID%>').val('');
            $('#<%=otherRelationshipTextBox.ClientID%>').val('');
            $('#<%=ddlPurposeOfRemitance.ClientID%>').val('');
            $('#<%=ddlPaymentMode.ClientID%>').val('');
            $('#<%=ddlPayoutPatner.ClientID%>').val('');
            $('#<%=txtBankName.ClientID%>').val('');
            $('#<%=txtBenificaryAc.ClientID%>').val('');
            $('#<%=DDLBankLocation.ClientID%>').val('');
            $('#<%=txtRemarks.ClientID%>').val('');
            $('#<%=customerName.ClientID%>').text('');
            $('#<%=txtMembershipId.ClientID%>').text('');
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

        function ddlCountryChange() {
            $('#<%=txtSenderMobileNo.ClientID%>').attr('disabled', 'disabled');
            PopulateCountryFlagForMobileNumber();
            PopulatePaymentMethod();
            PopulatePayoutPartner();
        }

        function CallBackAutocomplete(id) {
            ClearAllInputFields();
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hideCustomerId.ClientID%>').val(d[0]);
            LoadCustomerInfo(d[0]);
            $('#<%=regUp.ClientID%>').show();
        }

        function LoadCustomerInfo(customerId) {
            var data = { MethodName: "LoadCustomerInfo", customerId: customerId };
            $.ajax({
                url: "",
                type: "post",
                data: data,
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response != null) {
                        $('#<%=customerName.ClientID%>').text(response[0].fullName);
                        $('#<%=txtMembershipId.ClientID%>').text(response[0].membershipId);
                    }
                },
                error: function (error) {
                    alert("Something went wrong!!!")
                }
            });
        }

        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        }

        function PopulatePaymentMethod() {
            var data =
            {
                MethodName: "PopulatePaymentMode",
                country: $("#<%=ddlCountry.ClientID%> option:selected").text()
            };
            $.ajax({
                url: "",
                type: "post",
                data: data,
                dataType: "json",
                async: false,
                success: function (response) {
                    PopulateDDL(response, '<%=ddlPaymentMode.ClientID%>', "", "", "");
                },
                error: function (error) {
                    alert("Something went wrong!!!")
                }
            })
        }

        function PopulatePayoutPartner() {
            var pmode = $("#<%=ddlPaymentMode.ClientID%> option:selected").val();
            if (pmode == "2") {
                $("#<%=receiverAccountNo.ClientID%>").show();
                //$("#agentBankBranchDiv").show();
            }
            else {
                $("#<%=receiverAccountNo.ClientID%>").hide();
                $("#<%=DDLBankLocation.ClientID%>").val('');
                //$("#agentBankBranchDiv").hide();
            }

            var data =
            {
                MethodName: "PopulatePayoutPartner",
                country: $("#<%=ddlCountry.ClientID%> option:selected").val(),
                paymentMode: $("#<%=ddlPaymentMode.ClientID%> option:selected").text()
            };
            $.post("", data, function (response) {
                PopulateDDL(response, '<%=ddlPayoutPatner.ClientID%>', "", "", "");
            }).fail(function (error) {
                alert("Something went wrong!!!");
            });
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
                if (ddlId == '<%=ddlPaymentMode.ClientID%>') {
                    option.text = populateData[i].Value;
                    option.value = populateData[i].Key;
                } else if (ddlId == '<%=DDLBankLocation.ClientID%>') {
                    option.text = populateData[i].agentName;
                    option.value = populateData[i].agentId;

                } else {
                    option.text = populateData[i].AGENTNAME;
                    option.value = populateData[i].bankId;
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

        function showTextBox() {
            var res = $("#<% =ddlRelationship.ClientID%>").val();
            if (res.toUpperCase() == "11065") {
                $("#<%=otherRelationDiv.ClientID%>").show();
            }
            else {
                $("#<%=otherRelationDiv.ClientID%>").hide();
            }
        }

        function CheckFormValidation(e) {
            var reqField = "";
            $('#<%=ddlIdType.ClientID%>').removeAttr('style');
            $('#<%=txtIdValue.ClientID%>').removeAttr('style');
            paymentMode = $("#<% =ddlPaymentMode.ClientID%>").val();
            var requiredElement = document.getElementsByClassName('required');
            for (var i = 0; i < requiredElement.length; ++i) {
                var item = requiredElement[i].id;
                reqField += item + ",";
            }
            idTypeVal = $('#<%=ddlIdType.ClientID%>').val();
            if (idTypeVal !== null && idTypeVal !== "" && idTypeVal !== "0") {
                reqField +="<%=ddlIdType.ClientID%>,<%=txtIdValue.ClientID%>,";
            }
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            $('#<%=register.ClientID%>').attr('disabled', 'disabled');
            save();

        }

        function save() {
            var addType ='<%=GetReceiverAddType()%>';
            var data =
            {
                MethodName: "SaveReceiverDetails",
                nativeCountry: $("#<%=ddlNativeCountry.ClientID%>").val(),
                paymentMode: $("#<%=ddlPaymentMode.ClientID%> option:selected").val(),
                PayoutPatner: $("#<%=ddlPayoutPatner.ClientID%> option:selected").val(),
                Country: $("#<%=ddlCountry.ClientID%> option:selected").text(),
                BenificiaryType: $("#<%=ddlBenificiaryType.ClientID%> option:selected").val(),
                Email: $("#<%=txtEmail.ClientID%>").val(),
                ReceiverFName: $("#<%=txtReceiverFName.ClientID%>").val(),
                ReceiverMName: $("#<%=txtReceiverMName.ClientID%>").val(),
                ReceiverLName: $("#<%=txtReceiverLName.ClientID%>").val(),
                ReceiverAddress: $("#<%=txtReceiverAddress.ClientID%>").val(),
                ReceiverCity: $("#<%=txtReceiverCity.ClientID%>").val(),
                ContactNo: $("#<%=txtContactNo.ClientID%>").val(),
                SenderMobileNo: $("#<%=txtSenderMobileNo.ClientID%>").val(),
                Relationship: $("#<%=ddlRelationship.ClientID%> option:selected").val(),
                PlaceOfIssue: $("#<%=txtPlaceOfIssue.ClientID%>").val(),
                TypeId: $("#<%=ddlIdType.ClientID%> option:selected").val(),
                TypeValue: $("#<%=txtIdValue.ClientID%>").val(),
                BenificaryAc: $("#<%=receiverAccountNo.ClientID%>").val(),
                PurposeOfRemitance: $("#<%=ddlPurposeOfRemitance.ClientID%>").val(),
                BankLocation: $("#<%=DDLBankLocation.ClientID%>").val(),
                BankName: $("#<%=txtBankName.ClientID%>").val(),
                BenificaryAc: $("#<%=txtBenificaryAc.ClientID%>").val(),
                Remarks: $("#<%=txtRemarks.ClientID%>").val(),
                OtherRelationDescription: $("#<%=otherRelationshipTextBox.ClientID%>").val(),
                membershipId: $("#<%=hideMembershipId.ClientID%>").val(),
                ReceiverId: $("#<%=hideBenificialId.ClientID%>").val(),
                hideCustomerId: $("#<%=hideCustomerId.ClientID%>").val(),
                hideBenificialId: $("#<%=hideBenificialId.ClientID%>").val()
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
                            window.location.href = "AddBeneficiary.aspx";
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
            var getCountryId = $("#<%=ddlCountry.ClientID%> option:selected").val();
            if (getCountryId !== null && getCountryId !== "" && getCountryId !== "0") {
                var getCountry = $("#<%=ddlCountry.ClientID%> option:selected").text();
                $('#<%=txtSenderMobileNo.ClientID%>').removeAttr('disabled');
                var code = getCountry.split('(');
                code = code[1].split(')')[0];
                $("#<%=txtSenderMobileNo.ClientID%>").intlTelInput('setCountry', code);
            }
        }

        function PopulateLocation() {
            var pmode = $("#<%=ddlPaymentMode.ClientID%> option:selected").val();
            if (pmode == "2") {
                $("#<%=receiverAccountNo.ClientID%>").show();
                //$("#agentBankBranchDiv").show();
            }
            else {
                $("#<%=receiverAccountNo.ClientID%>").hide();
                $("#<%=DDLBankLocation.ClientID%>").val('');
                //$("#agentBankBranchDiv").hide();
            }

            var data =
            {
                MethodName: "PopulateLocation",
                country: $("#<%=ddlCountry.ClientID%> option:selected").val(),
                pAgent: $("#<%=ddlPayoutPatner.ClientID%> option:selected").val(),
                paymentMode: $("#<%=ddlPaymentMode.ClientID%> option:selected").val()
            };
            $.post("", data, function (response) {
                PopulateDDL(response, '<%=DDLBankLocation.ClientID%>', "", "", "");
            }).fail(function (error) {
                alert("Something went wrong!!!");
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:UpdatePanel ID="up1" runat="server">
        <ContentTemplate>
            <div class="hidden">
                <asp:HiddenField ID="hideCustomerId" runat="server" />
            </div>
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <h1></h1>
                            <ol class="breadcrumb">
                                <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="#">Registration </a></li>
                                <li><a href="#">Add Beneficiary </a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="#">Add Beneficiary</a></li>
                    </ul>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Add Beneficiary of :
                            <label runat="server" id="customerName"></label>
                                    (<label runat="server" id="txtMembershipId"></label>
                                    )</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div id="displayOnlyOnEdit" runat="server">
                                    <div class="col-sm-3 col-xs-12">
                                        <label class="control-label">Search By</label>
                                        <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-3 col-xs-12">
                                        <div class="form-group">
                                            <label>Choose Customer :<span class="errormsg">*</span></label>
                                            <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="report-tab" id="regUp" runat="server">
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane" id="List">
                        </div>
                        <div role="tabpanel" id="Manage">
                            <div class="row">
                                <div class="col-sm-12 col-md-12">
                                    <div class="register-form">
                                        <div class="panel panel-default clearfix m-b-20">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Receiver Details </h4>
                                            </div>
                                            <div class="panel-body">
                                                <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                    <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                </div>
                                                <%--body part--%>
                                                <asp:HiddenField ID="HiddenField1" runat="server" />
                                                <asp:HiddenField ID="hideBenificialId" runat="server" />
                                                <asp:HiddenField ID="hideMembershipId" runat="server" />
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>Country:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList ID="ddlCountry" onChange="ddlCountryChange()" CssClass="form-control required" runat="server">
                                                            <asp:ListItem Text="Select.."></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>Beneficiary Type:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList ID="ddlBenificiaryType" CssClass="form-control required" disabled="disabled" runat="server">
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
                                                        <label>Last Name:</label>
                                                        <asp:TextBox runat="server" ID="txtReceiverLName" CssClass="form-control" placeholder="Receiver Last Name"></asp:TextBox>
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
                                                        <asp:TextBox runat="server" ID="txtContactNo" onchange="CheckForPhoneNumber(this,'Contact No.')" CssClass="form-control" placeholder="Receiver Contact No" MaxLength="13"></asp:TextBox>
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
                                                        <label>Id Type:</label>
                                                        <asp:DropDownList ID="ddlIdType" CssClass="form-control" runat="server">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>Id Number:</label></label>
                                                    <div class="form-group">
                                                        <asp:TextBox runat="server" ID="txtIdValue" CssClass="form-control" placeholder="Any Photo Id"></asp:TextBox>
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
                                                        <label>Agent/Bank:</label>
                                                        <asp:DropDownList ID="ddlPayoutPatner" onchange="PopulateLocation()" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-4" hidden="hidden">
                                                    <div class="form-group">
                                                        <label>Agent/Bank:<span><i>Type if Not Found</i></span></label>
                                                        <asp:TextBox ID="txtBankName" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-md-4 showOnBankMethod" id="receiverAccountNo" runat="server">
                                                    <div class="form-group">
                                                        <label>Beneficiary A/c #:</label>
                                                        <asp:TextBox ID="txtBenificaryAc" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-md-4" id="agentBankBranchDiv" style="display: none">
                                                    <div class="form-group">
                                                        <label>Agnet/Bank Branch</label>
                                                        <asp:DropDownList ID="DDLBankLocation" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>
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
                                                        <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" />
                                                        <%--<asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" />--%>
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
</asp:Content>