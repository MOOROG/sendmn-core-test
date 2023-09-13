$(document).ready(function () {
    $('.nav-tabs > li a[title]').tooltip();

    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var $target = $(e.target);

        if ($target.parent().hasClass('disabled')) {
            return false;
        }
    });

    $(".next-step").click(function (e) {
        tabId = $(this).attr('id');
        if (CheckFormValidation(tabId) === true) {
            var $active = $('.wizard .nav-tabs li.active');
            $active.next().removeClass('disabled');
            nextTab($active);
            scroll(0, 0);
        }
    });

    $(".prev-step").click(function (e) {
        var $active = $('.wizard .nav-tabs li.active');
        prevTab($active);
        scroll(0, 0);
    });

    function nextTab(elem) {
        $(elem).next().find('a[data-toggle="tab"]').click();
    }

    function prevTab(elem) {
        $(elem).prev().find('a[data-toggle="tab"]').click();
    }

    function CheckFormValidation(callBy) {
        var reqField = "";
        var customerType = $('#' + ContentPlaceHolderId + 'ddlCustomerType').val();
        if (callBy.toLowerCase() === "btnstep1") {
            $("#step1 .required").each(function () {
                if (customerType === "4700") {
                    if (!$(this).hasClass("clearOnIndividual")) {
                        reqField += $(this).attr('id') + ",";
                    }
                }
                if (customerType === "4701") {
                    if (!$(this).hasClass("clearOnOrganisation")) {
                        reqField += $(this).attr('id') + ",";
                    }
                }
            });
            var custtypeval = $('#' + ContentPlaceHolderId + 'ddlCustomerType').val();
            $('#' + ContentPlaceHolderId + 'hdnCustomerType').val(custtypeval);
        }
        if (callBy === "jmeContinueSign") {
            $("#step2 .required").each(function () {
                reqField += $(this).attr('id') + ",";
            });
        }

        if (ValidRequiredField(reqField) === false) {
            return false;
        }
        var issueDate = $('#' + ContentPlaceHolderId + 'IssueDate').val();
        var exipreDate = $('#' + ContentPlaceHolderId + 'ExpireDate').val();
        if (!$('#' + ContentPlaceHolderId + 'expiryDiv').hasClass("hidden")) {
            if (issueDate > exipreDate) {
                alert("Issue Date cannot be greater than Valid date");
                return false;
            }
        }
        $('#' + ContentPlaceHolderId + 'ddlCustomerType').attr("disabled", true);
        return true;
    }

    $(document).on('click', '#tab2,#tab3,#tab4,#tab5', function () {
        $('#' + ContentPlaceHolderId + 'ddlCustomerType').attr('disabled', 'disabled');
    });
});

function CheckImageValidation() {
    if ($('#' + ContentPlaceHolderId + 'reg_front_id').val() === "") {
        alert("Please Choose National/Alien Reg ID Front Image");
        return false;
    }
    if ($('#' + ContentPlaceHolderId + 'reg_back_id').val() === "") {
        alert("Please Choose National/Alien Reg ID Back Image");
        return false;
    }
    return CheckSignatureCustomer();
}

function ClickFirstTab() {
    $('#' + ContentPlaceHolderId + 'ddlCustomerType').removeAttr('disabled');
}