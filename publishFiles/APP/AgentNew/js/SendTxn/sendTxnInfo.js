function ManageSendIdValidity() {
    var senIdType = $("#" + mId + "ddSenIdType").val();
    if (senIdType === "") {
        $("#" + mId + "tdSenExpDateLbl").show();
        $("#" + mId + "tdSenExpDateTxt").show();
        $("#" + mId + "txtSendIdValidDate").attr("class", "required readonlyOnCustomerSelect form-control");
    }
    else {
        var senIdTypeArr = senIdType.split('|');
        if (senIdTypeArr[1] === "E") {
            $("#" + mId + "tdSenExpDateLbl").show();
            $("#" + mId + "tdSenExpDateTxt").show();
            $("#" + mId + "txtSendIdValidDate").attr("class", "required readonlyOnCustomerSelect form-control");
        }
        else {
            $("#" + mId + "tdSenExpDateLbl").hide();
            $("#" + mId + "tdSenExpDateTxt").hide();
            $("#" + mId + "txtSendIdValidDate").attr("class", "readonlyOnCustomerSelect form-control");
        }
    }
}

function LoadCustomerRate() {
    var pCountry = $("#" + mId + "pCountry option:selected").val();
    var pMode = $("#" + mId + "pMode option:selected").val();
    var pModeTxt = $("#" + mId + "pMode option:selected").text();
    var pAgent = $("#" + mId + "pAgent option:selected").val();
    if (pAgent === "undefined")
        pAgent = null;
    if (pModeTxt === "CASH PAYMENT TO OTHER BANK")
        pAgent = $("#" + mId + "paymentThrough option:selected").val();
    var collCurr = $("#" + mId + "lblPerTxnLimitCurr").text();
    var dataToSend = {
        MethodName: 'LoadCustomerRate', pCountry: pCountry, pMode: pMode, pAgent: pAgent, collCurr: collCurr
    };

    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            var data = response;
            var collectionAmount = Number($("#" + mId + "txtCollAmt").val());
            $("#" + mId + "customerRateFields").hide();
            if (data === null || data === undefined || data === "")
                return;
            if (data[0].ErrCode !== "0") {
                $("#" + mId + "lblExRate").text(data[0].Msg);
                if (collectionAmount > 0) {
                    $("#" + mId + "customerRateFields").show();
                }
                return;
            }
            var exRate = data[0].exRate;
            var pCurr = data[0].pCurr;
            var limit = data[0].limit;
            var limitCurr = data[0].limitCurr;
            exRate = roundNumber(exRate, 10);
            $("#" + mId + "lblExRate").text(exRate);
            $("#" + mId + "lblExCurr").text(pCurr);
            $("#" + mId + "lblPerTxnLimit").text(limit);
            $("#" + mId + "lblPerTxnLimitCurr").text(limitCurr);
            $("#" + mId + "customerRateFields").hide();
            if (collectionAmount > 0) {
                $("#" + mId + "customerRateFields").show();
            }
            return;
        }
    };
    $.ajax(options);
    return true;
}

function CollAmtOnChange() {
    var collAmt = $("#" + mId + "txtCollAmt").val();
    if (collAmt === "")
        collAmt = "0";
    var collAmtFormatted = CurrencyFormatted(collAmt);
    collAmtFormatted = CommaFormatted(collAmtFormatted);
    var collCurr = $("#" + mId + "lblPerTxnLimitCurr").text();
    if (collAmt === "0") {
        ClearCalculatedAmount();
        return;
    }
    checkdata(collAmt, 'cAmt');
}

function LoadSublocation() {
    var pLocation = $("#" + mId + "locationDDL").val();
    var dataToSend = { MethodName: 'getSubLocation', PLocation: pLocation };
    var options = {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
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
    $('#subLocation').show();
    var data = response;
    var ddl = GetElement(mId + "subLocationDDL");
    $(ddl).empty();

    var option;
    option = document.createElement("option");

    for (var i = 0; i < data.length; i++) {
        option = document.createElement("option");

        option.text = data[i].LOCATIONNAME;
        option.value = data[i].LOCATIONID;

        if ($("#" + mId + "hddSubLocation").val()) {
            if (option.value === $("#" + mId + "hddSubLocation").val()) {
                option.selected = true;
            }
        }

        try {
            ddl.options.add(option);
        }
        catch (e) {
            alert(e);
        }
    }
}

function ClearTxnData() {
    $("#" + mId + "pAgent").empty();
    $("#" + mId + "pMode").empty();
    $("#txtpBranch_aValue").val("");
    $("#txtpBranch_aText").val("");
    $("#" + mId + "txtRecDepAcNo").val("");

    $("#" + mId + "txtCollAmt").val("");
    $("#" + mId + "txtCollAmt").attr("readonly", false);
    $("#" + mId + "txtPayAmt").val("");
    $("#" + mId + "txtPayAmt").attr("readonly", false);
    $("#" + mId + "lblSendAmt").val('0.00');
    $("#" + mId + "lblServiceChargeAmt").val('0');
    $("#" + mId + "lblExRate").text('0.00');
    $("#lblDiscAmt").text('0.00');
    $("#" + mId + "lblExRate").text('0.00');

    $("#scDiscount").val('0.00');
    $("#exRateOffer").val('0.00');
    $("#" + mId + "editServiceCharge").attr("disabled", "disabled");
    $("#" + mId + "lblServiceChargeAmt").attr("disabled", "disabled");
    $("#" + mId + "editServiceCharge").prop("checked", false);
    $("#" + mId + "lblPayCurr").text("");
    $("#" + mId + "lblPerTxnLimit").text('0.00');

    SetDDLValueSelected(mId + "pCountry", "");
    SetDDLValueSelected(mId + "ddlSalary", "");
    SetDDLValueSelected(mId + "isYourMoney", "");
    SetDDLValueSelected(mId + "isPep", "");
    SetDDLTextSelected(mId + "ddlScheme", "");
    $("#" + mId + "branch").empty();
    $("#" + mId + "ddlPayer").empty();
    $("#branchDetail").text('');
    $("#payerDetailsHistory").text('');
    $("#" + mId + "subLocationDDL").empty();
    $("#" + mId + "pCurrDdl").empty();
    $("#" + mId + "locationDDL").empty();
    $("#branch").empty();

    GetElement("spnWarningMsg").innerHTML = "";
    d = ["", ""];
    SetItem(mId + "introducerTxt", d);
    $('#availableBalReferral').text('');
    $('#availableBalReferral').val('');
    $("#" + mId + "hdnRefAvailableLimit").val('');
    $('#availableBalSpanReferral').hide();
}

function CalculateTxn(amt, obj, isManualSc) {
    if (isManualSc === undefined) {
        if ($("#" + mId + "editServiceCharge").is(':checked')) {
            isManualSc = 'Y';
        }
        else {
            isManualSc = 'N';
        }
    }
    var collAmt = parseFloat($("#" + mId + "txtCollAmt").val().replace(',', '').replace(',', '').replace(',', ''));
    var availableBal = parseFloat($('#availableBal').text().replace(',', '').replace(',', '').replace(',', ''));

    var customerId = $("#" + mId + "txtSearchData_aValue").val();
    if ($('#11063').is(':checked') || $('#11064').is(':checked')) {
        if (collAmt > availableBal) {
            alert('Amount can not be greater than Available Balance!');
            ClearAmountFields();
            return false;
        }
    }

    if (isManualSc === '' || isManualSc === undefined) {
        isManualSc = 'N';
    }

    if (isManualSc === 'N') {
        if (obj === '' || obj === null) {
            if (document.getElementById(mId + "txtPayAmt").disabled) {
                obj = 'cAmt';
                amt = GetValue(mId + "txtCollAmt");
            }
            else {
                obj = 'pAmt';
                amt = GetValue(mId + "txtPayAmt");
            }
        }
    }
    else {
        obj = $("#" + mId + "hddCalcBy").val();
        if (obj === 'cAmt') {
            amt = GetValue(mId + "txtCollAmt");
        }
        else {
            amt = GetValue(mId + "txtPayAmt");
        }
    }

    $("#DivLoad").show();
    var pCountry = GetValue(mId + "pCountry");
    var pCountrytxt = $("#" + mId + "pCountry option:selected").text();
    var pMode = GetValue(mId + "pMode");
    var pModetxt = $("#" + mId + "pMode option:selected").text();

    if (pCountry === "" || pCountry === null || pCountry === undefined) {
        alert("Please choose payout country");
        GetElement(mId + "pCountry").focus();
        return false;
    }

    if (pMode === "" || pMode === null || pMode === undefined) {
        alert("Please choose payment mode");
        GetElement(mId + "pMode").focus();
        return false;
    }

    if ($("#" + mId + "introducerTxt_aSearch").val() !== "") {
        var res = CheckReferralBalAndCamt();
        if (res === false) {
            $("#" + mId + "txtCollAmt").val('');
            $("#" + mId + "txtCollAmt").focus();
            return;
        }
    }

    var pAgent = Number(GetValue(mId + "pAgent"));
    var pAgentBranch = GetValue("txtpBranch_aValue");
    if (pModetxt === "CASH PAYMENT TO OTHER BANK") {
        pAgent = Number($("#" + mId + "paymentThrough option:selected").val());
        pAgentBranch = "";
        if (pAgent === "" || pAgent === undefined)
            pAgent = "";
    }

    collAmt = GetValue(mId + "txtCollAmt");
    var txtCustomerLimit = GetValue("txtCustomerLimit");
    var txnPerDayCustomerLimit = GetValue(mId + "txnPerDayCustomerLimit");
    var schemeCode = GetValue(mId + "ddlScheme");

    if (obj === "cAmt") {
        collAmt = amt;
        payAmt = 0;
    }

    if (obj === "pAmt") {
        payAmt = amt;
        collAmt = 0;
    }

    var payCurr = $("#" + mId + "pCurrDdl").val();
    var collCurr = $("#" + mId + "lblPerTxnLimitCurr").text();
    var senderId = $('#finalSenderId').text();
    var couponId = $("#" + mId + "iTelCouponId").val();

    var sc = $("#" + mId + "lblServiceChargeAmt").val();

    if (pCountry === "203" && payCurr === "USD") {
        if ((pMode === "1" && pAgent !== 2091) || (pMode !== "12" && pAgent !== 2091)) {
            alert('USD receiving is only allow for Door to Door');
            ClearAmountFields();
            return false;
        }
    }
    var collectAmount = Number($("#" + mId + "txtCollAmt").val());
    var payoutAmount = Number($("#" + mId + "txtPayAmt").val());
    var payoutPartner = $("#" + mId + "hddPayoutPartner").val();
    var IsExrateFromPartner = $("#" + mId + "hddFetchExrateFromPartner").val();
    var PCountryCode = $("#" + mId + "hddPCountryCode").val();
    if (collectAmount <= 0 && payoutAmount <= 0) {
        return;
    }

    $("#" + mId + "hddCalcBy").val(obj);
    var dataToSend = {
        MethodName: 'CalculateTxn', pCountry: pCountry, pCountrytxt: pCountrytxt, pMode: pMode, pAgent: pAgent
        , pAgentBranch: pAgentBranch, collAmt: collAmt, payAmt: payAmt, payCurr: payCurr, collCurr: collCurr
        , pModetxt: pModetxt, senderId: senderId, schemeCode: schemeCode, couponId: couponId, isManualSc: isManualSc
        , sc: sc, payoutPartner: payoutPartner, IsExrateFromPartner: IsExrateFromPartner, PCountryCode: PCountryCode
    };

    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
        success: function (response) {
            ParseCalculateData(response, obj);
        }
    };
    $.ajax(options);
    $("#DivLoad").hide();
    return true;
}

function UnmapTxn() {
    var tranIds = [];
    $.each($("input[name='chkDepositMappingUnmap']:checked"), function () {
        tranIds.push($(this).val());
    });
    if (tranIds === '') {
        alert('No data to save');
        return false;
    }
    dataToSend = { MethodName: 'UnMapData', tranIds: tranIds, customerId: $("#" + mId + "hddCustomerId").val() };
    if (confirm('Do you want to continue with save?')) {
        $.post("", dataToSend, function (response) {
            var data = jQuery.parseJSON(response);
            if (data.ErrorCode == 0) {
                alert(data.Msg);
                $("#myModal2").modal('hide');
                CheckAvailableBalance($("input[name='chkCollMode']:checked").val());
                ClearAmountFields();
            } else {
                alert(data.Msg);
            }
        });
    }
    return false;
}

function ConfirmSave() {
    var tranIds = [];
    $.each($("input[name='chkDepositMapping']:checked"), function () {
        tranIds.push($(this).val());
    });
    if (tranIds === '') {
        alert('No data to save');
        return false;
    }
    dataToSend = { MethodName: 'MapData', tranIds: tranIds, customerId: $("#" + mId + "hddCustomerId").val() };
    if (confirm('Do you want to continue with save?')) {
        $.post("", dataToSend, function (response) {
            var data = jQuery.parseJSON(response);
            if (data.ErrorCode == 0) {
                alert(data.Msg);
                $("#myModal2").modal('hide');
                CheckAvailableBalance($("input[name='chkCollMode']:checked").val());
                ClearAmountFields();
            } else {
                alert(data.Msg);
            }
        });
    }
    return false;
}

function SetPayCurrency(pCountry) {
    var dataToSend = { MethodName: 'PCurrPcountry', pCountry: pCountry };
    var options = {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
        success:
            function (response) {
                var data = response;
                var ddl = GetElement(mId + "pCurrDdl");
                $(ddl).empty();

                var option;

                for (var i = 0; i < data.length; i++) {
                    option = document.createElement("option");

                    option.text = data[i].currencyCode;
                    option.value = data[i].currencyCode;

                    try {
                        ddl.options.add(option);
                        if (data[i].isDefault === "Y") {
                            $("#" + mId + "pCurrDdl").val(data[i].currencyCode);
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

$(document).on('click', '#calc', function () {
    SendTransactionMethod();
});

$(document).on('click', '#btnSendTxnCDDI', function () {
    var isValid = 'Y';
    $(".requiredCompliance").each(function () {
        if (!$.trim($(this).val())) {
            $(this).addClass('error');
            isValid = 'N';
        }
    });
    if (isValid === 'N') {
        return alert("Required Field(s)\n _____________________________ \n The red fields are required!")
    }
    SendTransactionMethod();
});

function SendTransactionMethod() {
    ReCalculate();
    if ($("#" + mId + "visaStatusNotFound").val() == 'true') {
        var visaStatusId = $("#ContentPlaceHolder1_visaStatusDdl").val();
        if (visaStatusId === null || visaStatusId === "") {
            alert('Please choose visa status of customer !!!');
            return;
        }
    }
    var isCDDI = $("#" + mId + "hddIsAdditionalCDDI").val();
    var hddAgentRefId = $("#" + mId + "hddAgentRefId").val();
    var xmlDataForCDDI = '';
    if (isCDDI === 'Y') {
        xmlDataForCDDI = GetXMLData();
        sessionStorage.setItem("XmlDataForCDDI", xmlDataForCDDI);
    }
    $(".readonlyOnCustomerSelect").each(function () {
        if ($(this).is(":disabled")) {
            $(this).addClass('abc').removeAttr("disabled");
        }
    });
    $(".readonlyOnReceiverSelect").each(function () {
        if ($(this).is(":disabled")) {
            $(this).addClass('abc').removeAttr('disabled');
        }
    });
    if ($("#form1").validate().form() === false) {
        $(".required").each(function () {
            if (!$.trim($(this).val())) {
                $(this).focus();
            }
        });
        $(".abc").each(function () {
            $(this).removeClass('abc').attr('disabled', 'disabled');
        });
        return false;
    }
    $(".abc").each(function () {
        $(this).removeClass('abc').attr('disabled', 'disabled');
    });

    var pBankBranchText = $("#" + mId + "branch option:selected").text();
    if (pBankBranchText.length <= 0) {
        pBankBranchText = $("#branch option:selected").text();
    }

    var pBankBranch = $("#" + mId + "branch option:selected").val();
    if (pBankBranch === undefined || pBankBranch.length <= 0) {
        pBankBranch = $("#branch option:selected").val();
    }
    if (pBankBranch === undefined) {
        pBankBranch = "";
    }
    var pBank = $("#" + mId + "pAgent option:selected").val();
    if (pBank === "SELECT" || pBank === "undefined" || pBank === undefined)
        pBank = "";
    var hdnreqAgent = $('#hdnreqAgent').html();
    var hdnreqBranch = $("#" + mId + "hddBranchRequired").val();
    var dm = $("#" + mId + "pMode option:selected").text();
    if (hdnreqBranch === 'MANUAL TYPE' || hdnreqBranch === 'SELECT') {
        if (hdnreqBranch === 'SELECT') {
            if (pBankBranchText === null || pBankBranchText === "" || pBankBranchText === undefined || pBankBranchText === "undefined" || pBankBranchText === "-1") {
                alert("Branch is required ");
                return false;
            }
        }
        if (hdnreqBranch === "MANUAL TYPE") {
            pBankBranchText = $('#branch_manual').val();
            if (pBankBranchText === null || pBankBranchText === "" || pBankBranchText === undefined || pBankBranchText === "undefined" || pBankBranchText === "-1") {
                alert("Branch is required ");
                return false;
            }
        }
    }
    if (hdnreqAgent === "M") {
        if (pBank === null || pBank === "" || pBank === "undefined" || pBank === undefined) {
            alert("Agent/Bank is required ");
            $("#" + mId + "pAgent").focus();
            return false;
        }
    }
    var por = $("#" + mId + "purpose option:selected").text();
    por = por.replace("SELECT", "");
    var sof = $("#" + mId + "sourceOfFund option:selected").text().replace("SELECT", "");
    sof = sof.replace("SELECT", "");
    var sendAmt = $("#" + mId + "lblSendAmt").val();

    if (sendAmt > parseInt(eddval)) {
        if (por === "") {
            alert("Purpose of Remittance is required for sending amount greater than " + eddval);
            $("#" + mId + "purpose").focus();
            return false;
        }
        if (sof === "") {
            alert("Source of fund is required for sending amount greater than " + eddval);
            $("#" + mId + "sourceOfFund").focus();
            return false;
        }
    }
    var pCountry = $("#" + mId + "pCountry option:selected").text();
    if (pCountry === "SELECT" || pCountry === undefined)
        pCountry = "";
    var pCountryId = $("#" + mId + "pCountry option:selected").val();
    var collMode = $("#" + mId + "pMode option:selected").text();
    var collModeId = $("#" + mId + "pMode option:selected").val();

    var pAgent = "";
    var pAgentName = "";
    if (collMode === "CASH PAYMENT TO OTHER BANK") {
        pAgent = $("#" + mId + "paymentThrough option:selected").val();
        pAgentName = $("#" + mId + "paymentThrough option:selected").text();
        if (pAgentName === "SELECT" || pAgentName === undefined) {
            pAgent = "";
            pAgentName = "";
        }
    }

    var pBankText = $("#" + mId + "pAgent option:selected").text();
    if (pBankText === "[SELECT]" || pBankText === "[Any Where]" || pBankText === undefined)
        pBankText = "";

    SetDDLValueSelected(mId + "pAgentDetail", pBank);
    var pBankType = $("#" + mId + "pAgentDetail option:selected").text();
    var pCurr = $("#" + mId + "lblPayCurr").text();
    var collCurr = $("#" + mId + "lblPerTxnLimitCurr").text();
    var collAmt = GetValue(mId + "txtCollAmt");
    var customerTotalAmt = GetValue("txtCustomerLimit");
    var payAmt = GetValue(mId + "txtPayAmt");
    var scharge = $("#" + mId + "lblServiceChargeAmt").val();
    var discount = $('#lblDiscAmt').text();
    var handling = "0";
    var exRate = $("#" + mId + "lblExRate").text();
    var scDiscount = $('#scDiscount').val();
    var exRateOffer = $('#exRateOffer').val();
    var schemeName = $("#" + mId + "ddlScheme option:selected").text();
    if (schemeName === "SELECT" || schemeName === "undefined" || schemeName === undefined)
        schemeName = "";

    var schemeType = $("#" + mId + "ddlScheme option:selected").val();
    if (schemeType === "SELECT" || schemeType === "undefined" || schemeType === undefined)
        schemeType = "";

    var couponId = $("#" + mId + "iTelCouponId").val();
    //sender values
    var senderId = $('#finalSenderId').text();
    var sfName = GetValue(mId + "txtSendFirstName");
    var smName = GetValue(mId + "txtSendMidName");
    var slName = GetValue(mId + "txtSendLastName");
    var slName2 = GetValue(mId + "txtSendSecondLastName");
    var sIdType = $("#" + mId + "ddSenIdType option:selected").text();
    if (sIdType === "SELECT" || sIdType === undefined || sIdType === "")
        sIdType = "";
    else
        sIdType = sIdType.split('|')[0];
    var sGender = $("#" + mId + "ddlSenGender option:selected").val();
    var sIdNo = GetValue(mId + "txtSendIdNo");
    var sIdValid = GetValue(mId + "txtSendIdValidDate");
    if (ValidateDate(sIdValid) === false) {
        alert('Sender Id expiry date is invalid');
        $("#" + mId + "txtSendIdValidDate").focus();
        return false;
    }
    var sdob = GetValue(mId + "txtSendDOB");
    var sTel = GetValue(mId + "txtSendTel");
    var sMobile = GetValue(mId + "txtSendMobile");
    var sCompany = GetValue(mId + "companyName");

    var sNaCountry = $("#" + mId + "txtSendNativeCountry option:selected").text();

    var sCity = $("#" + mId + "txtSendCity").val();
    var sPostCode = GetValue(mId + "txtSendPostal");
    var sAdd1 = GetValue(mId + "txtSendAdd1");
    var sAdd2 = GetValue(mId + "txtSendAdd2");
    var sEmail = GetValue(mId + "txtSendEmail");
    if (sEmail !== "" && sEmail !== null) {
        if (!EmailValidation("#" + mId + "txtSendEmail", sEmail, "Sender")) {
            return false;
        }
    }
    var memberCode = GetValue(mId + "memberCode");
    var smsSend = "N";
    if ($("#" + mId + "ChkSMS").is(":checked"))
        smsSend = "Y";
    var newCustomer = "N";

    var rfName = GetValue(mId + "txtRecFName");
    var rmName = GetValue(mId + "txtRecMName");
    var rlName = GetValue(mId + "txtRecLName");
    var rlName2 = GetValue(mId + "txtRecSLName");

    var rIdType = $("#" + mId + "ddlRecIdType option:selected").text();

    var iymValue = $("#questionnarie_1 option:selected").val();
    var pepValue = $("#questionnarie_4 option:selected").val();

    if (pepValue === undefined || pepValue === "undefined" || pepValue === "") {
        alert("Please select : Are you or any member of your family or relative Politically Exposed Persons (PEP)? ");
        return;
    }

    if (iymValue === "" || iymValue === undefined || iymValue === "undefined") {
        alert("Please select : Is this your money?");
        return;
    }

    if (iymValue == "NO") {
        alert("Please Select YES To Proceed Ahead In This Field : Is this your money?");
        return;
    }

    var Questionnarie = GetXMLData_Questionnarie();
    sessionStorage.setItem("XmlDataForQuestinnarie", Questionnarie);

    if (rIdType === "SELECT" || rIdType === undefined || rIdType === "undefined")
        rIdType = "";

    var rGender = $("#" + mId + "ddlRecGender option:selected").val();
    var rIdNo = GetValue(mId + "txtRecIdNo");
    var rTel = GetValue(mId + "txtRecTel");
    var rMobile = GetValue(mId + "txtRecMobile");

    var rCity = GetValue(mId + "txtRecCity");
    var rPostCode = GetValue(mId + "txtRecPostal");
    var rAdd1 = GetValue(mId + "txtRecAdd1");
    var rAdd2 = GetValue(mId + "txtRecAdd2");
    var rEmail = GetValue(mId + "txtRecEmail");
    if (rEmail !== null && rEmail !== "") {
        if (!EmailValidation("#" + mId + "txtRecEmail", rEmail, "Sender")) {
            return false;
        }
    }
    var accountNo = GetValue(mId + "txtRecDepAcNo");

    var pLocation = GetValue(mId + "locationDDL");
    var pLocationText = $("#" + mId + "locationDDL option:selected").text();
    var pSubLocation = GetValue(mId + "subLocationDDL");
    var pSubLocationText = $("#" + mId + "subLocationDDL option:selected").text();

    var isManualSC = 'N';
    if ($("#" + mId + "editServiceCharge").is(":checked"))
        isManualSC = "Y";

    var manualSC = $("#" + mId + "lblServiceChargeAmt").val();

    //********IF NEW CUSTOMER CHECK REQUIRED FIELD******

    if ($("#" + mId + "NewCust").is(":checked")) {
        newCustomer = "Y";

        if (sfName === "" || sfName === null) {
            alert('Sender First Name missing');
            $("#" + mId + "txtSendFirstName").focus();
            return false;
        }
    }
    if ($("#" + mId + "NewCust").is(":checked") === false) {
        if (senderId === "" || senderId === null) {
            alert('Please Choose Existing Sender ');
            return false;
        }
    }
    var enrollCustomer = "N";
    var collModeFrmCustomer = $("input[name='chkCollMode']:checked").val();
    if (collModeFrmCustomer === undefined || collModeFrmCustomer === '') {
        alert('Please choose collect mode first!');
        return false;
    } if (collModeFrmCustomer == "Existing Balance") {
        collModeFrmCustomer = "Bank Deposit"
    }

    //New params added
    var sCustStreet = $("#" + mId + "sCustStreet").val();
    var sCustLocation = $("#" + mId + "custLocationDDL").val();
    var sCustomerType = $("#" + mId + "ddlSendCustomerType").val();
    var sCustBusinessType = $("#" + mId + "ddlEmpBusinessType").val();
    var sCustIdIssuedCountry = $("#" + mId + "ddlIdIssuedCountry").val();
    var sCustIdIssuedDate = $("#" + mId + "txtSendIdExpireDate").val();

    var benId = $('#finalBenId').text();
    var hddreceiverId = $("#" + mId + "hddreceiverId").val();
    console.log("HdnreceiverId" + hddreceiverId);
    var receiverId = $("#" + mId + "ddlReceiver").val() == "" ? hddreceiverId : $("#" + mId + "ddlReceiver").val();

    if (benId === '' || benId === null || benId === undefined) {
        benId = $("#" + mId + "ddlReceiver").val();
    }

    var payoutPartnerId = $("#" + mId + "hddPayoutPartner").val();
    var cashCollMode = collModeFrmCustomer;
    var customerDepositedBank = $("#" + mId + "depositedBankDDL").val();
    var introducerTxt = $("#" + mId + "introducerTxt_aValue").val();

    var rel = $("#" + mId + "relationship option:selected").text().replace("Select", "");
    rel = rel.replace("Select", "");
    var occupation = $("#" + mId + "occupation option:selected").val();
    var payMsg = escape(GetValue(mId + " txtPayMsg"));
    var company = GetValue(mId + "companyName");
    var cancelrequestId = $("#" + mId + "cancelrequestId").val();
    var salary = $("#" + mId + "ddlSalary option:selected").val();
    if (salary === "Select" || rIdType === undefined || rIdType === "undefined")
        salary = "";
    var payerId = "";
    var payerBranchId = "";
    var isOpen = $("#myModal1").hasClass('isopen');
    var choosePayer = $("#" + mId + "hddChoosePayer").val();
    if (choosePayer === 'true') {
        payerId = $("#" + mId + "ddlPayer").val();
        if (payerId === null || payerId === "") {
            alert("Payer Data Not Selected Please Choose Payer Information first!");
            return false;
        }
    }

    var promotionCode = $('#hddPromotionCode').val();
    var promotionAmount = $('#hddPromotionAmt').val();

    var calcBy = $("#" + mId + "hddCalcBy").val();
    var isRealTime = $("#" + mId + "hddIsRealTimeTxn").val();
    var tpExRate = $("#" + mId + "hddTPExRate").val();
    var IsExrateFromPartner = $("#" + mId + "hddFetchExrateFromPartner").val();
    var branchId = $("#" + mId + "sendingAgentOnBehalfDDL").val().split('|')[0];
    var branchName = $("#" + mId + "sendingAgentOnBehalfDDL :selected").text();
    var iym = $("#" + mId + "isYourMoney option:selected").val();
    var ipp = $("#" + mId + "isPep option:selected").val();
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
        "&sMobile=" + encodeURIComponent(sMobile) +
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
        "&rfName=" + FilterStringReceiverName(rfName) +
        "&rmName=" + FilterStringReceiverName(rmName) +
        "&rlName=" + FilterStringReceiverName(rlName) +
        "&rlName2=" + FilterStringReceiverName(rlName2) +
        "&rIdType=" + FilterString(rIdType) +
        "&rIdNo=" + FilterString(rIdNo) +
        "&rGender=" + FilterString(rGender) +
        "&rTel=" + FilterString(rTel) +
        "&rMobile=" + encodeURIComponent(rMobile) +
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
        "&exRate=" + FilterString(exRate) +
        "&por=" + por +
        "&sof=" + sof +
        "&rel=" + rel +
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
        "&sCustStreet=" + sCustStreet +
        "&sCustLocation=" + sCustLocation +
        "&sCustomerType=" + sCustomerType +
        "&sCustBusinessType=" + sCustBusinessType +
        "&sCustIdIssuedCountry=" + sCustIdIssuedCountry +
        "&sCustIdIssuedDate=" + sCustIdIssuedDate +
        "&receiverId=" + receiverId +
        "&payoutPartnerId=" + payoutPartnerId +
        "&cashCollMode=" + cashCollMode +
        "&customerDepositedBank=" + customerDepositedBank +
        "&introducerTxt=" + introducerTxt +
        "&pSubLocationText=" + pSubLocationText +
        "&payerId=" + payerId +
        "&payerBranchId=" + payerBranchId +
        "&branchId=" + branchId +
        "&isCDDI=" + FilterString(isCDDI) +
        "&isRealTime=" + isRealTime +
        "&agentRefId=" + hddAgentRefId +
        "&IsExrateFromPartner=" + IsExrateFromPartner +
        "&calcBy=" + calcBy +
        "&promotionCode=" + promotionCode +
        "&promotionAmount=" + promotionAmount +
        "&branchName=" + branchName +
        "&couponId=" + couponId;

    var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";

    var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    var isSafari = navigator.userAgent.toLowerCase().indexOf('safari') > -1;

    var is_mobile = false;
    if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
        is_mobile = true;
    }

    if (is_mobile) {
        window.open(url, '_blank');
        return true;
    }

    if (isChrome) {
        PopUpWindow(url, param);

        return true;
    }
    var id = PopUpWindow(url, param);

    if (isSafari) {
        var confirmResponse = document.getElementById("confirmHidden").value;
        var res = confirmResponse.split('-:::-');

        if (res[0] === 1) {
            var errMsgArr = res[1].split('\n');
            for (var i = 0; i < errMsgArr.length; i++) {
                alert(errMsgArr[i]);
            }
        }
        else {
            window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
        }
    }

    else {
        if (id === "undefined" || id === null || id === "") {
            return;
        }
        else {
            res = id.split('-:::-');
            if (res[0] === 1) {
                errMsgArr = res[1].split('\n');
                for (i = 0; i < errMsgArr.length; i++) {
                    alert(errMsgArr[i]);
                }
            }
            else {
                window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
            }
        }
    }

    return true;
}

function GetXMLData_Questionnarie() {
    var xml = '<root>';
    var table = $('#tblQuestionnarieQsn > tbody > tr');

    $(table).each(function (index, tr) {
        for (var i = 0; i < tr.cells.length; i = i + 2) {
            var ddl = tr.cells[i + 1].childNodes[1].id;
            var value = ddl.split('_')[1];
            var text = $("#" + ddl + " option:selected").text();

            if (text === undefined || text === '')
                break;

            xml += '<row qId="' + value + '" answer="' + text + '" qType=""/>';
        }
    });

    xml += '</root>';
    return xml;
}

function GetXMLData() {
    var xml = '<root>';
    var table = $('#tblComplianceQsn > tbody > tr');

    $(table).each(function (index, tr) {
        xml += '<row id="' + tr.cells[1].innerHTML + '" answer="' + $('#complianceQuestionnare_' + tr.cells[0].innerHTML).val() + '" />';
    });
    xml += '</root>';
    return xml;
}

$(document).on('click', '#btnCalcPopUp', function () {
    var pCountry = GetValue(mId + "pCountry");
    var pMode = GetValue(mId + "pMode");
    var pAgent = GetValue(mId + "pAgent");
    if (pMode === "") {
        alert("Please select receiving mode");
        return;
    }
    var queryString = "?pMode=" + pMode + "&pCountry=" + pCountry + "&pAgent=" + pAgent;
    var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
    var res = PopUpWindow("Calculator.aspx" + queryString, param);
    if (res === undefined || res === "undefined" || res === null || res === "") {
        return;
    }
    else {
        GetElement(mId + "txtCollAmt").value = res;
        CalculateTxn();
    }
});

function ReceivingModeOnChange(pModeSelected, pAgentSelected) {
    ResetAmountFields();
    $("#" + mId + "pAgent").empty();
    PaymentModeChange(pModeSelected, pAgentSelected);
}

function PaymentModeChange(pModeSelected, pAgentSelected) {
    var pMode = "";
    if (pModeSelected === "" || pModeSelected === null)
        pMode = $("#" + mId + "pMode option:selected").text();
    else {
        pMode = pModeSelected;
    }

    pCountry = GetValue(mId + "pCountry");
    $('#trAccno').hide();
    $("#" + mId + "txtRecDepAcNo").attr("class", "form-control");
    $('#trForCPOB').hide();
    GetElement(mId + "paymentThrough").className = "";
    if (pMode === "BANK DEPOSIT") {
        $('#trAccno').show();
        $("#" + mId + "txtRecDepAcNo").attr("class", "required form-control");
        $('#trAccno').show();
    }
    var dataToSend = { MethodName: "loadAgentBank", pMode: pMode, pCountry: pCountry };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
        success: function (response) {
            LoadAgentSetting();
            ParseLoadDDl(response, GetElement(mId + "pAgent"), 'agentSelection', "");
            if (pAgentSelected !== "" && pAgentSelected !== null && pAgentSelected !== undefined) {
                SetDDLValueSelected(mId + "pAgent", pAgentSelected);
            }
            var agentId = $("#" + mId + "pAgent").val();
            if (agentId !== "" && agentId !== null && agentId !== undefined) {
                var payMode = $("#" + mId + "pMode").val();
                PopulateBankDetails(agentId, payMode, null, null);
                $('.same').show();
            }
            LoadCustomerRate();
        }
    };
    $.ajax(options);
}

function LoadPaymentThroughDdl(response, myDdl, label) {
    var data = jQuery.parseJSON(response);
    CheckSession(data);
    $(myDdl).empty();

    var option;
    if (label !== "") {
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

$(document).on('change', '#' + mId + 'editServiceCharge', function () {
    if ($("#" + mId + "allowEditSC").val() === 'N') {
        alert('You are not allowed to edit Service Charge!');
        $("#" + mId + "editServiceCharge").prop("checked", false);
        return false;
    }
    var ischecked = $(this).is(':checked');
    if (ischecked) {
        $("#" + mId + "lblServiceChargeAmt").removeAttr('disabled');
        $("#" + mId + "lblServiceChargeAmt").removeAttr('readonly');
    }
    else {
        $("#" + mId + "lblServiceChargeAmt").attr('disabled', true);
        $("#" + mId + "lblServiceChargeAmt").attr('readonly', true);
    }
})

$(document).on('blur', '#' + mId + 'txtCollAmt', function () {
    CollAmtOnChange();
})

$(document).on('blur', '#' + mId + 'txtPayAmt', function () {
    checkdata($("#" + mId + "txtPayAmt").val(), 'pAmt');
})

$(document).on('click', '#btnCalcClean', function () {
    ClearTxnData();
})

$(document).on('click', '#btnCalculate', function () {
    CalculateTxn();
})

$(document).on('click', '.collMode-chk', function () {
    if (!$(this).is(':checked')) {
        return false;
    }
    if ($(this).val() === 'Bank Deposit') {
        var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
        if (customerId === "" || customerId === null || customerId === undefined) {
            alert('Please Choose Existing Sender for Coll Mode: Bank Deposit');
            return false;
        }
        $("#" + mId + "tranDate").val('');
        $("#" + mId + "particulars").val('');
        GetDataInList();
        CheckAvailableBalance($(this).val());
        ClearAmountFields();
    } else if ($(this).val() === 'Existing Balance') {
        var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
        if (customerId === "" || customerId === null || customerId === undefined) {
            alert('Please Choose Existing Sender');
            return false;
        }
        CheckAvailableBalance("Bank Deposit", false);
    }
    else {
        $('#availableBalSpan').hide();
        ClearAmountFields();
    }
    $('.collMode-chk').not(this).prop('checked', false);
})

function PostMessageToParent(id) {
    if (id === "undefined" || id === null || id === "") {
        return;
    }
    else {
        res = id.split('-:::-');
        if (res[0] === '1') {
            errMsgArr = res[1].split('\n');
            for (i = 0; i < errMsgArr.length; i++) {
                alert(errMsgArr[i]);
            }
        }
        else if (res[0] === '102' || res[0] === '103') {
            alert(res[2]);
            alert(res[1] + ' Please fill up the Additional Customer Due Diligence Information (CDDI)');

            $("#" + mId + "hddIsAdditionalCDDI").val('Y');
            $("#" + mId + "hddAgentRefId").val(res[4]);

            if (res[3] === 'Y') {
                $("#modalAdditionalDocumentRequired").modal('show');
            }
            GetAdditionalCDDIForm();
        }
        else {
            window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
        }
    }
}

function GetAdditionalCDDIForm() {
    var customerId = $("#" + mId + "txtSearchData_aValue").val();
    $('#additionalCDDI').show();
    $('#calc').attr('disabled', true);
    $('.infoDiv').css('pointer-events', 'none');
    $('.notDisable').css('pointer-events', 'auto');

    var dataToSend = { MethodName: 'getAdditionalCDDI', customerId: customerId };
    $.ajax({
        type: "POST",
        data: dataToSend,
        async: true,
        success: function (response) {
            var table = $('#tblComplianceQsn');
            table.find("tbody tr").remove();

            var result = jQuery.parseJSON(response);
            var count = 1;
            $.each(result, function (i, d) {
                var isRequired = '';
                if (d['isRequired'] == 'requiredCompliance')
                    isRequired = '<span class="ErrMsg">*</span>';

                var row = '<tr>';
                row += '<td>' + d['ID'] + '</td>';
                row += '<td>' + d['QSN'] + ' ' + isRequired + '</td>';
                row += '<td><input type="text" value="' + d['ANSWER_TEXT'] + '" id="complianceQuestionnare_' + d['ID'] + '" class="form-control ' + d['isRequired'] + '"/></td>';
                row += '</tr>';

                table.append(row);
                count++;
            });
        },
        fail: function () {
            $('#calc').attr('disabled', false);
            alert("Error fetching data");
        }
    });
}