var countryListForTfPayerData = [16, 104, 42, 169];
///////////////////////////////////////////// ------ Location /////////////////////////////////////////

function PcountryOnChange(obj, pmode, pAgentSelected="") {
    var pCountry = $("#" + mId + "pCountry").val();
    if (pCountry === "" || pCountry === null)
        return;

    var method = "";
    if (obj === 'c') {
        method = "PaymentModePcountry";
    }
    if (obj === 'pcurr') {
        method = "PCurrPcountry";
    }

    var dataToSend = { MethodName: method, pCountry: pCountry };
    var options =
    {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
        success: function (response) {
            if (obj === 'c') {
                LoadPayMode(response, document.getElementById(mId + "pMode"), 'pcurr', "", pmode);
                ReceivingModeOnChange("", pAgentSelected);
                GetPayoutPartner(response[0].serviceTypeId);
            }
            else if (obj === 'pcurr') {
                if (response === "")
                    return false;
                $("#" + mId + "lblPayCurr").text(response[0].currencyCode);
                $("#" + mId + "lblExCurr").text(response[0].currencyCode);

                return true;
            }
            return true;
        },
      error: function (xhr, ajaxOptions, thrownError) {
        console.log("Status: " + xhr.status + " Error: " + thrownError);
         alert("Due to unexpected errors we were unable to load data");
        }
    };
    $.ajax(options);
}

function PickLocation() {
    var pAgent = $("#" + mId + "pAgent option:selected").val();
    $("#" + mId + "pAgentDetail").val(pAgent);
    if (pAgent === "" || pAgent === undefined || pAgent === 0) {
        alert('First Select a Agent/Branch');
        $("#" + mId + "pAgent").focus();
        return;
    }
    var url = "TxnHistory/PickLocationByAgent.aspx?pAgent=" + pAgent;
    var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
    PopUpWindow(url, param);
}

function SchemeByPCountry() {
    var pCountry = $("#" + mId + "pCountry").val();
    var pAgent = $("#" + mId + "pAgent").val();
    var sCustomerId = $('#finalSenderId').text();
    if (pCountry === "" || pCountry === null)
        return;
    var dataToSend = { MethodName: 'LoadSchemeByRcountry', pCountry: pCountry, pAgent: pAgent, sCustomerId: sCustomerId };
    var option;
    var options =
    {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            var myDDL = document.getElementById("#" + mId + "ddlScheme");
            $(myDDL).empty();

            option = document.createElement("option");
            option.text = "Select";
            option.value = "";
            myDDL.options.add(option);

            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (response === "") {
                $(".trScheme").hide();
                $("#tdScheme").hide();
                $("#tdSchemeVal").hide();
                return false;
            }
            $(".trScheme").show();
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

function GetAddressByZipCode() {
    var zipCodeValue = $("#" + mId + "txtSendPostal").val();
    $("#txtState").val('');
    $("#txtStreet").val('');
    $("#city").val('');
    $("#txtsenderCityjapan").val('');
    $("#txtstreetJapanese").val('');
    var zipCodePattern = /^\d{3}(-\d{4})?$/;
    test = zipCodePattern.test(zipCodeValue);
    if (!test) {
        $("#" + mId + "txtSendPostal").val('');
        $("#" + mId + "txtSendPostal").focus();
        $("#" + mId + "txtSendPostal").attr("style", "display:block; background:#FFCCD2");
        return alert("Please Enter Valid Zip Code(XXX-XXXX)");
    }
    var dataToSend = { MethodName: 'GetAddressDetailsByZipCode', zipCode: zipCodeValue };
    var options = {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success:
            function (response) {
                ShowAddress(response);
            },
        error: function (result) {
            alert("Due to unexpected errors we were unable to load data");
        }
    };
    $.ajax(options);
}

function ShowAddress(erd) {
    if (erd !== null) {
        if (erd === false) {
            $("#" + mId + "txtSendPostal").val('');
            $("#" + mId + "txtSendPostal").focus();
            $("#" + mId + "txtSendPostal").attr("style", "display:block; background:#FFCCD2");
            return alert("Please Enter Valid Zip Code(XXX-XXXX)");
        }
        $("#" + mId + "txtSendPostal").removeAttr("style");
        $("#tempAddress").html(erd);
        var fullAddress = $(".town div:first-child").text();
        var newZipCode = $(".town a:first-child").text();
        fullAddress = fullAddress.replace(newZipCode, '');
        fullAddress = fullAddress.split('(')[0];
        var fullAddressArr = fullAddress.split(",");
        $("#zipCode").val(newZipCode);
        fullAddressArr.reverse();
        $("#txtState").val(fullAddressArr[0].trim());
        $("#" + mId + "sCustStreet").val(fullAddressArr[1].trim());
        $("#" + mId + "txtSendCity").val(fullAddressArr[2]);
        $("#txtsenderCityjapan").val(fullAddressArr[3]);
        $("#txtstreetJapanese").val(fullAddressArr[4]);
    }
}

function ManageLocationData() {
    var pCountry = $("#" + mId + "pCountry :selected").text();
    var pMode = $("#" + mId + "pMode").val();
    var payoutPartnerId = $("#" + mId + "hddPayoutPartner").val();
    if (pCountry === 'NEPAL') {
        GetElement(mId + "locationDDL").className = "form-control";
        GetElement(mId + "subLocationDDL").className = "form-control";
        $("#" + mId + "locationDDL").empty();
        $("#" + mId + "subLocationDDL").empty();
    }
    GetElement(mId + "locationDDL").className = "required form-control";
    GetElement(mId + "subLocationDDL").className = "required form-control";
    $('.locationRow').show();
    var dataToSend = { MethodName: 'getLocation', PCountry: pCountry, PMode: pMode, PartnerId: payoutPartnerId };
    var options = {
        url: 'SendV2.aspx?',
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        async: false,
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
    var data = response;
    var ddl = GetElement(mId + "locationDDL");
    $(ddl).empty();

    $("#" + mId + "subLocationDDL").empty();

    var option;
    option = document.createElement("option");

    for (var i = 0; i < data.length; i++) {
        option = document.createElement("option");
        if (data[i].LOCATIONNAME === 'Any State') {
            $('#subLocation').hide();
        }
        option.text = data[i].LOCATIONNAME;
        option.value = data[i].LOCATIONID;

        if ($("#" + mId + "hddLocation").val()) {
            if (option.value === $("#" + mId + "hddLocation").val()) {
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

    if ($("#" + mId + "hddSubLocation").val()) {
        LoadSublocation();
    }
}
$(document).on('change', '#' + mId + 'locationDDL', function () {
    LoadSublocation();
});

//////////////////////////////////////////// ------ End Location /////////////////////////////////////

//////////////////////////////////////// ------ Agents / Agent's Branchs //////////////////////////////

$(document).on('change', '#ContentPlaceHolder1_sendingAgentOnBehalfDDL', function () {
    OnBehalfAgentOnChange();
});

function LoadAgentSetting() {
    var pCountry = $("#" + mId + "pCountry option:selected").val();
    var pMode = $("#" + mId + "pMode option:selected").val();
    var pModeTxt = $("#" + mId + "pMode option:selected").text();
    var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pMode: pMode };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            ApplyAgentSetting(response, pModeTxt);
        }
    };
    $.ajax(options);
}

function LoadAgentByExtAgent(pAgent) {
    var dataToSend = { MethodName: "LoadAgentByExtAgent", pAgent: pAgent };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            LoadPaymentThroughDdl(response, GetElement(mId + "paymentThrough"), "SELECT");
        }
    };
    $.ajax(options);
}

function PickpBranch() {
    var pAgent = $("#" + mId + "pAgent option:selected").val();
    $("#" + mId + "pAgentDetail").val(pAgent);
    var pAgentType = $("#" + mId + "pAgentDetail option:selected").text();
    if (pAgent === "" || pAgent === undefined || pAgent === 0) {
        alert('First Select a Agent/Branch');
        $("#" + mId + "pAgent").focus();
        return;
    }
    var url = "TxnHistory/PickBranchByAgent.aspx?pAgent=" + pAgent + "&pAgentType=" + pAgentType;
    var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
    var res = PopUpWindow(url, param);
    if (res === "undefined" || res === undefined || res === null || res === "") {
        return;
    }
    else {
        var splitVal = res.split('|');
        var pBranchValue = splitVal[0];
        var pBranchText = splitVal[1];
        $("#txtpBranch_aValue").val(splitVal[0]);
        $("#txtpBranch_aText").val(splitVal[1]);

        var pMode = $("#" + mId + "pMode option:selected").text();
        if (pMode === "CASH PAYMENT TO OTHER BANK")
            PBranchChange(pBranchValue);
    }
}
// WHILE CLICKING Pagent POPULATE agent branch
function PAgentChange() {
    $("#" + mId + "branch").empty();
    var pAgent = $(mId + "pAgent").val();
    if (pAgent === null || pAgent === "" || pAgent === undefined)
        return;
    SetDDLValueSelected(mId + "pAgentDetail", pAgent);
    var pBankType = $("#" + mId + "pAgentDetail option:selected").text();
    var pCountry = $("#" + mId + "pCountry option:selected").val();
    var pMode = $("#" + mId + "pMode option:selected").val();
    var pModeTxt = $("#" + mId + "pMode option:selected").text();
    var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pAgent: pAgent, pMode: pMode, pBankType: pBankType };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            ApplyAgentSetting(response, pModeTxt);
            if (pModeTxt === "CASH PAYMENT TO OTHER BANK")
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
    if (data === "" || data === null) {
        var defbeneficiaryIdReq = $("#" + mId + "hdnBeneficiaryIdReq").val();
        var defbeneficiaryContactReq = $("#" + mId + "hdnBeneficiaryContactReq").val();
        var defrelationshipReq = $("#" + mId + "hdnRelationshipReq").val();
        $("#" + mId + "txtRecIdNo").attr("disabled", "disabled");


        if (defbeneficiaryIdReq === "H") {
            //$(".trRecId").hide();
            $("#" + mId + "ddlRecIdType").attr("class", "form-control readonlyOnReceiverSelect");
            $("#" + mId + "txtRecIdNo").attr("class", "form-control readonlyOnReceiverSelect");
            $("#" + mId + "txtRecIdNo_err").hide();
        }
        else if (defbeneficiaryIdReq === "M") {
            //$(".trRecId").show();
            $("#" + mId + "ddlRecIdType").attr("class", "required form-control readonlyOnReceiverSelect");
            $("#" + mId + "txtRecIdNo").attr("class", "required form-control readonlyOnReceiverSelect");
            $("#" + mId + "ddlRecIdType_err").show();
            $("#" + mId + "txtRecIdNo_err").show();
        }
        else if (defbeneficiaryIdReq === "O") {
            //$(".trRecId").show();
            $("#" + mId + "ddlRecIdType").attr("class", "form-control readonlyOnReceiverSelect");
            $("#" + mId + "txtRecIdNo").attr("class", "form-control readonlyOnReceiverSelect");
            $("#" + mId + "ddlRecIdType_err").hide();
            $("#" + mId + "txtRecIdNo_err").hide();
        }

        if (defrelationshipReq === "H") {
            $("#" + mId + "trRelWithRec").hide();
            $("#" + mId + "relationship").attr("class", "form-control");
        }
        else if (defrelationshipReq === "M") {
            $("#" + mId + "trRelWithRec").show();
            $("#" + mId + "relationship").attr("class", "required form-control");
            $("#" + mId + "relationship_err").show();
        }
        else if (defrelationshipReq === "O") {
            $("#" + mId + "trRelWithRec").show();
            $("#" + mId + "relationship").attr("class", "form-control");
            $("#" + mId + "relationship_err").hide();
        }

        if (defbeneficiaryContactReq === "H") {
            $("#" + mId + "trRecContactNo").hide();
            $("#" + mId + "txtRecMobile").attr("class", "form-control");
        }
        else if (defbeneficiaryContactReq === "M") {
            $("#" + mId + "trRecContactNo").show();
            $("#" + mId + "txtRecMobile").attr("class", "required form-control");
            $("#" + mId + "txtRecMobile_err").show();
        }
        else if (defbeneficiaryContactReq === "O") {
            $("#" + mId + "trRecContactNo").show();
            $("#" + mId + "txtRecMobile").attr("class", "form-control");
            $("#" + mId + "txtRecMobile_err").hide();
        }

        $("#tdLblBranch").show();
        $("#tdTxtBranch").show();

        if (pModeTxt === "BANK DEPOSIT") {
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

    var branchSelection = data[0].branchSelection.toUpperCase();
    var maxLimitAmt = data[0].maxLimitAmt;
    var agMaxLimitAmt = data[0].agMaxLimitAmt;
    var beneficiaryIdReq = data[0].benificiaryIdReq;
    var relationshipReq = data[0].relationshipReq;
    var beneficiaryContactReq = data[0].benificiaryContactReq;
    var acLengthFrom = data[0].acLengthFrom;
    var acLengthTo = data[0].acLengthTo;
    var acNumberType = data[0].acNumberType;
    $("#" + mId + "txtRecIdNo").attr("disabled", "disabled");
    $("#" + mId + "hddBranchRequired").val(branchSelection);

    if (branchSelection === "NOT REQUIRED") {
        $('.same').hide();
        $('#divBankBranch').hide();
        $('#divBankBranch_manualType').hide();

        $("#tdLblBranch").hide();
        $("#tdTxtBranch").hide();
        $('#txtpBranch_aText').attr("class", "disabled form-control");
        $('#' + mId + 'branch').attr("class", "disabled js-example-basic-single form-group select2-hidden-accessible");
        $("#agentBranchRequired").hide();

        $("#txtpBranch_err").hide();
    }
    else if (branchSelection === "MANUAL TYPE") {
        $('.same').show();
        $('#divBankBranch').hide();
        $('#divBankBranch_manualType').show();


        $("#tdLblBranch").show();
        $("#tdTxtBranch").show();
        $('#txtpBranch_aText').attr("readonly", false);
        $('#txtpBranch_aText').attr("class", "required form-control");

        $("#txtpBranch_err").show();
        $("#divBranchMsg").show();
        $("#btnPickBranch").hide();
    }
    else if (branchSelection === "SELECT") {
        $('.same').show();
        $('#divBankBranch').show();
        $('#divBankBranch_manualType').hide();

        $("#tdLblBranch").show();
        $("#tdTxtBranch").show();
        $('#txtpBranch_aText').attr("readonly", true);
        $('#txtpBranch_aText').attr("class", "required disabled form-control");
        $('#' + mId + 'branch').attr("class", "required disabled js-example-basic-single form-group select2-hidden-accessible");
        $("#agentBranchRequired").show();
        $("#txtpBranch_err").show();
    }
    else {
        $("#tdLblBranch").show();
        $("#tdTxtBranch").show();
        $('#txtpBranch_aText').attr("readonly", true);
        $('#txtpBranch_aText').attr("class", "disabled form-control");
        $("#txtpBranch_err").hide();
    }

    if (beneficiaryIdReq === "H") {
        //$("#" + mId + "trRecId").hide();
        $("#" + mId + "ddlRecIdType").attr("class", "form-control readonlyOnReceiverSelect");
        $("#" + mId + "txtRecIdNo").attr("class", "form-control readonlyOnReceiverSelect");
        $("#" + mId + "txtRecIdNo_err").hide();
    }
    else if (beneficiaryIdReq === "M") {
        //$("#" + mId + "trRecId").show();
        $("#" + mId + "ddlRecIdType").attr("class", "required form-control readonlyOnReceiverSelect");
        $("#" + mId + "txtRecIdNo").attr("class", "required form-control readonlyOnReceiverSelect");
        $("#" + mId + "ddlRecIdType_err").show();
        $("#" + mId + "txtRecIdNo_err").show();
    }
    else if (beneficiaryIdReq === "O") {
        //$("#" + mId + "trRecId").show();
        $("#" + mId + "ddlRecIdType").attr("class", "form-control readonlyOnReceiverSelect");
        $("#" + mId + "txtRecIdNo").attr("class", "form-control readonlyOnReceiverSelect");
        $("#" + mId + "ddlRecIdType_err").hide();
        $("#" + mId + "txtRecIdNo_err").hide();
    }

    if (relationshipReq === "H") {
        $("#" + mId + "trRelWithRec").hide();
        $("#" + mId + "relationship").attr("class", "form-control");
    }
    else if (relationshipReq === "M") {
        $("#" + mId + "trRelWithRec").show();
        $("#" + mId + "relationship").attr("class", "required form-control");
        $("#" + mId + "relationship_err").show();
    }
    else if (relationshipReq === "O") {
        $("#" + mId + "trRelWithRec").show();
        $("#" + mId + "relationship").attr("class", "form-control");
        $("#" + mId + "relationship_err").hide();
    }

    if (beneficiaryContactReq === "H") {
        $("#" + mId + "trRecContactNo").hide();
        $("#" + mId + "txtRecMobile").attr("class", "form-control");
    }
    else if (beneficiaryContactReq === "M") {
        $("#" + mId + "trRecContactNo").show();
        $("#" + mId + "txtRecMobile").attr("class", "required form-control");
        $("#" + mId + "txtRecMobile_err").show();
    }
    else if (beneficiaryContactReq === "O") {
        $("#" + mId + "trRecContactNo").show();
        $("#" + mId + "txtRecMobile").attr("class", "form-control");
        $("#" + mId + "txtRecMobile_err").hide();
    }

    if (data[0].ROW_ID !== '') {
        //$('#lblCampaign').text(data[0].PROMOTIONAL_MSG + ': (' + data[0].PROMOTION_TYPE + ') ' + data[0].PROMOTION_VALUE + ' JPY');
        $('#hddPromotionCode').val(data[0].ROW_ID);
        $('#hddPromotionAmt').val(data[0].PROMOTION_VALUE);
        $("#" + mId + "editServiceCharge").attr("disabled", true);
        $("#" + mId + "lblServiceChargeAmt").attr("readonly", true);
    }
    //else {
    //    $('#lblCampaign').text('N/A');
    //    $('#hddPromotionCode').val('');
    //}
}

//PickLocation

function PBranchChange(pBranch) {
    ResetAmountFields();
    var dataToSend = { MethodName: "PBranchChange", pBranch: pBranch };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            LoadPaymentThroughDdl(response, GetElement(mId + "paymentThrough"), "SELECT");
        }
    };
    $.ajax(options);
}

$(document).on('change', "#" + mId + "pAgent", function () {
    var bankId = $("#" + mId + "pAgent option:selected").val();
    if (bankId === "" || bankId === null) {
        return;
    }
    var pmode = $("#" + mId + "pMode").val();
    var partnerId = $("#" + mId + "hddPayoutPartner").val();
    //$('.same').hide();
    $("#" + mId + "branch").removeClass('required');
    $('.displayPayerInfo').hide();
    PopulateBankDetails(bankId, pmode);
    if (partnerId === apiPartnerIds[0] || pmode === "2") {
        //if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
        //    $('#agentBranchRequired').hide();
        //}
        //$('.same').show();
        //if (partnerId === apiPartnerIds[0] && pmode === "2" && (bankId !== "0" && bankId !== null && bankId !== "")) {
        //    LoadPayerData();
        //}
    }
});

function PopulateBankDetails(bankId, receiveMode, isBranchByName, branchSelected) {
    ManageHiddenFields(receiveMode);
    return;
    $("#" + mId + "branch").empty();
    var partnerId = $("#" + mId + "hddPayoutPartner").val();
    var receivingCountryId = $("#" + mId + "pCountry").val();
    var dataToSend = '';
    if (isBranchByName === '' || isBranchByName === undefined) {
        dataToSend = { bankId: bankId, type: 'bb', pMode: receiveMode, partnerId: partnerId, receivingCountryId: receivingCountryId };
    }
    else {
        dataToSend = { bankId: bankId, type: 'bb', isBranchByName: isBranchByName, branchSelected: branchSelected, pMode: receiveMode, partnerId: partnerId, receivingCountryId: receivingCountryId };
    }
    $.get("/AgentNew/SendTxn/FormLoader.aspx", dataToSend, function (data) {
        GetElement("divBankBranch").innerHTML = data;
    });
}

function ManageHiddenFields(receiveMode) {
    return true;
    receiveMode = ($("#" + mId + "pMode option:selected").val() === '' || $("#" + mId + "pMode option:selected").val() === undefined) ? receiveMode : $("#" + mId + "pMode option:selected").val();
    if (receiveMode === "2" || receiveMode.toUpperCase() === 'BANK DEPOSIT') {
        $(".same").css("display", "");
        $("#" + mId + "branch").addClass('required');
    }
    else {
        $(".same").css("display", "none");
        $("#" + mId + "branch").removeClass('required');
    }
}

function LoadPayerData() {
    $("#myModal1").removeClass("isopen");
    var countryId = Number($("#" + mId + "pCountry").val());
    var bankId = $("#" + mId + "pAgent").val();
    var pMode = $("#" + mId + "pMode").val();
    var pCountry = $("#" + mId + "pCountry").val();

    var bankCode = $("#" + mId + "pAgent option:selected").text().split('||')[1];
    var PCountryCode = $("#" + mId + "hddPCountryCode").val();
    var payCurr = $("#" + mId + "pCurrDdl").val();
    var isSyncPayerData = 'Y';
    if (bankId !== null && bankId !== "") {
        var partnerId = $("#" + mId + "hddPayoutPartner").val();
        if (partnerId === apiPartnerIds[1]) {
            bankId = $("#" + mId + "pAgent :selected").text();
        }
        var dataToSend = {
            MethodName: 'getPayerDataByBankId', bankId: bankId, partnerId: partnerId, pMode: pMode
            , pCountry: pCountry, bankCode: bankCode, PCountryCode: PCountryCode, payCurr: payCurr, countryId: countryId
            , isSyncPayerData: isSyncPayerData
        };
        var options = {
            url: 'SendV2.aspx?',
            data: dataToSend,
            dataType: 'JSON',
            type: 'POST',
            async: false,
            success: function (response) {
                    if ($("#" + mId + "pCountry option:selected").text().toLowerCase() !== 'india') {
                        $("#myModal1").modal('show');
                        $("#myModal1").addClass("isopen");
                    }
                    var ddl = GetElement(mId + "ddlPayerBranch");
                    $(ddl).empty();
                CreateDDLFromData(response, mId + "ddlPayer", null, $("#" + mId + "hddPayerData").val());
                },
            error: function (result) {
                alert("Due to unexpected errors we were unable to load data");
            }
        };
        $.ajax(options);
    }
}

$(document).on('change', "#" + mId + "ddlPayer", function () {
    return true;
    $("#myModal1").removeClass("isopen");
    var payerId = $(this).val();
    var cityId = $("#" + mId + "subLocationDDL").val();
    if (payerId !== "" && payerId !== null) {
        var partnerId = $("#" + mId + "hddPayoutPartner").val();
        var dataToSend = { MethodName: 'getPayerBranchDataByPayerAndCityId', payerId: payerId, partnerId: partnerId, CityId: cityId };
        $.post("", dataToSend, function (response) {
            $("#myModal1").modal('show');
            $("#myModal1").addClass("isopen");
            var data = jQuery.parseJSON(response);
            CreateDDLFromData(data, mId + "ddlPayerBranch");
        });
    }
});

$(document).on('change', "#" + mId + "ddlPayerBranch", function () {
    payerBranchId = $(this).val();
    if (payerBranchId === null || payerBranchId === "") {
        return alert("Please Select Payer Branch Information");
    }
    payerText = $("#" + mId + "ddlPayer option:selected").text();
    payerBranchText = $("#" + mId + "ddlPayerBranch option:selected").text();
    $("#" + mId + "payerText").text(payerText);
    $("#" + mId + "payerBranchText").text(payerBranchText);
    $('.displayPayerInfo').show();
    $("#myModal1").modal('hide');
});

function OnBehalfAgentOnChange() {
    var dataToSend = { MethodName: 'getAvailableBalance', branchId: $("#" + mId + "sendingAgentOnBehalfDDL").val().split('|')[0] };
    $.post("", dataToSend, function (response) {
        var data = jQuery.parseJSON(response);
        ClearTxnData();
        //added by gunn
        var actAsBranch = $("#" + mId + "sendingAgentOnBehalfDDL").val().split('|')[1];
       
        
        //if (actAsBranch === "N") {
        //    $("#ReferralDiv").hide();
        //} else {
        //    $("#ReferralDiv").show();
        //}


        //up to here
        if (data === null || data === undefined || data === '') {
            $("#" + mId + "availableAmt").text('N/A');
        }
        else {
            $("#" + mId + "availableAmt").text(data[0].availableBal);
            $("#" + mId + "balCurrency").text(data[0].balCurrency);
            $("#" + mId + "lblPerDayLimit").text(data[0].txnPerDayCustomerLimit);
            $("#" + mId + "lblPerDayCustomerCurr").text(data[0].sCurr);
            $("#" + mId + "lblPerTxnLimitCurr").text(data[0].sCurr);
            $("#" + mId + "lblSendCurr").text(data[0].sCurr);
            $("#" + mId + "lblServiceChargeCurr").text(data[0].sCurr);
            $("#" + mId + "txnPerDayCustomerLimit").val(data[0].txnPerDayCustomerLimit);
            $("#" + mId + "hdnLimitAmount").val(data[0].sCountryLimit);
        }
    });
}
function GetPayoutPartner(payMode) {
    var pCountry = $("#" + mId + "pCountry").val();
    var pMode = $("#" + mId + "pMode").val();
    var dataToSend = { MethodName: 'getPayoutPartner', PCountry: pCountry, PMode: pMode };
    var options = {
        url: 'SendV2.aspx?',
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
                $("#" + mId + "hddPayoutPartner").val(agentId);
                $("#" + mId + "hddFetchExrateFromPartner").val(datas[0].exRateCalByPartner);
                $("#" + mId + "hddIsRealTimeTxn").val(datas[0].isRealTime);
                $("#" + mId + "hddPCountryCode").val(datas[0].COUNTRYCODE);
                $("#" + mId + "hddChoosePayer").val(datas[0].ChoosePayer);
            },
        error: function (result) {
            alert("Due to unexpected errors we were unable to load data");
        }
    };
    $.ajax(options);
}

$(document).on('change', "#" + mId + "pCountry", function () {
    ResetAmountFields();
    ClearCalculatedAmount();
    $("#" + mId + "branch").empty();
    $("#" + mId + "pMode").empty();
    $("#" + mId + "pAgent").empty();
    $('.same').hide();
    $("#" + mId + "branch").removeClass('required');
    $("#tdLblBranch").hide();
    $("#tdTxtBranch").hide();
    $("#tdItelCouponIdLbl").hide();
    $("#tdItelCouponIdTxt").hide();
    $('#txtpBranch_aText').attr("class", "disabled form-control");
    $("#txtpBranch_err").hide();
    $("#txtpBranch_aValue").val('');
    $("#txtpBranch_aText").val('');
    $("#" + mId + "txtRecDepAcNo").val('');
    $("#" + mId + "lblExCurr").text('');
    $("#" + mId + "lblPayCurr").text('');
    $("#" + mId + "lblPerTxnLimit").text('0.00');
    GetElement("spnPayoutLimitInfo").innerHTML = "";
    $("#" + mId + "txtSendEmail").removeClass("required");
    $("#receiverEmailIsRequired").hide();
    $("#senderEmailIsRequired").hide();

    $("#" + mId + "txtRecEmail").removeClass("required");
    if ($("#" + mId + "pCountry option:selected ").val() !== "") {
        PcountryOnChange('c', "");
        SetPayCurrency($("#" + mId + "pCountry").val());
        ManageLocationData();
    }
    var pmode = $("#" + mId + "pMode").val();
    var partnerId = $("#" + mId + "hddPayoutPartner").val();
    if (partnerId === apiPartnerIds[0] || pmode === "2") {
        $("#" + mId + "branch").addClass('required');
        //$("#receiverEmailIsRequired").show();
        //$("#senderEmailIsRequired").show();
        //$("#" + mId + "txtSendEmail").addClass("required");
        //$("#" + mId + "txtRecEmail").addClass("required");
        //if (partnerId === apiPartnerIds[0] && pmode === "2") {
        //    $('#agentBranchRequired').hide();
        //    $("#" + mId + "branch").removeClass('required');
        //}
        $('.same').show();
    }
    //if (partnerId === apiPartnerIds[0] && pmode === "2") {
    //    LoadPayerData();
    //}
    //if (countryListForTfPayerData.includes(Number($("#" + mId + "pCountry").val()))) {
    //    $("#" + mId + "branch").removeClass('required');
    //    $('#agentBranchRequired').hide();
    //}
});

$(document).on('change', '#' + mId + 'pMode', function () {
    ManageHiddenFields();
    $("#" + mId + "branch").empty();
    ClearCalculatedAmount();
    $('.displayPayerInfo').hide();
    $("#" + mId + "txtRecDepAcNo").val('');
    $("#tdLblBranch").hide();
    $("#tdTxtBranch").hide();
    $('#txtpBranch_aText').attr("class", "disabled form-control");
    $("#txtpBranch_err").hide();
    $("#txtpBranch_aValue").val('');
    $("#txtpBranch_aText").val('');
    ReceivingModeOnChange("","");
    GetPayoutPartner();
    var pmode = $("#" + mId + "pMode").val();
    var partnerId = $("#" + mId + "hddPayoutPartner").val();
    if (partnerId === apiPartnerIds[0] || pmode === "2") {
        $("#" + mId + "branch").addClass('required');
        //if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
        //    $('#agentBranchRequired').hide();
        //    $("#" + mId + "branch").removeClass('required');
        //}
        $('.same').show();
        //if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
        //    LoadPayerData();
        //}
    }
});

$(document).on('change', '#' + mId + 'paymentThrough', function () {
    ResetAmountFields();
    LoadCustomerRate();
});

$(document).on('change', '#' + mId + 'ddlScheme', function () {
    ResetAmountFields();
    $("#tdItelCouponIdLbl").hide();
    $("#tdItelCouponIdTxt").hide();
    if ($("#" + mId + "ddlScheme option:selected").text().toUpperCase() === "ITEL COUPON SCHEME") {
        $("#tdItelCouponIdLbl").show();
        $("#tdItelCouponIdTxt").show();
    }
});

//btnDepositDetail
$(document).on('#btnDepositDetail', 'click', function () {
    var collAmt = PopUpWindow("CollectionDetail.aspx", "");
    if (collAmt === "undefined" || collAmt === undefined || collAmt === null || collAmt === "") {
        collAmt = $("#" + mId + "txtCollAmt").text();
    }
    else {
        if ((collAmt) > 0) {
            SetValueById(mId + "txtCollAmt", collAmt, "");
            $("#" + mId + "txtCollAmt").attr("readonly", true);
            $("#" + mId + "txtPayAmt").attr("readonly", true);
        }
        else {
            SetValueById(mId + "txtCollAmt", "", "");
            SetValueById(mId + "txtPayAmt", "", "");
            $("#" + mId + "txtCollAmt").attr("readonly", false);
            $("#" + mId + "txtPayAmt").attr("readonly", false);
        }
        CalculateTxn(collAmt);
    }
});
//added by gunn
$(document).on('blur', mId + "introducerTxt_aSearch", function () {
    var referral = $(mId + "introducerTxt_aText").val();
    if (referral === "") {
        $('#availableBalReferral').text('');
        $('#availableBalReferral').val('');
        $("#" + mId + "hdnRefAvailableLimit").val('');
        $('#availableBalSpanReferral').hide();
    }
});

///////////////////////////////////// ------ End Agents / Agent's Branchs /////////////////////////////