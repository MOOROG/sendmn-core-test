<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Send.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendTransactionIRH.Send" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Send Transaction</title>

    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
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

        LoadCalendars();
        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }

        //    function ViewImage(senderId) {
        //        var url = "CustomerID.aspx?customerId=" + senderId;
        //        OpenDialog(url, 500, 620, 100, 100);
        //    }

        function LoadCalendars() {
            VisaValidDateSend("#<% =txtSendIdValidDate.ClientID%>");
        CalSenderDOB("#<% =txtSendDOB.ClientID%>");
        CalReceiverDOB("#<% =txtRecDOB.ClientID%>");
        VisaValidDateRec("#<% =txtRecValidDate.ClientID%>");
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
        $("#lblServiceChargeAmt").text('0.00');
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
            $("#txtSendIdValidDate").attr("class", "required");
        }
        else {
            var senIdTypeArr = senIdType.split('|');
            if (senIdTypeArr[1] == "E") {
                $("#tdSenExpDateLbl").show();
                $("#tdSenExpDateTxt").show();
                $("#txtSendIdValidDate").attr("class", "required");
            }
            else {
                $("#tdSenExpDateLbl").hide();
                $("#tdSenExpDateTxt").hide();
                $("#txtSendIdValidDate").attr("class", "");
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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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

        $("#tdLblLocation").hide();
        $("#tdTxtLocation").hide();
        $('#txtpLocation_Text').attr("class", "disabled");
        $("#txtpLocation_Text").val('');
        $("#txtpLocation_Value").val('');

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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
        var collAmtFormatted = collAmt;  //CurrencyFormatted(collAmt);

        collAmtFormatted = CommaFormatted(collAmtFormatted);
        var collCurr = $('#lblCollCurr').text();
        if (collAmt == "0")
            return;
        if (confirm("You have entered " + collAmtFormatted + " " + collCurr + " as collection amount")) {
            checkdata(collAmt, 'cAmt');
        }
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

        $("#pCountry").change(function () {
            ResetAmountFields();
            $("#<%=pMode.ClientID %>").empty();
            $("#<%=pAgent.ClientID %>").empty();

            $("#tdLblBranch").hide();
            $("#tdTxtBranch").hide();
            $("#tdItelCouponIdLbl").hide();
            $("#tdItelCouponIdTxt").hide();
            $('#txtpBranch_aText').attr("class", "disabled");
            $("#txtpBranch_err").hide();
            $("#txtpBranch_aValue").val('');
            $("#txtpBranch_aText").val('');
            $("#txtRecDepAcNo").val('');
            $("#lblExCurr").text('');
            $("#lblPayCurr").text('');

            //for location field
            $("#tdLblLocation").hide();
            $("#tdTxtLocation").hide();
            $('#txtpLocation_Text').attr("class", "disabled");
            $("#txtpLocation_Text").val('');
            $("#txtpLocation_Value").val('');
            GetElement("spnPayoutLimitInfo").innerHTML = "";
            if ($("#pCountry option:selected").val() != "") {
                PcountryOnChange('c', "");
            }
        });

        $("#pMode").change(function () {
            $("#txtRecDepAcNo").val('');
            $("#tdLblBranch").hide();
            $("#tdTxtBranch").hide();
            $('#txtpBranch_aText').attr("class", "disabled");
            $("#txtpBranch_err").hide();
            $("#txtpBranch_aValue").val('');
            $("#txtpBranch_aText").val('');
            ReceivingModeOnChange();
        });

        $("#paymentThrough").change(function () {
            ResetAmountFields();
            LoadCustomerRate();
        });

        $("#pAgent").change(function () {
            ResetAmountFields();
            $("#txtpBranch_aValue").val('');
            $("#txtpBranch_aText").val('');
            $("#txtRecDepAcNo").val('');

            //for location field
            $("#tdLblLocation").hide();
            $("#tdTxtLocation").hide();
            $("#txtpLocation_Text").val('');
            $("#txtpLocation_Value").val('');

            if ($("#pAgent option:selected").val() != "") {
                var pmode = $('#<%=pMode.ClientID %> option:selected').text();
                if (pmode == "DOOR TO DOOR") {
                    $("#tdLblLocation").show();
                    $("#tdTxtLocation").show();
                    $('#txtpLocation_Text').attr("class", "required disabled");
                }
                PAgentChange();
                SchemeByPCountry();
                var pCountry = $("#pCountry option:selected").text();
                $("#pAgentMaxPayoutLimit").val($("#pAgent option:selected").val());
                var payoutLimit = $("#pAgentMaxPayoutLimit option:selected").text();
                GetElement("spnPayoutLimitInfo").innerHTML = "Payout Limit for " + pCountry + " : " + payoutLimit;
            }
            else {
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $("#tdLblLocation").hide();
                $("#tdTxtLocation").hide();
                $('#txtpLocation_Text').attr("class", "");
            }
            //                <txtpBranch.InitFunction() %>
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
        $("#lblServiceChargeAmt").text('0.00');
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

    $(function () {
        $('#btnSearchCustomer').click(function () {
            var searchType = GetValue("<%=ddlCustomerType.ClientID %>"); //"MobileNo";
            var searchValue = GetValue("<%=txtSearchData.ClientID %>"); //"9841298807";
            if (searchValue == "" || searchValue == null) {
                alert('Search value is missing');
                $('#txtSearchData').focus();
                return false;
            }
            var dataToSend = { MethodName: 'SearchCustomer', searchType: searchType, searchValue: searchValue };

            var options =
                            {
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
                                data: dataToSend,
                                dataType: 'JSON',
                                type: 'POST',
                                success: function (response) {
                                    ParseResponseData(response);
                                }
                            };
            $.ajax(options);
            return true;
        });
    });

    ////calculation part
    $(function () {
        $('#btnCalculate').click(function () {
            CalculateTxn();
        });
    });

    function CalculateTxn(amt, obj) {
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

        var payCurr = $('#lblPayCurr').text();
        var collCurr = $('#lblCollCurr').text();
        var senderId = $('#finalSenderId').text();
        var couponId = $("#iTelCouponId").val();

        var dataToSend = {
            MethodName: 'CalculateTxn', pCountry: pCountry, pCountrytxt: pCountrytxt, pMode: pMode, pAgent: pAgent
                                , pAgentBranch: pAgentBranch, collAmt: collAmt, payAmt: payAmt, payCurr: payCurr, collCurr: collCurr
                                , pModetxt: pModetxt, senderId: senderId, schemeCode: schemeCode, couponId: couponId
        };

        var options =
                            {
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
                                data: dataToSend,
                                dataType: 'JSON',
                                type: 'POST',
                                success: function (response) {
                                    ParseCalculateData(response, obj);
                                }
                            };
        $.ajax(options);

        return true;
    }

    function ClearAmountFields() {
        $('#lblSendAmt').text('0.00');
        $('#lblExRate').text('0.00');
        $('#lblPerTxnLimit').text('0.00');
        $('#lblServiceChargeAmt').text('0.00');
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

        $('#lblPerTxnLimit').text(data[0].limit);
        $('#lblPerTxnLimitCurr').text(data[0].limitCurr);

        $('#lblServiceChargeAmt').text(parseFloat(data[0].scCharge).toFixed(2));

        SetValueById("<%=txtCollAmt.ClientID %>", parseFloat(data[0].collAmt.toFixed(3)), ""); //
        SetValueById("<%=lblSendAmt.ClientID %>", parseFloat(data[0].sAmt.toFixed(3)), ""); //
        SetValueById("<%=txtPayAmt.ClientID %>", parseFloat(data[0].pAmt).toFixed(2), "");

        var exRateOffer = data[0].exRateOffer;
        var scOffer = data[0].scOffer;
        var scDiscount = data[0].scDiscount;
        SetValueById("scDiscount", data[0].scDiscount, "");
        SetValueById("exRateOffer", data[0].exRateOffer, "");
        var html = "<span style='color: red;'>" + exRateOffer + "</span> (Exchange Rate)<br />";
        html += "<span style='color: red;'>" + scDiscount + "</span> (Service Charge)";
        SetValueById("spnSchemeOffer", "", html);

        //             CheckThriK(parseFloat(data[0].collAmt).toFixed(2));
    }

    function CheckThriK(sAmt) {
        GetElement("<%=sourceOfFund.ClientID %>").className = "";
        GetElement("<%=purpose.ClientID %>").className = "";
        $('#sourceOfFund_err').html("");
        $('#purpose_err').html("");
        if (sAmt >= 3000) {
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
            GetElement("<%=pAgent.ClientID %>").className = "required";
        }
        else {
            $('#pAgent_err').hide();
            GetElement("pAgent_err").innerHTML = "";
            GetElement("<%=pAgent.ClientID %>").className = "";
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
        //$('#NewCust').attr("checked", false);
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
        var a = true;
        var b = false;

        if ($('#NewCust').is(':checked')) {
            a = false;
            b = true;
            ClearSearchSection();
            HideElement('tblSearch');
            GetElement("<%=ExistCust.ClientID %>").checked = false;
        }
        else {
            ShowElement('tblSearch');
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
        $('#btnSearchCustomer').attr("disabled", b);
        EnableDisableBtn("btnSearchCustomer", b);
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
                                url: '<%=ResolveUrl("Send.aspx") %>?',
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
                                url: '<%=ResolveUrl("Send.aspx") %>?',
                                data: dataToSend,
                                dataType: 'JSON',
                                type: 'POST',
                                success: function (response) {
                                    SchemeByPCountry();
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
        $("#txtRecDepAcNo").attr("class", "");
        $('#trForCPOB').hide();
        GetElement("<%=paymentThrough.ClientID %>").className = "";
        if (pMode == "BANK DEPOSIT") {
            $('#trAccno').show();
            $("#txtRecDepAcNo").attr("class", "required");
            $('#trAccno').show();
        }
        var dataToSend = { MethodName: "loadAgentBank", pMode: pMode, pCountry: pCountry };
        var options =
                            {
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                                    url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                                        url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                $("#ddlRecIdType").attr("class", "");
                $("#txtRecIdNo").attr("class", "");
                $("#tdRecIdExpiryLbl").hide();
                $("#tdRecIdExpiryTxt").hide();
            }
            else if (defbeneficiaryIdReq == "M") {
                $("#trRecId").show();
                $("#ddlRecIdType").attr("class", "required");
                $("#txtRecIdNo").attr("class", "required");
                $("#ddlRecIdType_err").show();
                $("#txtRecIdNo_err").show();
                $("#tdRecIdExpiryLbl").show();
                $("#tdRecIdExpiryTxt").show();
            }
            else if (defbeneficiaryIdReq == "O") {
                $("#trRecId").show();
                $("#ddlRecIdType").attr("class", "");
                $("#txtRecIdNo").attr("class", "");
                $("#ddlRecIdType_err").hide();
                $("#txtRecIdNo_err").hide();
                $("#tdRecIdExpiryLbl").show();
                $("#tdRecIdExpiryTxt").show();
            }

            if (defrelationshipReq == "H") {
                $("#trRelWithRec").hide();
                $("#relationship").attr("class", "");
            }
            else if (defrelationshipReq == "M") {
                $("#trRelWithRec").show();
                $("#relationship").attr("class", "required");
                $("#relationship_err").show();
            }
            else if (defrelationshipReq == "O") {
                $("#trRelWithRec").show();
                $("#relationship").attr("class", "");
                $("#relationship_err").hide();
            }

            if (defbeneficiaryContactReq == "H") {
                $("#trRecContactNo").hide();
                $("#txtRecMobile").attr("class", "");
            }
            else if (defbeneficiaryContactReq == "M") {
                $("#trRecContactNo").show();
                $("#txtRecMobile").attr("class", "required");
                $("#txtRecMobile_err").show();
            }
            else if (defbeneficiaryContactReq == "O") {
                $("#trRecContactNo").show();
                $("#txtRecMobile").attr("class", "");
                $("#txtRecMobile_err").hide();
            }

            $("#tdLblBranch").show();
            $("#tdTxtBranch").show();

            if (pModeTxt == "BANK DEPOSIT") {
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "required disabled");
                $("#txtpBranch_err").show();
            }
            else {
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "disabled");
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
            $('#txtpBranch_aText').attr("class", "disabled");
            $("#txtpBranch_err").hide();
        }
        else if (branchSelection == "Manual Type") {
            $("#tdLblBranch").show();
            $("#tdTxtBranch").show();
            $('#txtpBranch_aText').attr("readonly", false);
            $('#txtpBranch_aText').attr("class", "required");

            $("#txtpBranch_err").show();
            $("#divBranchMsg").show();
            $("#btnPickBranch").hide();
        }
        else if (branchSelection == "Select") {
            $("#tdLblBranch").show();
            $("#tdTxtBranch").show();
            $('#txtpBranch_aText').attr("readonly", true);
            $('#txtpBranch_aText').attr("class", "required disabled");
            $("#txtpBranch_err").show();
        }
        else {
            $("#tdLblBranch").show();
            $("#tdTxtBranch").show();
            $('#txtpBranch_aText').attr("readonly", true);
            $('#txtpBranch_aText').attr("class", "disabled");
            $("#txtpBranch_err").hide();
        }
        if (beneficiaryIdReq == "H") {
            $("#trRecId").hide();
            $("#ddlRecIdType").attr("class", "");
            $("#txtRecIdNo").attr("class", "");
            $("#tdRecIdExpiryLbl").hide();
            $("#tdRecIdExpiryTxt").hide();
        }
        else if (beneficiaryIdReq == "M") {
            $("#trRecId").show();
            $("#ddlRecIdType").attr("class", "required");
            $("#txtRecIdNo").attr("class", "required");
            $("#ddlRecIdType_err").show();
            $("#txtRecIdNo_err").show();
            $("#tdRecIdExpiryLbl").show();
            $("#tdRecIdExpiryTxt").show();
        }
        else if (beneficiaryIdReq == "O") {
            $("#trRecId").show();
            $("#ddlRecIdType").attr("class", "");
            $("#txtRecIdNo").attr("class", "");
            $("#ddlRecIdType_err").hide();
            $("#txtRecIdNo_err").hide();
            $("#tdRecIdExpiryLbl").show();
            $("#tdRecIdExpiryTxt").show();
        }

        if (relationshipReq == "H") {
            $("#trRelWithRec").hide();
            $("#relationship").attr("class", "");
        }
        else if (relationshipReq == "M") {
            $("#trRelWithRec").show();
            $("#relationship").attr("class", "required");
            $("#relationship_err").show();
        }
        else if (relationshipReq == "O") {
            $("#trRelWithRec").show();
            $("#relationship").attr("class", "");
            $("#relationship_err").hide();
        }

        if (beneficiaryContactReq == "H") {
            $("#trRecContactNo").hide();
            $("#txtRecMobile").attr("class", "");
        }
        else if (beneficiaryContactReq == "M") {
            $("#trRecContactNo").show();
            $("#txtRecMobile").attr("class", "required");
            $("#txtRecMobile_err").show();
        }
        else if (beneficiaryContactReq == "O") {
            $("#trRecContactNo").show();
            $("#txtRecMobile").attr("class", "");
            $("#txtRecMobile_err").hide();
        }
    }

    //PICK AGENT FROM SENDER HISTORY  --SenderDetailById
    function PickDataFromSender(obj) {
        var dataToSend = { MethodName: "SearchCustomer", searchValue: obj, searchType: "customerId" };
        var options =
                            {
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
                $('#txtpBranch_aText').attr("class", "required disabled");
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

            PAgentChange();
            $("#txtpBranch_aValue").val('');
            $("#txtpBranch_aText").val('');
            if (data[0].pBankBranch != "" && data[0].pBankBranch != undefined) {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "required disabled");
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
            }
                GetElement("<%=ddSenIdType.ClientID %>").disabled = false;

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
            SetValueById("<%=txtSendCity.ClientID %>", data[0].sCity, "");
            if (data[0].sCity == "")
                $('#txtSendCity').attr("readonly", false);
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
        SetValueById("<%=txtSearchData.ClientID %>", "", "");
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
        SetValueById("<%=txtSendCity.ClientID %>", "", "");
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

    ////send transacion calc
    $(function () {
        $('#calc').click(function () {

            Show(GetElement("btnBen"), 'tblSend');
            Show(GetElement("Button1"), 'tblBen');
            Show(GetElement("Button2"), 'tblAdditional');
            if ($("#form2").validate().form() == false) {
                $(".required").each(function () {
                    if (!$.trim($(this).val())) {
                        $(this).focus();
                    }

                });
                return false;
            }
            var pBankBranchText = $("#txtpBranch_aText").val();
            var pBank = $("#<%=pAgent.ClientID %> option:selected").val();

            if (pBank == "Select" || pBank == "undefined")
                pBank = "";
            var hdnreqAgent = $('#hdnreqAgent').html();
            var hdnreqBranch = $('#hdnreqBranch').html();
            var dm = $("#<%=pMode.ClientID %> option:selected").text();
            if (hdnreqBranch == "Manual Type") {
                if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined") {
                    alert("Branch is required ");
                    $("txtpBranch_aText").focus();
                    return false;
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

            if (sendAmt > 3000) {
                if (por == "") {
                    alert("Purpose of Remittance is required for sending amount greater than 3000 ");
                    $("#<%=purpose.ClientID %>").focus();
                    return false;
                }
                if (sof == "") {
                    alert("Source of fund is required for sending amount greater than 3000 ");
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
            var pBankBranch = $("#txtpBranch_aValue").val();
            if (pBankBranch == "Select" || pBankBranch == undefined)
                pBankBranch = "";

            var pLocation = $("#txtpLocation_Text").val();
            if (pLocation != null && pLocation != "" && pLocation != undefined)
                pBankBranchText = pLocation;

            SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pBank);
            var pBankType = $("#pAgentDetail option:selected").text();
            var pCurr = $('#lblPayCurr').text();
            var collCurr = $('#lblCollCurr').text();
            var collAmt = GetValue("<% =txtCollAmt.ClientID %>");
            var customerTotalAmt = GetValue("txtCustomerLimit");
            var payAmt = GetValue("<% =txtPayAmt.ClientID %>");
            var scharge = $('#lblServiceChargeAmt').text();
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
            var sdob = GetValue("<% =txtSendDOB.ClientID %>");
            var sTel = GetValue("<% =txtSendTel.ClientID %>");
            var sMobile = GetValue("<% =txtSendMobile.ClientID %>");
            var sCompany = GetValue("<%=companyName.ClientID %>");

            var sNaCountry = $("#<%=txtSendNativeCountry.ClientID %> option:selected").text();

            var sCity = GetValue("<% =txtSendCity.ClientID %>");
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
                    alert('Please choose Sender');
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
                "&schemeName=" + FilterString(schemeName) +
                "&exRate=" + FilterString(exRate) +
                "&schemeType=" + FilterString(schemeType) +
                "&couponId=" + FilterString(couponId) +
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
                "&salary=" + salary;

            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            var id = PopUpWindow(url, param);

            if (id == "undefined" || id == null || id == "") {
            }
            else {
                var res = id.split('|');
                if (res[0] == "1") {
                    var errormsgArr = res[1].split('\n');
                    for (var i = 0; i < errormsgArr.length; i++) {
                        alert(errormsgArr[i]);
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
    </script>
    <style type="text/css">
        .hide {
            display: none;
        }

        .SmallTextBox {
            width: 130px;
        }

        .LargeTextBox {
            width: 425px;
        }

        td {
            font-size: 11px;
        }

        .frmTitle {
            background: #e00024 !important;
        }

        .amountLabel {
            font-size: 16px;
            font-weight: bold;
            color: Red;
            padding: 2px;
        }

        #availableAmt {
            color: Red;
        }

        .mainContainer {
            clear: both;
            width: 850px;
            float: left;
        }

        .rowContainer {
            clear: both;
            display: block;
            float: left;
            margin-bottom: 5px;
        }

        .amountDiv {
            background: none repeat scroll 0 0 black;
            clear: both;
            color: white;
            float: right;
            font-size: 20px;
            font-weight: 600;
            padding: 2px 8px;
            width: auto;
        }

        #mask {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: red;
            z-index: 99;
        }

        label {
            float: left;
        }

            label.error {
                float: none;
                color: red;
                vertical-align: top;
                font-size: 10px;
                font-family: Verdana;
                font-weight: bold;
            }

        .inv {
            float: none;
            color: red;
            vertical-align: top;
            font-size: 10px;
            font-family: Verdana;
            font-weight: bold;
        }

        input.error {
            border-style: solid;
            border-width: 1px;
            background-color: #FFD9D9;
        }

        select.error {
            border-style: solid;
            border-width: 1px;
            background-color: #FFD9D9;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .table th, .table td {
            border-top: none !important;
        }
    </style>
</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper" style="margin-top: 100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>Send Transaction
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Send Money</a></li>
                            <li class="active"><a href="#">Send Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivLoad" style="position: absolute; height: 20px; width: 220px; background-color: #333333; display: none; left: 300px; top: 150px;">
                <img src="../../../images/progressBar.gif" border="0" alt="Loading..." />
            </div>
            <div id="divStep1" class="mainContainer">
                <!-- Main Container Div Start -->
                <div class="rowContainer" style="float: right;">
                    <div class="amountDiv">
                        Limit :&nbsp;
                    <asp:Label ID="availableAmt" runat="server"></asp:Label>
                        <asp:Label ID="balCurrency" runat="server" Text="MYR"></asp:Label>
                    </div>
                </div>
                <br />
                <br />
                <div class="container">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class=" col-sm-3">
                                        <asp:CheckBox ID="NewCust" runat="server" Text="New Customer" onclick="ClearData();" />
                                    </div>
                                    <div class=" col-sm-3">
                                        <asp:CheckBox ID="ExistCust" runat="server" Text="Existing Customer" Checked="true" onclick="ExistingData();" />
                                    </div>

                                    <div class=" col-sm-3">
                                        <asp:CheckBox ID="EnrollCust" runat="server" Text="Issue Membership Card" onclick="ClickEnroll();" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-condensed table-responsive">
                                <tr>
                                    <td>
                                        <div class="row col-sm-12">
                                            <div class="form-group">
                                                <div class="col-sm-3">
                                                    <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="MembershipID" Text="Membership ID"></asp:ListItem>
                                                        <asp:ListItem Value="Passport" Text="Passport No." Selected="True"></asp:ListItem>
                                                        <asp:ListItem Value="IC" Text="NRIC"></asp:ListItem>
                                                        <asp:ListItem Value="controlNo" Text="BRN"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                                <div class="col-sm-3">
                                                    <asp:TextBox ID="txtSearchData" runat="server" CssClass="form-control" Text=""></asp:TextBox>
                                                </div>
                                                <div class="col-sm-6">
                                                    <input name="button2" type="button" id="btnSearchCustomer" value="Search" />
                                                    <input name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" value="Advance Search" />
                                                    <input name="button4" type="button" id="btnClear" value="Clear All Customer Info" onclick="ClearAllCustomerInfo();" />
                                                    <span style="display: none;">Country: </span><span style="width: 135px; display: none;">
                                                        <asp:DropDownList ID="sCountry" runat="server" Width="220px"></asp:DropDownList>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="hidden" id="hdnPayMode" runat="server" />
                                        <input type="hidden" id="hdntranCount" runat="server" />
                                        <asp:HiddenField ID="hdnLimitAmount" runat="server" />
                                        <asp:HiddenField ID="hdnBeneficiaryIdReq" runat="server" />
                                        <asp:HiddenField ID="hdnBeneficiaryContactReq" runat="server" />
                                        <asp:HiddenField ID="hdnRelationshipReq" runat="server" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Information:  </h4>
                            <span style="display: none; background-color: black; font-size: 15px; color: #FFFFFF; line-height: 13px; vertical-align: middle; text-align: center; font-weight: bold;">[Per day per customer transaction limit:
                                <asp:Label ID="lblPerDayLimit" runat="server"></asp:Label>&nbsp;<asp:Label ID="lblPerDayCustomerCurr" runat="server"></asp:Label>
                                ]                            </span>
                        </div>
                        <div class="panel-body">
                            <table class="table table-condensed">

                                <tr>
                                    <td>Receiving Country:
                            <span class="errormsg" id='pCountry_err'>*</span>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="pCountry" runat="server" Width="220px" CssClass="required form-control"></asp:DropDownList>
                                    </td>
                                    <td nowrap="nowrap">Receiving Mode:
                            <span class="errormsg" id='pMode_err'>*</span>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList ID="pMode" runat="server" Width="220px" CssClass="required form-control"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <span id="lblPayoutAgent">Agent / Bank:</span>
                                        <span class="errormsg" id="pAgent_err">*</span>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                        <asp:DropDownList ID="pAgentDetail" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                        <asp:DropDownList ID="pAgentMaxPayoutLimit" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                        <span id="hdnreqAgent" style="display: none"></span>
                                        <input type="hidden" id="hdnBankType" />
                                    </td>
                                    <td id="tdLblBranch" style="display: none;">Branch:
                            <span id="txtpBranch_err" class="errormsg">*</span>                        </td>
                                    <td id="tdTxtBranch" style="display: none;">
                                        <input type="text" id="txtpBranch_aText" class="form-control" />
                                        <input type="hidden" id="txtpBranch_aValue" />

                                        <span id="hdnreqBranch" style="display: none"></span>
                                        <span class="errormsg" id="reqBranch" style="display: none"></span>
                                        <input id="btnPickBranch" type="button" value="Search" onclick="PickpBranch();" class="btn btn-default btn-sm" />
                                        <div id="divBranchMsg" style="display: none;" class="note">* Please type branch name if not found</div>
                                    </td>
                                </tr>
                                <tr id="trForCPOB" style="display: none;">
                                    <td>Payment through:
                            <span class="errormsg">*</span>                        </td>
                                    <td colspan="3">
                                        <asp:DropDownList ID="paymentThrough" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr id="trAccno" style="display: none;">
                                    <td>Bank Account No:
                            <span id="txtRecDepAcNo_err" class="errormsg">*</span>                        </td>
                                    <td colspan="3">
                                        <asp:TextBox ID="txtRecDepAcNo" runat="server" CssClass="SmallTextBox form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr id="trScheme" style="display: none;">
                                    <td>Scheme/Offer:</td>
                                    <td>
                                        <asp:DropDownList ID="ddlScheme" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </td>
                                    <td id="tdItelCouponIdLbl" style="display: none;">ITEL Coupon ID:</td>
                                    <td id="tdItelCouponIdTxt" style="display: none;">
                                        <asp:TextBox ID="iTelCouponId" runat="server" CssClass="form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" valign="top">Collection Amount:
                           <span class="errormsg" id='txtCollAmt_err'>*</span>                        </td>
                                    <td nowrap="nowrap">
                                        <asp:TextBox ID="txtCollAmt" runat="server" CssClass="required BigAmountField" Style="font-size: 18px; font-weight: bold; padding: 2px;"></asp:TextBox>
                                        <asp:Label ID="lblCollCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label><br />
                                        (Max Limit: <u><b>
                                            <asp:Label ID="lblPerTxnLimit" runat="server" Text="0.00"></asp:Label></b></u>)&nbsp;
                            <asp:Label ID="lblPerTxnLimitCurr" runat="server"></asp:Label>
                                    </td>
                                    <td id="tdLblLocation" style="display: none;">Location:
                            <span id="tdLblLocation_err" class="errormsg">*</span>
                                    </td>

                                    <td id="tdTxtLocation" style="display: none;">
                                        <input type="text" id="txtpLocation_Text" style="width: 130px" readonly="readonly" class="disabled" />
                                        <input type="hidden" id="txtpLocation_Value" />
                                        <input type="button" id="BtnLocation" onclick="PickLocation();" value="Search Location" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Service Charge: </td>
                                    <td>
                                        <asp:Label ID="lblServiceChargeAmt" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                        <asp:Label ID="lblServiceChargeCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                    </td>
                                    <td>Sending Amount: </td>
                                    <td>
                                        <asp:Label ID="lblSendAmt" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                        <asp:Label ID="lblSendCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Customer Rate:</td>
                                    <td>
                                        <asp:Label ID="lblExRate" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                        <asp:Label ID="lblExCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                    </td>
                                    <td id="tdScheme" style="display: none;" valign="top">Scheme/Offer:</td>
                                    <td id="tdSchemeVal">
                                        <span id="spnSchemeOffer" style="font-weight: bold; font-family: Verdana; color: black; font-size: 10px;"></span>
                                        <input type="hidden" id="scDiscount" name="scDiscount" />
                                        <input type="hidden" id="exRateOffer" value="exRateOffer" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Payout Amount: <span class="errormsg" id='txtPayAmt_err'>*</span></td>
                                    <td>
                                        <asp:TextBox ID="txtPayAmt" runat="server" Enabled="false" CssClass="required BigAmountField disabled form-control"></asp:TextBox>
                                        <asp:Label ID="lblPayCurr" runat="server" Text="" class="amountLabel"></asp:Label></td>
                                    <td colspan="2" rowspan="4">
                                        <span id="spnPayoutLimitInfo" style="color: red; font-size: 16px; font-weight: bold;"></span></td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td>
                                        <input type="button" id="btnCalculate" value="Calculate" />&nbsp;
                            <input type="button" id="btnCalcClean" value="Clear" />&nbsp;
					        <input name="button" type="button" id="btnCalcPopUp" value="Calculator" />

                                        <span id="finalSenderId" style="display: none"></span>
                                        <span id="finalBenId" style="display: none"></span>

                                        <input type="hidden" id="finalAgentId" />
                                        <input type="hidden" id="txtCustomerLimit" value="0" />
                                        <asp:HiddenField ID="txnPerDayCustomerLimit" runat="server" Value="0" />
                                        <input type="hidden" id="hdnInvoicePrintMethod" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" align="center">
                                        <div align="center">
                                            <span id="span_txnInfo" align="center" runat="server" style="font-size: 15px; color: #FFFFFF; background-color: #333333; line-height: 15px; vertical-align: middle; text-align: center; font-weight: bold;"></span>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <span id="spnWarningMsg" style="font-size: 13px; font-family: Verdana; font-weight: bold; color: Red;"></span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="col-sm-3">
                                        <h4 class="panel-title">Sender Information: </h4>
                                        <span id="senderName"></span>
                                    </div>
                                    <div class="col-sm-6"></div>
                                    <div class="col-sm-3">
                                        <a href="javascript:void(0);" class="btn btn-default btn-sm" onclick="PickReceiverFromSender('s');">View Transaction History</a>
                                        <input id="btnBen" type="button" onclick="ShowHide(this, 'tblSend');" value="-" title="Show/Hide" class="btn btn-danger btn-xs" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table width="840px" cellspacing="0" cellpadding="0" class="formTable">

                                <tr>
                                    <td>
                                        <table id="tblSend" cellspacing="0">
                                            <tr>
                                                <td style="width: 135px;">First Name:
                                                    <span class="errormsg" id='txtSendFirstName_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendFirstName" runat="server" CssClass="required SmallTextBox" onblur="CheckForSpecialCharacter(this,'Sender First Name');"></asp:TextBox>
                                                </td>
                                                <td>Middle Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtSendMidName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Sender Middle Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Last Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtSendLastName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Sender Last Name');"></asp:TextBox>
                                                    <span class="errormsg" id='txtSendLastName_err'></span>
                                                </td>
                                                <td>Second Last Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtSendSecondLastName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Sender Second Last Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trSenId" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblsIdtype" Text="ID Type:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='ddSenIdType_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddSenIdType" runat="server" Width="134px"></asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblSidNo" Text="ID Number:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtSendIdNo_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendIdNo" runat="server" Width="130px" onblur="CheckSenderIdNumber(this);"></asp:TextBox>
                                                    <br />
                                                    <span id="spnIdNumber" style="color: red; font-size: 10px; font-family: verdana; font-weight: bold; display: none;"></span>
                                                </td>
                                            </tr>
                                            <tr id="trIdExpirenDob" runat="server">
                                                <td id="tdSenExpDateLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblsExpDate" Text="ID Expiry Date:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtSendIdValidDate_err'>*</span>
                                                </td>
                                                <td id="tdSenExpDateTxt" runat="server" nowrap="nowrap">
                                                    <asp:TextBox ID="txtSendIdValidDate" runat="server" ReadOnly="true" Width="130px"></asp:TextBox>
                                                </td>
                                                <td id="tdSenDobLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblSDOB" Text="DOB:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtSendDOB_err'>*</span>
                                                </td>
                                                <td id="tdSenDobTxt" runat="server" nowrap="nowrap">
                                                    <asp:TextBox ID="txtSendDOB" runat="server" ReadOnly="true" Width="130px"></asp:TextBox>
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
                                                </td>
                                            </tr>
                                            <tr id="trSenContactNo" runat="server">
                                                <td id="tdSenMobileNoLbl" runat="server">Mobile No:
                                                    <span runat="server" class="errormsg" id='txtSendMobile_err'>*</span>
                                                </td>
                                                <td id="tdSenMobileNoTxt" runat="server">
                                                    <asp:TextBox ID="txtSendMobile" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Sender Mobile No.');"></asp:TextBox>
                                                </td>
                                                <td id="tdSenTelNoLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblSTelNo" Text="Tel. No.:"></asp:Label></td>
                                                <td id="tdSenTelNoTxt" runat="server">
                                                    <asp:TextBox ID="txtSendTel" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this);"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdSenCityLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblsCity" Text="City:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtSendCity_err'>*</span>
                                                </td>
                                                <td id="tdSenCityTxt" runat="server">
                                                    <asp:TextBox ID="txtSendCity" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Sender City');"></asp:TextBox>
                                                </td>
                                                <td>Postal Code:</td>
                                                <td>
                                                    <asp:TextBox ID="txtSendPostal" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Sender Postal Code');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trSenCompany" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblCompName" Text="Company Name:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='companyName_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="companyName" runat="server" Width="425px" onblur="CheckForSpecialCharacter(this, 'Sender Company Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trSenAddress1" runat="server">
                                                <td>Address1:
                                                    <span runat="server" class="errormsg" id='txtSendAdd1_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtSendAdd1" runat="server" Width="425px" onblur="CheckForSpecialCharacter(this, 'Sender Address 1');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trSenAddress2" runat="server">
                                                <td>Address2:</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtSendAdd2" runat="server" CssClass="LargeTextBox" onblur="CheckForSpecialCharacter(this, 'Sender Address 2');"></asp:TextBox></td>
                                            </tr>
                                            <tr>
                                                <td>Native Country:
                                                    <span class="errormsg" id='txtSendNativeCountry_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="txtSendNativeCountry" runat="server" Width="134px"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Email:</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtSendEmail" runat="server" CssClass="LargeTextBox"></asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="txtSendEmail"></asp:RegularExpressionValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Send SMS To Sender:</td>
                                                <td nowrap="nowrap">
                                                    <asp:CheckBox ID="ChkSMS" runat="server" />
                                                </td>
                                                <td></td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td>Gender:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlSenGender" runat="server" Width="134px">
                                                        <asp:ListItem Value="">Select</asp:ListItem>
                                                        <asp:ListItem Value="Male">Male</asp:ListItem>
                                                        <asp:ListItem Value="Female">Female</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td id="lblMem" style="display: none">Membership ID:</td>
                                                <td id="valMem" style="display: none">
                                                    <asp:TextBox ID="memberCode" runat="server" Width="130px"></asp:TextBox>
                                                    <span id="memberCode_err" class="errormsg"></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <div id="divSenderIdImage"></div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="col-sm-2">
                                        <h4 class="panel-title">Receiver Information:</h4>
                                        <span id="receiverName"></span>
                                    </div>
                                    <div class="col-sm-6"></div>
                                    <div class="col-sm-4">
                                        <a href="javascript:void(0);" class="btn btn-default btn-sm" onclick="PickReceiverFromSender('r');">Select Receiver</a>
                                        <input id="btnReceiverClr" type="button" value="Clear" class="btn btn-default btn-sm" />
                                        <input id="Button1" type="button" onclick="ShowHide(this, 'tblBen');" value="-" title="Show/Hide" class="btn btn-danger btn-xs" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table width="840px" cellspacing="0" cellpadding="0" class="formTable">

                                <tr>
                                    <td>
                                        <table id="tblBen" cellspacing="0">
                                            <tr>
                                                <td style="width: 135px;">First Name:
                                        <span class="errormsg" id='txtRecFName_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecFName" runat="server" CssClass="required SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Receiver First Name');"></asp:TextBox>
                                                </td>
                                                <td>Middle Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtRecMName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Receiver Middle Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Last Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtRecLName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Receiver Last Name');"></asp:TextBox>
                                                    <span class="errormsg" id='txtRecLName_err'></span>
                                                </td>
                                                <td>Second Last Name:</td>
                                                <td>
                                                    <asp:TextBox ID="txtRecSLName" runat="server" CssClass="SmallTextBox" onblur="CheckForSpecialCharacter(this, 'Receiver Second Last Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecId" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblRidType" Text="ID Type:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='ddlRecIdType_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlRecIdType" runat="server" Width="134px"></asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblRidNo" Text="ID Number:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtRecIdNo_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecIdNo" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Receiver ID Number');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecIdExpirynDob" runat="server">
                                                <td id="tdRecIdExpiryLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblrExpDate" Text="ID Expiry Date:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtRecValidDate_err'>*</span>
                                                </td>
                                                <td id="tdRecIdExpiryTxt" runat="server">
                                                    <asp:TextBox ID="txtRecValidDate" runat="server" Width="130px" ReadOnly="true"></asp:TextBox>
                                                </td>
                                                <td id="tdRecDobLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblDOB" Text="DOB:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtRecDOB_err'>*</span>
                                                </td>
                                                <td id="tdRecDobTxt" runat="server">
                                                    <asp:TextBox ID="txtRecDOB" runat="server" Width="130px" ReadOnly="true"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecContactNo" runat="server">
                                                <td id="tdRecMobileNoLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblRecMobile" Text="Mobile:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtRecMobile_err'>*</span>
                                                </td>
                                                <td id="tdRecMobileNoTxt" runat="server">
                                                    <asp:TextBox ID="txtRecMobile" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Receiver Mobile No.');"></asp:TextBox>
                                                </td>
                                                <td id="tdRecTelNoLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblRTelno" Text="Tel. No.:"></asp:Label></td>
                                                <td id="tdRecTelNoTxt" runat="server">
                                                    <asp:TextBox ID="txtRecTel" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Receiver Tel. No.');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdRecCityLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblrCity" Text="City:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='txtRecCity_err'>*</span>
                                                </td>
                                                <td id="tdRecCityTxt" runat="server">
                                                    <asp:TextBox ID="txtRecCity" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Receiver City');"></asp:TextBox>
                                                </td>
                                                <td>Postal Code:</td>
                                                <td>
                                                    <asp:TextBox ID="txtRecPostal" runat="server" Width="130px" onblur="CheckForSpecialCharacter(this, 'Receiver Postal Code');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecAddress1" runat="server">
                                                <td>Address1:
                                        <span runat="server" class="errormsg" id='txtRecAdd1_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecAdd1" runat="server" Width="425px" onblur="CheckForSpecialCharacter(this, 'Receiver Address 1');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecAddress2" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblrAdd" Text="Address2:" onblur="CheckForSpecialCharacter(this, 'Receiver Address 2');"></asp:Label></td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecAdd2" runat="server" CssClass="LargeTextBox"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Email:</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecEmail" runat="server" CssClass="LargeTextBox"></asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="txtRecEmail"></asp:RegularExpressionValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Gender:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlRecGender" runat="server" Width="136px">
                                                        <asp:ListItem Value="">Select</asp:ListItem>
                                                        <asp:ListItem Value="Male">Male</asp:ListItem>
                                                        <asp:ListItem Value="Female">Female</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td>&nbsp;</td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td colspan="4"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="col-sm-4">
                                        <h4 class="panel-title">Customer Due Diligence Information -(CDDI) </h4>
                                    </div>
                                    <div class="col-sm-7"></div>
                                    <div class="col-sm-1">
                                        <input id="Button2" type="button" onclick="ShowHide(this, 'tblAdditional');" value="-" title="Show/Hide" class="btn btn-danger btn-xs" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table" cellspacing="0" cellpadding="0">

                                <tr>
                                    <td>
                                        <table id="tblAdditional" cellspacing="0">
                                            <tr id="trOccupation" runat="server">
                                                <td width="172" style="width: 170px">
                                                    <asp:Label runat="server" ID="lblOccupation" Text="Occupation:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='occupation_err'>*</span>                                    </td>
                                                <td width="357">
                                                    <asp:DropDownList ID="occupation" runat="server" Width="220px"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trSourceOfFund" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblSof" Text="Source of Fund:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='sourceOfFund_err'>*</span>                                    </td>
                                                <td>
                                                    <asp:DropDownList ID="sourceOfFund" runat="server" Width="220px"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trPurposeOfRemittance" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblPoRemit" Text="Purpose of Remittance:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='purpose_err'>*</span>                                    </td>
                                                <td>
                                                    <asp:DropDownList ID="purpose" runat="server" Width="220px"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trRelWithRec" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblRelation" Text="Relationship with Receiver:"></asp:Label>
                                                    <span runat="server" class="errormsg" id='relationship_err'>*</span>                                    </td>
                                                <td>
                                                    <asp:DropDownList ID="relationship" runat="server" Width="220px"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trSalaryRange" runat="server">
                                                <td>
                                                    <asp:Label runat="server" ID="lblSalaryRange" Text="Monthly Income:"></asp:Label>
                                                    <span runat="server" id="ddlSalary_err" class="errormsg">*</span>								 </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlSalary" runat="server" Width="134px"></asp:DropDownList></td>
                                            </tr>
                                            <tr>
                                                <td>Message to Receiver:</td>
                                                <td>
                                                    <asp:TextBox ID="txtPayMsg" runat="server" CssClass=" LargeTextBox " TextMode="MultiLine" onblur="CheckForSpecialCharacter(this, 'Message to Receiver');"></asp:TextBox></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>

                                    <td align="center">
                                        <br />
                                        <br />
                                        <div align="center">
                                            <input type="button" name="calc" id="calc" value="Send Transaction" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <br />
            <br />

            <div id="divStep2">
            </div>
        </div>
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
        if (res == "undefined" || res == null || res == "") {
        }
        else {
            var splitVal = res.split('|');
            $("#txtpLocation_Value").val(splitVal[0]);
            $("#txtpLocation_Text").val(splitVal[1]);
        }
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
</script>