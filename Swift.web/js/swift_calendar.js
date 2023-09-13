//var imgPath = "/images/calendar.gif";
var dateFormatType = 'yy-mm-dd';
function ShowCalDefault(cal) {
    $(document).ready(function () {
        $(function () {
            $(cal).datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: "both",
                //buttonImage: imgPath,
                //buttonImageOnly: true,
                dateFormat: dateFormatType,
                onClose: function () {
                    this.focus();
                }
            });
        });
    });
}

function CalIDIssueDate(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            //buttonImage: "/images/calendar.gif",
            //buttonImageOnly: true,
            //yearRange: "-90",
            //maxDate: "+0",
            //minDate: "-2Y",
            dateFormat: dateFormatType,
            maxDate: "+0Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-90Y",
            onClose: function (x, y) {
                this.focus();
            }
        });
    });
}

function VisaValidDateSend(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            buttonImage: "/images/calendar.gif",
            buttonImageOnly: true,
            dateFormat: dateFormatType,
            //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+1"
        });
    });
}

function CalSenderDOB(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            buttonImage: "/images/calendar.gif",
            buttonImageOnly: true,
            dateFormat: dateFormatType,
            yearRange: "-90:-16", //16 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "-16Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-90Y"

            //onClose: function (x, y) {
            //    $("#txtSendMobile").focus();
            //}
        });
    });
}

function CalReceiverDOB(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            //buttonImage: imgPath,
            //buttonImageOnly: true,
            dateFormat: dateFormatType,
            yearRange: "-90:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "-18Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-90Y",

            onClose: function (x, y) {
                $("#txtRecMobile").focus();
            }
        });
    });
}

function CalFromToday(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            //buttonImageOnly: true,
            maxDate: "+20Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+0",

            onClose: function (x, y) {
                $("#txtRecMobile").focus();
            }
        });
    });
}

function CalFromYesterdayToToday(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            //buttonImageOnly: true,
            yearRange: "-90:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+0", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-1",

            onClose: function (x, y) {
                $("#txtRecMobile").focus();
            }
        });
    });
}

function CalUpToToday(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            // buttonImage: imgPath,
            //buttonImageOnly: true,
            // yearRange: "-90:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+0", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-2Y",
        });
    });
}

function ExpiryDate(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: "/images/calendar.gif",
            //buttonImageOnly: true,
            //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+6M",
            onClose: function () {
                this.focus();
            }
        });
    });
}

function AllowFutureDate(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: "/images/calendar.gif",
            //buttonImageOnly: true,
            //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+0D",
            onClose: function () {
                this.focus();
            }
        });
    });
}

function VisaValidDate(cal) {
    $(function () {
        alert("Visa");

        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            // buttonImageOnly: true,
            //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+1",
            onClose: function () {
                this.focus();
            }
        });
    });
}

function VisaValidDateRec(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            // buttonImageOnly: true,
            //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "+1",
            onClose: function (x, y) {
                $("#txtRecMobile").focus();
            }
        });
    });
}

function ShowCalFromTo(calFrom, calTo, nom) {
    if (nom === null || nom === "" || nom === undefined) nom = 1;
    $(function () {
        $(calFrom).datepicker({
            //defaultDate: "+1w",
            changeMonth: true,
            changeYear: true,
            numberOfMonths: nom,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            // buttonImageOnly: true,
            onSelect: function (selectedDate) {
                $(calTo).datepicker("option", "minDate", selectedDate);
            }
        });

        $(calTo).datepicker({
            //defaultDate: "+1w",
            changeMonth: true,
            changeYear: true,
            numberOfMonths: nom,
            showOn: "both", dateFormat: dateFormatType,
            //buttonImage: imgPath,
            //buttonImageOnly: true,
            onSelect: function (selectedDate) {
                $(calFrom).datepicker("option", "maxDate", selectedDate);
            }
        });
    });
}

function CalSendB2BDoi(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            dateFormat: dateFormatType,
            //buttonImage: imgPath,
            // buttonImageOnly: true,
            // yearRange: "-90:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
            maxDate: "+0", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
            minDate: "-90Y",

            onClose: function (x, y) {
                $("#txtRecMobile").focus();
            }
        });
    });
}
//@PRALHAD  allow to select till today
function CalTillToday(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            numberOfMonths: 1,
            showOn: "both",
            dateFormat: dateFormatType,
            maxDate: "+0",
            minDate: "-80Y",
            onSelect: function (selectedDate) {
                $(cal).datepicker("option", "minDate", selectedDate);
            }
        });
    });
}

function ShowCalFromToUpToToday(calFrom, calTo, nom) {
    if (nom === null || nom === "" || nom === undefined) nom = 1;
    $(function () {
        if (calFrom !== undefined && calFrom.length > 0) {
            $(calFrom).datepicker({
                //defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "both",
                dateFormat: dateFormatType,
                //buttonImage: imgPath,
                // buttonImageOnly: true,
                maxDate: "+0",
                //minDate: "-2Y",
                onSelect: function (selectedDate) {
                    $(calTo).datepicker("option", "minDate", selectedDate);
                }
            });
            var fromDateIdNameOnly = calFrom.split('#')[1];
            document.getElementById(fromDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + fromDateIdNameOnly + "','t')");
        }
        if (calTo !== undefined && calTo.length > 0) {
            $(calTo).datepicker({
                //defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: nom,
                showOn: "both",
                //buttonImage: imgPath,
                //buttonImageOnly: true,
                dateFormat: dateFormatType,
                maxDate: "+0",
                //minDate: "-2Y",
                onSelect: function (selectedDate) {
                    $(calFrom).datepicker("option", "maxDate", selectedDate);
                }
            });
            var toDateIdNameOnly = calFrom.split('#')[1];
            if (calTo !== undefined && calTo.length > 0) {
                document.getElementById(toDateIdNameOnly).removeAttribute("onchange");
                toDateIdNameOnly = calTo.split("#")[1];
                document.getElementById(toDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + toDateIdNameOnly + "','t','" + toDateIdNameOnly + "')");
                document.getElementById(toDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + toDateIdNameOnly + "','t','" + toDateIdNameOnly + "')");
            }
        }
    });
}

function ShowCalFromToUpToTodayForInput(calFrom, calTo, nom) {
    if (nom === null || nom === "" || nom === undefined) nom = 1;
    $(function () {
        var fromDateIdNameOnly = calFrom.split('#')[1];
        var selectedDate = $(calFrom).val();
        if (selectedDate.length > 0) {
            $(calTo).datepicker("option", "minDate", selectedDate);
            document.getElementById(fromDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + fromDateIdNameOnly + "','t')");
        }
        if (calTo !== undefined) {
            var toDate = $(calTo).val();
            if (toDate.length > 0) {
                $(calFrom).datepicker("option", "maxDate", toDate);
            }
            if (calTo !== undefined && calTo.length > 0) {
                document.getElementById(fromDateIdNameOnly).removeAttribute("onchange");
                toDateIdNameOnly = calTo.split("#")[1];
                document.getElementById(fromDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + fromDateIdNameOnly + "','t','" + toDateIdNameOnly + "')");
                document.getElementById(toDateIdNameOnly).setAttribute("onchange", "return DateValidation('" + fromDateIdNameOnly + "','t','" + toDateIdNameOnly + "')");
            }
        }
    });
}
//// Input Date Validation

function DateValidation(id, typeVal, compareId, compareTypeVal) {
    var firstDate = '';
    var firstId = id;
    var inputDate = document.getElementById(id).value;
    var dates = inputDate.split("-");
    if (id !== undefined && id.length > 0 && inputDate.length > 0) {
        if (dates.length === 3 && dates[0].length === 4 && dates[1].length <= 2 && dates[1] > 0 && dates[1] <= 12 && dates[2].length <= 2 && dates[2] > 0 && dates[2] <= 31) {
            var currentDate = new Date(Date.now()).toLocaleDateString();
            var currentDates = currentDate.split('/');
            if (dates[1] <= 9 && dates[1].length <= 1) {
                dates[1] = '0' + dates[1];
            }
            if (dates[2] <= 9 && dates[2].length <= 1) {
                dates[2] = '0' + dates[2];
            }
            if (currentDates[0] <= 9 && currentDates[0].length <= 1) {
                currentDates[0] = '0' + currentDates[0];
            }
            if (currentDates[1] <= 9 && currentDates[1].length <= 1) {
                currentDates[1] = '0' + currentDates[1];
            }
            inputDate = dates[0] + "-" + dates[1] + "-" + dates[2];
            currentDate = currentDates[2] + '-' + currentDates[0] + '-' + currentDates[1];
            if (typeVal === "dob") {
                CalSenderDOB("#" + id);
                var dobValidDate = currentDates[2] - 16 + '-' + currentDates[0] + '-' + currentDates[1];
                if (inputDate <= dobValidDate) {
                }
                else {
                    SetValueById(id, '', '');
                    alert("Date Of Birth Must Be At Least 16 Years Old.");
                    return document.getElementById(id).focus();
                }
            }
            else if (typeVal === "t") {
                ShowCalFromToUpToToday("#" + id);
                var ValidDate = currentDates[2] - 2 + '-' + currentDates[0] + '-' + currentDates[1];
                if (inputDate < ValidDate) {
                    SetValueById(id, '', '');
                    return document.getElementById(id).focus();
                }
                if (inputDate > currentDate) {
                    SetValueById(id, '', '');
                    alert("You Cannot Input Future Date.");
                    return document.getElementById(id).focus();
                }
            }
            else if (typeVal === "f") {
                AllowFutureDate("#" + id);
                if (inputDate < currentDate) {
                    SetValueById(id, '', '');
                    alert("You Cannot Input Past Date.");
                    return document.getElementById(id).focus();
                }
            }
            else if (typeVal === "i") {
                CalTillToday("#" + id);
                if (inputDate > currentDate) {
                    SetValueById(id, '', '');
                    alert("You Cannot Input Future Date.");
                    return document.getElementById(id).focus();
                }
            }
            firstDate = inputDate;
            $("#" + id).val(inputDate);
        }
        else {
            SetValueById(id, '');
            alert("Invalid Date Format ! Please Enter yyyy-mm-dd format");
            return document.getElementById(id).focus();
        }
    }
    if (compareId !== undefined && compareId.length > 0) {
        var compareDate = document.getElementById(compareId).value;
        if (compareDate.length > 0) {
            if (compareTypeVal !== undefined && compareTypeVal.length > 0) {
                typeVal = '';
                typeVal = compareTypeVal;
            }
            var dates = compareDate.split("-");
            if (dates.length == 3 && dates[0].length == 4 && dates[1].length <= 2 && dates[1] > 0 && dates[1] <= 12 && dates[2].length <= 2 && dates[2] > 0 && dates[2] <= 31) {
                var currentDate = new Date(Date.now()).toLocaleDateString();
                var currentDates = currentDate.split('/');
                if (dates[1] <= 9 && dates[1].length <= 1) {
                    dates[1] = '0' + dates[1];
                }
                if (dates[2] <= 9 && dates[2].length <= 1) {
                    dates[2] = '0' + dates[2];
                }
                if (currentDates[0] <= 9 && currentDates[0].length <= 1) {
                    currentDates[0] = '0' + currentDates[0];
                }
                if (currentDates[1] <= 9 && currentDates[1].length <= 1) {
                    currentDates[1] = '0' + currentDates[1];
                }
                compareDate = dates[0] + "-" + dates[1] + "-" + dates[2];
                currentDate = currentDates[2] + '-' + currentDates[0] + '-' + currentDates[1];
                if (typeVal === "t") {
                    var ValidDate = currentDates[2] - 2 + '-' + currentDates[0] + '-' + currentDates[1];
                    if (compareDate < ValidDate) {
                        SetValueById(compareId, '', '');
                        compareDate = '';
                        document.getElementById(compareId).focus();
                    }
                    if (compareDate > currentDate) {
                        SetValueById(compareId, '', '');
                        compareDate = '';
                        alert("You Cannot Input Future Date.");
                        document.getElementById(compareId).focus();
                    }
                }
                if (firstDate.length === 10) {
                    if (firstDate > compareDate) {
                        SetValueById(compareId, '');
                        compareDate = '';
                        alert("To Date Must Be Greater Or Equal To From Date");
                        document.getElementById(id).focus();
                    }
                }
                $("#" + compareId).val(compareDate);
            }
            else {
                SetValueById(compareId, '');
                alert("Invalid Date Format ! Please Enter yyyy-mm-dd format");
                return document.getElementById(compareId).focus();
            }
        }
        ShowCalFromToUpToTodayForInput("#" + id, "#" + compareId);
    }
}

function From(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            numberOfMonths: 1,
            showOn: "both",
            dateFormat: dateFormatType,
            maxDate: "+0",
            minDate: "-80Y",
            onSelect: function (selectedDate) {
                $('#to').datepicker("option", "minDate", selectedDate);
            }
        });
    });
}
function To(cal) {
    $(function () {
        $(cal).datepicker({
            changeMonth: true,
            changeYear: true,
            numberOfMonths: 1,
            showOn: "both",
            dateFormat: dateFormatType,
            maxDate: "+0",
            minDate: "-80Y",
            onSelect: function (selectedDate) {
                var fromDate = $('#from').val();
                $(cal).datepicker("option", "minDate", fromDate);
            }
        });
    });
}