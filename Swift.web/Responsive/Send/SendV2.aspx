<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendV2.aspx.cs" Inherits="Swift.web.Responsive.Send.SendMoneyv2.SendV2" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            $("#editServiceCharge").attr("disabled", true);
            $("#lblServiceChargeAmt").attr("readonly", true);
            $("#ddlCustomerType").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
                <% = txtSearchData.InitFunction() %>;
            });
            $("#editServiceCharge").change(function () {
                if ($('#allowEditSC').val() == 'N') {
                    alert('You are not allowed to edit Service Charge!');
                    $("#editServiceCharge").propAttr("checked", false);
                    return false;
                }
                var ischecked = $(this).is(':checked');
                if (ischecked)
                    $('#lblServiceChargeAmt').removeAttr('readonly');
                else
                    $('#lblServiceChargeAmt').attr('readonly', 'readonly');
            });
        });

        function PostMessageToParent(id) {
            if (id == "undefined" || id == null || id == "") {
            }
            else {
                var res = id.split('-:::-');
                if (res[0] == "1") {
                    var errMsgArr = res[1].split('\n');
                    for (var i = 0; i < errMsgArr.length; i++) {
                        alert(errMsgArr[i]);
                    }
                }
                else {
                    //alert('called');
                    ClearAllCustomerInfo();
                    //window.location.replace("/Remit/Transaction/Agent/ReprintReceipt/SendIntlReceipt.aspx?controlNo=" + res[2]);
                    window.location.replace("/AgentPanel/International/SendMoneyv2/SendIntlReceipt.aspx?controlNo=" + res[2]);
                }
            }
        }

        function ReCalculate() {
            if (!$("#lblServiceChargeAmt").attr("readonly")) {
                CalculateTxn($("#txtCollAmt").val(), 'cAmt', 'Y');
            }
        }

        function PostMessageToParentNew(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {
                ClearSearchField();
                PopulateReceiverDDL(id);
                SearchCustomerDetails(id);
            }
        }
        function PostMessageToParentNewForReceiver(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {
                SearchReceiverDetails(id);
            }
        }
        function DDLReceiverOnChange() {
            var customerId = $("#ddlReceiver").val();
            if (customerId != '' || customerId != undefined) {
                SearchReceiverDetails(customerId);
            }
        };
        function SearchReceiverDetails(customerId) {
            if (customerId == "" || customerId == null) {
                ClearReceiverData();
                alert('Invalid receiver selected!');
            }
            var dataToSend = { MethodName: 'SearchReceiver', customerId: customerId };

            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseResponseForReceiverData(response);
                    }
                };
            $.ajax(options);
            return true;
        }
        function ParseResponseForReceiverData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }

            if (data.length > 0) {
                //****Transaction Detail****
                $("#txtRecFName").val(data[0].firstName);
                $("#txtRecMName").val(data[0].middleName);
                $("#txtRecLName").val(data[0].lastName1);
                $("#txtRecAdd1").val(data[0].address);
                $("#txtRecCity").val(data[0].city);
                $("#txtRecMobile").val(data[0].mobile);
                $("#txtRecTel").val(data[0].homePhone);
                $("#txtRecIdNo").val(data[0].idNumber);
                $("#txtRecEmail").val(data[0].email);

                SetDDLTextSelected("ddlRecIdType", data[0].idType);
                SetDDLTextSelected("ddlRecGender", data[0].gender);
            }
        }
        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            SetItem("<% =txtSearchData.ClientID%>", d);
            PopulateReceiverDDL(GetItem("<%=txtSearchData.ClientID %>")[0]);
            SearchCustomerDetails(GetItem("<%=txtSearchData.ClientID %>")[0]);
        }
        function PopulateReceiverDDL(customerId) {
            if (customerId == "" || customerId == null) {
                alert('Invalid customer selected!');
            }
            var dataToSend = { MethodName: 'PopulateReceiverDDL', customerId: customerId };

            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        PopulateReceiverDataDDL(response);
                    }
                };
            $.ajax(options);
            return true;
        }
        function PopulateReceiverDataDDL(response) {
            var data = jQuery.parseJSON(response);
            var ddl = GetElement("ddlReceiver");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'SELECT RECEIVER';
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
        }
        function GetCustomerSearchType() {
            return $('#ddlCustomerType').val();
        }
        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }
        function CheckForMobileNumber(nField, fieldName) {
            var userInput = nField.value;
            if (userInput == "" || userInput == undefined) {
                return;
            }

            if (/^[0-9 ./\\()]*$/.test(userInput) == false) {
                alert('Special Character(e.g. !@#$%^&*) and alphabets are not allowed in field : ' + fieldName);
                setTimeout(function () { nField.focus(); }, 1);
            }
        }
        function LoadCalendars() {
            VisaValidDateSend("#<% =txtSendIdValidDate.ClientID%>");
            CalIDIssueDate("#<% =txtSendIdExpireDate.ClientID%>");
            CalSenderDOB("#<% =txtSendDOB.ClientID%>");
            CalReceiverDOB("#<% =txtRecDOB.ClientID%>");
            VisaValidDateRec("#<% =txtRecValidDate.ClientID%>");
        }
        LoadCalendars();
    </script>
    <script type="text/javascript" language="javascript">

        $.validator.messages.required = "Required!";

        $(document).ready(function () {
            $("#form2").validate();
        });

        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });

        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }

        function GetpAgentId() {
            var pagent = $("#<%=pAgent.ClientID %> option:selected").val();
            return pagent;
        }

        function ResetAmountFields() {
            //Reset Fields
            $("#txtPayAmt").val('0');
            $('#txtPayAmt').attr("readonly", false);
            $("#lblSendAmt").text('0.00');
            $("#lblServiceChargeAmt").val('0');
            $("#lblExRate").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#lblPayCurr").text('');
            GetElement("spnSchemeOffer").innerHTML = "";
            GetElement("spnWarningMsg").innerHTML = "";
        }

        function checkdata(amt, obj) {
            if (amt > 0)
                CalculateTxn(amt, obj);
        }

        function CalcOnEnter(e) {
            var evtobj = window.event ? event : e;

            var charCode = e.which || e.keyCode;
            //            alert(charCode);
            if (charCode == 13) {
                //                CollAmtOnChange();
                $("#btnCalculate").focus();
            }
        }

        function ManageSendIdValidity() {
            var senIdType = $("#ddSenIdType").val();
            if (senIdType == "") {
                $("#tdSenExpDateLbl").show();
                $("#tdSenExpDateTxt").show();
                $("#txtSendIdValidDate").attr("class", "required form-control");
            }
            else {
                var senIdTypeArr = senIdType.split('|');
                if (senIdTypeArr[1] == "E") {
                    $("#tdSenExpDateLbl").show();
                    $("#tdSenExpDateTxt").show();
                    $("#txtSendIdValidDate").attr("class", "required form-control");
                }
                else {
                    $("#tdSenExpDateLbl").hide();
                    $("#tdSenExpDateTxt").hide();
                    $("#txtSendIdValidDate").attr("class", "form-control");
                }
            }
        }

        function CheckSenderIdOnKeyUp(me) {
            var sIdNo = me.value;
            if (sIdNo == "" || sIdNo == null || sIdNo == undefined) {
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
                            GetElement("spnIdNumber").innerHTML = data[0].msg;
                            GetElement("spnIdNumber").style.display = "block";
                        }
                        else {
                            GetElement("spnIdNumber").innerHTML = "";
                            GetElement("spnIdNumber").style.display = "none";
                        }
                    }
                };
            $.ajax(options);
        }

        function CheckSenderIdNumber(me) {
            if (me.readOnly) {
                GetElement("spnIdNumber").innerHTML = "";
                GetElement("spnIdNumber").style.display = "none";
                return;
            }
            CheckForSpecialCharacter(me, 'Sender ID Number');
            var sIdNo = me.value;
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
                            GetElement("spnIdNumber").innerHTML = data[0].msg;
                            GetElement("spnIdNumber").style.display = "block";
                        }
                        else {
                            GetElement("spnIdNumber").innerHTML = "";
                            GetElement("spnIdNumber").style.display = "none";
                        }
                    }
                };
            $.ajax(options);
        }

        function ReceivingModeOnChange() {
            ReceivingModeOnChange("", "");
        }

        function ReceivingModeOnChange(pModeSelected, pAgentSelected) {
            ResetAmountFields();
            $("#<%=pAgent.ClientID %>").empty();



            PaymentModeChange(pModeSelected, pAgentSelected);
        }

        function LoadCustomerRate() {
            var pCountry = $("#pCountry option:selected").val();
            var pMode = $('#<%=pMode.ClientID %> option:selected').val();
            var pModeTxt = $('#<%=pMode.ClientID %> option:selected').text();
            var pAgent = $("#pAgent option:selected").val();
            if (pModeTxt == "CASH PAYMENT TO OTHER BANK")
                pAgent = $("#paymentThrough option:selected").val();
            var collCurr = $('#lblCollCurr').text();
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
                        var data = jQuery.parseJSON(response);
                        if (data == null || data == undefined || data == "")
                            return;
                        if (data[0].ErrCode != "0") {
                            $("#lblExRate").text(data[0].Msg);
                            return;
                        }
                        var exRate = data[0].exRate;
                        var pCurr = data[0].pCurr;
                        var limit = data[0].limit;
                        var limitCurr = data[0].limitCurr;
                        exRate = roundNumber(exRate, 10);
                        $("#lblExRate").text(exRate);
                        $("#lblExCurr").text(pCurr);
                        $("#lblPerTxnLimit").text(limit);
                        $("#lblPerTxnLimitCurr").text(limitCurr);
                        return;
                    }
                };
            $.ajax(options);

            return true;
        }

        function CollAmtOnChange() {
            var collAmt = $("#txtCollAmt").val();
            if (collAmt == "")
                collAmt = "0";
            var collAmtFormatted = CurrencyFormatted(collAmt); //collAmt;  

            collAmtFormatted = CommaFormatted(collAmtFormatted);
            var collCurr = $('#lblCollCurr').text();
            if (collAmt == "0")
                return;
            //if (confirm("You have entered " + collAmtFormatted + " " + collCurr + " as collection amount")) {
            //    checkdata(collAmt, 'cAmt');
            //}
            checkdata(collAmt, 'cAmt');
        }

        function ClearAllCustomerInfo() {
            ClearSearchSection();
            ClearAmountFields();
        }

        $(document).ready(function () {
            $('#txtpBranch_aText').attr("readonly", true);

            $("#txtCollAmt").blur(function () {
                CollAmtOnChange();
            });

            $("#txtPayAmt").blur(function () {
                checkdata($("#txtPayAmt").val(), 'pAmt');
            });


            //btnDepositDetail
            $('#btnDepositDetail').click(function () {
                var collAmt = PopUpWindow("CollectionDetail.aspx", "");
                if (collAmt == "undefined" || collAmt == null || collAmt == "") {
                    collAmt = $('#txtCollAmt').text();
                }
                else {
                    if ((collAmt) > 0) {
                        SetValueById("<%=txtCollAmt.ClientID %>", collAmt, "");
                        $('#txtCollAmt').attr("readonly", true);
                        $('#txtPayAmt').attr("readonly", true);
                    }
                    else {
                        SetValueById("<%=txtCollAmt.ClientID %>", "", "");
                        SetValueById("<%=txtPayAmt.ClientID %>", "", "");
                        $('#txtCollAmt').attr("readonly", false);
                        $('#txtPayAmt').attr("readonly", false);
                    }
                    CalculateTxn(collAmt);
                }
            });

            $("#ddSenIdType").change(function () {
                ManageSendIdValidity();
            });

            $("#locationDDL").change(function () {
                LoadSublocation();
            });



            $("#pCountry").change(function () {
                ResetAmountFields();
                $("#<%=pMode.ClientID %>").empty();
                $("#<%=pAgent.ClientID %>").empty();

                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $("#tdItelCouponIdLbl").hide();
                $("#tdItelCouponIdTxt").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                $("#txtRecDepAcNo").val('');
                $("#lblExCurr").text('');
                $("#lblPayCurr").text('');

                GetElement("spnPayoutLimitInfo").innerHTML = "";
                if ($("#pCountry option:selected").val() != "") {
                    PcountryOnChange('c', "");
                    SetPayCurrency($("#pCountry").val());
                }

            });

            $("#pMode").change(function () {
                ManageHiddenFields()

                $("#txtRecDepAcNo").val('');
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                ReceivingModeOnChange();
                ManageLocationData();
            });

            $("#paymentThrough").change(function () {
                ResetAmountFields();
                LoadCustomerRate();
            });

            $("#<%=ddlScheme.ClientID %>").change(function () {
                ResetAmountFields();
                $("#tdItelCouponIdLbl").hide();
                $("#tdItelCouponIdTxt").hide();
                if ($("#ddlScheme option:selected").text().toUpperCase() == "ITEL COUPON SCHEME") {
                    $("#tdItelCouponIdLbl").show();
                    $("#tdItelCouponIdTxt").show();
                }
            });
        });

        function LoadSublocation() {
            var pLocation = $('#locationDDL').val();
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
            var data = jQuery.parseJSON(response);
            var ddl = GetElement("<%=subLocationDDL.ClientID %>");
            $(ddl).empty();

            var option;
            option = document.createElement("option");
            option.text = "Select Location";
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

        function ManageLocationData() {
            var pCountry = $('#pCountry').val();
            var pMode = $('#pMode').val();
            if (pCountry == '151') {
                GetElement("<%=locationDDL.ClientID %>").className = "form-control";
                GetElement("<%=subLocationDDL.ClientID %>").className = "form-control";
                $('#locationRow').hide();
                $('#locationDDL').empty();
                $('#subLocationDDL').empty();
                return;
            }
            GetElement("<%=locationDDL.ClientID %>").className = "required form-control";
            GetElement("<%=subLocationDDL.ClientID %>").className = "required form-control";
            $('#locationRow').show();
            var dataToSend = { MethodName: 'getLocation', PCountry: pCountry, PMode: pMode };
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

        function LoadLocationDDL(response) {
            var data = jQuery.parseJSON(response);
            var ddl = GetElement("<%=locationDDL.ClientID %>");
            $(ddl).empty();

            $('#subLocationDDL').empty();

            var option;
            option = document.createElement("option");
            option.text = "SELECT COUNTRY";
            option.value = '';
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

        $(function () {
            $('#btnCalcClean').click(function () {
                ClearTxnData();
            });
        });

        //function to clear transaction 
        function ClearTxnData() {
            $("#pAgent").empty();
            $("#pMode").empty();
            $("#txtpBranch_aValue").val("");
            $("#txtpBranch_aText").val("");
            $("#txtRecDepAcNo").val("");

            $("#txtCollAmt").val("0");
            $('#txtCollAmt').attr("readonly", false);
            $("#txtPayAmt").val("0");
            $('#txtPayAmt').attr("readonly", false);
            $("#lblSendAmt").text('0.00');
            $("#lblServiceChargeAmt").val('0');
            $("#lblExRate").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#lblExRate").text('0.00');


            $("#scDiscount").val('0.00');
            $("#exRateOffer").val('0.00');

            $("#lblPayCurr").text("");
            $("#lblPerTxnLimit").text('0.00');

            SetDDLValueSelected("pCountry", "");
            SetDDLValueSelected("ddlSalary", "");
            SetDDLTextSelected("ddlScheme", "");

            GetElement("spnWarningMsg").innerHTML = "";
        }
        function SearchCustomerDetails(customerId) {
            if (customerId == "" || customerId == null) {
                alert('Search value is missing');
                $('#txtSearchData').focus();
                return false;
            }
            var dataToSend = { MethodName: 'SearchCustomer', customerId: customerId };

            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseResponseData(response);
                    }
                };
            $.ajax(options);
            return true;
        }
        ////calculation part
        $(function () {
            $('#btnCalculate').click(function () {
                CalculateTxn();
            });
        });

        function CalculateTxn(amt, obj, isManualSc) {
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

            var pAgent = GetValue("<%=pAgent.ClientID %>");
            var pAgentBranch = GetValue("txtpBranch_aValue");
            if (pModetxt == "CASH PAYMENT TO OTHER BANK") {
                pAgent = $("#<%=paymentThrough.ClientID %> option:selected").val();
                pAgentBranch = "";
                if (pAgent == "" || pAgent == undefined)
                    pAgent = "";
            }

            var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
            var txtCustomerLimit = GetValue("txtCustomerLimit");
            var txnPerDayCustomerLimit = GetValue("<%=txnPerDayCustomerLimit.ClientID %>");
            var schemeCode = GetValue("<%=ddlScheme.ClientID %>");

            if (obj == "cAmt")
                collAmt = amt;

            if (parseFloat(txtCustomerLimit) + parseFloat(collAmt) > txnPerDayCustomerLimit) {
                alert('Transaction cannot be proceed. Customer limit exceeded ' + parseFloat(txnPerDayCustomerLimit));
                ClearAmountFields();
                return false;
            }

            var payAmt = GetValue("<%=txtPayAmt.ClientID %>");
            if (obj == "pAmt")
                payAmt = amt;

            var payCurr = $('#pCurrDdl').val();
            var collCurr = $('#lblCollCurr').text();
            var senderId = $('#finalSenderId').text();
            var couponId = $("#iTelCouponId").val();
            var sc = $("#lblServiceChargeAmt").val();


            if (pCountry == "203" && payCurr == "USD") {
                if ((pMode == "1" && pAgent != "2091") || (pMode != "12" && pAgent != "2091")) {
                    alert('USD receiving is only allow for Door to Door');
                    ClearAmountFields();
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

        function ClearAmountFields() {
            $('#lblSendAmt').text('0.00');
            $('#lblExRate').text('0.00');
            $('#lblPerTxnLimit').text('0.00');
            $('#lblServiceChargeAmt').val('0');
            $('#lblDiscAmt').text('0.00');
            SetValueById("<%=txtCollAmt.ClientID %>", '0.00', "");
            SetValueById("<%=txtPayAmt.ClientID %>", '0.00', "");
            GetElement("spnSchemeOffer").innerHTML = "";
        }

        //Calculate Button Pressed and Json return;
        function ParseCalculateData(response, amtType) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].ErrCode == "1") {
                alert(data[0].Msg);
                ClearAmountFields();
                return;
            }
            if (data[0].ErrCode == "101") {
                SetValueById("spnWarningMsg", "", data[0].Msg);
            }
            $('#lblSendAmt').text(parseFloat(data[0].sAmt.toFixed(3))); //
            $('#lblExRate').text(roundNumber(data[0].exRate, 8));
            $('#lblPayCurr').text(data[0].pCurr);
            $('#lblExCurr').text(data[0].pCurr);

            if ($('#allowEditSC').val() == 'Y') {
                $("#editServiceCharge").attr("disabled", false);
            }

            $('#lblPerTxnLimit').text(data[0].limit);
            $('#lblPerTxnLimitCurr').text(data[0].limitCurr);

            if (!$("#editServiceCharge").is(':checked')) {
                $('#lblServiceChargeAmt').attr('readonly', 'readonly');
            }

            $('#lblServiceChargeAmt').val(parseFloat(data[0].scCharge).toFixed(0));

            if (data[0].tpExRate != '' || data[0].tpExRate != undefined) {
                $('#hddTPExRate').val(data[0].tpExRate)
            }

            SetValueById("<%=txtCollAmt.ClientID %>", parseFloat(data[0].collAmt.toFixed(3)), ""); //
            SetValueById("<%=lblSendAmt.ClientID %>", parseFloat(data[0].sAmt.toFixed(3)), ""); //
            SetValueById("<%=txtPayAmt.ClientID %>", parseFloat(data[0].pAmt).toFixed(2), "");

            var exRateOffer = data[0].exRateOffer;
            var scOffer = data[0].scOffer;
            var scDiscount = data[0].scDiscount;
            SetValueById("scDiscount", data[0].scDiscount, "");
            SetValueById("exRateOffer", data[0].exRateOffer, "");
            var html = "<span style='color: red;'>" + exRateOffer + "</span> (Exchange Rate)<br/>";
            html += "<span style='color: red;'>" + scDiscount + "</span> (Service Charge)";
            SetValueById("spnSchemeOffer", "", html);

            //             CheckThriK(parseFloat(data[0].collAmt).toFixed(2));
        }
        var eddval = "<%=Swift.web.Library.GetStatic.ReadWebConfig("cddEddBal","300000") %>";
        function CheckThriK(sAmt) {
            GetElement("<%=sourceOfFund.ClientID %>").className = "";
            GetElement("<%=purpose.ClientID %>").className = "";
            $('#sourceOfFund_err').html("");
            $('#purpose_err').html("");

            if (sAmt >= parseInt(eddval)) {
                GetElement("<%=sourceOfFund.ClientID %>").className = "required";
                GetElement("<%=purpose.ClientID %>").className = "required";
                $('#sourceOfFund_err').html("*");
                $('#purpose_err').html("*");
            }
        }

        //load payement mode 
        function LoadPayMode(response, myDDL, recall, selectField, obj) {
            var data = jQuery.parseJSON(response);
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
                SetDDLTextSelected("pMode", obj);
                //PcountryOnChange(recall);
            }
            ManageLocationData();
        }

        function ParseLoadDDl(response, myDDL, recall, selectField) {
            //alert(recall);
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            var ddl2 = GetElement("<%=pAgentDetail.ClientID %>");
            var ddl3 = GetElement("<%=pAgentMaxPayoutLimit.ClientID %>");
            $(ddl2).empty();
            $(ddl3).empty();
            $(myDDL).empty();

            GetElement("spnPayoutLimitInfo").innerHTML = "";
            if ($("#pMode option:selected").val() != "" && recall == "agentSelection") {
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

                option.text = data[i].AGENTNAME;
                option.value = data[i].AGENTID;

                var option2 = document.createElement("option");
                option2.value = data[i].AGENTID;
                option2.text = data[i].FLAG;

                var option3 = document.createElement("option");
                option3.value = data[i].AGENTID;
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

            if (data[0].AGENTNAME == "[Select]") {
                $('#pAgent_err').show();
                GetElement("pAgent_err").innerHTML = "*";
                GetElement("<%=pAgent.ClientID %>").className = "required form-control";
            }
            else {
                $('#pAgent_err').hide();
                GetElement("pAgent_err").innerHTML = "";
                GetElement("<%=pAgent.ClientID %>").className = "form-control";
            }


            var pCountry = $("#pCountry option:selected").text();
            var pCurr = $("#lblPayCurr").text();
            GetElement("spnPayoutLimitInfo").innerHTML = "Payout Limit for " + pCountry + " : " + data[0].maxPayoutLimit;
        }

        function SetDDLTextSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).text() == selectText) {
                    $(this).attr("selected", "selected");
                    return;
                }
            });
        }

        function SetDDLValueSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).val() == selectText) {
                    $(this).attr("selected", "selected");
                    return;
                }
            });
        }

        function ClickEnroll() {
            if ($('#EnrollCust').is(':checked')) {
                if ($('#NewCust').is(':checked') == false && $('#senderName').text() == "" || $('#senderName').text() == null) {
                    ClearSearchSection();
                    ClearData();
                }
                $('#lblMem').show();
                $('#valMem').show();
                $('#memberCode_err').html("*");
                return;
            }
            $('#NewCust').attr("checked", false);
            $('#lblMem').hide();
            $('#valMem').hide();
            $('#memberCode_err').html("");
        }



        function ExistingData() {
            if ($('#ExistCust').is(':checked')) {
                GetElement("<%=NewCust.ClientID %>").checked = false;
                ClearData();
            }
            else {
                GetElement("<%=NewCust.ClientID %>").checked = true;
                ClearData();
            }
        }

        //clear data  btnClear
        function ClearData() {
            var a = false;
            var b = false;

            if ($('#NewCust').is(':checked')) {
                a = false;
                b = true;
                ClearSearchSection();
                HideElement('tblSearch');
                $('#divHideShow').hide();
                GetElement("<%=ExistCust.ClientID %>").checked = false;
            }
            else {
                ShowElement('tblSearch');
                $('#divHideShow').show();
                GetElement("<%=ExistCust.ClientID %>").checked = true;
            }
            $('#txtSendFirstName').attr("readonly", a);
            $('#txtSendMidName').attr("readonly", a);
            $('#txtSendLastName').attr("readonly", a);
            $('#txtSendSecondLastName').attr("readonly", a);
            GetElement("<%=ddSenIdType.ClientID %>").disabled = a;
            $('#txtSendIdNo').attr("readonly", a);
            //        $('#txtSendDOB').attr("readonly", a);
            $('#txtSendNativeCountry').attr("readonly", a);
            //$('#btnSearchCustomer').attr("disabled", b);
            //EnableDisableBtn("btnSearchCustomer", b);
            $('#btnAdvSearch').attr("disabled", b);
            EnableDisableBtn("btnAdvSearch", b);
        }

        function SchemeByPCountry() {
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            var pAgent = GetValue("<%=pAgent.ClientID %>");
            var sCustomerId = $('#finalSenderId').text();
            if (pCountry == "" || pCountry == null)
                return;
            var dataToSend = { MethodName: 'LoadSchemeByRcountry', pCountry: pCountry, pAgent: pAgent, sCustomerId: sCustomerId };
            var option;
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?',
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        var myDDL = document.getElementById("<%=ddlScheme.ClientID %>");
                        $(myDDL).empty();

                        option = document.createElement("option");
                        option.text = "Select";
                        option.value = "";
                        myDDL.options.add(option);

                        var data = jQuery.parseJSON(response);
                        CheckSession(data);
                        if (response == "") {
                            $("#trScheme").hide();
                            $("#tdScheme").hide();
                            $("#tdSchemeVal").hide();
                            return false;
                        }
                        $("#trScheme").show();
                        $("#tdScheme").show();
                        $("#tdSchemeVal").show();
                        for (var i = 0; i < data.length; i++) {
                            option = document.createElement("option");
                            option.text = data[i].schemeName;
                            option.value = data[i].schemeCode;
                            try {
                                myDDL.options.add(option);
                            }
                            catch (e) {
                                alert(e);
                            }
                        }
                        return true;
                    }
                };
            $.ajax(options);
        }


        // pcountryn onchange
        function PcountryOnChange(obj, pmode) {
            PcountryOnChange(obj, pmode, "");
        }

        function PcountryOnChange(obj, pmode, pAgentSelected) {
            var pCountry = GetValue("<%=pCountry.ClientID %>"); //"MobileNo";
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
                    success: function (response) {
                        //SchemeByPCountry();
                        if (obj == 'c') {
                            LoadPayMode(response, document.getElementById("<%=pMode.ClientID %>"), 'pcurr', "", pmode);
                            ReceivingModeOnChange("", pAgentSelected);
                        }
                        else if (obj == 'pcurr') {
                            var data = jQuery.parseJSON(response);
                            if (response == "")
                                return false;
                            $('#lblPayCurr').text(data[0].currencyCode);
                            $('#lblExCurr').text(data[0].currencyCode);

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
            $("#txtRecDepAcNo").attr("class", "form-control");
            $('#trForCPOB').hide();
            GetElement("<%=paymentThrough.ClientID %>").className = "";
            if (pMode == "BANK DEPOSIT") {
                $('#trAccno').show();
                $("#txtRecDepAcNo").attr("class", "required form-control");
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
            var pCountry = $("#pCountry option:selected").val();
            var pMode = $("#pMode option:selected").val();
            var pModeTxt = $("#pMode option:selected").text();
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

        function LoadPaymentThroughDdl(response, myDdl, label) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            $(myDdl).empty();

            var option;
            if (label != "") {
                option = document.createElement("option");
                option.text = label;
                option.value = "";
                myDdl.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].agentName;
                option.value = data[i].agentId;
                try {
                    myDdl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function PBranchChange(pBranch) {
            ResetAmountFields();
            var dataToSend = { MethodName: "PBranchChange", pBranch: pBranch };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        LoadPaymentThroughDdl(response, GetElement("<%=paymentThrough.ClientID %>"), "Select");
                    }
                };
            $.ajax(options);
        }

        function LoadAgentByExtAgent(pAgent) {
            var dataToSend = { MethodName: "LoadAgentByExtAgent", pAgent: pAgent };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        LoadPaymentThroughDdl(response, GetElement("<%=paymentThrough.ClientID %>"), "Select");
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
            var pBankType = $("#pAgentDetail option:selected").text();
            var pCountry = $("#pCountry option:selected").val();
            var pMode = $("#pMode option:selected").val();
            var pModeTxt = $("#pMode option:selected").text();
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
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            $("#btnPickBranch").show();
            $("#divBranchMsg").hide();
            if (data == "" || data == null) {
                var defbeneficiaryIdReq = $("#hdnBeneficiaryIdReq").val();
                var defbeneficiaryContactReq = $("hdnBeneficiaryContactReq").val();
                var defrelationshipReq = $("hdnRelationshipReq").val();
                if (defbeneficiaryIdReq == "H") {
                    $("#trRecId").hide();
                    $("#ddlRecIdType").attr("class", "form-control");
                    $("#txtRecIdNo").attr("class", "form-control");
                    $("#tdRecIdExpiryLbl").hide();
                    $("#tdRecIdExpiryTxt").hide();
                }
                else if (defbeneficiaryIdReq == "M") {
                    $("#trRecId").show();
                    $("#ddlRecIdType").attr("class", "required form-control");
                    $("#txtRecIdNo").attr("class", "required form-control");
                    $("#ddlRecIdType_err").show();
                    $("#txtRecIdNo_err").show();
                    $("#tdRecIdExpiryLbl").show();
                    $("#tdRecIdExpiryTxt").show();
                }
                else if (defbeneficiaryIdReq == "O") {
                    $("#trRecId").show();
                    $("#ddlRecIdType").attr("class", "form-control");
                    $("#txtRecIdNo").attr("class", "form-control");
                    $("#ddlRecIdType_err").hide();
                    $("#txtRecIdNo_err").hide();
                    $("#tdRecIdExpiryLbl").show();
                    $("#tdRecIdExpiryTxt").show();
                }

                if (defrelationshipReq == "H") {
                    $("#trRelWithRec").hide();
                    $("#relationship").attr("class", "form-control");
                }
                else if (defrelationshipReq == "M") {
                    $("#trRelWithRec").show();
                    $("#relationship").attr("class", "required form-control");
                    $("#relationship_err").show();
                }
                else if (defrelationshipReq == "O") {
                    $("#trRelWithRec").show();
                    $("#relationship").attr("class", "form-control");
                    $("#relationship_err").hide();
                }

                if (defbeneficiaryContactReq == "H") {
                    $("#trRecContactNo").hide();
                    $("#txtRecMobile").attr("class", "form-control");
                }
                else if (defbeneficiaryContactReq == "M") {
                    $("#trRecContactNo").show();
                    $("#txtRecMobile").attr("class", "required form-control");
                    $("#txtRecMobile_err").show();
                }
                else if (defbeneficiaryContactReq == "O") {
                    $("#trRecContactNo").show();
                    $("#txtRecMobile").attr("class", "form-control");
                    $("#txtRecMobile_err").hide();
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
            else if (branchSelection == "Select") {
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
                $("#trRecId").hide();
                $("#ddlRecIdType").attr("class", "form-control");
                $("#txtRecIdNo").attr("class", "form-control");
                $("#tdRecIdExpiryLbl").hide();
                $("#tdRecIdExpiryTxt").hide();
            }
            else if (beneficiaryIdReq == "M") {
                $("#trRecId").show();
                $("#ddlRecIdType").attr("class", "required form-control");
                $("#txtRecIdNo").attr("class", "required form-control");
                $("#ddlRecIdType_err").show();
                $("#txtRecIdNo_err").show();
                $("#tdRecIdExpiryLbl").show();
                $("#tdRecIdExpiryTxt").show();
            }
            else if (beneficiaryIdReq == "O") {
                $("#trRecId").show();
                $("#ddlRecIdType").attr("class", "form-control");
                $("#txtRecIdNo").attr("class", "form-control");
                $("#ddlRecIdType_err").hide();
                $("#txtRecIdNo_err").hide();
                $("#tdRecIdExpiryLbl").show();
                $("#tdRecIdExpiryTxt").show();
            }

            if (relationshipReq == "H") {
                $("#trRelWithRec").hide();
                $("#relationship").attr("class", "form-control");
            }
            else if (relationshipReq == "M") {
                $("#trRelWithRec").show();
                $("#relationship").attr("class", "required form-control");
                $("#relationship_err").show();
            }
            else if (relationshipReq == "O") {
                $("#trRelWithRec").show();
                $("#relationship").attr("class", "form-control");
                $("#relationship_err").hide();
            }

            if (beneficiaryContactReq == "H") {
                $("#trRecContactNo").hide();
                $("#txtRecMobile").attr("class", "form-control");
            }
            else if (beneficiaryContactReq == "M") {
                $("#trRecContactNo").show();
                $("#txtRecMobile").attr("class", "required form-control");
                $("#txtRecMobile_err").show();
            }
            else if (beneficiaryContactReq == "O") {
                $("#trRecContactNo").show();
                $("#txtRecMobile").attr("class", "form-control");
                $("#txtRecMobile_err").hide();
            }
        }

        //PICK AGENT FROM SENDER HISTORY  --SenderDetailById
        function PickDataFromSender(obj) {
            var dataToSend = { MethodName: "SearchCustomer", searchValue: obj, searchType: "customerId" };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseResponseData(response);
                    }
                };
            $.ajax(options);
        }

        //PICK receiveer FROM SENDER HISTORY
        function SetReceiverFromSender(obj) {
            var senderId = $('#finalSenderId').text();
            var dataToSend = { MethodName: "ReceiverDetailBySender", id: obj, senderId: senderId };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseReceiverData(response);
                    }
                };
            $.ajax(options);
        }



        ////populate receiver data
        function ParseReceiverData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            // alert(response);
            if (data.length > 0) {
                alert(data[0].receiverName);
                $('#receiverName').text(data[0].receiverName);
                $('#finalBenId').text(data[0].id);
                SetDDLTextSelected("pCountry", data[0].country.toUpperCase());
                PcountryOnChange('c', data[0].paymentMethod, data[0].pBank);
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
                SetValueById("<%=txtRecFName.ClientID %>", data[0].firstName, "");
                SetValueById("<%=txtRecMName.ClientID %>", data[0].middleName, "");
                SetValueById("<%=txtRecLName.ClientID %>", data[0].lastName1, "");
                SetValueById("<%=txtRecSLName.ClientID %>", data[0].lastName2, "");

                SetDDLTextSelected("ddlRecIdType", data[0].idType);
                SetValueById("<%=txtRecIdNo.ClientID %>", data[0].idNumber, "");
                SetValueById("<%=txtRecValidDate.ClientID %>", data[0].validDate, "");
                SetValueById("<%=txtRecDOB.ClientID %>", data[0].dob, "");
                SetValueById("<%=txtRecTel.ClientID %>", data[0].homePhone, "");
                SetValueById("<%=txtRecMobile.ClientID %>", data[0].mobile, "");

                SetValueById("<%=txtRecAdd1.ClientID %>", data[0].address, "");
                SetValueById("<%=txtRecAdd2.ClientID %>", data[0].state, "");
                SetValueById("<%=txtRecCity.ClientID %>", data[0].state, "");
                SetValueById("<%=txtRecPostal.ClientID %>", data[0].zipCode, "");

                SetValueById("<%=txtRecEmail.ClientID %>", data[0].email, "");
                SetValueById("<%=txtRecDepAcNo.ClientID %>", data[0].accountNo, "");
            }
        }

        function ParseResponseData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }

            if (data.length > 0) {
                //****Transaction Detail****
                ClearTxnData();
                SetDDLTextSelected("pCountry", data[0].pCountry.toUpperCase());

                PcountryOnChange('c', data[0].paymentMethod, data[0].pBank);
                $('#lblPayCurr').text(data[0].payoutCurr);

                //            SetDDLTextSelected("pMode", data[0].paymentMethod.toUpperCase());


                //select bank branch
                if (data[0].paymentMethod.toUpperCase() == 'BANK DEPOSIT') {
                    var isBranchByName = 'N';
                    var branch = '';
                    if (data[0].pBankBranch == '' || data[0].pBankBranch == undefined || data[0].pBankBranch == '0') {
                        isBranchByName = 'Y';
                        branch = data[0].pBankBranchName;
                    }
                    else {
                        branch = data[0].pBankBranch;
                    }
                    PopulateBankDetails(data[0].pBank, data[0].paymentMethod, isBranchByName, branch);
                }
                SetPayCurrency(data[0].pCountryId);
                PAgentChange();
                SetDDLTextSelected("ddlReceiver", data[0].receiverName.toUpperCase());

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

                SetDDLTextSelected("paymentThrough", data[0].pAgent.toUpperCase());

                $("#txtRecDepAcNo").val(data[0].accountNo);

                $('#span_txnInfo').html("Today's Sent : #Txn(" + data[0].txnCount + "), Amount(" + data[0].txnSum + " " + data[0].collCurr + ")");

                SetValueById("txtCustomerLimit", data[0].txnSum2, "");
                SetValueById("<%=txnPerDayCustomerLimit.ClientID %>", data[0].txnPerDayCustomerLimit, "");
                SetValueById("<%=hdntranCount.ClientID %>", data[0].txnCount, "");
                //****End of Transaction Detail****


                //****Sender Detail****
                $('#senderName').text(data[0].senderName);
                $('#finalSenderId').text(data[0].customerId);

                //New data added
                $('#txtSendPostal').val(data[0].szipCode);
                $('#sCustStreet').val(data[0].street);
                $('#txtSendCity').val(data[0].sCity);
                $('#companyName').val(data[0].companyName)
                SetValueById("<%=custLocationDDL.ClientID %>", data[0].sState, "");
                SetValueById("<%=ddlEmpBusinessType.ClientID %>", data[0].organizationType, "");
                                                                                                                                //SetValueById("<%=ddlIdIssuedCountry.ClientID %>", data[0].sfirstName, "");
                SetValueById("<%=ddlSendCustomerType.ClientID %>", data[0].customerType, "");
                SetValueById("<%=txtSendIdExpireDate.ClientID %>", data[0].idIssueDate, "");

                SetValueById("<%=txtSendFirstName.ClientID %>", data[0].sfirstName, "");
                SetValueById("<%=txtSendMidName.ClientID %>", data[0].smiddleName, "");
                SetValueById("<%=txtSendLastName.ClientID %>", data[0].slastName1, "");
                SetValueById("<%=txtSendSecondLastName.ClientID %>", data[0].slastName2, "");

                SetValueById("<%=txtSendIdNo.ClientID %>", data[0].sidNumber, "");
                if (data[0].sidNumber == "") {
                    $('#txtSendIdNo').attr("readonly", false);
                    GetElement("<%=ddSenIdType.ClientID %>").disabled = false;
                    SetDDLValueSelected("<%=ddSenIdType.ClientID %>", "");
                }
                else {
                    $('#txtSendIdNo').attr("readonly", true);
                    GetElement("<%=ddSenIdType.ClientID %>").disabled = false;
                }

                SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].svalidDate, "");
                SetValueById("<%=txtSendDOB.ClientID %>", data[0].sdob, "");
                SetValueById("<%=txtSendTel.ClientID %>", data[0].shomePhone, "");
                if (data[0].shomePhone == "")
                    $('#txtSendTel').attr("readonly", false);
                SetValueById("<%=txtSendMobile.ClientID %>", data[0].smobile, "");
                if (data[0].smobile == "")
                    $('#txtSendMobile').attr("readonly", false);
                SetValueById("<%=txtSendAdd1.ClientID %>", data[0].saddress, "");
                if (data[0].saddress == "")
                    $('#txtSendAdd1').attr("readonly", false);
                SetValueById("<%=txtSendAdd2.ClientID %>", data[0].saddress2, "");
                if (data[0].saddress2 == "")
                    $('#txtSendAdd2').attr("readonly", false);

           <%-- SetValueById("<%=txtSendCity.ClientID %>", data[0].sCity, "");
            if (data[0].sCity == "")
                $('#txtSendCity').attr("readonly", false);--%>
                SetValueById("<%=txtSendPostal.ClientID %>", data[0].szipCode, "");
                if (data[0].szipCode == "")
                    $('#txtSendPostal').attr("readonly", false);
                SetDDLValueSelected("txtSendNativeCountry", data[0].scountry);
                SetValueById("<%=txtSendEmail.ClientID %>", data[0].semail, "");
                if (data[0].semail == "")
                    $('#txtSendEmail').attr("readonly", false);
                SetValueById("<%=companyName.ClientID %>", data[0].companyName, "");
                if (data[0].companyName == "")
                    $('#companyName').attr("readonly", false);
                SetDDLValueSelected("ddlSenGender", data[0].sgender);
                SetDDLTextSelected("ddSenIdType", data[0].idName);
                ManageSendIdValidity();

                GetElement("divSenderIdImage").innerHTML = data[0].SenderIDimage;
                //****End of Sender Detail****

                //****Receiver Detail****
                $('#receiverName').text(data[0].receiverName);
                $('#finalBenId').text(data[0].rID);
                SetValueById("<%=txtRecFName.ClientID %>", data[0].rfirstName, "");
                SetValueById("<%=txtRecMName.ClientID %>", data[0].rmiddleName, "");
                SetValueById("<%=txtRecLName.ClientID %>", data[0].rlastName1, "");
                SetValueById("<%=txtRecSLName.ClientID %>", data[0].rlastName2, "");

                SetDDLTextSelected("ddlRecIdType", data[0].ridtype);
                SetDDLValueSelected("ddlRecGender", data[0].rgender);
                SetValueById("<%=txtRecIdNo.ClientID %>", data[0].ridNumber, "");
                SetValueById("<%=txtRecValidDate.ClientID %>", data[0].rvalidDate, "");
                SetValueById("<%=txtRecDOB.ClientID %>", data[0].rdob, "");
                SetValueById("<%=txtRecTel.ClientID %>", data[0].rhomePhone, "");
                SetValueById("<%=txtRecMobile.ClientID %>", data[0].rmobile, "");

                SetValueById("<%=txtRecAdd1.ClientID %>", data[0].raddress, "");
                SetValueById("<%=txtRecAdd2.ClientID %>", data[0].raddress2, "");
                SetValueById("<%=txtRecCity.ClientID %>", data[0].rCity, "");
                SetValueById("<%=txtRecPostal.ClientID %>", data[0].rzipCode, "");

                SetValueById("<%=txtRecEmail.ClientID %>", data[0].remail, "");
                //****END of Receiver Detail****

                //****Customer Due Diligence Information****
                SetDDLValueSelected("occupation", data[0].sOccupation);
                SetDDLTextSelected("relationship", data[0].relWithSender);
                //****End of CDDI****
            }
        }

        function ClearSearchSection() {
            $('#senderName').text("");
            $('#finalSenderId').text("");
            ClearSearchField();
            $("#ddlReceiver").empty();
                                                                                                                            //SetValueById("<%=txtSearchData.ClientID %>", "", "");
            SetDDLTextSelected("<%=ddlCustomerType.ClientID %>", "Passport No.");
            SetDDLValueSelected("<%=pCountry.ClientID %>", "");
            $("#pMode").empty();
            $("#pAgent").empty();
            $("#tdLblBranch").hide();
            $("#tdTxtBranch").hide();
            $("#trAccno").hide();
            $("#spnPayoutLimitInfo").hide();
            $("#divSenderIdImage").hide();
            SetValueById("<%=txtSendFirstName.ClientID %>", "", "");
            SetValueById("<%=txtSendMidName.ClientID %>", "", "");
            SetValueById("<%=txtSendLastName.ClientID %>", "", "");
            SetValueById("<%=txtSendSecondLastName.ClientID %>", "", "");

            SetDDLTextSelected("ddSenIdType", "Select");
            SetDDLTextSelected("ddlSenGender", "Select");
            SetValueById("<%=txtSendIdNo.ClientID %>", "", "");
            SetValueById("<%=memberCode.ClientID %>", "", "");
            SetValueById("<%=txtSendIdValidDate.ClientID %>", "", "");
            SetValueById("<%=txtSendDOB.ClientID %>", "", "");
            SetValueById("<%=txtSendTel.ClientID %>", "", "");
            SetValueById("<%=txtSendMobile.ClientID %>", "", "");
            SetValueById("<%=companyName.ClientID %>", "", "");

            SetValueById("<%=txtSendAdd1.ClientID %>", "", "");
            SetValueById("<%=txtSendAdd2.ClientID %>", "", "");
                                                                                                                            //SetValueById("<%=txtSendCity.ClientID %>", "", "");
            SetValueById("<%=txtSendPostal.ClientID %>", "", "");
            SetValueById("<%=txtSendNativeCountry.ClientID %>", "", "");
            SetValueById("<%=txtSendEmail.ClientID %>", "", "");

            SetDDLValueSelected("<%=occupation.ClientID %>", "");
            SetDDLValueSelected("<%=relationship.ClientID %>", "");
            SetDDLValueSelected("<%=ddlSalary.ClientID %>", "");

            ClearReceiverData();
        }

        function ClearReceiverData() {
            $('#receiverName').text('');
            $('#finalBenId').text('');
            $('#txtSendIdExpireDate').val('');
            $('#sCustStreet').val('');
            $('#txtSendCity').val('');
            $('#txtSendCity').val('');
            SetDDLValueSelected("<%=ddlEmpBusinessType.ClientID %>", "11007");
            SetDDLValueSelected("<%=ddlIdIssuedCountry.ClientID %>", "");
            SetDDLValueSelected("<%=ddSenIdType.ClientID %>", "");
            SetDDLValueSelected("<%=ddlSendCustomerType.ClientID %>", "");
            SetDDLValueSelected("<%=custLocationDDL.ClientID %>", "");
            SetDDLValueSelected("<%=ddlReceiver.ClientID %>", "");

            SetValueById("<%=txtRecFName.ClientID %>", "", "");
            SetValueById("<%=txtRecMName.ClientID %>", "", "");
            SetValueById("<%=txtRecLName.ClientID %>", "", "");
            SetValueById("<%=txtRecSLName.ClientID %>", "", "");
            SetDDLTextSelected("ddlRecIdType", "Select");
            SetDDLTextSelected("ddlRecGender", "Select");
            SetValueById("<%=txtRecIdNo.ClientID %>", "", "");
            SetValueById("<%=txtRecValidDate.ClientID %>", "", "");
            SetValueById("<%=txtRecDOB.ClientID %>", "", "");
            SetValueById("<%=txtRecTel.ClientID %>", "", "");
            SetValueById("<%=txtRecMobile.ClientID %>", "", "");
            SetValueById("<%=txtRecAdd1.ClientID %>", "", "");
            SetValueById("<%=txtRecAdd2.ClientID %>", "", "");
            SetValueById("<%=txtRecCity.ClientID %>", "", "");
            SetValueById("<%=txtRecPostal.ClientID %>", "", "");
            SetValueById("<%=txtRecEmail.ClientID %>", "", "");

            SetDDLValueSelected("<%=relationship.ClientID %>", "");
        }
        //clear receiver dtaa
        $(function () {
            $('#btnReceiverClr').click(function () {
                ClearReceiverData();
            });
        });
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
        ////send transacion calc
        $(function () {
            $('#calc').click(function () {
                if ($("#form2").validate().form() == false) {
                    $(".required").each(function () {
                        if (!$.trim($(this).val())) {
                            $(this).focus();
                        }

                    });
                    return false;
                }
                //var pBankBranchText = $("#txtpBranch_aText").val();
                var pBankBranchText = $("#branch option:selected").text();
                var pBank = $("#<%=pAgent.ClientID %> option:selected").val();
                if (pBank == "Select" || pBank == "undefined")
                    pBank = "";
                var hdnreqAgent = $('#hdnreqAgent').html();
                var hdnreqBranch = $('#hdnreqBranch').html();
                var dm = $("#<%=pMode.ClientID %> option:selected").text();
                if ($('#pMode').val() == '2') {
                    if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                        alert("Branch is required ");
                        //$("txtpBranch_aText").focus();
                        return false;
                    }
                    if (hdnreqBranch == "Manual Type") {
                        if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                            alert("Branch is required ");
                            //$("txtpBranch_aText").focus();
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
                por = por.replace("Select", "");
                var sof = $("#<%=sourceOfFund.ClientID %> option:selected").text().replace("Select", "");
                sof = sof.replace("Select", "");
                var sendAmt = $('#lblSendAmt').text();

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
                if (pCountry == "Select" || pCountry == undefined)
                    pCountry = "";
                var pCountryId = $("#<%=pCountry.ClientID %> option:selected").val();
                var collMode = $("#<%=pMode.ClientID %> option:selected").text();
                var collModeId = $("#<%=pMode.ClientID %> option:selected").val();

                var pAgent = "";
                var pAgentName = "";
                if (collMode == "CASH PAYMENT TO OTHER BANK") {
                    pAgent = $("#<%=paymentThrough.ClientID %> option:selected").val();
                    pAgentName = $("#<%=paymentThrough.ClientID %> option:selected").text();
                    if (pAgentName == "Select" || pAgentName == undefined) {
                        pAgent = "";
                        pAgentName = "";
                    }
                }

                var pBankText = $("#<%=pAgent.ClientID %> option:selected").text();
                if (pBankText == "[Select]" || pBankText == "[Any Where]" || pBankText == undefined)
                    pBankText = "";
                //var pBankBranch = $("#txtpBranch_aValue").val();
                var pBankBranch = $("#branch option:selected").val();
                if (pBankBranch == "Select" || pBankBranch == undefined)
                    pBankBranch = "";


                SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pBank);
                var pBankType = $("#pAgentDetail option:selected").text();
                var pCurr = $('#lblPayCurr').text();
                var collCurr = $('#lblCollCurr').text();
                var collAmt = GetValue("<% =txtCollAmt.ClientID %>");
                var customerTotalAmt = GetValue("txtCustomerLimit");
                var payAmt = GetValue("<% =txtPayAmt.ClientID %>");
                var scharge = $('#lblServiceChargeAmt').val();
                var discount = $('#lblDiscAmt').text();
                var handling = "0";
                var exRate = $('#lblExRate').text();
                var scDiscount = $('#scDiscount').val();
                var exRateOffer = $('#exRateOffer').val();
                var schemeName = $("#<%=ddlScheme.ClientID %> option:selected").text();
                if (schemeName == "Select" || schemeName == "undefined")
                    schemeName = "";

                var schemeType = $("#<%=ddlScheme.ClientID %> option:selected").val();
                if (schemeType == "Select" || schemeType == "undefined")
                    schemeType = "";

                var couponId = $("#iTelCouponId").val();
                //sender values
                var senderId = $('#finalSenderId').text();
                var sfName = GetValue("<% =txtSendFirstName.ClientID %>");
                var smName = GetValue("<% =txtSendMidName.ClientID %>");
                var slName = GetValue("<% =txtSendLastName.ClientID %>");
                var slName2 = GetValue("<% =txtSendSecondLastName.ClientID %>");
                var sIdType = $("#<% =ddSenIdType.ClientID %> option:selected").text();
                if (sIdType == "Select" || sIdType == undefined || sIdType == "")
                    sIdType = "";
                else
                    sIdType = sIdType.split('|')[0];
                var sGender = $("#<% =ddlSenGender.ClientID %> option:selected").val();
                var sIdNo = GetValue("<% =txtSendIdNo.ClientID %>");
                var sIdValid = GetValue("<% =txtSendIdValidDate.ClientID %>");
                if (ValidateDate(sIdValid) == false) {
                    alert('Sender Id expiry date is invalid');
                    $('#txtSendIdValidDate').focus();
                    return false;
                }
                var sdob = GetValue("<% =txtSendDOB.ClientID %>");
                var sTel = GetValue("<% =txtSendTel.ClientID %>");
                var sMobile = GetValue("<% =txtSendMobile.ClientID %>");
                var sCompany = GetValue("<%=companyName.ClientID %>");

                var sNaCountry = $("#<%=txtSendNativeCountry.ClientID %> option:selected").text();

                var sCity = $('#txtSendCity').val(); --GetItem("txtSendCity")[0];
                var sPostCode = GetValue("<% =txtSendPostal.ClientID %>");
                var sAdd1 = GetValue("<% =txtSendAdd1.ClientID %>");
                var sAdd2 = GetValue("<% =txtSendAdd2.ClientID %>");
                var sEmail = GetValue("<% =txtSendEmail.ClientID %>");
                var memberCode = GetValue("<% =memberCode.ClientID %>");
                var smsSend = "N";
                if ($('#ChkSMS').is(":checked"))
                    smsSend = "Y";
                var newCustomer = "N";

                var benId = $('#finalBenId').text();
                var rfName = GetValue("<% =txtRecFName.ClientID %>");
                var rmName = GetValue("<% =txtRecMName.ClientID %>");
                var rlName = GetValue("<% =txtRecLName.ClientID %>");
                var rlName2 = GetValue("<% =txtRecSLName.ClientID %>");

                var rIdType = $("#<% =ddlRecIdType.ClientID %> option:selected").text();

                if (rIdType == "Select" || rIdType == "undefined")
                    rIdType = "";

                var rGender = $("#<% =ddlRecGender.ClientID %> option:selected").val();
                var rIdNo = GetValue("<% =txtRecIdNo.ClientID %>");
                var rIdValid = GetValue("<% =txtRecValidDate.ClientID %>");
                var rdob = GetValue("<% =txtRecDOB.ClientID %>");
                var rTel = GetValue("<% =txtRecTel.ClientID %>");
                var rMobile = GetValue("<% =txtRecMobile.ClientID %>");

                var rCity = GetValue("<% =txtRecCity.ClientID %>");
                var rPostCode = GetValue("<% =txtRecPostal.ClientID %>");
                var rAdd1 = GetValue("<% =txtRecAdd1.ClientID %>");
                var rAdd2 = GetValue("<% =txtRecAdd2.ClientID %>");
                var rEmail = GetValue("<% =txtRecEmail.ClientID %>");
                var accountNo = GetValue("<% =txtRecDepAcNo.ClientID %>");

                var pLocation = GetValue("<% =locationDDL.ClientID %>");
                var pLocationText = $("#<%=locationDDL.ClientID %> option:selected").text();
                var pSubLocation = GetValue("<% =subLocationDDL.ClientID %>");
                var pSubLocationText = $("#<%=subLocationDDL.ClientID %> option:selected").text();

                var tpExRate = $('#hddTPExRate').val();


                var isManualSC = 'N';
                if ($('#editServiceCharge').is(":checked"))
                    isManualSC = "Y";

                var manualSC = $('#lblServiceChargeAmt').val();

                //********IF NEW CUSTOMER CHECK REQUIRED FIELD******

                if ($('#NewCust').is(":checked")) {
                    newCustomer = "Y";

                    if (sfName == "" || sfName == null) {
                        alert('Sender First Name missing');
                        $('#txtSendFirstName').focus();
                        return false;
                    }
                }
                if ($('#NewCust').is(":checked") == false) {
                    if (senderId == "" || senderId == null) {
                        alert('Please Choose Existing Sender ');
                        return false;
                    }
                }
                var enrollCustomer = "N";
                if ($('#EnrollCust').is(":checked")) {
                    enrollCustomer = "Y";
                    if (memberCode == "" || memberCode == null) {
                        alert('MemberCode is missing for Customer Enrollment');
                        $('#memberCode').focus();
                        return false;
                    }
                }

                //New params added
                sCustStreet = $('#sCustStreet').val();
                sCustLocation = $('#custLocationDDL').val();
                sCustomerType = $('#ddlSendCustomerType').val();
                sCustBusinessType = $('#ddlEmpBusinessType').val();
                sCustIdIssuedCountry = $('#ddlIdIssuedCountry').val();
                sCustIdIssuedDate = $('txtSendIdExpireDate').val();
                receiverId = $('#ddlReceiver').val();

                var rel = $("#<%=relationship.ClientID %> option:selected").text().replace("Select", "");
                rel = rel.replace("Select", "");
                var occupation = $("#<%=occupation.ClientID %> option:selected").val();
                var payMsg = escape(GetValue("<% = txtPayMsg.ClientID %>"));
                var company = GetValue("<% =companyName.ClientID %>");
                var cancelrequestId = '<%=GetResendId()%>';
                var salary = $("#<%=ddlSalary.ClientID %> option:selected").val();
                if (salary == "Select" || rIdType == "undefined")
                    salary = "";
                var url = "Confirm.aspx?senderId=" + senderId +
                    "&sfName=" + sfName +
                    "&smName=" + smName +
                    "&slName=" + slName +
                    "&slName2=" + slName2 +
                    "&sIdType=" + sIdType +
                    "&sIdNo=" + sIdNo +
                    "&sIdValid=" + sIdValid +
                    "&sGender=" + sGender +
                    "&sdob=" + sdob +
                    "&sTel=" + sTel +
                    "&sMobile=" + sMobile +
                    "&sNaCountry=" + FilterString(sNaCountry) +
                    "&sCity=" + FilterString(sCity) +
                    "&sPostCode=" + FilterString(sPostCode) +
                    "&sAdd1=" + FilterString(sAdd1) +
                    "&sAdd2=" + FilterString(sAdd2) +
                    "&sEmail=" + sEmail +
                    "&smsSend=" + FilterString(smsSend) +
                    "&memberCode=" + FilterString(memberCode) +
                    "&sCompany=" + FilterString(sCompany) +
                    "&benId=" + FilterString(benId) +
                    "&rfName=" + FilterString(rfName) +
                    "&rmName=" + FilterString(rmName) +
                    "&rlName=" + FilterString(rlName) +
                    "&rlName2=" + FilterString(rlName2) +
                    "&rIdType=" + FilterString(rIdType) +
                    "&rIdNo=" + FilterString(rIdNo) +
                    "&rIdValid=" + rIdValid +
                    "&rGender=" + FilterString(rGender) +
                    "&rdob=" + rdob +
                    "&rTel=" + FilterString(rTel) +
                    "&rMobile=" + FilterString(rMobile) +
                    "&rCity=" + FilterString(rCity) +
                    "&rPostCode=" + FilterString(rPostCode) +
                    "&rAdd1=" + FilterString(rAdd1) +
                    "&rAdd2=" + FilterString(rAdd2) +
                    "&rEmail=" + rEmail +
                    "&accountNo=" + FilterString(accountNo) +
                    "&pCountry=" + FilterString(pCountry) +
                    "&payCountryId=" + FilterString(pCountryId) +
                    "&collMode=" + FilterString(collMode) +
                    "&collModeId=" + FilterString(collModeId) +
                    "&pBank=" + FilterString(pBank) +
                    "&pBankText=" + FilterString(pBankText) +
                    "&pBankBranch=" + FilterString(pBankBranch) +
                    "&pBankBranchText=" + FilterString(pBankBranchText) +
                    "&pAgent=" + FilterString(pAgent) +
                    "&pAgentName=" + FilterString(pAgentName) +
                    "&pBankType=" + pBankType +
                    "&pCurr=" + FilterString(pCurr) +
                    "&collCurr=" + FilterString(collCurr) +
                    "&collAmt=" + FilterString(collAmt) +
                    "&payAmt=" + FilterString(payAmt) +
                    "&sendAmt=" + FilterString(sendAmt) +
                    "&scharge=" + FilterString(scharge) +
                    "&customerTotalAmt=" + FilterString(customerTotalAmt) +
                    "&discount=" + FilterString(discount) +
                    "&scDiscount=" + FilterString(scDiscount) +
                    "&exRateOffer=" + FilterString(exRateOffer) +
                    //"&schemeName=" + FilterString(schemeName) +
                    "&exRate=" + FilterString(exRate) +
                    //"&schemeType=" + FilterString(schemeType) +
                    //"&couponId=" + FilterString(couponId) +
                    "&por=" + FilterString(por) +
                    "&sof=" + FilterString(sof) +
                    "&rel=" + FilterString(rel) +
                    "&occupation=" + FilterString(occupation) +
                    "&payMsg=" + payMsg +
                    "&company=" + FilterString(company) +
                    "&newCustomer=" + FilterString(newCustomer) +
                    "&EnrollCustomer=" + FilterString(enrollCustomer) +
                    "&cancelrequestId=" + FilterString(cancelrequestId) +
                    "&hdnreqAgent=" + FilterString(hdnreqAgent) +
                    "&hdnreqBranch = " + FilterString(hdnreqBranch) +
                    "&salary=" + salary +
                    "&pLocation=" + pLocation +
                    "&pLocationText=" + pLocationText +
                    "&pSubLocation=" + pSubLocation +
                    "&tpExRate=" + tpExRate +
                    "&manualSC=" + manualSC +
                    "&isManualSC=" + isManualSC +
                    //new fields
                    "&sCustStreet=" + sCustStreet +
                    "&sCustLocation=" + sCustLocation +
                    "&sCustomerType=" + sCustomerType +
                    "&sCustBusinessType=" + sCustBusinessType +
                    "&sCustIdIssuedCountry=" + sCustIdIssuedCountry +
                    "&sCustIdIssuedDate=" + sCustIdIssuedDate +
                    "&receiverId=" + receiverId +
                    //new fields added end
                    "&pSubLocationText=" + pSubLocationText;

                var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";

                var isChrome = !!window.chrome && !!window.chrome.webstore;

                if (isChrome) {
                    PopUpWindow(url, param);

                    return true;
                }
                var id = PopUpWindow(url, param);

                if (id == "undefined" || id == null || id == "") {
                }
                else {
                    var res = id.split('|');
                    if (res[0] == "1") {
                        var errMsgArr = res[1].split('\n');
                        for (var i = 0; i < errMsgArr.length; i++) {
                            alert(errMsgArr[i]);
                        }
                    }
                    else {
                        window.location.replace("NewReceipt.aspx?controlNo=" + res[1] + "&invoicePrintMode=" + res[2]);
                    }
                }

                return true;
            });
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
        function SetPayCurrency(pCountry) {

            var dataToSend = { MethodName: 'PCurrPcountry', pCountry: pCountry };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        var data = jQuery.parseJSON(response);
                        var ddl = GetElement("pCurrDdl");
                        $(ddl).empty();

                        var option;

                        for (var i = 0; i < data.length; i++) {
                            option = document.createElement("option");
                            if (data[i].isDefault == "Y") {
                                option.setAttribute("selected", "selected");
                            }
                            option.text = data[i].currencyCode;
                            option.value = data[i].currencyCode;

                            try {
                                ddl.options.add(option);
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
    </script>
    <style type="text/css">
        .amountDiv {
            background: none repeat scroll 0 0 black;
            clear: both;
            color: white;
            float: left;
            font-size: 20px;
            font-weight: 600;
            padding: 2px 8px;
            margin-right: 15px;
            margin-bottom: 10px;
            width: auto;
        }

        /*.table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 0px !important;
        }*/
    </style>
    <style type="text/css">
        .ErrMsg {
            color: red !important;
            display: inline-block !important;
            font-size: 12px;
        }
   
        #divStep1 .panel-body {
            /*background: rgba(236, 28, 28, 0.2);*/
            background: rgba(174, 214, 241, 0.4);
        }

            #divStep1 .panel-body td {
                color: #212121;
            }
            /*.sender-info .col-md-4,
            .receiver-info .col-md-4{
                  padding-right: 8px!important;
                    padding-left: 15px !important;
            }*/
          
    </style>
</head>
<body>
    <form id="form2" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-8">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Transaction</a></li>
                            <li class="active"><a href="#">Send Transaction Int'l</a></li>

                        </ol>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="amountDiv">
                        Limit :&nbsp;
                                         <asp:Label ID="availableAmt" runat="server"></asp:Label>
                        <asp:Label ID="balCurrency" runat="server" Text="MYR"></asp:Label>
                    </div>
                </div>
            </div>
            <div id="divLoad" style="position: absolute; left: 450px; top: 250px; background-color: black; border: 1px solid black; display: none;">
                Processing...
            </div>
            <div id="divStep1" class="mainContainer">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-md-4">
                                        <asp:CheckBox ID="NewCust" runat="server" Checked="true" Text="New Customer" onclick="ClearData();" />
                                    </div>
                                    <div class="col-md-4">
                                        <asp:CheckBox ID="ExistCust" runat="server" Text="Existing Customer" onclick="ExistingData();" />
                                    </div>
                                    <div class="col-md-4" style="display: none;">
                                        <asp:CheckBox ID="EnrollCust" runat="server" Text="Issue Membership Card" onclick="ClickEnroll();" />
                                    </div>
                                </div>

                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body" id="divHideShow">
                                <div class="row">
                                    <div class="col-md-2">
                                        <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="accountNo" Text="Account No."></asp:ListItem>
                                            <asp:ListItem Value="email" Text="Email ID" Selected="True"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-3">
                                        <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" CssClass="form-control" Param1="@GetCustomerSearchType()" Title="Blank for All" />
                                    </div>
                                    <div style="display: none;">
                                        <div class="col-md-1">
                                            <label class="control-label">Country:</label>
                                        </div>
                                        <div class="col-md-2">

                                            <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <input name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" class="btn btn-primary" value="Advance Search" />
                                        <input name="button4" type="button" id="btnClear" value="Clear All Customer Info" class="btn btn-primary" onclick="ClearAllCustomerInfo();" />

                                    </div>
                                </div>

                            </div>
                        </div>
                        <input type="hidden" id="hdnPayMode" runat="server" />
                        <input type="hidden" id="hdntranCount" runat="server" />
                        <asp:HiddenField ID="hdnLimitAmount" runat="server" />
                        <asp:HiddenField ID="hdnBeneficiaryIdReq" runat="server" />
                        <asp:HiddenField ID="hdnBeneficiaryContactReq" runat="server" />
                        <asp:HiddenField ID="hdnRelationshipReq" runat="server" />
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">Sender Information: <span id="senderName"></span></h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row form-group ">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Sender Name: <span class="ErrMsg" id='txtSendFirstName_err'>*</span>
                                        </label>
                                    </div>
                                    <div class="col-md-4">
                                         <div class="row sender-info">
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtSendFirstName" placeholder="First Name" runat="server" CssClass="required SmallTextBox form-control" onblur="CheckForSpecialCharacter(this,'Sender First Name');"></asp:TextBox>
                                    </div>

                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtSendMidName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Sender Middle Name');"></asp:TextBox>
                                    </div>

                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtSendLastName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Sender Last Name');"></asp:TextBox>
                                        <span class="ErrMsg" id='txtSendLastName_err'></span>
                                    </div>

                                    <div style="display: none;">
                                        <div class="col-md-2">
                                            <asp:TextBox ID="txtSendSecondLastName" runat="server" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Sender Second Last Name');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                    </div>
                                    </div>
                                
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Email:</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtSendEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control"></asp:TextBox>
                                        <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                            ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                            ControlToValidate="txtSendEmail"></asp:RegularExpressionValidator>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Customer Type:
                                        </label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlSendCustomerType" runat="server" CssClass="SmallTextBox form-control">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Zip Code
                                        </label>

                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtSendPostal" runat="server" placeholder="Potsal Code" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Sender Postal Code');"></asp:TextBox>
                                    </div>
                                    <div id="trSenCompany" runat="server">
                                        <div class="col-md-2">

                                            <asp:Label runat="server" class="control-label" ID="lblCompName" Text="Company Name:"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='companyName_err'>*</span>

                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="companyName" runat="server" placeholder="Company Name" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Sender Company Name');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Street  <span runat="server" class="ErrMsg" id='sCustStreet_err'>*</span>
                                        </label>

                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="sCustStreet" runat="server" placeholder="Street" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Sender Street Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Business Type <span runat="server" class="ErrMsg" id='Span2'>*</span></label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlEmpBusinessType" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>

                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2" id="tdSenCityLbl" runat="server">
                                        <label class="control-label"></label>
                                        <asp:Label runat="server" ID="lblsCity" Text="City:" class="control-label"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='txtSendCity_err'>*</span>

                                    </div>
                                    <div class="col-md-4" id="tdSenCityTxt" runat="server">

                                        <%--<uc1:SwiftTextBox ID="txtSendCity" Category="remit-cityList" Param1="NotClear" runat="server" CssClass="form-control" />--%>
                                        <asp:TextBox ID="txtSendCity" runat="server" placeholder="City" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Sender City');"></asp:TextBox>

                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            State:<span class="ErrMsg">*</span>
                                        </label>

                                    </div>
                                    <div class="col-md-3">
                                        <asp:DropDownList ID="custLocationDDL" runat="server" CssClass="form-control required"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-1">
                                        <span id="lblSendCountryName"><b>JAPAN</b></span>
                                    </div>

                                </div>
                                <div class="row form-group">

                                    <div id="trSenId" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" class="control-label" ID="lblsIdtype" Text="ID Type:"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='ddSenIdType_err'>*</span>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:DropDownList ID="ddSenIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblSidNo" Text="ID Number:" class="control-label" Style="display: none;"></asp:Label>

                                            <asp:TextBox ID="txtSendIdNo" placeholder="ID Number" MaxLength="14" runat="server" CssClass="form-control" onblur="CheckSenderIdNumber(this);"></asp:TextBox><span runat="server" class="ErrMsg" id='txtSendIdNo_err'></span>
                                            <br />
                                            <span id="spnIdNumber" style="color: red; font-size: 10px; font-family: verdana; font-weight: bold; display: none;"></span>
                                        </div>
                                    </div>
                                    <div id="trSenContactNo" runat="server">
                                        <div class="col-md-2" id="tdSenMobileNoLbl" runat="server">
                                            <label class="control-label">Mobile No:<span runat="server" class="ErrMsg" id='txtSendMobile_err'>*</span></label>
                                        </div>
                                        <div class="col-md-2" id="tdSenMobileNoTxt" runat="server">
                                            <asp:TextBox ID="txtSendMobile" runat="server" placeholder="Mobile Number" CssClass="form-control" MaxLength="13"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2" id="tdSenTelNoTxt" runat="server">
                                            <asp:TextBox ID="txtSendTel" runat="server" placeholder="Phone Number" CssClass="form-control" onblur="CheckForMobileNumber(this);" MaxLength="17"></asp:TextBox>
                                        </div>
                                    </div>

                                </div>

                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Place Of Issue</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlIdIssuedCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Gender:</label>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:DropDownList ID="ddlSenGender" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="">Select</asp:ListItem>
                                            <asp:ListItem Value="Male">Male</asp:ListItem>
                                            <asp:ListItem Value="Female">Female</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>




                                <div class="row form-group" id="trIdExpirenDob" runat="server">
                                    <div class="col-md-2 showHideIDIssuedDate" id="tdSenIssuedDateLbl" runat="server">
                                        <asp:Label runat="server" ID="lblsIssuedDate" Text="Issued Date:" class="control-label"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='Span1'>*</span>
                                    </div>
                                    <div class="col-md-4 showHideIDIssuedDate" id="td2" runat="server" nowrap="nowrap">
                                        <asp:TextBox ID="txtSendIdExpireDate" runat="server" placeholder="MM/DD/YYYY" CssClass="form-control"></asp:TextBox>
                                        <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="txtSendIdExpireDate"
                                            Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                            ErrorTooltipEnabled="True" />
                                        <asp:RangeValidator ID="RangeValidator3" runat="server"
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
                                    <div class="col-md-2 showHideIDExpDate" id="tdSenExpDateLbl" runat="server" nowrap="nowrap">
                                        <asp:Label runat="server" ID="lblsExpDate" Text="Expire Date:" class="control-label"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='txtSendIdValidDate_err'>*</span>
                                    </div>
                                    <div class="col-md-4 showHideIDExpDate" id="tdSenExpDateTxt" runat="server" nowrap="nowrap">
                                        <asp:TextBox ID="txtSendIdValidDate" runat="server" placeholder="MM/DD/YYYY" CssClass="form-control"></asp:TextBox>
                                        <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="txtSendIdValidDate"
                                            Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                            ErrorTooltipEnabled="True" />
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
                                </div>


                                <div class="row form-group">
                                    <div class="col-md-2" id="tdSenDobLbl" runat="server">
                                        <label class="control-label">
                                            <asp:Label runat="server" ID="lblSDOB" Text="Date Of Birth:"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='txtSendDOB_err'>*</span>
                                        </label>
                                    </div>
                                    <div class="col-md-4" id="tdSenDobTxt" runat="server" nowrap="nowrap">
                                        <asp:TextBox ID="txtSendDOB" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                        <asp:RangeValidator ID="RangeValidator1" runat="server"
                                            ControlToValidate="txtSendDOB"
                                            MaximumValue="12/31/2100"
                                            MinimumValue="01/01/1900"
                                            Type="Date"
                                            ErrorMessage="Invalid date!"
                                            ValidationGroup="customer"
                                            CssClass="inv"
                                            SetFocusOnError="true"
                                            Display="Dynamic"> </asp:RangeValidator>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Native Country:  <span class="ErrMsg" id='txtSendNativeCountry_err'>*</span></label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="txtSendNativeCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel panel-default" style="display: none;">
                            <div class="'panel-body">
                                <div class="row form-group">
                                    <div id="trSenAddress1" runat="server" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">Address1:</label>
                                            <span runat="server" class="ErrMsg" id='txtSendAdd1_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtSendAdd1" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div id="trSenAddress2" runat="server" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">Address2:</label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtSendAdd2" runat="server" CssClass="LargeTextBox form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div style="display: none">
                                        <div class="col-md-2">
                                            <label class="control-label">Send SMS To Sender:</label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:CheckBox ID="ChkSMS" runat="server" />
                                        </div>
                                    </div>
                                    <div>
                                        <div class="col-md-2">
                                            <label class="control-label" id="lblMem" style="display: none">Membership ID:</label>
                                        </div>
                                        <div class="col-md-4" id="valMem" style="display: none">
                                            <asp:TextBox ID="memberCode" runat="server" CssClass="form-control"></asp:TextBox>
                                            <span id="memberCode_err" class="ErrMsg"></span>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="col-md-2">
                                            <label class="control-label"></label>
                                        </div>
                                        <div class="col-md-4" id="divSenderIdImage">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-md-10">
                                        <h4 class="panel-title">Receiver Information:  <span id="receiverName"></span></h4>
                                    </div>
                                    <div class="col-md-2">
                                        <div style="float: right; margin-right: 15px;">
                                            <a href="javascript:void(0);" class="btn btn-xs btn-primary" onclick="PickReceiverFromSender('r');" title="Pick Receiver"><i class="fa fa-file-archive-o"></i></a>
                                            <a href="javascript:void(0);" id="btnReceiverClr" class="btn btn-xs btn-primary" title="Clear"><i class="fa fa-eraser"></i></a>
                                            <%--<a href="javascript:void(0);" style="margin-left: 10px; margin-right: 10px; margin-top: -10px;">Clear</a>--%>
                                            <%--<input id="btnReceiverClr" type="button" value="Clear" class="btn btn-primary" style="margin-left: 10px; margin-right: 10px;" />--%>
                                        </div>
                                    </div>
                                </div>

                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Choose Receiver: </label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlReceiver" runat="server" onchange="DDLReceiverOnChange();" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="row form-group ">
                                    <div class="col-md-2">
                                        <label class="control-label">Receiver Name:</label>
                                        <span class="ErrMsg" id='txtRecFName_err'>*</span>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="row receiver-info">
                                             <div class="col-md-4">
                                        <asp:TextBox ID="txtRecFName" runat="server" placeholder="First Name" CssClass="required SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Receiver First Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtRecMName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Middle Name');"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtRecLName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Last Name');"></asp:TextBox>
                                        <span class="ErrMsg" id='txtRecLName_err'></span>
                                    </div>
                                    <div class="col-md-4" style="display: none;">
                                        <asp:TextBox ID="txtRecSLName" runat="server" CssClass="SmallTextBox form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Second Last Name');"></asp:TextBox>
                                    </div>
                                        </div>
                                    </div>
                                   
                                </div>
                                <div class="row form-group">
                                    <div id="trRecId" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblRidType" Text="ID Type:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='ddlRecIdType_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="ddlRecIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div id="trRecId1" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblRidNo" Text="ID Number:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='txtRecIdNo_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtRecIdNo" runat="server" MaxLength="7" placeholder="ID Number" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver ID Number');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group" id="trRecIdExpirynDob" runat="server">
                                    <div class="col-md-2 recIdDateValidate" id="tdRecIdExpiryLbl" runat="server">
                                        <asp:Label runat="server" ID="lblrExpDate" Text="ID Expiry Date:" CssClass="control-label"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='txtRecValidDate_err'>*</span>
                                    </div>
                                    <div class="col-md-4 recIdDateValidate" id="tdRecIdExpiryTxt" runat="server" nowrap="nowrap">
                                        <asp:TextBox ID="txtRecValidDate" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                        <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="txtRecValidDate"
                                            Mask="99/99/9999" MessageValidatorTip="true" MaskType="Date" InputDirection="LeftToRight"
                                            ErrorTooltipEnabled="True" />
                                        <asp:RangeValidator ID="RangeValidator4" runat="server"
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
                                    <div class="col-md-2" id="tdRecDobLbl" runat="server">
                                        <asp:Label runat="server" ID="lblDOB" Text="DOB:"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='txtRecDOB_err'>*</span>
                                    </div>
                                    <div class="col-md-4" id="tdRecDobTxt" runat="server" nowrap="nowrap">
                                        <asp:TextBox ID="txtRecDOB" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div id="trRecAddress1" runat="server">
                                        <div class="col-md-2">
                                            <label class="control-label">Address1:</label>
                                            <span runat="server" class="ErrMsg" id='txtRecAdd1_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtRecAdd1" runat="server" placeholder="Receiver Address" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div id="trRecAddress2" runat="server" style="display: none;">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblrAdd" Text="Address2:"></asp:Label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtRecAdd2" runat="server" CssClass="LargeTextBox form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2" id="tdRecCityLbl" runat="server">
                                        <asp:Label runat="server" ID="lblrCity" Text="City:" CssClass="control-label"></asp:Label>
                                        <span runat="server" class="ErrMsg" id='txtRecCity_err'>*</span>
                                    </div>
                                    <div class="col-md-4" id="tdRecCityTxt" runat="server">
                                        <asp:TextBox ID="txtRecCity" placeholder="Receiver City" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver City');"></asp:TextBox>
                                        <asp:TextBox Style="display: none" ID="txtRecPostal" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Postal Code');"></asp:TextBox>
                                    </div>
                                    <div id="trRecContactNo" runat="server">
                                        <div class="col-md-2" id="tdRecMobileNoLbl" runat="server">
                                            <label class="control-label">Mobile No:</label><span runat="server" class="ErrMsg" id='txtRecMobile_err'>*</span>
                                        </div>
                                        <div class="col-md-2" id="tdRecMobileNoTxt" runat="server">
                                            <asp:TextBox ID="txtRecMobile" runat="server" placeholder="Mobile Number" CssClass="form-control" onblur="CheckForMobileNumber(this, 'Receiver Mobile No.');"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2" id="tdRecTelNoTxt" runat="server">
                                            <asp:TextBox ID="txtRecTel" runat="server" placeholder="Phone Number" CssClass="form-control" onblur="CheckForMobileNumber(this, 'Receiver Tel. No.');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>


                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Gender:</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlRecGender" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="">Select</asp:ListItem>
                                            <asp:ListItem Value="Male">Male</asp:ListItem>
                                            <asp:ListItem Value="Female">Female</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Email:</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtRecEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control"></asp:TextBox>
                                        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                            ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                            ControlToValidate="txtRecEmail"></asp:RegularExpressionValidator>
                                    </div>
                                </div>

                            </div>
                        </div>



                        <div class="panel panel-default margin-b-30">
                            <div class="panel-heading">
                                <h4 class="panel-title">Transaction Information:</h4>
                                <span style="display: none; background-color: black; font-size: 15px; color: #FFFFFF; line-height: 13px; vertical-align: middle; text-align: center; font-weight: bold;">[Per day per customer transaction limit:
                                    <asp:Label ID="lblPerDayLimit" runat="server"></asp:Label>&nbsp;<asp:Label ID="lblPerDayCustomerCurr" runat="server"></asp:Label>

                                </span>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">

                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Receiving Country:</label>
                                        <span class="ErrMsg" id="pCountry_err">*</span>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Receiving Mode:</label><span class="ErrMsg">*</span>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="pMode" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            <span id="lblPayoutAgent">Agent / Bank:</span>
                                        </label>
                                        <span class="ErrMsg" id="pAgent_err">*</span>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                        <asp:DropDownList ID="pAgentDetail" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                        <asp:DropDownList ID="pAgentMaxPayoutLimit" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                        <span id="hdnreqAgent" style="display: none"></span>
                                        <input type="hidden" id="hdnBankType" />
                                    </div>
                                    <div class="col-md-2 same" style="display: none">
                                        <label class="control-label">Branch:</label><span class="ErrMsg">*</span>
                                    </div>
                                    <div class="col-md-4 same" style="display: none">
                                        <div id="divBankBranch"></div>
                                        <input type="hidden" id="txtpBranch_aValue" class="form-control" />
                                        <span id="hdnreqBranch" style="display: none"></span><span class="ErrMsg" id="reqBranch" style="display: none"></span>
                                        <div id="divBranchMsg" style="display: none;" class="note"></div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div id="trForCPOB" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">
                                                Payment through:
                                                        <span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="paymentThrough" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div id="trAccno" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">
                                                Bank Account No:
                                                        <span id="txtRecDepAcNo_err" class="ErrMsg">*</span>
                                            </label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtRecDepAcNo" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Acc No.');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div id="trScheme" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">Scheme/Offer:</label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="ddlScheme" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div id="tdItelCouponIdLbl" style="display: none;">
                                        <div class="col-md-2">
                                            <label class="control-label">ITEL Coupon ID:</label>
                                        </div>
                                        <div class="col-md-4" id="tdItelCouponIdTxt" style="display: none;">

                                            <asp:TextBox ID="iTelCouponId" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group" id="locationRow" style="display: none;">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            State:<span class="ErrMsg">*</span>
                                        </label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="locationDDL" runat="server" CssClass="form-control required"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">District:<span class="ErrMsg">*</span></label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="subLocationDDL" runat="server" CssClass="form-control required"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Collection Amount:</label><span class="ErrMsg" id='txtCollAmt_err'>*</span>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="txtCollAmt" runat="server" placeholder="Amount including service charge" CssClass="required BigAmountField form-control" Style="font-size: 16px; font-weight: bold; padding: 2px;"></asp:TextBox>
                                        <asp:Label ID="lblCollCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label><br />
                                        (Max Limit: <u><b>
                                            <asp:Label ID="lblPerTxnLimit" runat="server" Text="0.00"></asp:Label></b></u>)&nbsp;
                                                            <asp:Label ID="lblPerTxnLimitCurr" runat="server"></asp:Label>
                                    </div>
                                    <div class="col-md-2" id="tdLblPCurr">
                                        <label class="control-label">Payout Currency:<span class="ErrMsg">*</span></label>
                                    </div>
                                    <div class="col-md-4" id="tdTxtPCurr">
                                        <select id="pCurrDdl" class="form-control" onchange="CalculateTxn();"></select>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Service Charge:</label>
                                    </div>
                                    <div class="col-md-2">
                                        <input type="checkbox" id="editServiceCharge" runat="server">EDIT</input>
                                        <asp:HiddenField ID="allowEditSC" runat="server" />
                                    </div>
                                    <div class="col-md-2">
                                        <asp:TextBox ID="lblServiceChargeAmt" runat="server" Text="0" class="form-control" Style="display: inherit !important;" onblur="return ReCalculate();"></asp:TextBox>
                                        <asp:Label ID="lblServiceChargeCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="control-label">Sending Amount:</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:Label ID="lblSendAmt" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                        <asp:Label ID="lblSendCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Customer Rate:</label>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:Label ID="lblExRate" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                        <asp:Label ID="lblExCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                    </div>
                                    <div class="col-md-2" id="tdScheme" style="display: none;">
                                        <label class="control-label">Scheme/Offer:</label>
                                    </div>
                                    <div class="col-md-4" id="tdSchemeVal" style="display: none;">
                                        <span id="spnSchemeOffer" style="font-weight: bold; font-family: Verdana; color: black; font-size: 10px;"></span>
                                        <input type="hidden" id="scDiscount" name="scDiscount" />
                                        <input type="hidden" id="exRateOffer" value="exRateOffer" />
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Payout Amount: <span class="ErrMsg" id='txtPayAmt_err'>*</span>
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:TextBox ID="txtPayAmt" runat="server" Enabled="false" CssClass="required BigAmountField disabled form-control"></asp:TextBox>
                                        <asp:Label ID="lblPayCurr" runat="server" Text="" class="amountLabel"></asp:Label></td>
                                    </div>
                                    <div class="col-md-2">
                                        <span id="spnPayoutLimitInfo" style="color: red; font-size: 16px; font-weight: bold;"></span>
                                    </div>

                                </div>
                                <div class="row form-group">
                                    <div class="col-md-12">
                                        <input type="button" id="btnCalculate" value="Calculate" class="btn btn-primary" />&nbsp;
                                                        <input type="button" id="btnCalcClean" value="Clear" class="btn btn-primary" />&nbsp;
					                                    <input name="button" type="button" id="btnCalcPopUp" value="Calculator" class="btn btn-primary" />

                                        <span id="finalSenderId" style="display: none"></span>
                                        <span id="finalBenId" style="display: none"></span>

                                        <input type="hidden" id="finalAgentId" />
                                        <input type="hidden" id="txtCustomerLimit" value="0" />
                                        <asp:HiddenField ID="txnPerDayCustomerLimit" runat="server" Value="0" />
                                        <input type="hidden" id="hdnInvoicePrintMethod" />
                                    </div>
                                    <div class="col-md-12">
                                        <center>
                                            <span id="span_txnInfo" align="center" runat="server" style="font-size: 15px; color: #FFFFFF; background-color: #333333; line-height: 15px; vertical-align: middle; text-align: center; font-weight: bold; "></span>
                                        </center>
                                    </div>
                                    <div class="col-md-12">
                                        <span id="spnWarningMsg" style="font-size: 13px; font-family: Verdana; font-weight: bold; color: Red;"></span></td>
                                    </div>
                                </div>


                            </div>
                        </div>

                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">Customer Due Diligence Information -(CDDI)</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row form-group">
                                    <div id="trOccupation" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblOccupation" Text="Occupation:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='occupation_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="occupation" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div id="trSourceOfFund" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblSof" Text="Source of Fund:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='sourceOfFund_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="sourceOfFund" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div id="trPurposeOfRemittance" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblPoRemit" Text="Purpose of Remittance:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='purpose_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="purpose" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div id="trRelWithRec" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblRelation" Text="Relationship with Receiver:" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='relationship_err'>*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="relationship" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div id="trSalaryRange" runat="server">
                                        <div class="col-md-2">
                                            <asp:Label runat="server" ID="lblSalaryRange" Text="Monthly Income:" CssClass="control-label"></asp:Label>
                                            <span runat="server" id="ddlSalary_err" class="ErrMsg">*</span>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control">
                                                <asp:ListItem>Select</asp:ListItem>
                                                <asp:ListItem>KRW 0-KRW1,700,000</asp:ListItem>
                                                <asp:ListItem>KRW1,700,000- KRW3,400,000</asp:ListItem>
                                                <asp:ListItem>KRW3,400,000-KRW6,800,000</asp:ListItem>
                                                <asp:ListItem>KRW6,800,000-KRW13,000,000</asp:ListItem>
                                                <asp:ListItem>Above KRW13,000,000</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="col-md-2">
                                            <label class="control-label">Message to Receiver:</label>
                                        </div>
                                        <div class="col-md-4">
                                            <asp:TextBox ID="txtPayMsg" runat="server" CssClass="LargeTextBox form-control" TextMode="MultiLine" onblur="CheckForSpecialCharacter(this, 'Message to Receiver');"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row form-group">
                                    <div class="col-md-12">
                                        <input type="button" name="calc" id="calc" value="Send Transaction" class="btn btn-primary" />
                                    </div>
                                    
                                </div>


                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddTPExRate" runat="server" />
    </form>
</body>
</html>
<script type="text/javascript">
    ClearData();

    function Autocomplete() {
        $(".searchinput").autocomplete({
            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "../../../Autocomplete.asmx/GetAllCountry",
                    data: "{'keywordStartsWith':'" + request.term + "'}",
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
    }

    Autocomplete();

</script>
<script type="text/javascript">
    function PickSenderData(obj) {
        var url = "";
        if (obj == "a") {
            url = "" + "TxnHistory/SenderAdvanceSearch.aspx";
        }
        if (obj == "s") {
            url = "" + "TxnHistory/SenderTxnHistory.aspx";
        }
        var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
        var res = PopUpWindow(url, param);

        if (res == "undefined" || res == null || res == "") {
        }
        else {

            PickDataFromSender(res);
        }
    }
    //PickLocation
    function PickLocation() {
        var pAgent = $('#<%=pAgent.ClientID %> option:selected').val();
        $('#<%=pAgentDetail.ClientID %>').val(pAgent);
        var pAgentType = $('#<%=pAgentDetail.ClientID %> option:selected').text();
        if (pAgent == "" || pAgent == undefined || pAgent == 0) {
            alert('First Select a Agent/Branch');
            $('#<%=pAgent.ClientID %>').focus();
            return;
        }
        var url = "TxnHistory/PickLocationByAgent.aspx?pAgent=" + pAgent;
        var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
        var res = PopUpWindow(url, param);

    }
    function PickpBranch() {
        var pAgent = $('#<%=pAgent.ClientID %> option:selected').val();
        $('#<%=pAgentDetail.ClientID %>').val(pAgent);
        var pAgentType = $('#<%=pAgentDetail.ClientID %> option:selected').text();
        if (pAgent == "" || pAgent == undefined || pAgent == 0) {
            alert('First Select a Agent/Branch');
            $('#<%=pAgent.ClientID %>').focus();
            return;
        }
        var url = "TxnHistory/PickBranchByAgent.aspx?pAgent=" + pAgent + "&pAgentType=" + pAgentType;
        var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
        var res = PopUpWindow(url, param);
        if (res == "undefined" || res == null || res == "") {
        }
        else {
            var splitVal = res.split('|');
            var pBranchValue = splitVal[0];
            var pBranchText = splitVal[1];
            $("#txtpBranch_aValue").val(splitVal[0]);
            $("#txtpBranch_aText").val(splitVal[1]);

            var pMode = $("#<%=pMode.ClientID%> option:selected").text();
            if (pMode == "CASH PAYMENT TO OTHER BANK")
                PBranchChange(pBranchValue);
        }
    }

    function PickReceiverFromSender(obj) {
        //var urlRoot = "%=GetStatic.GetUrlRoot() %>";PickReceiverFromSender
        var senderId = $('#finalSenderId').text();
        var sName = $('#senderName').text();
        if (senderId == "" || senderId == "undefined") {
            alert('Please select the Sender`s Details');
            return;
        }
        var url = "";
        if (obj == "r") {
            url = "" + "TxnHistory/ReceiverHistoryBySender.aspx?sname=" + sName + "&senderId=" + senderId;
        }
        if (obj == "s") {
            url = "" + "TxnHistory/SenderTxnHistory.aspx?senderId=" + senderId;
        }

        //var url = "" + "TxnHistory/ReceiverHistoryBySender.aspx?senderId=" + senderId;
        var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
        var res = PopUpWindow(url, param);
        if (res == "undefined" || res == null || res == "") {
        }
        else {
            //PickDataFromSender(res);
            SetReceiverFromSender(res);
        }
    }

    function ShowHide(me, tbl) {
        var text = me.value;
        if (text == "+") {
            me.value = "-";
            me.title = "Hide";
            ShowElement(tbl);
        } else {
            me.value = "+";
            me.title = "Show";
            HideElement(tbl);
        }
    }

    function Show(me, tbl) {
        me.value = "-";
        me.title = "Hide";
        ShowElement(tbl);
    }

    $('#txtSendDOB').blur(function () {
        var CustomerDob = GetValue("<%=txtSendDOB.ClientID %>");
        if (CustomerDob != "") {
            var CustYears = datediff(CustomerDob, 'years');

            if (parseInt(CustYears) < 18) {
                alert('Customer age must be 18 or above !');
                return;
            }
        }
    });

    $(function () {
        $('#btnCalcPopUp').click(function () {
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            var pMode = GetValue("<%=pMode.ClientID %>");
            var pAgent = GetValue("<%=pAgent.ClientID %>");
            if (pMode == "") {
                alert("Please select receiving mode");
                return;
            }
            var queryString = "?pMode=" + pMode + "&pCountry=" + pCountry + "&pAgent=" + pAgent;
            var res = PopUpWindow("Calculator.aspx" + queryString, "dialogHeight:350px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes");
            if (res == "undefined" || res == null || res == "") {
            }
            else {
                //PickDataFromSender(res);
                GetElement("<%=txtCollAmt.ClientID %>").value = res;
                CalculateTxn();
            }
        });
    });

    document.getElementById("NewCust").focus();

    $(function () {
        $('#ddlRecIdType').change(function () {
            var idType = $("#ddlRecIdType option:selected").text();

            if (idType == "Alien Registration Card") {
                $(".recIdDateValidate").css("display", "");
            }
            else {
                $(".recIdDateValidate").css("display", "none");
            }
        });
    });

    $(function () {
        $("#<%= pAgent.ClientID %>").change(function () {
            var bankId = $("#<%= pAgent.ClientID %> option:selected").val();
            PopulateBankDetails(bankId);
        });
    });

    function PopulateBankDetails(bankId, receiveMode, isBranchByName, branchSelected) {
        ManageHiddenFields(receiveMode);
        var dataToSend = '';
        if (isBranchByName == '' || isBranchByName == undefined) {
            dataToSend = { bankId: bankId, type: 'bb' };
        }
        else {
            dataToSend = { bankId: bankId, type: 'bb', isBranchByName: isBranchByName, branchSelected: branchSelected };
        }


        $.get("/AgentPanel/International/SendMoneyv2/FormLoader.aspx", dataToSend, function (data) {
            GetElement("divBankBranch").innerHTML = data;
        });
    }
    function ManageHiddenFields(receiveMode) {
        receiveMode = ($("#pMode option:selected").val() == '' || $("#pMode option:selected").val() == undefined) ? receiveMode : $("#pMode option:selected").val();
        if (receiveMode == "2" || receiveMode.toUpperCase() == 'BANK DEPOSIT') {
            $(".same").css("display", "");
        }
        else {
            $(".same").css("display", "none");
        }
    }

</script>
