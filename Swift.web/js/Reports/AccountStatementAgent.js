function ViewStatementReport(type) {
    var startDate = '';
    var endDate = '';
    if (type == 're') {
        startDate = $('#startDateAfterSearch').val();
        endDate = $('#endDateAfterSearch').val();
    }
    else {
        reqField = "startDate,endDate,";
        if (ValidRequiredField(reqField) === false) {
            return false;
        }
        $('#startDateAfterSearch').val($('#startDate').val());
        $('#endDateAfterSearch').val($('#endDate').val());

        startDate = $('#startDate').val();
        endDate = $('#endDate').val();
    }

    $('#Search').attr('disabled', true);
    $('#SearchAgain').attr('disabled', true);
    var dataObject = {
        MethodName: 'ViewStatement',
        FromDate: startDate,
        ToDate: endDate,
        accCurr: $("#ddlCurrency").val(),
        type: 'a-new'
    };

    url = '';
    $.post(url, dataObject, function (data) {
        $('#statementResult').show();
        $('#searchDiv').hide();

        var sn = 1;
        var BAlance = 0, OpenBalnce = 0, fcyOpening = 0, crAmt = 0, drAmt = 0;
        var drCount = 0, crCount = 0;
        var drLink = '', curr = '';
        var url = '';

        var table = $('#statementReportTbl');
        table.find("tbody tr").remove();

        $('#Search').attr('disabled', false);
        $('#SearchAgain').attr('disabled', false);
        var result = data;//jQuery.parseJSON(data);
        $.each(result, function (i, d) {
            curr = d['fcy_Curr'];
            if (d['tran_particular'] == 'Balance Brought Forward') {
                sn = 0;
                if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
                    OpenBalnce = parseFloat(d['tran_amt']);
                }
                else {
                    OpenBalnce = parseFloat(d['usd_amt']);
                }
                fcyOpening = parseFloat(d['usd_amt']);
                BAlance = parseFloat(d['tran_amt']);
            }
            else {
                if (d['part_tran_type'] == 'dr') {
                    if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
                        drAmt += parseFloat(d['tran_amt']);
                    }
                    else {
                        drAmt += parseFloat(d['usd_amt']);
                    }
                    drCount++;
                }
                else {
                    if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
                        crAmt += parseFloat(d['tran_amt']);
                    }
                    else {
                        crAmt += parseFloat(d['usd_amt']);
                    }
                    crCount++;
                }
                BAlance += parseFloat(d['tran_amt']);
                fcyOpening += parseFloat(d['usd_amt']);
            }
            url = 'userreportResultSingle.aspx?company_id=1&vouchertype=' + d['tran_type'] + '&type=trannumber&trn_date=' + d['tran_date'] + '&tran_num=' + d['ref_num'];
            drLink = '<a href="javascript:void(0)" onclick="OpenInNewWindow(\'' + url + '\')"';
            drLink += ' title="Transaction info">';
            drLink += CurrencyFormatted(parseFloat(d['tran_amt'])) + '</a>';

            var row = '<tr>';
            row += '<td>' + sn + '</td>';
            row += '<td nowrap align="center">' + (d['tran_date'] == '1900.01.01' ? '&nbsp;' : d['tran_date']) + '</td>';
            row += '<td>' + d['tran_particular'] + '</td>';
            row += '<td>' + d['fcy_Curr'] + '</td>';
            row += '<td>' + CurrencyFormatted(parseFloat(d['usd_amt'])) + '</td>';
            row += '<td>' + CurrencyFormatted(parseFloat(fcyOpening)) + '</td>';
            row += '<td>' + d['part_tran_type'] + '</td>';
            row += '<td>' + (d['tran_particular'] == 'Balance Brought Forward' ? CurrencyFormatted(parseFloat(d['tran_amt'])) : drLink) + '</td>';
            row += '<td>' + CurrencyFormatted(parseFloat(BAlance)) + '</td>';
            row += '<td>' + (parseFloat(BAlance) > 0 ? 'CR' : 'DR') + '</td>';
            row += '</tr>';
            table.append(row);

            sn++;
        });

        $('#openingBalance').text(CurrencyFormatted(OpenBalnce));
        $('#totalCrCount').text(crCount);
        $('#totalCR').text(CurrencyFormatted(crAmt));
        $('#totalDrCount').text(drCount);
        $('#totalDR').text(CurrencyFormatted(drAmt));
        $('#DrOrCr').text((BAlance > 0 ? "CR" : "DR"));

        if (curr == null || curr == "JPY") {
            $('#closingBalance').text(CurrencyFormatted(BAlance > 0 ? BAlance * -1 : BAlance));
        }
        else {
            $('#closingBalance').text(CurrencyFormatted(fcyOpening > 0 ? fcyOpening * -1 : fcyOpening));
        }
    }).fail(function () {
        $('#Search').attr('disabled', false);
        $('#SearchAgain').attr('disabled', false);
        alert('error occured!');
    });
};

var guid = (function () {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    return function () {
        return s4() + s4() + '' + s4() + '' + s4();
    };
})();

function OpenInNewWindow(url) {
    url = url + "&srcCode=" + guid;
    window.open(url, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
}

//Textbox with Comma Separation
function CurrencyFormatted(amount) {
    var i = parseFloat(amount);
    if (isNaN(i)) { i = 0.00; }
    var minus = '';
    if (i < 0) { minus = '-'; }
    i = Math.abs(i);
    i = parseInt((i + .005) * 100);
    i = i / 100;
    s = new String(i);
    if (s.indexOf('.') < 0) { s += '.00'; }
    if (s.indexOf('.') == (s.length - 2)) { s += '0'; }
    //s = minus + s;

    //if (amount < 0)
    //    s = -1 * amount;

    return CommaFormatted(s, amount);
}

function CommaFormatted(amount, amountMain) {
    var delimiter = ",";
    var a = amount.split('.', 2);
    var d = a[1];
    var i = parseInt(a[0]);
    if (isNaN(i)) { return ''; }
    var minus = '';
    if (i < 0) { minus = '-'; }
    i = Math.abs(i);
    var n = new String(i);
    var a = [];
    while (n.length > 3) {
        var nn = n.substr(n.length - 3);
        a.unshift(nn);
        n = n.substr(0, n.length - 3);
    }
    if (n.length > 0) { a.unshift(n); }
    n = a.join(delimiter);
    if (d.length < 1) { amount = n; }
    else { amount = n + '.' + d; }
    amount = minus + amount;

    if (amountMain > 0)
        return "(" + amount + ")";
    else
        return amount;
}
$(document).on('click', '.cmdPdf', function () {
    var prtContent = document.getElementById('mainFrame');
    var html = prtContent.contentWindow.document.getElementById("main").innerHTML;
    //alert(html);
    if (prtContent == null || prtContent == "" || prtContent == undefined) {
        return false;
    }
    window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));
});