ClearData();
////////// Start Function For Load Calendars Data ////////////
function LoadCalendars() {
    ShowCalDefault("#" + mId + "txtSendIdValidDate");
    CalIDIssueDate("#" + mId + "txtSendIdExpireDate");
    CalSenderDOB("#" + mId + "txtSendDOB");
    CalReceiverDOB("#" + mId + "txtRecDOB");
    //CalFromToday("#"+mId+"txtRecValidDate");
}
LoadCalendars();
///////// End Function For Load Calendars Data ///////////////

//////// Start Function For Mobile/Phone No Validation ///////

function CheckForMobileNumber(nField, fieldName) {
    var numberPattern = /^[+]?[0-9]{6,16}$/;
    var maxLength = nField.maxLength;
    test = numberPattern.test(nField.value);
    if (!test) {
        alert(fieldName + ' Is Not Valid ! Maximum ' + maxLength + ' Numeric Characters only valid ');
        nField.value = '';
        nField.focus();
        return false;
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
        return false;
    }
    return true;
}

/////// End Function For Mobile/Phone No Validation //////////

function PostMessageToParentNew(id) {
    if (id === undefined || id === "undefined" || id === null || id === "") {
        alert('No customer selected!');
    }
    else {
        ClearSearchField();
        PopulateReceiverDDL(id);
        SearchCustomerDetails(id);
    }
}

function PostMessageToParentNewFromCalculator(collAmt) {
    if (collAmt === undefined || collAmt === "undefined" || collAmt === null || collAmt === "") {
        alert('No Amount selected!');
        alert('No Amount selected!');
    }
    else {
        SetValueById(mId + "txtCollAmt", collAmt, "");
        CalculateTxn();
    }
}

function checkdata(amt, obj) {
    if (amt > 0)
        CalculateTxn(amt, obj);
    else
        ClearCalculatedAmount();
}

function CalcOnEnter(e) {
    var evtobj = window.event ? event : e;

    var charCode = e.which || e.keyCode;
    if (charCode === 13) {
        $("#btnCalculate").focus();
    }
}

function ClearCollModeAndAvailableBal() {
    $('#availableBal').text('0');
    $('#11063').removeAttr('checked');
    $('#11062').prop('checked', true);
}

function ParseCalculateData(response, amtType) {
    var data = response;
    CheckSession1(data);
    if (data[0].ErrCode === '1') {
        alert(data[0].Msg);
        ClearAmountFields();
        return;
    }
    if (data[0].ErrCode === '101') {
        SetValueById("spnWarningMsg", "", data[0].Msg);
    }
    var availableBal = parseFloat($('#availableBal').text().replace(',', '').replace(',', '').replace(',', ''));
    var camt = parseFloat(Number(data[0].collAmt).toFixed(3));
    if ($('#11063').is(':checked') || $('#11064').is(':checked')) {
        if (camt > availableBal) {
            alert('Insufficient Available Balance!');
        
            ClearAmountFields();
            return false;
        }

    }


    $("#" + mId + "iTelCouponId").val(data[0].forexSessionId); //

    $("#" + mId + "lblSendAmt").val(parseFloat(Number(data[0].sAmt).toFixed(3))); //
    $("#" + mId + "lblExRate").text(roundNumber(data[0].exRate, 8));
    $("#" + mId + "lblPayCurr").text(data[0].pCurr);
    $("#" + mId + "lblExCurr").text(data[0].pCurr);

    $("#" + mId + "lblServiceChargeCurr").text(data[0].ScChargeCurr);


    if ($("#" + mId + "allowEditSC").val() === 'Y') {
        $("#" + mId + "editServiceCharge").attr("disabled", false);
    }

    $("#" + mId + "lblPerTxnLimit").text(data[0].limit);
    $("#" + mId + "lblPerTxnLimitCurr").text(data[0].limitCurr);

    if (!$("#" + mId + "editServiceCharge").is(':checked')) {
        $("#" + mId + "lblServiceChargeAmt").attr('disabled', 'disabled');
    }

    $("#" + mId + "lblServiceChargeAmt").val(parseFloat(data[0].scCharge).toFixed(0));
    

    SetValueById(mId + "txtCollAmt", parseFloat(Number(data[0].collAmt).toFixed(3)), ""); //
    //added by gunn
    if ($("#" + mId + "introducerTxt_aSearch").val() !== "") {
        var res = CheckReferralBalAndCamt();
        if (res === false) {
            $("#" + mId + "txtPayAmt").val('');
            $("#" + mId + "txtPayAmt").focus();
            return;
        }
    }
    SetValueById(mId + "lblSendAmt", parseFloat(Number(data[0].sAmt).toFixed(3)), ""); //
    SetValueById(mId + "txtPayAmt", parseFloat(Number(data[0].pAmt).toFixed(2)), "");

    $("#" + mId + "hddTPExRate").val(data[0].tpExRate);

    var exRateOffer = data[0].exRateOffer;
    var scOffer = data[0].scOffer;
    var scDiscount = data[0].scDiscount;
    SetValueById("scDiscount", data[0].scDiscount, "");
    SetValueById("exRateOffer", data[0].exRateOffer, "");
    var html = "<span style='color: red;'>" + exRateOffer + "</span> (Exchange Rate)<br />";
    html += "<span style='color: red;'>" + scDiscount + "</span> (Service Charge)";
    SetValueById("spnSchemeOffer", "", html);
    $("#" + mId + "customerRateFields").hide();
    var collectionAmount = Number($("#" + mId + "txtCollAmt").val());
    if (collectionAmount > 0) {
        $("#" + mId + "customerRateFields").show();
    }



    //disable service charge if promotion is defined
    if ($('#hddPromotionCode').val() !== '') {
        $("#" + mId + "editServiceCharge").attr("disabled", true);
        $("#" + mId + "lblServiceChargeAmt").attr("readonly", true);
    }

}

function CheckSession1(data) {
    if (data === undefined || data === "" || data === null)
        return;
    if (data.session_end === "1") {
        document.location = "../../../Logout.aspx";
    }
}

//load payement mode
function LoadPayMode(response, myDDL, recall, selectField, obj) {
    var data = response;
    CheckSession(data);
    $(myDDL).empty();

    var option;
    if (selectField !== "" && selectField !== undefined) {
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
    if (recall === 'pcurr') {
        SetDDLTextSelected(mId + "pMode", obj);
    }
}

function ParseLoadDDl(response, myDDL, recall, selectField) {
    var data = response;
    CheckSession(data);
    var ddl2 = GetElement(mId + "pAgentDetail");
    var ddl3 = GetElement(mId + "pAgentMaxPayoutLimit");
    $(ddl2).empty();
    $(ddl3).empty();
    $(myDDL).empty();

    GetElement("spnPayoutLimitInfo").innerHTML = "";
    if ($("#" + mId + "pMode option:selected").val() !== "" && recall === "agentSelection") {
        $('#hdnreqAgent').text(data[0].agentSelection);
    }

    var option;
    if (selectField !== "" && selectField !== undefined) {
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

    if (data[0].AGENTNAME === "[SELECT BANK]") {
        $('#pAgent_err').show();
        GetElement("pAgent_err").innerHTML = "*";
        GetElement(mId + "pAgent").className = "required form-control";
    }
    else {
        $('#pAgent_err').hide();
        GetElement("pAgent_err").innerHTML = "";
        GetElement(mId + "pAgent").className = "form-control";
    }

    var pCountry = $("#" + mId + "pCountry option:selected").text();
    var pCurr = $("#" + mId + "lblPayCurr").text();
    GetElement("spnPayoutLimitInfo").innerHTML = "Payout Limit for " + pCountry + " : " + data[0].maxPayoutLimit;
}

function SetDDLTextSelected(ddl, selectText) {
    $("#" + ddl + " option").each(function () {
        if ($(this).text() === $.trim(selectText)) {
            $(this).prop('selected', true);
            return;
        }
    });
}

function SetDDLValueSelected(ddl, selectText) {
    $("#" + ddl + " option").each(function () {
        if ($(this).val() === $.trim(selectText)) {
            $(this).prop('selected', true);
            return;
        }
    });
}

function ClickEnroll() {
    if ($("#" + mId + "EnrollCust").is(':checked')) {
        if ($("#" + mId + "NewCust").is(':checked') === false && $('#senderName').text() === "" || $('#senderName').text() === null) {
            ClearSearchSection();
            ClearData();
        }
        $('#lblMem').show();
        $('#valMem').show();
        $('#memberCode_err').html("*");
        return;
    }
    $("#" + mId + "NewCust").attr("checked", false);
    $('#lblMem').hide();
    $('#valMem').hide();
    $('#memberCode_err').html("");
}

function ExistingData() {
    if ($("#" + mId + "ExistCust").is(':checked')) {
        GetElement(mId + "NewCust").checked = false;
        ClearData();
    }
    else {
        GetElement(mId + "NewCust").checked = true;
        ClearData();
    }
}

//clear data  btnClear
function ClearData() {
    var a = false;
    var b = false;

    if ($("#" + mId + "NewCust").is(':checked')) {
        $(".readonlyOnCustomerSelect").removeAttr("disabled");
        $('.readonlyOnReceiverSelect').removeAttr("disabled");
        $(".showOnCustomerSelect").addClass("hidden");
        a = false;
        b = true;
        ClearSearchSection();
        HideElement('tblSearch');
        $('#divHideShow').hide();
        GetElement(mId + "ExistCust").checked = false;
    }
    else {
        $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
        $(".showOnCustomerSelect").removeClass("hidden");
        ShowElement('tblSearch');
        $('#divHideShow').show();
        GetElement(mId + "ExistCust").checked = true;
    }
    $("#" + mId + "txtSendFirstName").attr("readonly", a);
    $("#" + mId + "txtSendMidName").attr("readonly", a);
    $("#" + mId + "txtSendLastName").attr("readonly", a);
    $("#" + mId + "txtSendSecondLastName").attr("readonly", a);
    $("#" + mId + "txtSendIdNo").attr("readonly", a);
    $("#" + mId + "txtSendNativeCountry").attr("readonly", a);
    $('#availableBal').text('0');
}

function CheckSession(data) {
    if (data === undefined || data === "" || data === null)
        return;
    if (data[0].session_end === "1") {
        document.location = "../../../Logout.aspx";
    }
}

function GetpAgentId() {
    var pagent = $("#" + mId + "pAgent option:selected").val();
    return pagent;
}

function RemoveDisableProperty() {
    $("#" + mId + "txtSendMobile").prop("disabled", false);
    $("#" + mId + "ddlSalary").removeAttr("disabled");
    $("#" + mId + "txtSendEmail").attr("disabled", false);
    $("#" + mId + "ddlIdIssuedCountry").removeAttr("disabled");
    $("#" + mId + "occupation").removeAttr("disabled");
}

function ClearSearchSection() {
    ClearSearchField();
    $("#" + mId + "ddlReceiver").empty();
    $("#" + mId + "pMode").empty();
    $("#" + mId + "pAgent").empty();
    $("#tdLblBranch").hide();
    $("#tdTxtBranch").hide();
    $("#trAccno").hide();
    $("#spnPayoutLimitInfo").hide();
    $("#divSenderIdImage").hide();
    SetDDLValueSelected(mId + "occupation", "");
    SetDDLValueSelected(mId + "relationship", "");
    $("#" + mId + "ddlSalary").val("Select");
    SetDDLValueSelected(mId + "custLocationDDL", "");
    SetDDLValueSelected(mId + "branch", "");
    SetDDLValueSelected(mId + "pCurrDdl", "");
    $("#" + mId + "locationDDL").empty();
    $("#" + mId + "subLocationDDL").empty();
    $("#" + mId + "branch").empty();
    $("#" + mId + "pCurrDdl").empty();
    $("#branch").empty();
    SetValueById(mId + "sourceOfFund", "", "");
    ClearReceiverData();
}

function ValidateDate(date) {
    if (date === "") {
        return true;
    }
    if (Date.parse(date)) {
        return true;
    } else {
        return false;
    }
}

function GetDataInList() {
    $("#" + mId + "UnmappedDepositMapping").html('');
    $("#" + mId + "UnApprovedDepositMapping").html('');
    var tranDate = $("#" + mId + "tranDate").val();
    var particulars = $("#" + mId + "particulars").val();
    var customerId = $("#" + mId + "txtSearchData_aValue").val();
    var amount = $("#" + mId + "amount").val();
    var dataToSend = { MethodName: 'getListData', customerId: customerId, particulars: particulars, tranDate: tranDate, amount: amount };
    $.ajax({
        type: "POST",
        data: dataToSend,
        async: true,
        success: function (response) {
            $("#myModal2").modal('show');
            $("#" + mId + "UnmappedDepositMapping").html(response.split('[[<<>>]]')[0]);
            $("#" + mId + "UnApprovedDepositMapping").html(response.split('[[<<>>]]')[1]);
            ShowCalDefault("#" + mId + "tranDate");
        },
        fail: function () {
            alert("Error from Deposit Mapping");
        }
    });
}

function ShowHide(me, tbl) {
    var text = me.value;
    if (text === "+") {
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

function CreateDDLFromData(data, elementId, defaultText = null, selectedValue = null) {
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

        if (selectedValue === option.value) {
            option.selected = true;
        }

        try {
            ddl.options.add(option);
        }
        catch (e) {
            alert(e);
        }
    }
}

$(document).on('click', '#clearBtn', function () {
    $("#" + mId + "tranDate").val('');
    $("#" + mId + "particulars").val('');
    GetDataInList();
});

$(document).on('click', "#filterBtn", function () {
    GetDataInList();
});

////////// Start Function For Clear DDL Receiver /////////////
function ClearReceiverDDLData() {
    var ddl = GetElement(mId + "ddlReceiver");
    $(ddl).empty();
}
////////// End Function For Clear DDL Receiver ////////////////

////////// Start Function For Clear All Data /////////////////

function ClearAllCustomerInfo() {
    $('.infoDiv').css('pointer-events', 'auto');
    $('#additionalCDDI').hide();
    $('#calc').attr('disabled', false);
    $("#" + mId + "hddIsAdditionalCDDI").val('N');
    $("#" + mId + "hddAgentRefId").val('');

    ClearSearchSection();
    ClearAmountFields();
    ///need to change
    ClearSenderInfoData();
    ClearReceiverData();
    ClearCollModeAndAvailableBal();
    ClearCDDIInfo();
    ClearCalculatedAmount();
    $('.displayPayerInfo').hide();
    $('#availableBalSpan').hide();
    ClearLocationRModeCurrencyInfoData();
    ClearIntroducerData();
}

////////// End Function For Clear All Data   /////////////////

////////// Start Function For Showing Customer Data /////////////////
function ShowHistory() {
    var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
    if (customerId === "" || customerId === null || customerId === undefined) {
        alert('Please Choose Existing Sender');
        return false;
    }
    url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerHistory&customerId='" + customerId+"'";
    OpenInNewWindow(url);
}




////////// Start Function For Sender Info Data ///////////////
function ClearSenderInfoData() {
    SetDDLValueSelected(mId + "ddlCustomerType", "");
    $('#senderName').text("");
    $('#finalSenderId').text("");

    $("#" + mId + "txtSendFirstName").val("");
    $("#" + mId + "txtSendMidName").val("");
    $("#" + mId + "txtSendLastName").val("");
    $("#" + mId + "txtSendSecondLastName").val("");
    $("#" + mId + "txtSendEmail").val("");
    $("#" + mId + "txtSendPostal").val("");
    SetDDLValueSelected(mId + "ddlSendCustomerType", "");

    $("#" + mId + "sCustStreet").val("");
    $("#" + mId + "companyName").val("");
    $("#" + mId + "txtSendCity").val("");
    SetDDLValueSelected(mId + "ddlEmpBusinessType", "11010");
    SetDDLValueSelected(mId + "custLocationDDL", "");
    SetDDLValueSelected(mId + "ddlIdIssuedCountry", "");
    SetDDLTextSelected(mId + "ddSenIdType", "SELECT");
    $("#" + mId + "txtSendIdNo").val("");

    $("#" + mId + "txtSendMobile").val("");
    $("#" + mId + "txtSendTel").val("");
    SetDDLValueSelected(mId + "ddlSenGender", "");
    $("#" + mId + "txtSendIdValidDate").val("");
    $("#" + mId + "txtSendIdExpireDate").val("");

    SetDDLValueSelected(mId + "txtSendNativeCountry", "");
    SetDDLValueSelected(mId + "occupation", "");

    $("#" + mId + "memberCode").val("");
    $("#" + mId + "txtSendDOB").val("");
    $("#" + mId + "txtSendAdd1").val("");
    $("#" + mId + "txtSendAdd2").val("");
    $("#" + mId + "lblPerTxnLimit").text('0.00');
}
////////// End Function For Sender Info Data /////////////////

/////////// Start Function For Receiver Info Data ////////////
function ClearReceiverData() {
    $('#receiverName').text('');
    $('#finalBenId').text('');

    SetDDLValueSelected(mId + "ddlReceiver", "");
    SetDDLValueSelected(mId + "ddlRecIdType", "");

    $("#" + mId + "txtRecFName").val("");
    $("#" + mId + "txtRecMName").val("");
    $("#" + mId + "txtRecLName").val("");
    $("#" + mId + "txtRecSLName").val("");

    $("#" + mId + "txtRecAdd1").val("");
    $("#" + mId + "txtRecAdd2").val("");
    $("#" + mId + "txtRecCity").val("");
    $("#" + mId + "txtRecMobile").val("");
    $("#" + mId + "txtRecTel").val("");

    SetDDLValueSelected(mId + "ddlRecIdType", "");
    $("#" + mId + "txtRecIdNo").val("");
    SetDDLValueSelected(mId + "ddlRecGender", "");

    $("#" + mId + "txtRecPostal").val("");
    $("#" + mId + "txtRecEmail").val("");
    $("#" + mId + "txtRecIdNo").removeClass('required');
    $("#" + mId + "txtRecIdNo_err").hide();
}
/////////// End Function For Receiver Info Data //////////////

///////////// Start Function For Location/Reciving Mode/Payout Currency Info Data //////////
function ClearLocationRModeCurrencyInfoData() {
    SetDDLValueSelected(mId + "pCountry", "");
    $(mId + "locationDDL").empty();
    $(mId + "paymentThrough").empty();
    $(mId + "pAgent").empty();
    $(mId + "pAgentMaxPayoutLimit").empty();
    $(mId + "ddlScheme").empty();
    $("#" + mId + "txtRecDepAcNo").val("");
    $("#" + mId + "txtCollAmt").val("");
    $("#" + mId + "lblPerTxnLimit").val("0.00");
    $("#" + mId + "lblSendAmt").val("0");
    $("#" + mId + "editServiceCharge", '', "false");
    $("#" + mId + "allowEditSC", '', "N");
    $("#" + mId + "lblServiceChargeAmt").val("0");
    $("#" + mId + "lblExRate").text("0.00");

    $(mId + "depositedBankDDL").empty();
    $(mId + "pMode").empty();
    $(mId + "subLocationDDL").empty();
    $(mId + "branch").empty();
    $(mId + "iTelCouponId").empty();
    $(mId + "pCurrDdl").empty();
    $(mId + "txtPayAmt").empty();
    $(mId + "iTelCouponId").empty();
    $(mId + "iTelCouponId").empty();
    $("#" + mId + "scDiscount").val("0");
    $("#" + mId + "exRateOffer").val("0");
    $("#" + mId + "aValue").val("");
    $("#" + mId + "aText").val("");
    $("#" + mId + "aSearch").val("");
    $("#" + mId + "payerText").text("");
    $("#" + mId + "payerBranchText").text("");
    $("#" + mId + "aText").val("");

    $("#" + mId + "lblSendAmt").val("0");
    $("#" + mId + "lblSendAmt").val("0");
    $("#" + mId + "lblSendAmt").val("0");
}
///////////// End Function For Location Info Data ////////////

///////////// Start Function For Agent Info Data /////////////

///////////// End Function For Agent Info Data ///////////////

///////////// Start Function For CDDI  Info Data /////////////
function ClearCDDIInfo() {
    SetDDLValueSelected(mId + "purpose", "8060");
    SetDDLValueSelected(mId + "sourceOfFund", "");
    SetDDLValueSelected(mId + "relationship", "");
    SetValueById(mId + "txtPayMsg", "", "");
}
///////////// End Function For CDDI  Info Data ///////////////

///////////////// Start Function For Amount Info Data ////////
function ClearCalculatedAmount() {
    $("#" + mId + "txtCollAmt").val('');
    $("#" + mId + "lblSendAmt").val(0);
    $("#" + mId + "lblServiceChargeAmt").val(0);
    $("#" + mId + "lblExRate").val(0);
    $("#" + mId + "txtPayAmt").val('');
    $("#" + mId + "customerRateFields").hide();
}

function ClearAmountFields() {
    $("#" + mId + "lblSendAmt").val('0.00');
    $("#" + mId + "lblExRate").text('0.00');
    $("#" + mId + "lblPerTxnLimit").text('0.00');
    $("#" + mId + "lblServiceChargeAmt").val('0');
    $('#lblDiscAmt').text('0.00');
    $('#' +mId + "txtCollAmt").val("");
    $('#' +mId + "txtPayAmt").val("");
    GetElement("spnSchemeOffer").innerHTML = "";
}

function ChangeCalcBy() {
    ClearCalculatedAmount();
    if ($("#" + mId + "txtPayAmt").is(":disabled")) {
        $("#" + mId + "txtCollAmt").attr('disabled', true);
        $("#" + mId + "txtPayAmt").attr('disabled', false);
    } else {
        $("#" + mId + "txtPayAmt").attr('disabled', true);
        $("#" + mId + "txtCollAmt").attr('disabled', false);
    }
}

function ReCalculate() {
    if (!$("#" + mId + "lblServiceChargeAmt").attr("readonly")) {
        if (parseFloat($("#" + mId + "lblServiceChargeAmt").val()) >= 0) {
            CalculateTxn($("#" + mId + "txtCollAmt").val(), 'cAmt', 'Y');
        }
        else {
            alert('Service charge can not be negative!');
            $("#" + mId + "lblServiceChargeAmt").val('0');
            $("#" + mId + "lblServiceChargeAmt").focus();
        }
    }
}

function ResetAmountFields() {
    //Reset Fields
    $("#" + mId + "txtPayAmt").val('');
    $("#" + mId + "txtPayAmt").attr("readonly", false);
    $("#" + mId + "lblSendAmt").val('0.00');
    $("#" + mId + "lblServiceChargeAmt").val('0');
    $("#" + mId + "lblExRate").text('0.00');
    $("#lblDiscAmt").text('0.00');
    $("#" + mId + "lblPayCurr").text('');
    GetElement("spnSchemeOffer").innerHTML = "";
    GetElement("spnWarningMsg").innerHTML = "";
}
//added by gunn
function CheckReferralBalAndCamt() {
    var availableLimit = $("#" + mId + "hdnRefAvailableLimit").val();
    var collAmt = GetValue(mId + "txtCollAmt");
    if (parseFloat(collAmt) > parseFloat(availableLimit)) {
        alert("Introducer available balance exceeded");
        return false;
    }
}
//added by gunn
function GetReferralAvailabelLimit() {
    var dataToSend = { MethodName: 'getReferralBalance', referralCode: $("#" + mId + "introducerTxt_aValue").val() };
    $.ajax({
        type: "POST",
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        async: false,
        success: function (response) {
            $('#availableBalSpanReferral').show();
            $("#" + mId + "referralBalId").html(response);
            var bal = parseFloat($('#availableBalReferral').text().replace(/,/g, ''));
            $("#" + mId + "hdnRefAvailableLimit").val(bal);
        },
        fail: function () {
            alert("Error from GetReferralBalance");
        }
    });
}

function CheckAvailableBalance(collectionMode) {
    var customerId = $("#ContentPlaceHolder1_txtSearchData_aValue").val();
    var branchId = $("#" + mId + "sendingAgentOnBehalfDDL").val().split('|')[0];
    var dataToSend = { MethodName: 'CheckAvialableBalance', collectionMode: collectionMode, customerId: customerId, branchId: branchId };
    $.post('SendV2.aspx?', dataToSend, function (response) {
            $('#availableBalSpan').show();
            $("#availableBalSpan").html(response);
    }).fail(function () {
        alert("Due to unexpected errors we were unable to load data");
    });
}
///////////////// End Function For Amount Info Data //////////
///////////////// Start Function For Introducer Data /////////
function ClearIntroducerData() {
    IntroducerDataClear();
    $("#availableBalSpanReferral").text("");
    $("#" + mId + "referralBalId").hide();
}

function EmailValidation(thisField, emailData, displayName) {
    var pattern = /([A-Za-z0-9\+_\-]+)(\.[A-Za-z0-9\+_\-]+)*@([A-Za-z0-9\-]+\.)+[A-Za-z]{2,6}/;
    if (!pattern.test(emailData)) {
        alert(displayName + " Email Validation Not Match");
        $(thisField).val('');
        $(thisField).focus();
        return false;
    }
    return true;
}

///////////////// End Function For Introducer Data ///////////