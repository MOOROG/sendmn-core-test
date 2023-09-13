function AddNewReceiver(senderId) {
    url = "" + "/AgentNew/Administration/CustomerSetup/Benificiar/Manage.aspx?customerId=" + senderId + "&AddType=s";
    var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
    if (isChrome) {
        PopUpWindow(url, param);
        return true;
    }
    var id = PopUpWindow(url, param);

    if (id === "undefined" || id === null || id === "") {
        return;
    }
    else {
        PopulateReceiverDDL(senderId);
        SearchReceiverDetails(id);
    }
}

function PostMessageToParentAddReceiver(id) {
    var senderId = $("#" + mId + "txtSearchData_aValue").val();
    PopulateReceiverDDL(senderId);
    SearchReceiverDetails(id);
}

function PopulateReceiverDDL(customerId) {
    if (customerId === "" || customerId === null) {
        alert('Invalid customer selected!');
    }

    var dataToSend = { MethodName: 'PopulateReceiverDDL', customerId: customerId };

    $.post('SendV2.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
        PopulateReceiverDataDDL(response);
    }).fail(function () {
        alert("Error from pupulatereceiverDDL");
    });
    return true;
}

function SearchReceiverDetails(customerId) {
    if (customerId === "" || customerId === null) {
        ClearReceiverData();
        alert('Invalid receiver selected!');
    }
    var dataToSend = { MethodName: 'SearchReceiver', customerId: customerId };
    $.post('SendV2.aspx?x=' + new Date().getTime(), dataToSend, function (response) {
        ParseResponseForReceiverData(response);
    }).fail(function () {
    });
    return true;
}

function DDLReceiverOnChange() {
    ClearTxnData();
    var receiverId = $("#" + mId + "ddlReceiver").val();
    if (receiverId !== '' && receiverId !== undefined && receiverId !== "0") {
        SearchReceiverDetails(receiverId);
    }
    else if (receiverId === "0") {
        ClearReceiverData();
        PickReceiverFromSender('a');
    }
    else if (receiverId === null || receiverId === "") {
        $('.readonlyOnReceiverSelect').removeAttr("disabled");
        ClearReceiverData();
    }
}

function ParseResponseForReceiverData(response) {
    $('.readonlyOnReceiverSelect').attr("disabled", "disabled");
    var data = jQuery.parseJSON(response);
    CheckSession(data);
    if (data[0].errorCode !== 0) {
        alert(data[0].msg);
        return;
    }
    if (data.length > 0) {
        //****Transaction Detail****
        $("#receiverName").text(data[0].firstName + ' ' + data[0].middleName + ' ' + data[0].lastName1);
        $("#" + mId + "txtRecFName").val(data[0].firstName);
        $("#" + mId + "txtRecMName").val(data[0].middleName);
        $("#" + mId + "txtRecLName").val(data[0].lastName1);
        $("#" + mId + "txtRecAdd1").val(data[0].address);
        $("#" + mId + "txtRecCity").val(data[0].city);
        $("#" + mId + "txtRecMobile").val(data[0].mobile);
        $("#" + mId + "txtRecTel").val(data[0].homePhone);
        $("#" + mId + "txtRecIdNo").val(data[0].idNumber);
        $("#" + mId + "txtRecEmail").val(data[0].email);
        $("#" + mId + "ddlRecGender").val(data[0].gender);
        $("#" + mId + "ddlRecIdType").val(data[0].idType);
        SetDDLTextSelected(mId + "ddlRecGender", data[0].gender);
        SetDDLValueSelected(mId + "ddlReceiver", data[0].receiverId);
        $("#" + mId + "hddreceiverId").val(data[0].receiverId)

        if ($.isNumeric(data[0].purposeOfRemit)) {
            SetDDLValueSelected(mId + "purpose", data[0].purposeOfRemit);
        } else {
            SetDDLTextSelected(mId + "purpose", data[0].purposeOfRemit);
        }
        if ($.isNumeric(data[0].relationship)) {
            SetDDLValueSelected(mId + "relationship", data[0].relationship);
        } else {
            SetDDLTextSelected(mId + "relationship", data[0].relationship);
        }
        //****Transaction Detail****
        ClearTxnData();
        SetDDLTextSelected(mId + "pCountry", data[0].country.toUpperCase());

        PcountryOnChange('c', data[0].paymentMethod.toUpperCase(), data[0].bankId);
        if (data[0].paymentMethod.toUpperCase() === 'BANK DEPOSIT') {
            var isBranchByName = 'N';
            var branch = '';
            PopulateBankDetails(data[0].bankId, 2, isBranchByName, data[0].branchId);
        }
        $("#branchDetail").text(data[0].branchDetails.split('|')[1]);
        $("#payerDetailsHistory").text(data[0].payerDetailsHistory.split('|')[1]);
        SetPayCurrency(data[0].COUNTRYID);
        PAgentChange();
        $("#" + mId + "txtRecDepAcNo").val(data[0].receiverAccountNo);
        ManageHiddenFields(data[0].paymentMethod.toUpperCase());
        $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
        RemoveDisableProperty();
        $("#txtpBranch_aValue").val('');
        $("#txtpBranch_aText").val('');
        $("#" + mId + "hddLocation").val(data[0].pState);
        $("#" + mId + "hddSubLocation").val(data[0].pDistrict);
        ManageLocationData();
        if (data[0].branchDetails) {
            if (data[0].manualType === 'Y') {
                $('#branch_manual').val(data[0].branchDetails);
            }
            else {
                var dataSelectDDL = {
                    id: data[0].branchDetails.split('|')[0],
                    text: data[0].branchDetails.split('|')[1]
                };

                var newOption = new Option(dataSelectDDL.text, dataSelectDDL.id, false, false);
                $('.js-example-basic-single').append(newOption).trigger('change');
                $('.js-example-basic-single').val(dataSelectDDL.id); // Select the option with a value of '1'
                $('.js-example-basic-single').trigger('change');
            }
        }
        $("#" + mId + "hddPayerData").val(data[0].payerDetailsHistory.split('|')[0]);
        var a = data[0].payerDetailsHistory.split('|')[0];
        var choosePayer = $("#" + mId + "hddChoosePayer").val();
        if ($("#" + mId + "hddPayerData").val()) {
            if (choosePayer === 'true') {
                LoadPayerData();
            }
        }
        $("#" + mId + "hddLocation").val('');
        $("#" + mId + "hddSubLocation").val('');
        $("#" + mId + "hddPayerData").val('');
    }
}

function PickReceiverFromSender(obj) {
    var senderId = $('#finalSenderId').text();
    var sName = $('#senderName').text();
    if (senderId === "" || senderId === "undefined") {
        alert('Please select the Sender`s Details');
        return;
    }
    var url = "";
    if (obj === "a") {
        return AddNewReceiver(senderId);
    }
    if (obj === "r") {
        url = "" + "/AgentNew/SendTxn/TxnHistory/ReceiverHistoryBySender.aspx?sname=" + sName + "&senderId=" + senderId;
    }

    if (obj === "s") {
        url = "" + "/AgentNew/SendTxn/TxnHistory/SenderAdvanceSearch.aspx?senderId=" + senderId;
    }
    var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
    var res = PopUpWindow(url, param);
    if (res === undefined || res === "undefined" || res === null || res === "") {
        return;
    }
    else {
        SearchReceiverDetails(res);
    }
}

function PostMessageToParentNewForReceiver(id) {
    if (id === "undefined" || id === null || id === "") {
        alert('No customer selected!');
    }
    else {
        SearchReceiverDetails(id);
    }
}

function PopulateReceiverDataDDL(response) {
    var data = jQuery.parseJSON(response);
    var ddl = GetElement(mId + "ddlReceiver");
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

//PICK receiveer FROM SENDER HISTORY
function SetReceiverFromSender(obj) {
    var senderId = $('#finalSenderId').text();
    var dataToSend = { MethodName: "ReceiverDetailBySender", id: obj, senderId: senderId };
    var options =
    {
        url: 'SendV2.aspx?x=' + new Date().getTime(),
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
    receiverData = data;
    CheckSession(data);
    if (data.length > 0) {
        alert(data[0].receiverName);
        $('#receiverName').text(data[0].receiverName);
        $('#finalBenId').text(data[0].receiverId);
        SetDDLTextSelected(mId + "pCountry", data[0].country.toUpperCase());
        PcountryOnChange('c', data[0].paymentMethod, data[0].pBank);
        $("#txtpBranch_aValue").val('');
        $("#txtpBranch_aText").val('');
        if (data[0].pBankBranch !== "" && data[0].pBankBranch !== undefined) {
            $("#tdLblBranch").show();
            $("#tdTxtBranch").show();
            $('#txtpBranch_aText').attr("readonly", true);
            $('#txtpBranch_aText').attr("class", "required disabled form-control");
            $("#txtpBranch_err").show();
            $("#txtpBranch_aValue").val(data[0].pBankBranch);
            $("#txtpBranch_aText").val(data[0].pBankBranchName);
        }
        SetValueById(mId + "txtRecFName", data[0].firstName, "");
        SetValueById(mId + "txtRecMName", data[0].middleName, "");
        SetValueById(mId + "txtRecLName", data[0].lastName1, "");
        SetValueById(mId + "txtRecSLName", data[0].lastName2, "");

        $("#city option:selected")
        
        SetDDLTextSelected(mId + "ddlRecIdType", data[0].idType);
        SetValueById(mId + "txtRecIdNo", data[0].idNumber, "");

        SetValueById(mId + "txtRecTel", data[0].homePhone, "");
        SetValueById(mId + "txtRecMobile", data[0].mobile, "");

        SetValueById(mId + "txtRecAdd1", data[0].address, "");
        SetValueById(mId + "txtRecAdd2", data[0].state, "");
        SetValueById(mId + "txtRecCity", data[0].state, "");
        SetValueById(mId + "txtRecPostal", data[0].zipCode, "");

        SetValueById(mId + "txtRecEmail", data[0].email, "");
        SetValueById(mId + "txtRecDepAcNo", data[0].accountNo, "");
    }
}

$(document).on('change', "#" + mId + "ddlRecIdType", function () {
    $("#" + mId + "txtRecIdNo").val('');
    var idType = $("#" + mId + "ddlRecIdType option:selected").text();
    var idTypeVal = $("#" + mId + "ddlRecIdType option:selected").val();
    $("#" + mId + "txtRecIdNo").attr('disabled', 'disabled').removeClass('required').removeAttr('style');
    $("#" + mId + "txtRecIdNo_err").hide();
    if (idTypeVal !== "" && idTypeVal !== null && idTypeVal !== "0") {
        $("#" + mId + "txtRecIdNo").removeAttr('disabled').addClass('required');
        $("#" + mId + "txtRecIdNo_err").show();
    }
    if (idType === "Alien Registration Card") {
        $(".recIdDateValidate").css("display", "");
    }
    else {
        $(".recIdDateValidate").css("display", "none");
    }
});

$(document).on('focus', '#' + mId + 'txtPayMsg', function () {
    if ($('#confirmHiddenChrome').val() !== '') {
        var id = $('#confirmHiddenChrome').val();
        $('#confirmHiddenChrome').val('');
        $('#ContentPlaceHolder1_txtSearchData_aSearch').blur();

        if (id === undefined || id === "undefined" || id === null || id === "") {
            return;
        }
        else {
            var res = id.split('-:::-');
            if (res[0] === 1) {
                var errMsgArr = res[1].split('\n');
                for (var i = 0; i < errMsgArr.length; i++) {
                    alert(errMsgArr[i]);
                }
            }
            else {
                ClearAllCustomerInfo();
                window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
            }
        }
    }
});

$(document).on('click', '#btnReceiverClr', function () {
    $('.readonlyOnReceiverSelect').removeAttr("disabled");
    ClearReceiverData();
    ClearCDDIInfo();
    ClearCalculatedAmount();
    ClearAmountFields();
    ClearLocationRModeCurrencyInfoData();
    ClearIntroducerData();
    ClearTxnData();
});

$(document).on('change', '#' + mId + 'txtRecEmail', function () {
    var emailData = $(this).val();
    if (emailData !== "" && emailData !== null)
        EmailValidation(this, emailData, "Receiver ");
});