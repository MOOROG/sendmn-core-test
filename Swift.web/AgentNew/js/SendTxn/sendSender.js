
function CallBackAutocomplete(id) {
    if (id === "#" + mId + "txtSearchData") {
        var d = [GetItem(mId + "txtSearchData")[0], GetItem(mId + "txtSearchData")[1].split('|')[0]];
        SetItem(mId + "txtSearchData", d);
        ClearReceiverData();
        $("#" + mId + "hddCustomerId").val(GetItem(mId + "txtSearchData")[0]);
        PopulateReceiverDDL(GetItem(mId + "txtSearchData")[0]);
        SearchCustomerDetails(GetItem(mId + "txtSearchData")[0]);
    }
    //added by gunn
    else if (id === "#" + mId + "introducerTxt") {
        GetReferralAvailabelLimit();
        $("#" + mId + "referralBalId").show();
        if (GetValue(mId + "txtCollAmt") !== "") {
            var res = CheckReferralBalAndCamt();
            if (res === false) {
                if ($("#" + mId + "txtCollAmt").is(':disabled')) {
                    $("#" + mId + "txtPayAmt").val('');
                    $("#" + mId + "txtPayAmt").focus();
                } else if ($("#" + mId + "txtPayAmt").is(':disabled')) {
                    $("#" + mId + "txtCollAmt").val('');
                    $("#" + mId + "txtCollAmt").focus();
                }
            }
        }
    }
}

function SearchCustomerDetails(customerId, type) {
    if (customerId === "" || customerId === null) {
        alert('Search value is missing');
        $("#" + mId + "txtSearchData").focus();
        return false;
    }
    var dataToSend = { MethodName: 'SearchCustomer', customerId: customerId };
    $.post('SendV2.aspx?x=' + new Date().getTime(),
        dataToSend,
        function (response) {
            ParseResponseData(response);
            if (type === 'mapping') {
                var data = jQuery.parseJSON(response);
                var d = [customerId, data[0].senderName];
                SetItem(mId + "txtSearchData", d);
            }
        }).fail(function () {
        });
    return true;
}

function CheckSenderIdOnKeyUp(me) {
    var sIdNo = me.value;
    if (sIdNo === "" || sIdNo === null || sIdNo === undefined) {
        return;
    }
    var dataToSend = { MethodName: "CheckSenderIdNumber", sIdNo: sIdNo };
    $.post('SendV2.aspx?x=' + new Date().getTime(), dataToSend,
        function (response) {
            var data = jQuery.parseJSON(response);
            if (data[0].errorCode !== 0) {
                GetElement("spnIdNumber").innerHTML = data[0].msg;
                GetElement("spnIdNumber").style.display = "block";
            }
            else {
                GetElement("spnIdNumber").innerHTML = "";
                GetElement("spnIdNumber").style.display = "none";
            }
        }).fail(function () {
        });
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
            url: 'SendV2.aspx?x=' + new Date().getTime(),
            data: dataToSend,
            dataType: 'JSON',
            type: 'POST',
            success: function (response) {
                var data = jQuery.parseJSON(response);
                if (data[0].errorCode !== 0) {
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

function ChangeCustomerType() {
    //if customer type is individual
    customerTypeId = $("#" + mId + "ddlSendCustomerType").val();
    if (customerTypeId === "4700") {
        $(".hideOnIndividual").hide();
        $(".showOnIndividual").show();
        $("#" + mId + "companyName").removeClass("Required");
        $("#" + mId + "ddlEmpBusinessType").removeClass("required");
        $("#" + mId + "occupation").addClass("required");
    }
    else if (customerTypeId === "4701") {
        $(".hideOnIndividual").show();
        $(".showOnIndividual").hide();
        $("#" + mId + "ddlEmpBusinessType").addClass("required");
        $("#" + mId + "occupation").removeClass("required");
    }
}

$(document).on('blur', "#" + mId + "txtSendDOB", function () {
    var CustomerDob = GetValue(mId + "txtSendDOB");
    if (CustomerDob !== "") {
        var CustYears = datediff(CustomerDob, 'years');

        if (parseInt(CustYears) < 18) {
            alert('Customer age must be 18 or above !');
            return;
        }
    }
});
//PICK AGENT FROM SENDER HISTORY  --SenderDetailById
function PickDataFromSender(obj) {
    var dataToSend = { MethodName: "SearchCustomer", searchValue: obj, searchType: "customerId" };
    var options =
        {
            url: 'SendV2.aspx?x=' + new Date().getTime(),
            data: dataToSend,
            dataType: 'JSON',
            type: 'POST',
            success: function (response) {
                ParseResponseData(response);
            }
        };
    $.ajax(options);
}

function ParseResponseData(response) {
    $(".readonlyOnReceiverSelect").removeAttr("disabled");
    var data = jQuery.parseJSON(response);
    CheckSession(data);
    if (data[0].errorCode !== 0) {
        $(".readonlyOnReceiverSelect").prop("disabled", "disabled");
        var ddl = GetElement(mId + "ddlReceiver");
        $(ddl).empty();
        alert(data[0].msg);
        return;
    }
    $(".readonlyOnCustomerSelect").removeAttr("disabled");
    if (data.length > 0) {
        if (data[0].visaStatusNotFound == 'true') {
            $("#" + mId + "visaStatusNotFound").val('true');
            $("#visaStatusModal").modal('show');
        }
        //****Transaction Detail****
        ClearTxnData();
        SetDDLTextSelected(mId + "ddlSalary", data[0].monthlyIncome);
        $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
        RemoveDisableProperty();

        //****Sender Detail****
        $('#senderName').text(data[0].senderName);
        $('#finalSenderId').text(data[0].customerId);

        //New data added
        $("#" + mId + "txtSendPostal").val(data[0].szipCode);
        $("#" + mId + "sCustStreet").val(data[0].street);
        $("#" + mId + "txtSendCity").val(data[0].sCity);
        $("#" + mId + "companyName").val(data[0].companyName);
        $("#" + mId + "custLocationDDL").val(data[0].sState);
      $("#" + mId + "ddlEmpBusinessType").val(data[0].organizationType);
      $("#" + mId + "hddSenderIsOrg").val(data[0].isOrg);

        SetValueById(mId + "ddlSendCustomerType", data[0].customerType, "");
        SetValueById(mId + "txtSendIdExpireDate", data[0].idIssueDate, "");

        SetValueById(mId + "txtSendFirstName", data[0].sfirstName, "");
        SetValueById(mId + "txtSendMidName", data[0].smiddleName, "");
        SetValueById(mId + "txtSendLastName", data[0].slastName1, "");
        SetValueById(mId + "txtSendSecondLastName", data[0].slastName2, "");

        SetValueById(mId + "txtSendIdNo", data[0].sidNumber, "");
        if (data[0].sidNumber === "") {
            $("#" + mId + "txtSendIdNo").attr("readonly", false);
            SetDDLValueSelected(mId + "ddSenIdType", "");
        }
        else {
            $("#" + mId + "txtSendIdNo").attr("readonly", true);
        }

        SetValueById(mId + "txtSendIdValidDate", data[0].svalidDate, "");
        SetValueById(mId + "ddlIdIssuedCountry", data[0].PLACEOFISSUE, "");

        SetValueById(mId + "txtSendDOB", data[0].sdob, "");
        SetValueById(mId + "txtSendTel", data[0].shomePhone, "");
        if (data[0].shomePhone === "")
            $("#" + mId + "txtSendTel").attr("readonly", false);
        SetValueById(mId + "txtSendMobile", data[0].smobile, "");
        if (data[0].smobile === "")
            $("#" + mId + "txtSendMobile").attr("readonly", false);
        SetValueById(mId + "txtSendAdd1", data[0].saddress, "");
        if (data[0].saddress === "")
            $("#" + mId + "txtSendAdd1").attr("readonly", false);
        SetValueById(mId + "txtSendAdd2", data[0].saddress2, "");
        if (data[0].saddress2 === "")
            $("#" + mId + "txtSendAdd2").attr("readonly", false);

        SetValueById(mId + "txtSendPostal", data[0].szipCode, "");
        if (data[0].szipCode === "")
            $("#" + mId + "txtSendPostal").attr("readonly", false);
        SetDDLValueSelected(mId + "txtSendNativeCountry", "" + data[0].scountry + "");
        SetValueById(mId + "txtSendEmail", data[0].semail, "");
        if (data[0].semail === "")
            $("#" + mId + "txtSendEmail").attr("readonly", false);
        SetValueById(mId + "companyName", data[0].companyName, "");
        SetValueById(mId + "sourceOfFund", data[0].sourceOfFund, "");

        SetDDLValueSelected(mId + "ddlSenGender", data[0].sgender);
        SetDDLTextSelected(mId + "ddSenIdType", data[0].idName);
        ManageSendIdValidity();

        GetElement("divSenderIdImage").innerHTML = data[0].SenderIDimage;
        //****End of Sender Detail****

        //****Customer Due Diligence Information****
        SetDDLValueSelected(mId + "occupation", "" + data[0].sOccupation + "");
        SetDDLTextSelected(mId + "relationship", data[0].relWithSender);
        //****End of CDDI****

        ChangeCustomerType();
    }
    ManageLocationData();
}

$(document).on('change', '#' + mId + 'ddSenIdType', function () {
    ManageSendIdValidity();
});

$(document).on('change', '#' + mId + 'txtSearchData_aSearch', function () {
    customerId = $("#" + mId + "txtSearchData_aSearch").val();
    if (customerId === "" || customerId === null) {
        ClearSenderInfoData();
        ClearReceiverData();
        ClearReceiverDDLData();
        ClearLocationRModeCurrencyInfoData();
        $('#availableBalSpan').hide();
        ClearCollModeAndAvailableBal();
        ClearCDDIInfo();
        ClearIntroducerData();
        ClearSearchField();
    }
});

$(document).on('change', '#' + mId + 'txtSendEmail', function () {
    var emailData = $(this).val();
    EmailValidation('#' + mId + 'txtSendEmail', emailData, "Sender");
});

$("#btnVisaStatusClosePopup").click(function () {
    if ($("#ContentPlaceHolder1_visaStatusDdl").val() === '' || $("#ContentPlaceHolder1_visaStatusDdl").val() === undefined) {
        return false;
    }
    var dataToSend = {
        MethodName: "UpdateVisaStatus"
        , visaStatusId: $("#ContentPlaceHolder1_visaStatusDdl").val()
        , customerId: $("#" + mId + "hddCustomerId").val()
    };
    var options =
        {
            url: 'SendV2.aspx?x=' + new Date().getTime(),
            data: dataToSend,
            dataType: 'JSON',
            type: 'POST',
            success: function (response) {
                var data = jQuery.parseJSON(response);
                if (data.errorCode != 0) {
                    alert(data.msg);
                }
            }
        };
    $.ajax(options);

    $("#btnVisaStatusClosePopup").attr("data-dismiss", "modal");
});


