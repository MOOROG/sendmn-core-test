<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="SendV2.aspx.cs" Inherits="Swift.web.AgentNew.AgentSend.SendV2" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .error {
            color: red;
            float: right;
            margin-bottom: 0;
        }

        input, textarea {
            text-transform: uppercase;
        }

        .text-amount {
            font-family: Verdana;
            font-size: 13px;
            text-align: right;
            font-weight: bold;
        }

        .input-group-addon {
            padding: 4px 12px !important;
            font-weight: 600 !important;
        }

        .input-group .form-control:first-child {
            font-weight: 600 !important;
        }

        .amountDiv {
            background: none repeat scroll 0 0 black;
            clear: both;
            color: white;
            float: right;
            font-size: 12px;
            font-weight: 600;
            padding: 2px 8px;
            margin-right: 15px;
            margin-bottom: 0px;
            width: auto;
        }

        .amount_data {
            margin-right: 0PX;
        }

        .wizard .tab-pane {
            margin-top: 35px !important;
        }

        .ErrMsg {
            color: red !important;
        }

        td:empty:after {
            content: "\00a0";
        }

        .form-group {
            position: relative;
        }

            .form-group label.error {
                position: absolute;
                right: 15px;
                font-weight: 300;
            }

        .complete .form-group {
            margin-bottom: 0px !important;
        }

            .complete .form-group label {
                font-weight: 400;
            }

        .wizard {
            margin: 30px auto !important;
        }
    </style>

    <!-- #region Document Ready -->
    <script type="text/javascript">
        function GetCustomerSearchType() {
            return $('#<%=ddlCustomerType.ClientID%>').val();
        }
        $(document).ready(function () {
            scroll(0, 0);
            $('#divHideShow').show();
            $('#divHideShow').show();
            $('#subLocation').hide();
            $('#divBankBranch').hide();
            $('.displayPayerInfo').hide();
            $('#availableBalSpan').hide();
            $('#<%=ddlRecIdType_err.ClientID%>').hide();
            $('#<%=txtRecIdNo_err.ClientID%>').hide();
            $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
            var customerIdFromMapping = '<%=GetCustomerId()%>';
            if (customerIdFromMapping !== null && customerIdFromMapping !== '') {
                ExistingData();
                PopulateReceiverDDL(customerIdFromMapping);
                SearchCustomerDetails(customerIdFromMapping, 'mapping');
            }
            $('.trScheme').hide();

            $("#lblServiceChargeAmt").attr("readonly", true);
            $("#ddlCustomerType").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
            });

            $('txtpBranch_aText').attr("readonly", true);

            $("#<%=txtCollAmt.ClientID%>").blur(function () {
                CollAmtOnChange();
            });

            $("#<%=txtPayAmt.ClientID%>").blur(function () {
                checkdata($("#<%=txtPayAmt.ClientID%>").val(), 'pAmt');
            });

            $('#<%=ddlCustomerType.ClientID%>').change(function () {
                <% = txtSearchData.InitFunction() %>
            });

            $('#btnDepositDetail').click(function () {
                var collAmt = PopUpWindow("CollectionDetail.aspx", "");
                if (collAmt == "undefined" || collAmt == null || collAmt == "") {
                    collAmt = $('#<%=txtCollAmt.ClientID%>').text();
                }
                else {
                    if ((collAmt) > 0) {
                        SetValueById("<%=txtCollAmt.ClientID %>", collAmt, "");
                        $('#<%=txtCollAmt.ClientID%>').attr("readonly", true);
                        $('#<%=txtPayAmt.ClientID%>').attr("readonly", true);
                    }
                    else {
                        SetValueById("<%=txtCollAmt.ClientID %>", "", "");
                        SetValueById("<%=txtPayAmt.ClientID %>", "", "");
                        $('#<%=txtCollAmt.ClientID%>').attr("readonly", false);
                        $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
                    }
                    CalculateTxn(collAmt);
                }
            });

            $("#<%=ddSenIdType.ClientID%>").change(function () {
                ManageSendIdValidity();
            });

            $("#<%=locationDDL.ClientID%>").change(function () {
                LoadSublocation();
            });

            $("#<%=pCountry.ClientID%>").change(function () {
                ResetAmountFields();
                ClearCalculatedAmount();
                $("#<%=pMode.ClientID %>").empty();
                $("#<%=pAgent.ClientID %>").empty();
                $("#<%=pCurrDdl.ClientID %>").empty();
                $("#branch").empty();
                $('#<%=branch.ClientID%>').removeClass('required');
                $("#<%=locationDDL.ClientID %>").empty();
                $("#<%=subLocationDDL.ClientID %>").empty();
                $('#divBankBranch').hide();
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                $("#<%=txtRecDepAcNo.ClientID%>").val('');
                $("#<%=lblExCurr.ClientID%>").text('');
                $("#<%=lblPayCurr.ClientID%>").text('');
                $('#<%=lblPerTxnLimit.ClientID%>').text('0.00');
                $('#spnPayoutLimitInfo').html('');
                var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
                var pmode = $("#<%=pMode.ClientID%>").val();
                if ($("#<%=pCountry.ClientID%> option:selected ").val() != "") {
                    PcountryOnChange('c', "");
                    SetPayCurrency($("#<%=pCountry.ClientID%>").val());
                    ManageLocationData();
                }
                HideShowFieldsOnTxnTab();
            });

            $("#<%=pMode.ClientID%>").change(function () {
                ManageHiddenFields();
                ClearCalculatedAmount();
                $('.displayPayerInfo').hide();
                $("#<%=txtRecDepAcNo.ClientID%>").val('');
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                ReceivingModeOnChange();
                GetPayoutPartner();
                HideShowFieldsOnTxnTab();
            });

            $('.collMode-chk').click(function () {
                $('#availableBalSpan').hide();
                if (!$(this).is(':checked')) {
                    return false;
                }
                if ($(this).val() == 'Bank Deposit') {
                    var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
                    if (customerId == "" || customerId == null || customerId == undefined) {
                        alert('Please Choose Existing Sender for Coll Mode: Bank Deposit');
                        return false;
                    }
                    $('.deposited-bank').css('display', '');
                    $('.deposited-bank-hide').hide();
                    CheckAvailableBalance($(this).val());
                }
                else {
                    $('.deposited-bank').css('display', 'none');
                    $('.deposited-bank-hide').show();
                }
                $('.collMode-chk').not(this).prop('checked', false);
            });
        });

        ShowCalDefault("#<% =txtSendIdValidDate.ClientID%>");
        CalIDIssueDate("#<% =txtSendIdExpireDate.ClientID%>");
        CalSenderDOB("#<% =txtSendDOB.ClientID%>");

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            SetItem("<% =txtSearchData.ClientID%>", d);
            PopulateReceiverDDL(GetItem("<%=txtSearchData.ClientID %>")[0]);
            SearchCustomerDetails(GetItem("<%=txtSearchData.ClientID %>")[0]);
            ClearReceiverData();
            DisabledAllTabs();
        }

        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });

        $(document).on('click', '#btnCalcClean', function () {
            ClearTxnData();
            ClearCalculatedAmount();
            $('#<%=pCurrDdl.ClientID%>').empty();
        });

        $(document).on('click', '#btnReceiverClr', function () {
            $('.readonlyOnReceiverSelect').removeAttr("disabled");
            ClearReceiverData();
        });

        $(document).unbind('keydown').bind('keydown', function (event) {
            var doPrevent = false;
            if (event.keyCode === 8) {
                var d = event.srcElement || event.target;
                if ((d.tagName.toUpperCase() === 'INPUT' && (d.type.toUpperCase() === 'TEXT' || d.type.toUpperCase() === 'PASSWORD'))
                    || d.tagName.toUpperCase() === 'TEXTAREA') {
                    doPrevent = d.readOnly || d.disabled;
                }
                else {
                    doPrevent = true;
                }
            }

            if (doPrevent) {
                event.preventDefault();
                if (confirm("You have pressed back button. Are you sure you want to leave this page?")) {
                    window.history.back();
                }
            }
        });
        $(document).on('blur', '#<%=txtSendDOB.ClientID%>', function () {
            var CustomerDob = GetValue("<%=txtSendDOB.ClientID %>");
            if (CustomerDob != "") {
                var CustYears = datediff(CustomerDob, 'years');

                if (parseInt(CustYears) < 18) {
                    alert('Customer age must be 18 or above !');
                    return;
                }
            }
        });

        $(document).on('change', '#<%=ddlRecIdType.ClientID%>', function () {
            $('#<%=txtRecIdNo.ClientID%>').val('');
            var idType = $("#<%=ddlRecIdType.ClientID%> option:selected").text();
            var idTypeVal = $("#<%=ddlRecIdType.ClientID%> option:selected").val();
            $('#<%=txtRecIdNo.ClientID%>').attr('disabled', 'disabled').removeClass('required').removeAttr('style');
            $('#<%=txtRecIdNo_err.ClientID%>').hide();
            if (idTypeVal !== "" && idTypeVal !== null && idTypeVal !== "0") {
                $('#<%=txtRecIdNo.ClientID%>').removeAttr('disabled').addClass('required');
                $('#<%=txtRecIdNo_err.ClientID%>').show();
            }

            if (idType == "Alien Registration Card") {
                $(".recIdDateValidate").css("display", "");
            }
            else {
                $(".recIdDateValidate").css("display", "none");
            }
        });

        $(document).on('change', '#<%= pAgent.ClientID %>', function () {
            var bankId = $("#<%= pAgent.ClientID %> option:selected").val();
            if (bankId === "" || bankId === null) {
                return;
            }
            var pmode = $("#<%=pMode.ClientID%>").val();
            var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
            $('#divBankBranch').hide();
            $('#<%=branch.ClientID%>').removeClass('required');
            $('.displayPayerInfo').hide();
            PopulateBankDetails(bankId, pmode);
            if (partnerId === apiPartnerIds[0] || pmode === "2") {
                if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                    $('#agentBranchRequired').hide();
                }
                $('#divBankBranch').show();
                if ((partnerId === apiPartnerIds[0]) && pmode === "2" && (bankId != "0" && bankId != null && bankId != "")) {
                    LoadPayerData();
                }
            }
        });

        $(document).on('change', '#<%=ddlPayer.ClientID%>', function () {
            var payerId = $(this).val();
            var cityId = $("#<%=subLocationDDL.ClientID%>").val();
            if (payerId !== "" && payerId !== null) {
                var partnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
                var dataToSend = { MethodName: 'getPayerBranchDataByPayerAndCityId', payerId: payerId, partnerId: partnerId, CityId: cityId };
                $.post("", dataToSend, function (response) {
                    $("#myModal1").modal('show');
                    var data = jQuery.parseJSON(response);
                    CreateDDLFromData(data, "<%=ddlPayerBranch.ClientID%>");
                });
            }
        });

        $(document).on('change', '#<%=ddlPayerBranch.ClientID%>', function () {
            payerBranchId = $(this).val();
            if (payerBranchId === null || payerBranchId === "") {
                return alert("Please Select Payer Branch Information");
            }
            payerText = $('#<%=ddlPayer.ClientID%> option:selected').text();
            payerBranchText = $('#<%=ddlPayerBranch.ClientID%> option:selected').text();
            $("#<%=payerText.ClientID%>").text(payerText);
            $("#<%=payerBranchText.ClientID%>").text(payerBranchText);
            $('.displayPayerInfo').show();
            $("#myModal1").modal('hide');
        });
        $(document).on('change', "#ContentPlaceHolder1_txtSearchData_aSearch", function () {
            var value = $(this).val();
            if (value === null || value === "") {
                ClearAllCustomerInfo();
            }
        });
    </script>
    <!-- #endregion -->
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row" style="display: none;">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <asp:HiddenField ID="hideCustomerId" runat="server" />
                    <ol class="breadcrumb">
                        <li><a href="/AgentNew/Dashboard.aspx"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Transaction </a></li>
                        <li><a href="#">Send Transaction</a></li>
                        <span style="float: right;">
                            <div class="row" style="float: right;">
                                <div class="amountDiv">
                                    Limit :&nbsp;
                                <asp:Label ID="availableAmt" runat="server"></asp:Label>
                                    <asp:Label ID="balCurrency" runat="server" Text="<%$ AppSettings: currencyUSA %>"></asp:Label>
                                </div>
                            </div>
                        </span>
                    </ol>
                </div>
            </div>
        </div>
        <div class="col-md-12">
            <div class="amount_data amountDiv">
                <span>Available Limit: <span id="availableAmountDetails" runat="server"></span></span>
            </div>
        </div>
        <div id="divLoad" style="position: absolute; left: 450px; top: 250px; background-color: black; border: 1px solid black; display: none;">
            Processing...
        </div>

        <section>
            <asp:HiddenField ID="hdnOfacRes" runat="server" />
            <asp:HiddenField ID="hdnOfacReason" runat="server" />
            <input type="hidden" id="hdnPayMode" runat="server" />
            <input type="hidden" id="hdntranCount" runat="server" />
            <asp:HiddenField ID="hdnLimitAmount" runat="server" />
            <asp:HiddenField ID="hdnAgentRefId" runat="server" />
            <asp:HiddenField ID="hdnBeneficiaryIdReq" runat="server" />
            <asp:HiddenField ID="hdnBeneficiaryContactReq" runat="server" />
            <asp:HiddenField ID="hdnRelationshipReq" runat="server" />
            <input type="hidden" id="confirmHidden" />
            <input type="hidden" id="confirmHiddenChrome" />
            <asp:HiddenField ID="hddPayoutPartner" runat="server" />
            <asp:HiddenField ID="hddTPExRate" runat="server" />
            <asp:HiddenField ID="hddImgURL" runat="server" />
            <asp:HiddenField ID="isDisplaySignature" runat="server" />
            <input type="hidden" id="scDiscount" name="scDiscount" />
            <input type="hidden" id="exRateOffer" value="exRateOffer" />

            <div class="wizard" id="divStep1">
                <div class="wizard-inner">
                    <div class="connecting-line"></div>
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active" id="tab1">
                            <a href="#step1" data-toggle="tab" aria-controls="step1" id="firstTab" role="tab" title="Sender Information">
                                <span class="round-tab">
                                    <i class="fa fa-user" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>
                        <li role="presentation" class="disabled disableThisOnClearData" id="tab2">
                            <a href="#step2" data-toggle="tab" aria-controls="step2" role="tab" class="otherTab" title="Receiver Information">
                                <span class="round-tab">
                                    <i class="fa fa-user" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>
                        <li role="presentation" class="disabled disableThisOnClearData" id="tab3">
                            <a href="#step3" data-toggle="tab" aria-controls="step3" role="tab" class="otherTab" title="Transaction Information">
                                <span class="round-tab">
                                    <i class="fa fa-file-text-o" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>
                        <li role="presentation" class="disabled disableThisOnClearData" id="tab4">
                            <a href="#step4" data-toggle="tab" aria-controls="step4" role="tab" class="otherTab" title="Customer Due Diligence Information -(CDDI)">
                                <span class="round-tab">
                                    <i class="fa fa-check" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>

                        <li role="presentation" class="disabled disableThisOnClearData" id="tab5">
                            <a href="#ContentPlaceHolder1_complete" data-toggle="tab" aria-controls="complete" role="tab" class="otherTab" title="Sending Money Information">
                                <span class="round-tab">
                                    <i class="fa fa-check" aria-hidden="true"></i>
                                </span>
                            </a>
                        </li>
                    </ul>
                </div>

                <div class="tab-content">

                    <div class="tab-pane active" role="tabpanel" id="step1">
                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-4 form-group">
                                        <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control disableOnValidFirstTab" Style="margin-bottom: 5px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-4 form-group">
                                        <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" CssClass="form-control disableOnValidFirstTab" Param1="@GetCustomerSearchType()" Title="Blank for All" />
                                    </div>
                                    <div class="col-md-4 form-group">
                                        <%--<input name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" class="btn btn-primary disableOnValidFirstTab" value="Advance Search" style="margin-bottom: 2px;" />--%>
                                        <input name="button4" type="button" id="btnClear" value="Clear" class="btn btn-clear" onclick="ClearAllCustomerInfo();" style="margin-bottom: 2px;" />
                                    </div>
                                    <div class="col-md-2" style="display: none;">
                                        <span>Country: </span>
                                        <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <h3>Sender Information</h3>
                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-sm-4 form-group showOnIndividual">
                                        <label for="ContentPlaceHolder1_txtSendFirstName">First Name <span class="ErrMsg" id='txtSendFirstName_err'>*</span></label>
                                        <asp:TextBox ID="txtSendFirstName" placeholder="First Name" runat="server" CssClass="required SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this,'Sender First Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual">
                                        <label for="ContentPlaceHolder1_txtSendMidName">Middle Name</label>
                                        <asp:TextBox ID="txtSendMidName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Middle Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual">
                                        <label for="ContentPlaceHolder1_txtSendLastName">Last Name</label>
                                        <asp:TextBox ID="txtSendLastName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Last Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="ContentPlaceHolder1_txtSendEmail">
                                            Email<asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                ControlToValidate="txtSendEmail"></asp:RegularExpressionValidator></label>
                                        <asp:TextBox ID="txtSendEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control readonlyOnCustomerSelect"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="ContentPlaceHolder1_ddlSendCustomerType">Customer Type</label>
                                        <asp:DropDownList ID="ddlSendCustomerType" runat="server" onchange="ChangeCustomerType()" CssClass="SmallTextBox form-control readonlyOnCustomerSelect">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="txtSendPostal">Zip Code:<span class="ErrMsg" id=''>*</span></label>
                                        <asp:TextBox ID="txtSendPostal" runat="server" placeholder="Postal Code" CssClass="form-control required readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Postal Code');"></asp:TextBox>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="custLocationDDL">State:<span class="ErrMsg">*</span></label>
                                        <asp:DropDownList ID="custLocationDDL" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="sCustStreet">Street:<span runat="server" class="ErrMsg" id='sCustStreet_err'>*</span></label>
                                        <asp:TextBox ID="sCustStreet" runat="server" placeholder="Street" CssClass="required SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Street Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group" id="tdSenCityLbl" runat="server">
                                        <label for="txtSendCity" runat="server" id="lblsCity">
                                            City<span runat="server" class="ErrMsg" id='txtSendCity_err'>*</span></label>
                                        <asp:TextBox ID="txtSendCity" runat="server" placeholder="City" CssClass="required form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender City');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group hideOnIndividual">
                                        <label for="companyName">
                                            Company Name<span runat="server" class="ErrMsg" id='companyName_err'>*</span></label>
                                        <asp:TextBox ID="companyName" runat="server" placeholder="Company Name" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Company Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group hideOnIndividual">
                                        <label for="exampleInputEmail1">
                                            Business Type<span runat="server" class="ErrMsg" id='Span2'>*</span></label>
                                        <asp:DropDownList ID="ddlEmpBusinessType" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Mobile No<span runat="server" class="ErrMsg" id='txtSendMobile_err'>*</span></label>
                                        <asp:TextBox ID="txtSendMobile" runat="server" placeholder="Mobile Number" CssClass="required form-control readonlyOnCustomerSelect" MaxLength="16" onchange="CheckForMobileNumber(this, 'Receiver Mobile No.');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="txtSendTel">Sender Phone</label>
                                        <asp:TextBox ID="txtSendTel" runat="server" placeholder="Phone Number" CssClass="form-control readonlyOnCustomerSelect" onchange="CheckForPhoneNumber(this,'Sender Phone No.');" MaxLength="15"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Native Country<span class="ErrMsg" id='txtSendNativeCountry_err'>*</span></label>
                                        <asp:DropDownList ID="txtSendNativeCountry" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual" id="trOccupation" runat="server">
                                        <label for="exampleInputEmail1">
                                            Occupation<span runat="server" class="ErrMsg" id='occupation_err'>*</span></label>
                                        <asp:DropDownList ID="occupation" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual" id="trSalaryRange" runat="server">
                                        <label for="exampleInputEmail1">
                                            Monthly Income<%--<span runat="server" id="ddlSalary_err" class="ErrMsg">*</span>--%></label>
                                        <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control readonlyOnCustomerSelect">
                                            <asp:ListItem Value="">Select</asp:ListItem>
                                            <asp:ListItem>JPY0 - JPY1,700,000</asp:ListItem>
                                            <asp:ListItem>JPY1,700,000 - JPY3,400,000</asp:ListItem>
                                            <asp:ListItem>JPY3,400,000 - JPY6,800,000</asp:ListItem>
                                            <asp:ListItem>JPY6,800,000 - JPY13,000,000</asp:ListItem>
                                            <asp:ListItem>Above JPY13,000,000</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual">
                                        <label for="exampleInputEmail1">Gender</label>
                                        <asp:DropDownList ID="ddlSenGender" runat="server" CssClass="form-control readonlyOnCustomerSelect">
                                            <asp:ListItem Value="">Select</asp:ListItem>
                                            <asp:ListItem Value="Male">Male</asp:ListItem>
                                            <asp:ListItem Value="Female">Female</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group showOnIndividual">
                                        <label for="exampleInputEmail1">
                                            Date Of Birth<span runat="server" class="ErrMsg" id='txtSendDOB_err'>*</span></label>
                                        <asp:TextBox ID="txtSendDOB" runat="server" ReadOnly="true" CssClass="form-control readonlyOnCustomerSelect" placeholder="YYYY/MM/DD"></asp:TextBox>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Issued Date<span runat="server" class="ErrMsg" id="Span1">*</span></label>
                                        <asp:TextBox ID="txtSendIdExpireDate" onchange="return DateValidation('txtSendIdExpireDate','i')" MaxLength="10" runat="server" placeholder="YYYY/MM/DD" CssClass="required form-control readonlyOnCustomerSelect"></asp:TextBox>
                                        <asp:RangeValidator ID="RangeValidator3" runat="server"
                                            ControlToValidate="txtSendIdExpireDate"
                                            MaximumValue="12/31/2100"
                                            MinimumValue="01/01/1900"
                                            Type="Date"
                                            ForeColor="Red"
                                            ErrorMessage="Invalid date!"
                                            ValidationGroup="customer"
                                            CssClass="inv"
                                            SetFocusOnError="true"
                                            Display="Dynamic"> </asp:RangeValidator>
                                    </div>
                                    <div class="col-sm-4 form-group" id="tdSenExpDateLbl" runat="server">
                                        <label for="exampleInputEmail1">
                                            Expire Date<span runat="server" class="ErrMsg" id='txtSendIdValidDate_err'>*</span></label>
                                        <asp:TextBox ID="txtSendIdValidDate" onchange="return DateValidation('txtSendIdValidDate')" MaxLength="10" runat="server" placeholder="YYYY/MM/DD" CssClass="required form-control readonlyOnCustomerSelect"></asp:TextBox>
                                        <asp:RangeValidator ID="RangeValidator2" runat="server"
                                            ControlToValidate="txtSendIdValidDate"
                                            MaximumValue="12/31/2100"
                                            MinimumValue="01/01/1900"
                                            Type="Date"
                                            ForeColor="Red"
                                            ErrorMessage="Invalid date!"
                                            ValidationGroup="customer"
                                            CssClass="inv"
                                            SetFocusOnError="true"
                                            Display="Dynamic"> </asp:RangeValidator>
                                    </div>
                                    <div class="col-sm-4 form-group" id="trSenId" runat="server" valign="bottom">
                                        <label for="ddSenIdType" runat="server" id="Label1">
                                            ID Type<span runat="server" class="ErrMsg" id='ddSenIdType_err'>*</span></label>
                                        <asp:DropDownList ID="ddSenIdType" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="companyName">
                                            ID Number<span runat="server" class="ErrMsg" id='txtSendIdNo_err'>*</span></label>
                                        <asp:TextBox ID="txtSendIdNo" placeholder="ID Number" MaxLength="14" runat="server" CssClass="form-control required" onblur="CheckSenderIdNumber(this);" Style="width: 100%;"></asp:TextBox>
                                    </div>
                                    <div style="display:none" class="col-sm-4 form-group hideOnIndividual">
                                        <label for="exampleInputEmail1">
                                            Place Of Issue</label>
                                        <asp:DropDownList ID="ddlIdIssuedCountry" runat="server" CssClass="form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="senderDetails" class="btn btn-primary next-step" data-i="1">Save and continue</button>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-pane" role="tabpanel" id="step2">
                        <h3>Receiver Information</h3>
                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Choose Receiver</label>
                                        <asp:DropDownList ID="ddlReceiver" runat="server" onchange="DDLReceiverOnChange();" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">First Name<span class="ErrMsg" id='txtRecFName_err'>*</span></label>
                                        <asp:TextBox ID="txtRecFName" runat="server" placeholder="First Name" CssClass="required SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver First Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Middle Name</label>
                                        <asp:TextBox ID="txtRecMName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver Middle Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Last Name</label>
                                        <asp:TextBox ID="txtRecLName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver Last Name');"></asp:TextBox>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Address<span runat="server" class="ErrMsg" id='txtRecAdd1_err'>*</span></label>
                                        <asp:TextBox ID="txtRecAdd1" runat="server" placeholder="Receiver Address" CssClass="required form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group" id="trRecContactNo" runat="server">
                                        <label for="exampleInputEmail1">
                                            Mobile No. <span runat="server" class="ErrMsg" id='txtRecMobile_err'>*</span></label>
                                        <asp:TextBox ID="txtRecMobile" runat="server" MaxLength="16" placeholder="Mobile Number" CssClass="required form-control" onchange="CheckForMobileNumber(this, 'Receiver Mobile No.');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group" id="Div1" runat="server">
                                        <label for="exampleInputEmail1">Phone No.</label>
                                        <asp:TextBox ID="txtRecTel" runat="server" placeholder="Phone Number" CssClass="form-control readonlyOnReceiverSelect" MaxLength="15" onchange="CheckForPhoneNumber(this, 'Receiver Tel. No.');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group trRecId" id="trRecId" runat="server">
                                        <label for="ddlRecIdType">
                                            ID Type <span runat="server" class="ErrMsg" id='ddlRecIdType_err'>*</span></label>
                                        <asp:DropDownList ID="ddlRecIdType" runat="server" CssClass="form-control readonlyOnReceiverSelect"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group trRecId" id="trRecId1" runat="server">
                                        <label for="exampleInputEmail1">
                                            ID No.<span runat="server" class="ErrMsg" id='txtRecIdNo_err'>*</span></label>
                                        <asp:TextBox ID="txtRecIdNo" runat="server" placeholder="ID Number" CssClass="form-control readonlyOnReceiverSelect" disabled="disabled" onblur="CheckForSpecialCharacter(this, 'Receiver ID Number');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group" style="display: none">
                                        <label for="exampleInputEmail1">Gender</label>
                                        <asp:DropDownList ID="ddlRecGender" runat="server" CssClass="form-control readonlyOnReceiverSelect">
                                            <asp:ListItem Value="">SELECT</asp:ListItem>
                                            <asp:ListItem Value="Male">Male</asp:ListItem>
                                            <asp:ListItem Value="Female">Female</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group" id="tdRecCityLbl" runat="server" hidden>
                                        <label for="ddlRecIdType">
                                            City <span runat="server" class="ErrMsg" id='txtRecCity_err'>*</span></label>
                                        <asp:TextBox ID="txtRecCity" placeholder="Receiver City" runat="server" CssClass="form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver City');"></asp:TextBox>
                                    </div>
                                    <%--<div class="col-sm-4 form-group" id="tdRecDobLbl" runat="server" hidden>
                                        <label for="exampleInputEmail1">
                                            DOB <span runat="server" class="ErrMsg" id='txtRecDOB_err'>*</span></label>
                                        <asp:TextBox ID="txtRecDOB" runat="server" CssClass="form-control" ReadOnly="true" placeholder="YYYY/MM/DD"></asp:TextBox>
                                    </div>--%>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Email
                                        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                            ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                            ControlToValidate="txtRecEmail"></asp:RegularExpressionValidator></label>
                                        <asp:TextBox ID="txtRecEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control readonlyOnReceiverSelect"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="" class="btn btn-default prev-step">Previous</button>
                            </li>
                            <li>
                                <button id="receiverDetails" type="button" class="btn btn-primary next-step" data-i="2">Save and continue</button>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-pane" role="tabpanel" id="step3">
                        <h3>Transaction Information</h3>
                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-sm-8 form-group">
                                        <label for="exampleInputEmail1">Collection Mode</label>
                                        <div id="collModeTd" runat="server"></div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Receiving Country <span class="ErrMsg" id="pCountry_err">*</span></label>
                                        <asp:DropDownList ID="pCountry" runat="server" CssClass="required form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Receiving Mode <span class="ErrMsg">*</span></label>
                                        <asp:DropDownList ID="pMode" runat="server" CssClass="required form-control" AutoPostBack="false"></asp:DropDownList>
                                    </div>
                                    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                        <ContentTemplate>
                                            <div class="col-sm-4 form-group">
                                                <label for="exampleInputEmail1">Agent/Bank <span class="ErrMsg" id="pAgent_err">*</span></label>
                                                <asp:DropDownList ID="pAgent" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                <asp:DropDownList ID="pAgentDetail" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                                <asp:DropDownList ID="pAgentMaxPayoutLimit" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                                <span id="hdnreqAgent" style="display: none"></span>
                                                <input type="hidden" id="hdnBankType" />
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>

                                    <div class="col-sm-4 form-group" id="divBankBranch">
                                        <label for="branch">Branch <span class="ErrMsg">*</span></label>
                                        <div id="ddlAgentBranch">
                                            <select id="branch" runat="server" class="form-control">
                                                <option value="">SELECT BRANCH</option>
                                            </select>
                                        </div>
                                        <input type="hidden" id="txtpBranch_aValue" class="form-control" />
                                        <span id="hdnreqBranch" style="display: none"></span><span class="ErrMsg" id="reqBranch" style="display: none"></span>
                                        <div id="divBranchMsg" style="display: none;" class="note"></div>
                                    </div>
                                    <div class="col-sm-4 form-group" id="trAccno" style="display: none;">
                                        <label for="exampleInputEmail1">Bank Account No <span id="txtRecDepAcNo_err" class="ErrMsg">*</span></label>
                                        <asp:TextBox ID="txtRecDepAcNo" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Acc No.');"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Payout Currency <span class="ErrMsg">*</span></label>
                                        <select id="pCurrDdl" runat="server" class="required form-control" onchange="CalculateTxn();"></select>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">State <span class="ErrMsg">*</span></label>
                                        <asp:DropDownList ID="locationDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>

                                    <div class="col-sm-4 form-group" id="subLocation">
                                        <label for="exampleInputEmail1">City <span class="ErrMsg">*</span></label>
                                        <asp:DropDownList ID="subLocationDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>

                                    <div class="col-sm-4 form-group" hidden>
                                        <label for="exampleInputEmail1">Introducer (If Any)</label>
                                        <asp:TextBox runat="server" CssClass="form-control" ID="introducerTxt" placeholder="Introducer (If Any)"></asp:TextBox>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Collection Amount <span class="ErrMsg" id='txtCollAmt_err'>*</span></label>
                                        <div class="input-group m-b">
                                            <asp:TextBox ID="txtCollAmt" runat="server" CssClass="required BigAmountField form-control" Style="font-size: 16px; font-weight: bold; padding: 2px;"></asp:TextBox>
                                            <span class="input-group-addon">
                                                <asp:Label ID="lblCollCurr" runat="server"  class="amountLabel" Style="display: none"><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyJP","") %></asp:Label>
                                                (Max Limit: <u><b>
                                                    <asp:Label ID="lblPerTxnLimit" runat="server" Text="0.00"></asp:Label></b></u>)&nbsp;
                                                <asp:Label ID="lblPerTxnLimitCurr" runat="server"><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyJP","") %></asp:Label>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Sending Amount</label><br />
                                        <div class="input-group m-b">
                                            <asp:TextBox ID="lblSendAmt" runat="server" Text="0.00" class="amountLabel form-control disabled" disabled="disabled"></asp:TextBox>
                                            <span class="input-group-addon">
                                                <asp:Label ID="lblSendCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Service Charge:&nbsp;
                                        </label>
                                        <div class="input-group m-b">
                                            <asp:TextBox ID="lblServiceChargeAmt" runat="server" Text="0" class="form-control" onblur="return ReCalculate();"></asp:TextBox>
                                            <span class="input-group-addon">
                                                <asp:Label ID="lblServiceChargeCurr" runat="server" class="amountLabel"><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyJP","") %></asp:Label>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Payout Amount <span class="ErrMsg">*</span></label>
                                        <div class="input-group m-b">
                                            <asp:TextBox ID="txtPayAmt" runat="server" Enabled="false" CssClass="required BigAmountField disabled form-control"></asp:TextBox>
                                            <span class="input-group-addon">
                                                <asp:Label ID="lblPayCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                                <i class="fa fa-refresh btn btn-sm btn-primary" onclick="ChangeCalcBy()"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">Customer Rate</label>
                                        <div class="input-group m-b">
                                            <asp:TextBox ID="lblExRate" runat="server" Text="0.00" class="amountLabel form-control disabled" disabled="disabled"></asp:TextBox>
                                            <span class="input-group-addon">
                                                <asp:Label ID="lblExCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="col-md-12 displayPayerInfo">
                                        <div class="col-md-6">
                                            <div class="col-sm-2">
                                                <label for="payerText">Payer :</label>
                                            </div>
                                            <div class="col-sm-10">
                                                <b><span runat="server" id="payerText"></span></b>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="col-sm-3">
                                                <label for="payerBranchText">Payer Branch :</label>
                                            </div>
                                            <div class="col-sm-9">
                                                <b><span runat="server" id="payerBranchText"></span></b>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-12">
                                        <span id="spnWarningMsg" style="font-size: 13px; font-family: Verdana; font-weight: bold; color: Red;"></span>
                                    </div>
                                    <div class="col-md-12">
                                        <input type="button" id="btnCalcClean" value="Clear" class="btn btn-primary" />
                                        <input type="hidden" id="finalAgentId" />
                                        <span id="finalSenderId" style="display: none"></span>
                                        <input type="hidden" id="txtCustomerLimit" runat="server" value="0" />
                                        <asp:HiddenField ID="txnPerDayCustomerLimit" runat="server" Value="0" />
                                        <input type="hidden" id="hdnInvoicePrintMethod" />
                                    </div>
                                    <div class="col-md-12" align="center" style="display: none">
                                        <span id="span_txnInfo" align="center" runat="server" style="font-size: 15px; color: #FFFFFF; background-color: #333333; line-height: 15px; vertical-align: middle; text-align: center; font-weight: bold;"></span>
                                    </div>
                                    <div class="col-md-12" style="display: none">
                                        <span id="spnPayoutLimitInfo" style="color: red; font-size: 16px; font-weight: bold;"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="backToReceiver" class="btn btn-default prev-step">Previous</button>
                            </li>
                            <li>
                                <button type="button" id="txnDetails" class="btn btn-primary btn-info-full next-step" data-i="3">Save and continue</button>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-pane" role="tabpanel" id="step4">
                        <h3>Customer Due Diligence Information -(CDDI)</h3>

                        <div class="panel panel-default" style="margin-top: 10px;">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Purpose of Remittance<span runat="server" class="ErrMsg" id='purpose_err'>*</span>
                                        </label>
                                        <asp:DropDownList ID="purpose" runat="server" CssClass="required form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Relationship with Receiver<span runat="server" class="ErrMsg" id='relationship_err'>*</span>
                                        </label>
                                        <asp:DropDownList ID="relationship" runat="server" CssClass="required form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-sm-4 form-group">
                                        <label for="exampleInputEmail1">
                                            Source of Fund<span runat="server" class="ErrMsg" id='sourceOfFund_err'>*</span>
                                        </label>
                                        <asp:DropDownList ID="sourceOfFund" runat="server" CssClass="required form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <label for="exampleInputEmail1">Message to Receiver</label>
                                        <asp:TextBox ID="txtPayMsg" runat="server" CssClass="LargeTextBox form-control" TextMode="MultiLine" onblur="CheckForSpecialCharacter(this, 'Message to Receiver');"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="backToTxnDetails" class="btn btn-default prev-step">Previous</button>
                            </li>
                            <li>
                                <button type="button" class="btn btn-primary btn-info-full verifyTxn" data-i="4" id="jmeContinueSign">Save and continue</button>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-pane" runat="server" role="tabpanel" id="complete">
                        <h3>Sending Money Information</h3>
                        <div class="panel panel-default" style="margin-top: 10px;">

                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Sender Information</h4>
                                            </div>
                                            <div class="panel-body complete">
                                                <div class="row">
                                                    <div class="col-md-4 form-group">
                                                        <label>Sender's Name:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderName"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Address:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderAddress"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Id Type</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="senderIdType">Id Type:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Id No:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderIdNumber"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>ID Expiry Date:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderIdExpiryDate"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>DOB:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderDob"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>City:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderCity"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Country:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderCountry"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Email:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderEmail"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Contact No:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtSenderContactNo"></label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Receiver Information</h4>
                                            </div>
                                            <div class="panel-body complete">
                                                <div class="row">
                                                    <div class="col-md-4 form-group">
                                                        <label>Receiver's Name:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtReceiverName"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Address:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtReceiverAddress"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Id Type:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="receiverIdType"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Id No:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtReceiverIdNumber"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Purpose of Remittance:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="por"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Relationship:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txnRelationship"></label>
                                                    </div>

                                                    <div class="col-md-4 form-group">
                                                        <label>Email:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtReceiverEmail"></label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label>Contact No:</label>
                                                    </div>
                                                    <div class="col-md-8 form-group">
                                                        <label id="txtReceiverContactNo"></label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Transaction Information</h4>
                                            </div>
                                            <div class="panel-body complete">
                                                <div class="row">
                                                    <div class="col-md-2 form-group">
                                                        <label>Collection Amount:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtCollAmtJpy"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Sent Amount:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtSentAmtJpy"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Service Charge:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtServiceCharge"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Customer Rate:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtCustomerRate"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Payout Amount:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtPayoutRate"></label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Payout Agent/Bank Information</h4>
                                            </div>
                                            <div class="panel-body complete">
                                                <div class="row">
                                                    <div class="col-md-2 form-group">
                                                        <label>Country:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtPCountry"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Mode Of Payment:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtModeOfPayment"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Payout Agent/Location:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtPayoutAgent"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group payout-branch">
                                                        <label>Customer Branch:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group payout-branch">
                                                        <label id="txtCustomerBranch"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>City:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtReceiverCity"></label>
                                                    </div>
                                                    <div class="col-md-2 form-group">
                                                        <label>Country:</label>
                                                    </div>
                                                    <div class="col-md-4 form-group">
                                                        <label id="txtReceiverCountry"></label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12" id="ofacField" style="display: none">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">OFAC Information</h4>
                                            </div>
                                            <div>
                                                <span id="ofacMsg" style="font-size: 13px; font-family: Verdana; font-weight: bold; color: Red;"></span>
                                            </div>
                                            <div class="panel-body">

                                                <div class="row" id="ofacData">
                                                </div>
                                                <div>
                                                    <fieldset runat="server">
                                                        <legend style="background-color: red">Note: If are in compliance then you can not make the transaction !!!
                                                        </legend>
                                                    </fieldset>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12" id="complinceField" style="display: none">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">Complince Information</h4>
                                            </div>
                                            <div class="panel-body">
                                                <div class="row" id="complinceData">
                                                </div>

                                                <fieldset id="Fieldset1" runat="server">
                                                    <legend style="background-color: red">Note: If are in compliance then you can not make the transaction !!!
                                                    </legend>
                                                </fieldset>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-12" id="reConfirmField">
                                        <div class="col-sm-12" hidden>
                                            <div class="form-inline">
                                                <span>Txn. Password:</span> &nbsp; &nbsp;&nbsp;&nbsp;
                                                    <asp:TextBox ID="txnPassword" CssClass="form-control" placeholder="Enter Txn. Password" runat="server" Width="200px" TextMode="Password"></asp:TextBox>
                                                &nbsp;&nbsp;(Note: Please use your login password to confirm the transaction)
                                            </div>
                                        </div>

                                        <div id="EnableDigitalSignature" runat="server">
                                            <div class="form-group">
                                            <div class="col-sm-5" style="display:none">
                                                <label class="control-label">Customer Password:</label>
                                                <div>
                                                    <asp:TextBox TextMode="Password" ID="customerPassword" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                                                </div>
                                            </div>

                                            </div>

                                            <div class="form-group">
                                                <div class="col-sm-5">
                                                <span>Customer Signature:</span>
                                                <div id="signature-pad" class="signature-pad">
                                                    <div class="signature-pad--body">
                                                        <canvas></canvas>
                                                    </div>
                                                    <div class="signature-pad--footer">
                                                        <div class="description">Sign above</div>
                                                        <div class="signature-pad--actions">
                                                            <div>
                                                                <button type="button" class="btn btn-default clear" data-action="clear">Clear</button>
                                                                <button type="button" class="btn btn-default" data-action="undo">Undo</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-sm-12" hidden>
                                            <div class="form-group">
                                                <label>Receipt Print Mode</label>
                                                <asp:RadioButtonList ID="invoicePrintMode" CssClass="form-control" runat="server" RepeatDirection="Horizontal">
                                                    <asp:ListItem Value="s" style="margin-right: 10px">Single </asp:ListItem>
                                                    <asp:ListItem Value="d"> Double</asp:ListItem>
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>
                                        <div class="col-sm-12">
                                            <asp:UpdatePanel ID="updatePnl" runat="server">
                                                <ContentTemplate>
                                                    <div class="table-responsive">
                                                        <table class="table">
                                                            <tr>
                                                                <td>
                                                                    <asp:CheckBox ID="chkCdd" Visible="false" runat="server" Style="font-family: Verdana; font-weight: bold; font-size: 20px; color: red;"
                                                                        Text="We have conducted Due Diligence by filling up CDD (Customer Due Diligence) Form with the customer details." AutoPostBack="true"
                                                                        OnCheckedChanged="chkCdd_CheckedChanged" />
                                                                    <br />

                                                                    <asp:CheckBox ID="chkMultipleTxn" Visible="false" runat="server"
                                                                        Style="font-family: Verdana; font-weight: bold; font-size: 24px; color: Red;"
                                                                        Text="We have verified this sender's previous transaction and want to proceed this transaction."
                                                                        AutoPostBack="true" OnCheckedChanged="chkMultipleTxn_CheckedChanged" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="clearfix"></div>
                        </div>

                        <ul class="list-inline pull-right">
                            <li>
                                <button type="button" id="backToCDDI" class="btn btn-default prev-step">Previous</button>
                            </li>
                            <li>
                                <input type="button" id="sendTran" runat="server" value="Send Txn" class="btn btn-primary btn-info-full" onclick="proceed()" />
                                <%--<asp:Button ty="button" ID="sendTran" runat="server" Text="Send Txn" CssClass="btn btn-primary btn-info-full" OnClientClick="return proceed()" />--%>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="modal fade" id="myModal1" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-header" id="modelUserForSave">
                                    <center> <h2 class="modal-title">Choose Payer Details<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                                </div>
                                <div class="modal-body">
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <label class="control-label">Payer Data :<span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayer" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <label class="control-label">Payer Branch : <span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayerBranch" runat="server" CssClass="form-control"></asp:DropDownList>
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

    <!-- #region Tab View -->
    <script src="../js/SendTxnTab/sendtxn.js" type="text/javascript"></script>
    <script src="../js/SendTxnTab/CustomerSignature.js" type="text/javascript"></script>
    <!-- #endregion -->
    <!-- #region Signature -->

    <!-- #endregion -->

    <!-- #region Auto Complete -->
    <script type="text/javascript">
        function Autocomplete() {
            $(".searchinput").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "../../../Autocomplete.asmx/GetAllCountry",
                        data: "{'keywordStartsWith': '" + request.term + "'}",
                        dataType: "json",
                        async: true,
                        success: function (data) {
                            response(
                                $.map(data.d, function (item) {
                                    return {
                                        value: item.Value,
                                        key: item.Key
                                    };
                                }));
                            window.parent.resizeIframe();
                        },

                        error: function (result) {
                            alert("Due to unexpected errors we were unable to load data");
                        }
                    });
                },

                minLength: 2
            });
        };
        Autocomplete();
    </script>
    <!-- #endregion -->

    <!-- #region Functions -->

    <script type="text/javascript">

        function DisabledAllTabs() {
            $('.disableThisOnClearData').addClass('disabled');
        }

        function HideShowFieldsOnTxnTab() {
            $('#subLocation').show();
            $('#<%=subLocationDDL.ClientID%>').addClass('required');
            $('#<%=locationDDL.ClientID%>').addClass('required');
            var pmode = $("#<%=pMode.ClientID%>").val();
            var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
            if (partnerId === apiPartnerIds[1]) {
                $('#subLocation').hide();
                $('#<%=locationDDL.ClientID%>').removeClass('required');
                $('#<%=subLocationDDL.ClientID%>').removeClass('required');
            }
            if (partnerId === apiPartnerIds[0] || pmode === "2") {
                $('#<%=branch.ClientID%>').addClass('required');
                if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                    $('#agentBranchRequired').hide();
                    $('#<%=branch.ClientID%>').removeClass('required');
                    LoadPayerData();
                }
                $('#divBankBranch').show();
            }
        }

        function CalcOnEnter(e) {
            var evtobj = window.event ? event : e;

            var charCode = e.which || e.keyCode;
            if (charCode == 13) {
                $("#btnCalculate").focus();
            }
        }

        function AddNewReceiver(senderId) {
            url = "" + "/AgentNew/Administration/CustomerSetup/Benificiar/Manage.aspx?customerId=" + senderId + "&AddType=s";
            var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            if (isChrome) {
                PopUpWindow(url, param);
                return true;
            }
            var id = PopUpWindow(url, param);

            if (id == "undefined" || id == null || id == "") {
            }
            else {
                PopulateReceiverDDL(senderId);
                SearchReceiverDetails(id);
            }
        }

        function PostMessageToParentAddReceiver(id) {
            var senderId = $("#ContentPlaceHolder1_txtSearchData_aValue").val();
            PopulateReceiverDDL(senderId);
            SearchReceiverDetails(id);
            SetDDLValueSelected("<%=ddlReceiver.ClientID%>", id);
        }

        function ChangeCalcBy() {
            ClearCalculatedAmount();
            if ($("#<%=txtPayAmt.ClientID%>").is(":disabled")) {
                $('#<%=txtCollAmt.ClientID%>').attr('disabled', true);
                $('#<%=txtPayAmt.ClientID%>').attr('disabled', false);
            } else {
                $('#<%=txtPayAmt.ClientID%>').attr('disabled', true);
                $('#<%=txtCollAmt.ClientID%>').attr('disabled', false);
            }
        }

        function ReCalculate() {
            if (!$("#<%=lblServiceChargeAmt.ClientID%>").attr("readonly")) {
                if (parseFloat($('#<%=lblServiceChargeAmt.ClientID%>').val()) >= 0) {
                    CalculateTxn($("#<%=txtCollAmt.ClientID%>").val(), 'cAmt', 'Y');
                }
                else {
                    alert('Service charge can not be negative!');
                    $('#<%=lblServiceChargeAmt.ClientID%>').val('0');
                    $('#<%=lblServiceChargeAmt.ClientID%>').focus();
                }
            }
        }

        function PickSenderData(obj) {
            var url = "";
            if (obj == "a") {
                url = "" + "TxnHistory/SenderAdvanceSearch.aspx";
            }
            if (obj == "s") {
                url = "" + "TxnHistory/SenderTxnHistory.aspx";
            }
            var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";

            if (isChrome) {
                PopUpWindow(url, param);

                return true;
            }
            var id = PopUpWindow(url, param);
            if (id == "undefined" || id == null || id == "") {
            }
            else {
                ClearSearchField();
                PopulateReceiverDDL(id);
                SearchCustomerDetails(id);
            }
        }

        function PickReceiverFromSender(obj) {
            var senderId = $('#finalSenderId').text();
            var sName = $('#senderName').text();
            if (senderId == "" || senderId == "undefined") {
                alert('Please select the Sender`s Details');
                return;
            }
            var url = "";
            if (obj === "a") {
                return AddNewReceiver(senderId);

            }
            if (obj == "r") {
                url = "" + "/AgentNew/SendTxn/TxnHistory/ReceiverHistoryBySender.aspx?sname=" + sName + "&senderId=" + senderId;
            }

            if (obj == "s") {
                url = "" + "/AgentNew/SendTxn/TxnHistory/SenderAdvanceSearch.aspx?senderId=" + senderId;
            }

            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);
            if (res == "undefined" || res == null || res == "") {
            }
            else {
                SearchReceiverDetails(res);
            }
        }

        function DDLReceiverOnChange() {
            $('.readonlyOnReceiverSelect').attr("disabled", "disabled");
            var receiverId = $("#<%=ddlReceiver.ClientID%>").val();
            if (receiverId != '' && receiverId != undefined && receiverId != "0") {
                SearchReceiverDetails(receiverId);
            }
            else if (receiverId == "0") {
                PickReceiverFromSender('a');
            }
            else if (receiverId == null || receiverId == "") {
                $('.readonlyOnReceiverSelect').removeAttr("disabled");
                ClearReceiverData();
            }
        }

        function SearchReceiverDetails(customerId) {
            if (customerId == "" || customerId == null) {
                ClearReceiverData();
                alert('Invalid receiver selected!');
            }
            var dataToSend = { MethodName: 'SearchReceiver', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(), dataToSend, function (response) {
                ParseResponseForReceiverData(response);
            }).fail(function () {
            });
            return true;
        }

        function ParseResponseForReceiverData(response) {
            ClearTxnData();
            $('.readonlyOnReceiverSelect').attr("disabled", "disabled");
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }
            if (data.length > 0) {
                //****Transaction Detail****
                $("#receiverName").text(data[0].firstName + ' ' + data[0].middleName + ' ' + data[0].lastName1);
                $("#<%=txtRecFName.ClientID %>").val(data[0].firstName);
                $("#<%=txtRecMName.ClientID %>").val(data[0].middleName);
                $("#<%=txtRecLName.ClientID %>").val(data[0].lastName1);
                $("#<%=txtRecAdd1.ClientID %>").val(data[0].address);
                $("#<%=txtRecCity.ClientID %>").val(data[0].city);
                $("#<%=txtRecMobile.ClientID %>").val(data[0].mobile);
                $("#<%=txtRecTel.ClientID %>").val(data[0].homePhone);
                $("#<%=txtRecIdNo.ClientID %>").val(data[0].idNumber);
                $("#<%=txtRecEmail.ClientID %>").val(data[0].email);
                $("#<%=ddlRecGender.ClientID %>").val(data[0].gender);
                SetDDLValueSelected("<%=ddlRecIdType.ClientID %>", data[0].idType);
                SetDDLTextSelected("<%=ddlRecGender.ClientID %>", data[0].gender);
                SetDDLValueSelected("<%=ddlReceiver.ClientID %>", data[0].receiverId);
                if ($.isNumeric(data[0].purposeOfRemit)) {
                    SetDDLValueSelected("<%=purpose.ClientID %>", data[0].purposeOfRemit);
                } else {
                    SetDDLTextSelected("<%=purpose.ClientID %>", data[0].purposeOfRemit);
                }
                if ($.isNumeric(data[0].relationship)) {
                    SetDDLValueSelected("<%=relationship.ClientID %>", data[0].relationship);

                } else {
                    SetDDLTextSelected("<%=relationship.ClientID %>", data[0].relationship);

                }
                //****Transaction Detail****
                SetDDLValueSelected("<%=pCountry.ClientID%>", data[0].COUNTRYID);

                PcountryOnChange('c', data[0].paymentMethod.toUpperCase(), data[0].bankId);
                //select bank branch
                //if (data[0].paymentMethod.toUpperCase() == 'BANK DEPOSIT') {
                //    var isBranchByName = 'N';
                //    var branch = '';
                //}
                PopulateBankDetails(data[0].bankId, 2, 'N', data[0].branchId);
                SetPayCurrency(data[0].COUNTRYID);
                PAgentChange();
                $('#<%=txtRecDepAcNo.ClientID%>').val(data[0].receiverAccountNo);
                ManageHiddenFields(data[0].paymentMethod.toUpperCase());

                $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                <%--if ($("#<%=pCountry.ClientID%> option:selected ").val() != "") {
                    PcountryOnChange('c', "");
                    SetPayCurrency($("#<%=pCountry.ClientID%>").val());
                }--%>
                ManageLocationData();
                HideShowFieldsOnTxnTab();
            }
        }

        function PopulateReceiverDDL(customerId) {
            if (customerId == "" || customerId == null) {
                alert('Invalid customer selected!');
            }
            var dataToSend = { MethodName: 'PopulateReceiverDDL', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(), dataToSend, function (response) {
                PopulateReceiverDataDDL(response);
            }).fail(function () {
                alert("Error from pupulatereceiverDDL");
            });
            return true;
        }

        function PopulateReceiverDataDDL(response) {
            var data = jQuery.parseJSON(response);
            var ddl = GetElement("<%=ddlReceiver.ClientID%>");
            $(ddl).empty();
            var option = document.createElement("option");
            option.text = 'Select Receiver';
            option.value = '';
            ddl.options.add(option);
            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].fullName.toUpperCase();
                option.value = data[i].receiverId;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
            option = document.createElement("option");
            option.text = 'New Receiver';
            option.value = '0';
            ddl.options.add(option);
        }

        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }

        function CheckForMobileNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,16}$/;
            var maxLength = nField.maxLength;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid ! Maximum ' + maxLength + ' Numeric Characters only valid ');
                nField.value = '';
                nField.focus();
                return false
            }
            return true;
        }

        function CheckForPhoneNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,15}$/;
            var maxLength = nField.maxLength;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid ! Maximum ' + maxLength + ' Numeric Characters only valid ');
                nField.value = '';
                nField.focus();
                return false
            }
            return true;
        }

        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }

        function ResetAmountFields() {
            //Reset Fields
            $("#<%=txtPayAmt.ClientID%>").val('');
            $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
            $("#<%=lblSendAmt.ClientID%>").text('0.00');
            $("#<%=lblServiceChargeAmt.ClientID%>").val('0');
            $("#<%=lblExRate.ClientID%>").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#<%=lblPayCurr.ClientID%>").text('');
            $('#spnWarningMsg').html('');
        }

        function checkdata(amt, obj) {
            ClearCalculatedAmount();
            if (amt > 0)
                CalculateTxn(amt, obj);
            else
                ClearCalculatedAmount();
        }

        function ManageSendIdValidity() {
            var senIdType = $("#<%=ddSenIdType.ClientID%>").val();
            if (senIdType == "") {
                $("#<%=tdSenExpDateLbl.ClientID%>").show();
                $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "required readonlyOnCustomerSelect form-control");
            }
            else {
                var senIdTypeArr = senIdType.split('|');
                if (senIdTypeArr[1] == "E") {
                    $("#<%=tdSenExpDateLbl.ClientID%>").show();
                    $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "required readonlyOnCustomerSelect form-control");
                }
                else {
                    $("#<%=tdSenExpDateLbl.ClientID%>").hide();
                    $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "readonlyOnCustomerSelect form-control");
                }
            }
        }

        function CheckSenderIdNumber(me) {
            if (me.readOnly) {
                $('#spnIdNumber').html('');
                GetElement("spnIdNumber").style.display = "none";
                return;
            }
            CheckForSpecialCharacter(me, 'Sender ID Number');
            var sIdNo = me.value;
            if (sIdNo === null || sIdNo === "") {
                return;
            }
            var dataToSend = { MethodName: "CheckSenderIdNumber", sIdNo: sIdNo };
            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    var data = jQuery.parseJSON(response);
                    if (data[0].errorCode != "0") {
                        $('#spnIdNumber').html(data[0].msg);
                        GetElement("spnIdNumber").style.display = "block";
                    }
                    else {
                        $('#spnIdNumber').html('');
                        GetElement("spnIdNumber").style.display = "none";
                    }
                }
            };
            $.ajax(options);
        }

        function LoadCustomerRate() {
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $('#<%=pMode.ClientID %> option:selected').val();
            var pModeTxt = $('#<%=pMode.ClientID %> option:selected').text();
            var pAgent = $("#<%=pAgent.ClientID%> option:selected").val();
            if (pAgent === "undefined")
                pAgent = null;
            var collCurr = $('#<%=lblCollCurr.ClientID%>').text();
            var dataToSend = {
                MethodName: 'LoadCustomerRate', pCountry: pCountry, pMode: pMode, pAgent: pAgent, collCurr: collCurr
            };

            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    var data = response;
                    if (data == null || data == undefined || data == "")
                        return;
                    if (data[0].ErrCode != "0") {
                        $("#<%=lblExRate.ClientID%>").text(data[0].Msg);
                        return;
                    }
                    var exRate = data[0].exRate;
                    var pCurr = data[0].pCurr;
                    var limit = data[0].limit;
                    var limitCurr = data[0].limitCurr;
                    exRate = roundNumber(exRate, 10);
                    $("#<%=lblExRate.ClientID%>").text(exRate);
                    $("#<%=lblExCurr.ClientID%>").text(pCurr);
                    $("#<%=lblPerTxnLimit.ClientID%>").text(limit);
                    $("#<%=lblPerTxnLimitCurr.ClientID%>").text(limitCurr);
                    return;
                }
            };
            $.ajax(options);

            return true;
        }

        function CollAmtOnChange() {
            var collAmt = $("#<%=txtCollAmt.ClientID%>").val();
            if (collAmt == "")
                collAmt = "0";
            var collAmtFormatted = CurrencyFormatted(collAmt);

            collAmtFormatted = CommaFormatted(collAmtFormatted);
            var collCurr = $('#<%=lblCollCurr.ClientID%>').text();
            if (collAmt == "0") {
                ClearCalculatedAmount();
                return;
            }
            checkdata(collAmt, 'cAmt');
        }

        function ClearCalculatedAmount() {
            $("#<%=txtCollAmt.ClientID%>").val('');
            $('#<%=lblSendAmt.ClientID%>').val(0);
            $('#<%=lblServiceChargeAmt.ClientID%>').val(0);
            $('#<%=lblExRate.ClientID%>').val(0);
            $('#<%=txtPayAmt.ClientID%>').val('');
        }

        function ClearAllCustomerInfo() {
            location.reload();
        }

        function LoadLocationDDL(response) {
            var data = response;
            var ddl = GetElement("<%=locationDDL.ClientID %>");
            $(ddl).empty();

            $('#<%=subLocationDDL.ClientID%>').empty();

            var option;
            option = document.createElement("option");
            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].LOCATIONNAME;
                option.value = data[i].LOCATIONID;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function ManageLocationData() {
            var pCountry = $('#<%=pCountry.ClientID%> :selected').text();
            var pMode = $('#<%=pMode.ClientID%>').val();
            var payoutPartnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
            if (pCountry == '151') {
                $('#<%=locationDDL.ClientID%>').empty();
                $('#<%=subLocationDDL.ClientID%>').empty();
                return;
            }
            var dataToSend = { MethodName: 'getLocation', PCountry: pCountry, PMode: pMode, PartnerId: payoutPartnerId };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        LoadLocationDDL(response);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function GetPayoutPartner(payMode) {
            var pCountry = $('#<%=pCountry.ClientID%>').val();
            var pMode = $('#<%=pMode.ClientID%>').val();
            var dataToSend = { MethodName: 'getPayoutPartner', PCountry: pCountry, PMode: pMode };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success:
                    function (response) {
                        var datas = response;
                        var agentId = "";
                        if (datas.length > 0) {
                            agentId = datas[0].agentId;
                        }
                        $('#<%=hddPayoutPartner.ClientID%>').val(agentId);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function LoadSublocation() {
            var pLocation = $('#<%=locationDDL.ClientID%>').val();
            var dataToSend = { MethodName: 'getSubLocation', PLocation: pLocation };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        LoadSubLocationDDL(response);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function LoadSubLocationDDL(response) {
            var data = response;
            var ddl = GetElement("<%=subLocationDDL.ClientID %>");
            $(ddl).empty();

            var option;
            option = document.createElement("option");
            option.text = "Select City";
            option.value = "";
            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].LOCATIONNAME;
                option.value = data[i].LOCATIONID;

                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function ClearTxnData() {
            $("#<%=pAgent.ClientID%>").empty();
            $("#<%=pMode.ClientID%>").empty();
            $("#txtpBranch_aValue").val("");
            $("#txtpBranch_aText").val("");
            $("#<%=txtRecDepAcNo.ClientID%>").val("");

            $("#<%=txtCollAmt.ClientID%>").val("");
            $('#<%=txtCollAmt.ClientID%>').attr("readonly", false);
            $("#<%=txtPayAmt.ClientID%>").val("");
            $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
            $("#<%=lblSendAmt.ClientID%>").text('0.00');
            $("#<%=lblServiceChargeAmt.ClientID%>").val('0');
            $("#<%=lblExRate.ClientID%>").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#<%=lblExRate.ClientID%>").text('0.00');

            $("#scDiscount").val('0.00');
            $("#exRateOffer").val('0.00');

            $("#<%=lblPayCurr.ClientID%>").text("");
            $("#<%=lblPerTxnLimit.ClientID%>").text('0.00');

            SetDDLValueSelected("<%=pCountry.ClientID%>", "");
            SetDDLValueSelected("<%=ddlSalary.ClientID%>", "");

            SetDDLValueSelected("<%=ddlSalary.ClientID%>", "");
            $('#branch').empty();
            $('#<%=branch.ClientID%>').empty();
            $('#<%=locationDDL.ClientID%>').empty();
            $('#<%=subLocationDDL.ClientID%>').empty();

            $('#spnWarningMsg').html('');
        }

        function SearchCustomerDetails(customerId, type) {
            if (customerId == "" || customerId == null) {
                alert('Search value is missing');
                $('#<%=txtSearchData.ClientID%>').focus();
                return false;
            }
            var dataToSend = { MethodName: 'SearchCustomer', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                dataToSend,
                function (response) {
                    ParseResponseData(response);
                    if (type == 'mapping') {
                        var data = jQuery.parseJSON(response);
                        var d = [customerId, data[0].senderName];
                        SetItem("<% =txtSearchData.ClientID%>", d);
                    }
                }).fail(function () {

                });
            return true;
        }

        function CalculateTxn(amt, obj, isManualSc) {
            var collAmt = parseFloat($('#<%=txtCollAmt.ClientID%>').val().replace(',', '').replace(',', '').replace(',', ''));
            var availableBal = parseFloat($('#<%=availableAmountDetails.ClientID%>').text().replace(',', '').replace(',', '').replace(',', ''));
            if (collAmt === NaN || collAmt === null || collAmt === "")
                collAmt = 0;
            var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
            if ($('#11063').is(':checked')) {
                availableBal = parseFloat($('#availableBal').text().replace(',', '').replace(',', '').replace(',', ''));
                if (collAmt > availableBal) {
                    alert('Collection amount can not be greater then Available Balance!');
                    ClearCalculatedAmount();
                    return false;
                }
            }

            if (isManualSc == '' || isManualSc == undefined) {
                isManualSc = 'N';
            }
            $("#DivLoad").show();
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            var pCountrytxt = $("#<%=pCountry.ClientID %> option:selected").text();
            var pMode = GetValue("<%=pMode.ClientID %>");
            var pModetxt = $("#<%=pMode.ClientID %> option:selected").text();

            if (pCountry == "" || pCountry == null || pCountry == undefined) {
                alert("Please choose payout country");
                GetElement("<%=pCountry.ClientID %>").focus();
                return false;
            }

            if (pMode == "" || pMode == null || pMode == undefined) {
                alert("Please choose payment mode");
                GetElement("<%=pMode.ClientID %>").focus();
                return false;
            }

            var pAgent = Number(GetValue("<%=pAgent.ClientID %>"));
            var pAgentBranch = GetValue("txtpBranch_aValue");

            var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
            var txtCustomerLimit = GetValue("<%=txtCustomerLimit.ClientID%>");
            var txnPerDayCustomerLimit = GetValue("<%=txnPerDayCustomerLimit.ClientID %>");
            var schemeCode = '';

            if (obj == "cAmt")
                collAmt = amt;

            if (parseFloat(txtCustomerLimit) + parseFloat(collAmt) > txnPerDayCustomerLimit) {
                alert('Transaction cannot be proceed. Customer limit exceeded ' + parseFloat(txnPerDayCustomerLimit));
                ClearCalculatedAmount();
                return false;
            }

            var payAmt = GetValue("<%=txtPayAmt.ClientID %>");
            if (obj == "pAmt")
                payAmt = amt;

            var payCurr = $('#<%=pCurrDdl.ClientID%>').val();
            var collCurr = $('#<%=lblCollCurr.ClientID%>').text();
            var senderId = $('#finalSenderId').text();
            var couponId = '';
            var sc = $("#<%=lblServiceChargeAmt.ClientID%>").val();

            if (pCountry == "203" && payCurr == "USD") {
                if ((pMode == "1" && pAgent != "2091") || (pMode != "12" && pAgent != "2091")) {
                    alert('USD receiving is only allow for Door to Door');
                    ClearCalculatedAmount();
                    return false;
                }
            }

            var dataToSend = {
                MethodName: 'CalculateTxn', pCountry: pCountry, pCountrytxt: pCountrytxt, pMode: pMode, pAgent: pAgent
                , pAgentBranch: pAgentBranch, collAmt: collAmt, payAmt: payAmt, payCurr: payCurr, collCurr: collCurr
                , pModetxt: pModetxt, senderId: senderId, schemeCode: schemeCode, couponId: couponId, isManualSc: isManualSc
                , sc: sc
            };

            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    ParseCalculateData(response, obj);
                }
            };
            $.ajax(options);
            $("#DivLoad").hide();
            return true;
        }

        function ParseCalculateData(response, amtType) {
            var data = response;
            CheckSession1(data);
            if (data[0].ErrCode == "1") {
                alert(data[0].Msg);
                ClearCalculatedAmount();
                return;
            }
            if (data[0].ErrCode == "101") {
                SetValueById("spnWarningMsg", "", data[0].Msg);
            }
            $('#<%=lblSendAmt.ClientID%>').text(parseFloat(Number(data[0].sAmt).toFixed(3))); //
            $('#<%=lblExRate.ClientID%>').val(roundNumber(data[0].exRate, 8));
            $('#<%=lblPayCurr.ClientID%>').text(data[0].pCurr);
            $('#<%=lblExCurr.ClientID%>').text(data[0].pCurr);

            $('#<%=lblPerTxnLimit.ClientID%>').text(data[0].limit);
            $('#<%=lblPerTxnLimitCurr.ClientID%>').text(data[0].limitCurr);

            $('#<%=lblServiceChargeAmt.ClientID%>').val(parseFloat(data[0].scCharge).toFixed(0));

            if (data[0].tpExRate != '' || data[0].tpExRate != undefined) {
                $('#<%=hddTPExRate.ClientID%>').val(data[0].tpExRate)
            }

            SetValueById("<%=txtCollAmt.ClientID %>", parseFloat(Number(data[0].collAmt).toFixed(3)), ""); //
            SetValueById("<%=lblSendAmt.ClientID %>", parseFloat(Number(data[0].sAmt).toFixed(3)), ""); //
            SetValueById("<%=txtPayAmt.ClientID %>", parseFloat(Number(data[0].pAmt).toFixed(2)), "");

            var exRateOffer = data[0].exRateOffer;
            var scOffer = data[0].scOffer;
            var scDiscount = data[0].scDiscount;
            SetValueById("scDiscount", data[0].scDiscount, "");
            SetValueById("exRateOffer", data[0].exRateOffer, "");
            var html = "<span style='color: red;'>" + exRateOffer + "</span> (Exchange Rate)<br />";
            html += "<span style='color: red;'>" + scDiscount + "</span> (Service Charge)";
        }

        var eddval = "<%=Swift.web.Library.GetStatic.ReadWebConfig("cddEddBal","300000") %>";

        function CheckSession1(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data.session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }

        function LoadPayMode(response, myDDL, recall, selectField, obj) {
            var data = response;
            CheckSession(data);
            $(myDDL).empty();

            var option;
            if (selectField != "" && selectField != undefined) {
                option = document.createElement("option");
                option.text = selectField;
                option.value = "";
                myDDL.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].typeTitle;
                option.value = data[i].serviceTypeId;

                try {
                    myDDL.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
            if (recall == 'pcurr') {
                SetDDLTextSelected("<%=pMode.ClientID%>", obj);
            }
        }

        function ParseLoadDDl(response, myDDL, recall, selectField) {
            var data = response;
            CheckSession(data);
            var ddl2 = GetElement("<%=pAgentDetail.ClientID %>");
            var ddl3 = GetElement("<%=pAgentMaxPayoutLimit.ClientID%>");
            $(ddl2).empty();
            $(ddl3).empty();
            $(myDDL).empty();

            $('#spnPayoutLimitInfo').html('');
            if ($("#<%=pMode.ClientID%> option:selected").val() != "" && recall == "agentSelection") {
                $('#hdnreqAgent').text(data[0].agentSelection);
            }

            var option;
            if (selectField != "" && selectField != undefined) {
                option = document.createElement("option");
                option.text = selectField;
                option.value = "";
                myDDL.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].AGENTNAME.toUpperCase();
                option.value = data[i].bankId;

                var option2 = document.createElement("option");
                option2.value = data[i].bankId;
                option2.text = data[i].FLAG;

                var option3 = document.createElement("option");
                option3.value = data[i].bankId;
                option3.text = data[i].maxPayoutLimit;

                try {
                    myDDL.options.add(option);
                    ddl2.options.add(option2);
                    ddl3.options.add(option3);
                }
                catch (e) {
                    alert(e);
                }
            }
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").text();
            var pCurr = $("#<%=lblPayCurr.ClientID%>").text();
            $('#spnPayoutLimitInfo').html('Payout Limit for ' + pCountry + ' : ' + data[0].maxPayoutLimit);
        }

        function SetDDLTextSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).text() == selectText) {
                    $(this).prop('selected', true);
                    return;
                }
            });
        }

        function SetDDLValueSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).val() == selectText) {
                    $(this).prop('selected', true);
                    return;
                }
            });
        }

        function ClearData() {
            var a = true;
            var b = false;

            $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
            $(".showOnCustomerSelect").removeClass("hidden");
            ShowElement('tblSearch');
            $('#divHideShow').show();
            $('#<%=txtSendFirstName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendMidName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendLastName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendIdNo.ClientID%>').attr("readonly", a);
            $('#<%=txtSendNativeCountry.ClientID%>').attr("readonly", a);
            $('#availableBal').text('0');
        }

        function PcountryOnChange(obj, pmode) {
            PcountryOnChange(obj, pmode, "");
        }

        function PcountryOnChange(obj, pmode, pAgentSelected) {
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            if (pCountry == "" || pCountry == null)
                return;

            var method = "";
            if (obj == 'c') {
                method = "PaymentModePcountry";
            }
            if (obj == 'pcurr') {
                method = "PCurrPcountry";
            }

            var dataToSend = { MethodName: method, pCountry: pCountry };
            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success: function (response) {
                    if (obj == 'c') {
                        var data = response;
                        LoadPayMode(response, document.getElementById("<%=pMode.ClientID %>"), 'pcurr', "", pmode);
                        ReceivingModeOnChange("", pAgentSelected);
                        GetPayoutPartner(data[0].serviceTypeId);
                    }
                    else if (obj == 'pcurr') {
                        var data = response;
                        if (response == "")
                            return false;
                        $('#<%=lblPayCurr.ClientID%>').text(data[0].currencyCode);
                        $('#<%=lblExCurr.ClientID%>').text(data[0].currencyCode);

                        return true;
                    }
                    return true;
                },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function ReceivingModeOnChange(pModeSelected, pAgentSelected) {
            ResetAmountFields();
            $("#<%=pAgent.ClientID %>").empty();
            PaymentModeChange(pModeSelected, pAgentSelected);
        };

        // WHILE CLICKING COLL MODE POPULATE AGENT/BANK
        function PaymentModeChange(pModeSelected, pAgentSelected) {
            var pMode = "";
            if (pModeSelected == "" || pModeSelected == null)
                pMode = $("#<%=pMode.ClientID %> option:selected").text();
            else {
                pMode = pModeSelected;
            }
            pCountry = GetValue("<%=pCountry.ClientID %>");
            $('#trAccno').hide();
            $("#<%=txtRecDepAcNo.ClientID%>").attr("class", "form-control");
            $('#trForCPOB').hide();
            if (pMode == "BANK DEPOSIT") {
                $('#trAccno').show();
                $("#<%=txtRecDepAcNo.ClientID%>").attr("class", "required form-control");
                $('#trAccno').show();
            }
            var dataToSend = { MethodName: "loadAgentBank", pMode: pMode, pCountry: pCountry };
            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    LoadAgentSetting();
                    ParseLoadDDl(response, GetElement("<%=pAgent.ClientID %>"), 'agentSelection', "");
                    if (pAgentSelected != "" && pAgentSelected != null && pAgentSelected != undefined) {
                        SetDDLValueSelected("<%=pAgent.ClientID %>", pAgentSelected);
                    }
                    LoadCustomerRate();
                }
            };
            $.ajax(options);
        }

        function LoadAgentSetting() {
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $("#<%=pMode.ClientID%> option:selected").val();
            var pModeTxt = $("#<%=pMode.ClientID%> option:selected").text();
            var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pMode: pMode };
            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    ApplyAgentSetting(response, pModeTxt);
                }
            };
            $.ajax(options);
        }

        // WHILE CLICKING Pagent POPULATE agent branch
        function PAgentChange() {
            var pAgent = GetValue("<%=pAgent.ClientID %>");
            if (pAgent == null || pAgent == "" || pAgent == undefined)
                return;
            SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pAgent);
            var pBankType = $("#<%=pAgentDetail.ClientID%> option:selected").text();
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $("#<%=pMode.ClientID%> option:selected").val();
            var pModeTxt = $("#<%=pMode.ClientID%> option:selected").text();
            var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pAgent: pAgent, pMode: pMode, pBankType: pBankType };
            var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    ApplyAgentSetting(response, pModeTxt);
                    if (pModeTxt == "CASH PAYMENT TO OTHER BANK")
                        LoadAgentByExtAgent(pAgent);
                    LoadCustomerRate();
                }
            };
            $.ajax(options);
        }

        function ApplyAgentSetting(response, pModeTxt) {
            var data = response;
            CheckSession(data);
            $("#btnPickBranch").show();
            $("#divBranchMsg").hide();
            if (data == "" || data == null) {
                var defbeneficiaryIdReq = $("#<%=hdnBeneficiaryIdReq.ClientID%>").val();
                var defbeneficiaryContactReq = $("<%=hdnBeneficiaryContactReq.ClientID%>").val();
                if (defbeneficiaryIdReq == "H") {
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                }
                else if (defbeneficiaryIdReq == "M") {
                    $(".trRecId").show();
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                    $("#<%=ddlRecIdType_err.ClientID%>").show();
                    $("#<%=txtRecIdNo_err.ClientID%>").show();
                }
                else if (defbeneficiaryIdReq == "O") {
                    $(".trRecId").show();
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=ddlRecIdType_err.ClientID%>").hide();
                    $("#<%=txtRecIdNo_err.ClientID%>").hide();
                }

                if (defbeneficiaryContactReq == "H") {
                    $("#<%=trRecContactNo.ClientID%>").hide();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                }
                else if (defbeneficiaryContactReq == "M") {
                    $("#<%=trRecContactNo.ClientID%>").show();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "required form-control");
                    $("#<%=txtRecMobile_err.ClientID%>").show();
                }
                else if (defbeneficiaryContactReq == "O") {
                    $("#<%=trRecContactNo.ClientID%>").show();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                    $("#<%=txtRecMobile_err.ClientID%>").hide();
                }

                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();

                if (pModeTxt == "BANK DEPOSIT") {
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "required disabled form-control");
                    $("#txtpBranch_err").show();
                }
                else {
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "disabled form-control");
                    $("#txtpBranch_err").hide();
                }
                return;
            }
            var branchSelection = data[0].branchSelection;
            var maxLimitAmt = data[0].maxLimitAmt;
            var agMaxLimitAmt = data[0].agMaxLimitAmt;
            var beneficiaryIdReq = data[0].benificiaryIdReq;
            var relationshipReq = data[0].relationshipReq;
            var beneficiaryContactReq = data[0].benificiaryContactReq;
            var acLengthFrom = data[0].acLengthFrom;
            var acLengthTo = data[0].acLengthTo;
            var acNumberType = data[0].acNumberType;

            if (branchSelection == "Not Required") {
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
            }
            else if (branchSelection == "Manual Type") {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", false);
                $('#txtpBranch_aText').attr("class", "required form-control");

                $("#txtpBranch_err").show();
                $("#divBranchMsg").show();
                $("#btnPickBranch").hide();
            }
            else if (branchSelection == "SELECT") {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "required disabled form-control");
                $("#txtpBranch_err").show();
            }
            else {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
            }
            if (beneficiaryIdReq == "H") {
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
            }
            else if (beneficiaryIdReq == "M") {
                $("#<%=trRecId.ClientID%>").show();
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                $("#<%=ddlRecIdType_err.ClientID%>").show();
                $("#<%=txtRecIdNo_err.ClientID%>").show();
            }
            else if (beneficiaryIdReq == "O") {
                $("#<%=trRecId.ClientID%>").show();
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=ddlRecIdType_err.ClientID%>").hide();
                $("#<%=txtRecIdNo_err.ClientID%>").hide();
            }

            if (beneficiaryContactReq == "H") {
                $("#<%=trRecContactNo.ClientID%>").hide();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
            }
            else if (beneficiaryContactReq == "M") {
                $("#<%=trRecContactNo.ClientID%>").show();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "required form-control");
                $("#<%=txtRecMobile_err.ClientID%>").show();
            }
            else if (beneficiaryContactReq == "O") {
                $("#<%=trRecContactNo.ClientID%>").show();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                $("#<%=txtRecMobile_err.ClientID%>").hide();
            }
        }

        function ParseResponseData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }
            $(".readonlyOnCustomerSelect").removeAttr("disabled");
            $(".readonlyOnReceiverSelect").removeAttr("disabled");
            if (data.length > 0) {
                //****Transaction Detail****
                ClearTxnData();
                SetDDLTextSelected("<%=ddlSalary.ClientID%>", data[0].monthlyIncome);
                $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                if (data[0].pBankBranch != "" && data[0].pBankBranch != undefined) {
                    $("#tdLblBranch").show();
                    $("#tdTxtBranch").show();
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "required disabled form-control");
                    $("#txtpBranch_err").show();
                    $("#txtpBranch_aValue").val(data[0].pBankBranch);
                    $("#txtpBranch_aText").val(data[0].pBankBranchName);
                }

                $("#<%=txtRecDepAcNo.ClientID%>").val(data[0].accountNo);

                $('#<%=span_txnInfo.ClientID%>').html("Today's Sent : #Txn(" + data[0].txnCount + "), Amount(" + data[0].txnSum + " " + data[0].collCurr + ")");
                SetValueById("<%=txtCustomerLimit.ClientID%>", data[0].txnSum2, "");
                SetValueById("<%=txnPerDayCustomerLimit.ClientID %>", data[0].txnPerDayCustomerLimit, "");
                SetValueById("<%=hdntranCount.ClientID %>", data[0].txnCount, "");
                $('#senderName').text(data[0].senderName);
                $('#finalSenderId').text(data[0].customerId);

                $('#<%=txtSendPostal.ClientID%>').val(data[0].szipCode);
                $('#<%=sCustStreet.ClientID%>').val(data[0].street);
                $('#<%=txtSendCity.ClientID%>').val(data[0].sCity);
                $('#<%=companyName.ClientID%>').val(data[0].companyName);
                $('#availableBal').text(data[0].AVAILABLEBALANCE);
                $('#availableBalSpan').hide();
                $('#<%=custLocationDDL.ClientID %>').val(data[0].sState);
                $('#<%=ddlEmpBusinessType.ClientID %>').val(data[0].organizationType);
                SetValueById("<%=ddlSendCustomerType.ClientID %>", data[0].customerType, "");
                SetValueById("<%=txtSendIdExpireDate.ClientID %>", data[0].idIssueDate, "");

                SetValueById("<%=txtSendFirstName.ClientID %>", data[0].sfirstName, "");
                SetValueById("<%=txtSendMidName.ClientID %>", data[0].smiddleName, "");
                SetValueById("<%=txtSendLastName.ClientID %>", data[0].slastName1, "");
                SetValueById("<%=txtSendIdNo.ClientID %>", data[0].sidNumber, "");
                if (data[0].sidNumber == "") {
                    $('#<%=txtSendIdNo.ClientID%>').attr("readonly", false);
                    SetDDLValueSelected("<%=ddSenIdType.ClientID %>", "");
                }
                else {
                    $('#<%=txtSendIdNo.ClientID%>').attr("readonly", true);
                }

                SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].svalidDate, "");
                SetValueById("<%=ddlIdIssuedCountry.ClientID %>", data[0].PLACEOFISSUE, "");
                SetValueById("<%=txtSendDOB.ClientID %>", data[0].sdob, "");
                SetValueById("<%=txtSendTel.ClientID %>", data[0].shomePhone, "");
                if (data[0].shomePhone == "")
                    $('#<%=txtSendTel.ClientID%>').attr("readonly", false);
                SetValueById("<%=txtSendMobile.ClientID %>", data[0].smobile, "");
                if (data[0].smobile == "")
                    $('#<%=txtSendMobile.ClientID%>').attr("readonly", false);

                SetValueById("<%=txtSendPostal.ClientID %>", data[0].szipCode, "");
                if (data[0].szipCode == "")
                    $('#<%=txtSendPostal.ClientID%>').attr("readonly", false);
                SetDDLValueSelected("<%=txtSendNativeCountry.ClientID%>", data[0].scountry);
                SetValueById("<%=txtSendEmail.ClientID %>", data[0].semail, "");
                if (data[0].semail == "")
                    $('#<%=txtSendEmail.ClientID%>').attr("readonly", false);
                SetValueById("<%=companyName.ClientID %>", data[0].companyName, "");

                SetDDLValueSelected("<%=ddlSenGender.ClientID%>", data[0].sgender);
                SetDDLTextSelected("<%=ddSenIdType.ClientID%>", data[0].idName);
                ManageSendIdValidity();
                $('#divSenderIdImage').html(data[0].SenderIDimage);
                SetDDLValueSelected("<%=occupation.ClientID%>", data[0].sOccupation);
                SetDDLValueSelected("<%=sourceOfFund.ClientID%>", data[0].sourceOfFund);

                ChangeCustomerType();
                HideShowFieldsOnTxnTab();
            }
            ManageLocationData();
        }

        function ClearReceiverData() {
            $('#receiverName').text('');
            $('#finalBenId').text('');
            SetDDLValueSelected("<%=ddlEmpBusinessType.ClientID %>", "11010");
            SetDDLValueSelected("<%=ddlRecIdType.ClientID %>", "");
            SetDDLValueSelected("<%=ddlReceiver.ClientID %>", "");
            SetValueById("<%=txtRecFName.ClientID %>", "", "");
            SetValueById("<%=txtRecMName.ClientID %>", "", "");
            SetValueById("<%=txtRecLName.ClientID %>", "", "");
            SetDDLTextSelected("<%=ddlRecIdType.ClientID%>", "SELECT");
            SetDDLTextSelected("<%=ddlRecGender.ClientID%>", "SELECT");
            SetValueById("<%=txtRecIdNo.ClientID %>", "", "");
            SetValueById("<%=txtRecTel.ClientID %>", "", "");
            SetValueById("<%=txtRecMobile.ClientID %>", "", "");
            SetValueById("<%=txtRecAdd1.ClientID %>", "", "");
            SetValueById("<%=txtRecCity.ClientID %>", "", "");
            SetValueById("<%=txtRecEmail.ClientID %>", "", "");
            SetDDLValueSelected("<%=relationship.ClientID %>", "");
            SetDDLValueSelected("<%=purpose.ClientID %>", "");
        }

        function ValidateDate(date) {
            if (date == "") {
                return true;
            }
            if (Date.parse(date)) {
                return true;
            } else {
                return false;
            }
        }

        function SetPayCurrency(pCountry) {
            var dataToSend = { MethodName: 'PCurrPcountry', pCountry: pCountry };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success:
                    function (response) {
                        var data = response;
                        var ddl = GetElement("<%=pCurrDdl.ClientID%>");
                        $(ddl).empty();

                        var option;

                        for (var i = 0; i < data.length; i++) {
                            option = document.createElement("option");

                            option.text = data[i].currencyCode;
                            option.value = data[i].currencyCode;

                            try {
                                ddl.options.add(option);
                                if (data[i].isDefault == "Y") {
                                    $('#<%=pCurrDdl.ClientID%>').val(data[i].currencyCode);
                                }
                            }
                            catch (e) {
                                alert(e);
                            }
                        }
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function ChangeCustomerType() {
            customerTypeId = $("#<%=ddlSendCustomerType.ClientID%>").val();
            if (customerTypeId == "4700") {
                $(".hideOnIndividual").hide();
                var emptyOnCompany = ['#<%=companyName.ClientID%>'];
                for (i = 0; i < emptyOnCompany.length; i++) {
                    $(emptyOnCompany[i]).val('');
                    $(emptyOnCompany[i]).text('');
                    $(emptyOnCompany[i]).removeClass('required');
                }
                $(".showOnIndividual").show();
                $("#<%=companyName.ClientID%>").removeClass("Required");
                $("#<%=ddlEmpBusinessType.ClientID%>").val("11010");
                $("#<%=ddlEmpBusinessType.ClientID%>").removeClass("required");
                $("#<%=occupation.ClientID%>").addClass("required");
            }
            else if (customerTypeId == "4701") {
                $(".hideOnIndividual").show();
                $(".showOnIndividual").hide();
                var emptyOnIndividual = ['#<%=txtSendFirstName.ClientID%>', '#<%=txtSendMidName.ClientID%>', '#<%=txtSendLastName.ClientID%>'];
                for (i = 0; i < emptyOnIndividual.length; i++) {
                    $(emptyOnIndividual[i]).val('');
                    $(emptyOnIndividual[i]).text('');
                    $(emptyOnIndividual[i]).removeClass('required');
                }
                $('#<%=ddlSalary.ClientID%>').val('');
                $('#<%=occupation.ClientID%>').val('');
                $('#<%=ddlSenGender.ClientID%>').val('');
                $('#<%=txtSendDOB.ClientID%>').val('');
                $("#<%=ddlEmpBusinessType.ClientID%>").addClass("required");
                $("#<%=companyName.ClientID%>").addClass("required");
                $("#<%=occupation.ClientID%>").removeClass("required");
            }
        }

        function CheckAvailableBalance(collectionMode) {
            var customerId = $("#ContentPlaceHolder1_txtSearchData_aValue").val();
            var dataToSend = { MethodName: 'CheckAvialableBalance', collectionMode: collectionMode, customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?', dataToSend, function (response) {
                $('#availableBalSpan').show();
                $("#availableBalSpan").html(response);
            }).fail(function () {
                alert("Due to unexpected errors we were unable to load data");
            });
        }

        function PopulateBankDetails(bankId, receiveMode, isBranchByName, branchSelected) {
            ManageHiddenFields(receiveMode);
            var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
            var dataToSend = '';
            if (isBranchByName == '' || isBranchByName == undefined) {
                dataToSend = { bankId: bankId, type: 'bb', pMode: receiveMode, partnerId: partnerId };
            }
            else {
                dataToSend = { bankId: bankId, type: 'bb', isBranchByName: isBranchByName, branchSelected: branchSelected, pMode: receiveMode, partnerId: partnerId };
            }
            $.get("/AgentNew/SendTxn/FormLoader.aspx", dataToSend, function (data) {
                GetElement("ddlAgentBranch").innerHTML = data;
            });
        }

        function ManageHiddenFields(receiveMode) {
            receiveMode = ($("#<%=pMode.ClientID%> option:selected").val() == '' || $("#<%=pMode.ClientID%> option:selected").val() == undefined) ? receiveMode : $("#<%=pMode.ClientID%> option:selected").val();
            if (receiveMode == "2" || receiveMode.toUpperCase() == 'BANK DEPOSIT') {
                $("#divBankBranch").css("display", "");
            }
            else {
                $("#divBankBranch").css("display", "none");
            }
        }

        function GetPayoutPartner(payMode) {
            var pCountry = $('#<%=pCountry.ClientID%>').val();
            var pMode = $('#<%=pMode.ClientID%>').val();
            var dataToSend = { MethodName: 'getPayoutPartner', PCountry: pCountry, PMode: pMode };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success:
                    function (response) {
                        var datas = response;
                        var agentId = "";
                        if (datas.length > 0) {
                            agentId = datas[0].agentId;
                        }
                        $('#<%=hddPayoutPartner.ClientID%>').val(agentId);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function LoadPayerData() {
            var bankId = $("#<%=pAgent.ClientID%>").val();
            if (bankId !== null && bankId !== "") {
                var partnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
                if (partnerId === apiPartnerIds[1]) {
                    bankId = $('#<%=pAgent.ClientID%> :selected').text();
                }
                var dataToSend = { MethodName: 'getPayerDataByBankId', bankId: bankId, partnerId: partnerId };
                $.post("", dataToSend, function (response) {
                    $("#myModal1").modal('show');
                    var data = jQuery.parseJSON(response);
                    var ddl = GetElement("<%=ddlPayerBranch.ClientID%>");
                    $(ddl).empty();
                    CreateDDLFromData(data, "<%=ddlPayer.ClientID%>");
                });
            }
        }

        function CreateDDLFromData(data, elementId, defaultText = null) {
            var ddl = GetElement(elementId);
            $(ddl).empty();

            var option;
            if (defaultText !== null) {
                option = document.createElement("option");
                option.text = defaultText;
                option.value = '';
                ddl.options.add(option);
            }
            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].payerName;
                option.value = data[i].payerId;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function proceed() {
            var isdisplayDignature = $("#" + ContentPlaceHolderId + "isDisplaySignature").val();
            if (isdisplayDignature.toLowerCase() === 'true') {
                if (CheckSignatureCustomer()) {
                    ValidateTxn('S');
                    return true;
                } else {
                    return false;
                }
            }
            ValidateTxn('S');
            return true;
        }

        function GetFieldVaule(value) {
            if (value == '' || value == undefined || value == null) {
                return '&nbsp;'
            }
            else {
                return value;
            }
        }

        function ValidateTxn(type) {

            var pBankBranchText = $("#<%=branch.ClientID%> option:selected").text();
            if (pBankBranchText.length <= 0) {
                pBankBranchText = $("#branch option:selected").text();
            }
            var pBank = $("#<%=pAgent.ClientID %> option:selected").val();
            if (pBank == "SELECT" || pBank == "undefined")
                pBank = "";
            var hdnreqAgent = $('#hdnreqAgent').html();
            var hdnreqBranch = $('#hdnreqBranch').html();
            var dm = $("#<%=pMode.ClientID %> option:selected").text();

            if ($('#<%=pMode.ClientID%>').val() == '2') {
                if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                    alert("Branch is required ");
                    return false;
                }
                if (hdnreqBranch == "Manual Type") {
                    if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                        alert("Branch is required ");
                        return false;
                    }
                }
            }
            if (hdnreqAgent == "M") {
                if (pBank == null || pBank == "" || pBank == "undefined") {
                    alert("Agent/Bank is required ");
                    $("#<%=pAgent.ClientID %>").focus();
                    return false;
                }
            }

            var por = $("#<%=purpose.ClientID %> option:selected").text();
            por = por.replace("SELECT", "");
            var sof = $("#<%=sourceOfFund.ClientID %> option:selected").text().replace("SELECT", "");
            sof = sof.replace("SELECT", "");
            var sendAmt = $('#<%=lblSendAmt.ClientID%>').text();

            if (sendAmt > parseInt(eddval)) {
                if (por == "") {
                    alert("Purpose of Remittance is required for sending amount greater than " + eddval);
                    $("#<%=purpose.ClientID %>").focus();
                    return false;
                }
                if (sof == "") {
                    alert("Source of fund is required for sending amount greater than " + eddval);
                    $("#<%=sourceOfFund.ClientID %>").focus();
                    return false;
                }
            }

            var pCountry = $("#<%=pCountry.ClientID %> option:selected").text();
            if (pCountry == "SELECT" || pCountry == undefined)
                pCountry = "";
            var pCountryId = $("#<%=pCountry.ClientID %> option:selected").val();
            var collMode = $("#<%=pMode.ClientID %> option:selected").text();
            var collModeId = $("#<%=pMode.ClientID %> option:selected").val();

            var pAgent = "";
            var pAgentName = "";

            var pBankText = $("#<%=pAgent.ClientID %> option:selected").text();
            if (pBankText == "[SELECT]" || pBankText == "[Any Where]" || pBankText == undefined)
                pBankText = "";

            var pBankBranch = $("#<%=branch.ClientID%> option:selected").val();
            if (pBankBranch == "SELECT" || pBankBranch == undefined)
                pBankBranch = "";

            SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pBank);
            var pBankType = $("#<%=pAgentDetail.ClientID%> option:selected").text();
            var pCurr = $('#<%=lblPayCurr.ClientID%>').text();
            var collCurr = $('#<%=lblCollCurr.ClientID%>').text();
            var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
            var customerTotalAmt = GetValue("txtCustomerLimit");
            var payAmt = GetValue("<% =txtPayAmt.ClientID %>");
            var scharge = $('#<%=lblServiceChargeAmt.ClientID%>').val();
            var discount = $('#lblDiscAmt').text();
            var exRate = $('#<%=lblExRate.ClientID%>').val();
            var scDiscount = $('#scDiscount').val();
            var exRateOffer = $('#exRateOffer').val();

            //Sender Data
            var senderId = $('#finalSenderId').text();
            var sfName = GetValue("<% =txtSendFirstName.ClientID %>");
            var smName = GetValue("<% =txtSendMidName.ClientID %>");
            var slName = GetValue("<% =txtSendLastName.ClientID %>");
            var sIdType = $("#<% =ddSenIdType.ClientID %> option:selected").text();

            if (sIdType == "SELECT" || sIdType == undefined || sIdType == "")
                sIdType = "";
            else
                sIdType = sIdType.split('|')[0];

            var sGender = $("#<% =ddlSenGender.ClientID %> option:selected").val();
            var sIdNo = GetValue("<% =txtSendIdNo.ClientID %>");
            var sIdValid = GetValue("<% =txtSendIdValidDate.ClientID %>");
            if (ValidateDate(sIdValid) == false) {
                alert('Sender Id expiry date is invalid');
                $('#<%=txtSendIdValidDate.ClientID%>').focus();
                return false;
            }
            var sdob = GetValue("<% =txtSendDOB.ClientID %>");
            var sTel = GetValue("<% =txtSendTel.ClientID %>");
            var sMobile = GetValue("<% =txtSendMobile.ClientID %>");
            var sCompany = GetValue("<%=companyName.ClientID %>");

            var sNaCountry = $("#<%=txtSendNativeCountry.ClientID %> option:selected").text();

            var sCity = $('#<%=txtSendCity.ClientID%>').val(); --GetItem("<%=txtSendCity.ClientID%>")[0];
            var sPostCode = GetValue("<% =txtSendPostal.ClientID %>");
            var sEmail = GetValue("<% =txtSendEmail.ClientID %>");
            var smsSend = "N";
            var newCustomer = "N";

            var benId = $('#finalBenId').text();
            var rfName = GetValue("<% =txtRecFName.ClientID %>");
            var rmName = GetValue("<% =txtRecMName.ClientID %>");
            var rlName = GetValue("<% =txtRecLName.ClientID %>");

            var rIdType = $("#<% =ddlRecIdType.ClientID %> option:selected").text();

            if (rIdType == "SELECT" || rIdType == "undefined")
                rIdType = "";

            var rGender = $("#<% =ddlRecGender.ClientID %> option:selected").val();
            var rIdNo = GetValue("<% =txtRecIdNo.ClientID %>");
            var rTel = GetValue("<% =txtRecTel.ClientID %>");
            var rMobile = GetValue("<% =txtRecMobile.ClientID %>");

            var rCity = GetValue("<% =txtRecCity.ClientID %>");
            var rAdd1 = GetValue("<% =txtRecAdd1.ClientID %>");
            var rEmail = GetValue("<% =txtRecEmail.ClientID %>");
            var accountNo = GetValue("<% =txtRecDepAcNo.ClientID %>");

            var pLocation = GetValue("<% =locationDDL.ClientID %>");
            var pLocationText = $("#<%=locationDDL.ClientID %> option:selected").text();
            var pSubLocation = $("#<% =subLocationDDL.ClientID %>").val();
            var pSubLocationText = $("#<%=subLocationDDL.ClientID %> option:selected").text();

            var tpExRate = $('#<%=hddTPExRate.ClientID%>').val();

            var isManualSC = 'N';

            var manualSC = $('#<%=lblServiceChargeAmt.ClientID%>').val();
            var enrollCustomer = "N";

            var collModeFrmCustomer = $("input[name='chkCollMode']:checked").val();
            if (collModeFrmCustomer == undefined || collModeFrmCustomer == '') {
                alert('Please choose collect mode first!!!!');
                return false;
            }
            //New params added
            var sCustStreet = $('#<%=sCustStreet.ClientID%>').val();
            var sCustLocation = $('#<%=custLocationDDL.ClientID%>').val();
            var sCustomerType = $('#<%=ddlSendCustomerType.ClientID%>').val();
            var company = GetValue("<% =companyName.ClientID %>");
            if (sCustomerType === "4701") {
                sfName = company;
            }
            var sCustBusinessType = $('#<%=ddlEmpBusinessType.ClientID%>').val();
            var sCustIdIssuedCountry = $('#<%=ddlIdIssuedCountry.ClientID%>').val();
            var sCustIdIssuedDate = $('#<%=txtSendIdExpireDate.ClientID%>').val();
            var receiverId = $('#<%=ddlReceiver.ClientID%>').val();
            var payoutPartnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
            var cashCollMode = collModeFrmCustomer;
            var introducerTxt = $('#introducerTxt').val();

            var rel = $("#<%=relationship.ClientID %> option:selected").text().replace("Select", "");
            rel = rel.replace("Select", "");
            var occupation = $("#<%=occupation.ClientID %> option:selected").val();
            var payMsg = escape(GetValue("<% = txtPayMsg.ClientID %>"));
            var cancelrequestId = '<%=GetResendId()%>';
            var salary = $("#<%=ddlSalary.ClientID %> option:selected").val();
            if (salary == "Select" || rIdType == "undefined")
                salary = "";
            var payerId = "";
            var payerBranchId = "";
            if ((payoutPartnerId === apiPartnerIds[0]) && collModeId === "2") {
                payerId = $("#<%=ddlPayer.ClientID%>").val();
                payerBranchId = $("#<%=ddlPayerBranch.ClientID%>").val();
                if (payerBranchId === null || payerBranchId === "") {
                    alert("Payer Branch Data Not Selected Please Choose Payer Branch Information ");
                    return;
                }
            }
            <%--var txnPwd = $("#<% =txnPassword.ClientID %>").val();--%>
            var invoicePrint = $('#ContentPlaceHolder1_invoicePrintMode :checked').val();
            var customerSignature = $('#<%=hddImgURL.ClientID%>').val();
            if (type === "S") {
                CheckSignatureCustomer();
                <%--if (txnPwd === "") {
                    $("#<% =txnPassword.ClientID %>").focus();
                    alert("Txn Password Is Required");
                    return false;
                }--%>
            }
            var customerPassword = $('#<%=customerPassword.ClientID%>').val();
            var verifyTxnData = {
                MethodName: "Verifytxn",
                type: type, senderId: senderId, sfName: sfName, smName: smName, slName: slName, sIdType: sIdType, sIdNo: sIdNo, sIdValid: sIdValid, sGender: sGender,
                sdob: sdob, sTel: sTel, sMobile: sMobile, sNaCountry: sNaCountry, sCity: sCity, sPostCode: sPostCode, sEmail: sEmail, sCompany: sCompany, benId: benId,
                rfName: rfName, rmName: rmName, rlName: rlName, rIdType: rIdType, rIdNo: rIdNo, rGender: rGender, rTel: rTel, rMobile: rMobile,
                rCity: rCity, rAdd1: rAdd1, rEmail: rEmail, accountNo: accountNo, pCountry: pCountry, payCountryId: pCountryId, collMode: collMode, collModeId: collModeId,
                pBank: pBank, pBankText: pBankText, pBankBranch: pBankBranch, pBankBranchText: pBankBranchText, pAgent: pAgent, pAgentName: pAgentName, pBankType: pBankType,
                pCurr: pCurr, collCurr: collCurr, collAmt: collAmt, payAmt: payAmt, sendAmt: sendAmt, scharge: scharge, customerTotalAmt: customerTotalAmt, discount: discount,
                scDiscount: scDiscount, exRateOffer: exRateOffer, exRate: exRate, por: por, sof: sof, rel: rel, occupation: occupation, payMsg: payMsg, company: company,
                newCustomer: newCustomer, EnrollCustomer: enrollCustomer, cancelrequestId: cancelrequestId, hdnreqAgent: hdnreqAgent, hdnreqBranch: hdnreqBranch, salary: salary,
                pLocation: pLocation, pLocationText: pLocationText, pSubLocation: pSubLocation, tpExRate: tpExRate, manualSC: manualSC, isManualSC: isManualSC, sCustStreet: sCustStreet,
                sCustLocation: sCustLocation, sCustomerType: sCustomerType, sCustBusinessType: sCustBusinessType, sCustIdIssuedCountry: sCustIdIssuedCountry,
                sCustIdIssuedDate: sCustIdIssuedDate, receiverId: receiverId, payoutPartnerId: payoutPartnerId, cashCollMode: cashCollMode, invoicePrint: invoicePrint,
                introducerTxt: introducerTxt, pSubLocationText: pSubLocationText, payerId: payerId, payerBranchId: payerBranchId/*, txnPwd: txnPwd*/, customerSignature: customerSignature,
                customerPassword: customerPassword
            };

            $.post('<%=ResolveUrl("SendV2.aspx") %>?', verifyTxnData, function (responses) {
                var response = JSON.parse(responses);
                if (type == 'V') {
                    PopulateTxnDetails(response);
                }
                else if (type == 'S') {
                    var resultData = response[0].split(',');
                    alert(resultData[1]);
                    if (resultData[0] == "0" || resultData[0] == "100" || resultData[0] == "101") {
                        url = "/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + resultData[2];
                        location.href = url;
                        return true;
                    }
                    else {
                        return false;
                    }
                }
            }).fail(function () {
                alert("Due to unexpected errors we were unable to load data");
            });
        }

        function SetVerifyTxnData() {
            var sName = $('#<%=txtSendFirstName.ClientID%>').val();
            if ($('#<%=txtSendFirstName.ClientID%>').val() != '') {
                sName += ' ' + $('#<%=txtSendMidName.ClientID%>').val();
            }
            sName += ' ' + $('#<%=txtSendLastName.ClientID%>').val();
            if ($('#<%=ddlSendCustomerType.ClientID%> option:selected').val() === "4701") {
                sName = $("#<%=companyName.ClientID%>").val();
            }
            var sIdType = $("#<% =ddSenIdType.ClientID %> option:selected").text();
            if (sIdType == "SELECT" || sIdType == undefined || sIdType == "")
                sIdType = "";
            else
                sIdType = sIdType.split('|')[0];

            $('#txtSenderName').html(GetFieldVaule(sName));
            $('#txtSenderAddress').html(GetFieldVaule($('#<%=custLocationDDL.ClientID %> option:selected').text()));
            $('#senderIdType').html(GetFieldVaule(sIdType));
            $('#txtSenderIdNumber').html(GetFieldVaule($('#<%=txtSendIdNo.ClientID%>').val()));
            $('#txtSenderIdExpiryDate').html(GetFieldVaule($('#<%=txtSendIdExpireDate.ClientID%>').val()));
            $('#txtSenderDob').html(GetFieldVaule($('#<%=txtSendDOB.ClientID%>').val()));
            $('#txtSenderCity').html(GetFieldVaule($('#<%=txtSendCity.ClientID%>').val()));
            $('#txtSenderCountry').html(GetFieldVaule($('#<%=txtSendNativeCountry.ClientID %> option:selected').text()));
            $('#txtSenderEmail').html(GetFieldVaule($('#<%=txtSendEmail.ClientID%>').val()));
            $('#txtSenderContactNo').html(GetFieldVaule($('#<%=txtSendMobile.ClientID%>').val()));

            var rName = $('#<%=txtRecFName.ClientID%>').val();
            if ($('#<%=txtRecMName.ClientID%>').val() != '') {
                rName += ' ' + $('#<%=txtRecMName.ClientID%>').val();
            }
            rName += ' ' + $('#<%=txtRecLName.ClientID%>').val();

            var rIdType = $("#<% =ddlRecIdType.ClientID %> option:selected").text();

            if (rIdType == "SELECT" || rIdType == "undefined")
                rIdType = "";

            $('#txtReceiverName').html(GetFieldVaule(rName));
            $('#txtReceiverAddress').html(GetFieldVaule($('#<%=txtRecAdd1.ClientID%>').val()));
            $('#receiverIdType').html(GetFieldVaule(rIdType));
            $('#txtReceiverIdNumber').html(GetFieldVaule($('#<%=txtRecIdNo.ClientID%>').val()));
            $('#txtReceiverIdExpiryDate').html(GetFieldVaule(''));
            $('#txtReceiverCity').html(GetFieldVaule($('#<%=txtRecCity.ClientID%>').val()));
            $('#txtReceiverCountry').html(GetFieldVaule($("#<%=pCountry.ClientID %> option:selected").text()));
            $('#txtReceiverEmail').html(GetFieldVaule($('#<%=txtRecEmail.ClientID%>').val()));
            $('#txtReceiverContactNo').html(GetFieldVaule($('#<%=txtRecMobile.ClientID%>').val()));

            $('#txtCollAmtJpy').html(GetFieldVaule($('#ContentPlaceHolder1_txtCollAmt').val()));
            $('#txtSentAmtJpy').html(GetFieldVaule($('#ContentPlaceHolder1_lblSendAmt').val()));
            $('#txtServiceCharge').html(GetFieldVaule($('#ContentPlaceHolder1_lblServiceChargeAmt').val()));
            $('#txtCustomerRate').html(GetFieldVaule($('#ContentPlaceHolder1_lblExRate').val()));
            $('#txtPayoutRate').html(GetFieldVaule($('#ContentPlaceHolder1_txtPayAmt').val()));

            $('#txtPCountry').html(GetFieldVaule($("#<%=pCountry.ClientID %> option:selected").text()));
            $('#txtModeOfPayment').html(GetFieldVaule($("#<%=pMode.ClientID %> option:selected").text()));
            $('#txtPayoutAgent').html(GetFieldVaule($("#<%=pAgent.ClientID %> option:selected").text()));
            $('#txnRelationship').html(GetFieldVaule($("#<%=relationship.ClientID %> option:selected").text()));
            $('#txtReceiverCity').html(GetFieldVaule($("#<%=subLocationDDL.ClientID %> option:selected").text()));
            $('#por').html(GetFieldVaule($("#<%=purpose.ClientID %> option:selected").text()));

            var branchName = $("#<%=branch.ClientID %> option:selected").text();
            if (branchName == "SELECT BANK" || branchName == undefined || branchName == "")
                branchName = "N/A";

            $('#txtCustomerBranch').html(GetFieldVaule(branchName));
        }

        function PopulateTxnDetails(response) {
            var resultData = response[0].split(',');
            var errorCode = resultData[0];
            if (errorCode != "0") {
                if (errorCode === "1") {
                    alert(resultData[1]);
                    var $active = $('.wizard .nav-tabs li.active');
                    $($active).prev().find('a[data-toggle="tab"]').click();
                    $active = $('.wizard .nav-tabs li.active');
                    $($active).prev().find('a[data-toggle="tab"]').click();
                    $('#tab4').addClass('disabled');
                    $('#tab5').addClass('disabled');
                }
                if (errorCode == "100") {
                    if (response[1] != "") {
                        var confirmText = "Confirmation:\n_____________________________________";
                        confirmText += "\n\nYou are confirming to send this OFAC suspicious transaction!!!";
                        confirmText += "\n\nPlease note if this customer is found to be valid person from OFAC List then Teller will be charged fine from management";
                        confirmText += "\n\n\nPlease make sure you have proper evidence that show this customer is not from OFAC List";
                        document.getElementById("ofacData").innerHTML = response[1];
                        $("#ofacField").show();
                        $("#sendTxncc").text(confirmText);
                    }
                    var complainData = response[2];
                    if (complainData != "") {
                        document.getElementById("complinceData").innerHTML = response[1];
                        $("#complinceField").show();
                    }
                }

                if (errorCode == "101") {
                    var complainData = response[2];
                    if (complainData != "") {
                        document.getElementById("complinceData").innerHTML = complainData;
                        $("#complinceField").show();
                    }
                }
                if (errorCode == "102") {
                    var complainData = response[2];
                    if (complainData != "") {
                        document.getElementById("complinceData").innerHTML = complainData;
                        $("#complinceField").show();
                    }
                }
            }
        }
    </script>

    <!-- #endregion Functions-->
</asp:Content>