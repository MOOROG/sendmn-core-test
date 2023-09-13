$(document).ready(function () {
    $('.nav-tabs > li a[title]').tooltip();

    //Wizard
    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var $target = $(e.target);

        if ($target.parent().hasClass('disabled')) {
            return false;
        }
    });

    $(".next-step").click(function (e) {
        tabId = $(this).data('i');
        if (checkValidationByTab(tabId) === true) {
            var $active = $('.wizard .nav-tabs li.active');
            var i = Number($(this).data('i'));
            $('#tab' + i + 1).click();
            scroll(0, 0);
        }
    });

    $(document).on('click', '#tab1', function () {
        $('#' + ContentPlaceHolderId + 'txtSearchData_aSearch').removeAttr('disabled');
        $('#' + ContentPlaceHolderId + 'ddlCustomerType').removeAttr('disabled');
    });
    $('#' + ContentPlaceHolderId + 'ddlCustomerType').on('change', function () {
        $('#ContentPlaceHolder1_txtSearchData_aText').val('');
        ClearAllCustomerElementValue();
        DisabledAllTabs();
    });

    $(".prev-step").click(function (e) {
        var $active = $('.wizard .nav-tabs li.active');
        prevTab($active);
        scroll(0, 0);
    });

    function checkValidationByTab(tabId) {
        var requiredFields = "";
        $("#step" + tabId + " .required").each(function () {
            requiredFields += $(this).attr('id') + ",";
        });
        if (ValidRequiredField(requiredFields) === false) {
            return false;
        }
        if (tabId === 3) {
            var payoutPartnerId = $("#" + ContentPlaceHolderId + "hddPayoutPartner").val();
            if (payoutPartnerId === apiPartnerIds[0]) {
                var collModeId = $("#" + ContentPlaceHolderId + "pMode option:selected").val();
                if (collModeId === "2") {
                    var payerBranchId = $("#" + ContentPlaceHolderId + "ddlPayerBranch").val();
                    if (payerBranchId === null || payerBranchId === "") {
                        alert("Payer Branch Data Not Selected Please Choose Payer Branch Information ");
                        return;
                    }
                }
            }
            var collectionAmount = Number($('#' + ContentPlaceHolderId + 'txtCollAmt').val());
            var payAmountElement = $('#' + ContentPlaceHolderId + 'txtPayAmt');
            if (payAmountElement.attr('disabled') && collectionAmount <= 0) {
                $('#' + ContentPlaceHolderId + 'txtCollAmt').focus();
                return alert("Collection Amount Must Be More Than 0 Amount !");
            }
            var payoutAmount = Number(payAmountElement.val());
            if (!payAmountElement.attr('disabled') && payoutAmount <= 0) {
                $('#' + ContentPlaceHolderId + 'txtPayAmt').focus();
                return alert("Payout Amount Must Be More Than 0 Amount !");
            }
        }
        var $active = $('.wizard .nav-tabs li.active');
        $active.next().removeClass('disabled');
        nextTab($active);
        return true;
    }

    function nextTab(elem) {
        $(elem).next().find('a[data-toggle="tab"]').click();
    }

    function prevTab(elem) {
        $(elem).prev().find('a[data-toggle="tab"]').click();
    }

    $('.verifyTxn').click(function () {
        if (checkValidationByTab(4) === true) {
            ValidateTxn('V');
            SetVerifyTxnData();
        }
    });

    function ClearAllCustomerElementValue() {
        $('.readonlyOnCustomerSelect').each(function () {
            elementType = this.type;
            if (elementType === "select-one" || elementType === "select-multi") {
                $(this).val('');
            } else {
                $(this).val('');
                $(this).text('');
            }
        });
        $('.readonlyOnReceiverSelect').each(function () {
            elementType = this.type;
            if (elementType === "select-one" || elementType === "select-multi") {
                $(this).val('');
            } else {
                $(this).val('');
                $(this).text('');
            }
        });
    }
});