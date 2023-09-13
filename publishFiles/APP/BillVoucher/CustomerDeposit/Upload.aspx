<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="Swift.web.BillVoucher.CustomerDeposit.Upload" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.7.7/xlsx.core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xls/0.7.4-a/xls.core.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li class="active"><a href="#">Voucher Upload</a></li>
                            <li class="active"><a href="Upload.aspx">Customer Deposit Voucher Upload</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Deposit Voucher Upload
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row" id="divUpload" runat="server">
                                <div class="col-md-12 form-group">
                                    <label class="control-label" for="">
                                        Choose File:
                                    </label>
                                    <input type="file" id="excelfile" /><a href="/SampleFile/TwoEntryBatchUpload.csv">Sample File</a>
                                    <label style="color:red;">Note: Please Check File before upload(<i>by clicking on Check File</i>), to verify if the data is already uploaded or not!</label>
                                </div>
                                <div class="col-md-12 form-group">
                                    <input type="button" id="viewfile" value="Export To Table" class="btn btn-success" />
                                    <input type="button" id="checkData" value="Check File" class="btn btn-primary" />
                                    <input type="button" id="uploadFile" value="Upload File" class="btn btn-primary" />
                                </div>
                            </div>
                            <div class="row" id="fileUploadDiv">
                                <div class="col-md-12 form-group">
                                    <table class="table table-responsive table-bordered" id="exceltable">
                                    </table>
                                </div>
                            </div>
                            <div class="row" id="finalResultDiv" style="display: none;">
                                <div class="col-md-12 form-group">
                                    <table class="table table-responsive table-bordered" id="tblResponseSave">
                                        <thead>
                                            <tr>
                                                <th>S. No.</th>
                                                <th>Error Code</th>
                                                <th>Narration</th>
                                                <th>Voucher Number</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tblResult" runat="server">
                                            <tr>
                                                <td colspan="3">No data to view</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="row" id="divReUpload" runat="server" visible="false">
                                <div class="col-md-12 form-group">
                                    <asp:Button ID="btnReUpload" runat="server" CssClass="btn btn-primary" Text="Re Upload" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <input type="hidden" id="hddCheck" value="N" />
    </form>
    <script type="text/javascript">

        $(document).ready(function () {
            $("body").on("click", "#viewfile", function () {
                $('#fileUploadDiv').show();
                $('#finalResultDiv').hide();
                ExportToTable();
                $('#excelfile').val('');
            });

            $("body").on("click", "#checkData", function () {
                $("#uploadFile").attr("disabled", true);
                $("#viewfile").attr("disabled", true);
                $("#checkData").attr("disabled", true);

                var xmlData = GetXMLData();
                if (xmlData == '') {
                    $("#uploadFile").attr("disabled", false);
                    $("#viewfile").attr("disabled", false);
                    $("#checkData").attr("disabled", false);
                    return alert('No data for checking!');
                }
                xmlData = xmlData.replace(/</g, '&lt;');
                xmlData = xmlData.replace(/>/g, '&gt;');

                var dataToSend = {
                    MethodName: 'CheckData',
                    XmlData: xmlData
                };
                $.post('/BillVoucher/CustomerDeposit/Upload.aspx', dataToSend, function (response) {
                    $("#uploadFile").attr("disabled", false);
                    $("#viewfile").attr("disabled", false);
                    $("#checkData").attr("disabled", false);

                    if (response.ErrorCode == '0') {
                        $('#hddCheck').val('Y');
                    }
                    alert(response.Msg);
                });
            });

            $("body").on("click", "#uploadFile", function () {
                $("#uploadFile").attr("disabled", true);
                $("#viewfile").attr("disabled", true);
                $("#checkData").attr("disabled", true);

                if ($('#hddCheck').val() == 'N') {
                    $("#uploadFile").attr("disabled", false);
                    $("#viewfile").attr("disabled", false);
                    $("#checkData").attr("disabled", false);
                    return alert('You can not upload the file, either the file is not checked or file is aleardy uploaded with same data(Invalid)!');
                }
                var xmlData = GetXMLData();
                if (xmlData == '') {
                    $("#uploadFile").attr("disabled", false);
                    $("#viewfile").attr("disabled", false);
                    $("#checkData").attr("disabled", false);
                    return alert('No data to upload!');
                }
                xmlData = xmlData.replace(/</g, '&lt;');
                xmlData = xmlData.replace(/>/g, '&gt;');

                var dataToSend = {
                    MethodName: 'UploadVoucher',
                    XmlData: xmlData
                };
                $.post('/BillVoucher/CustomerDeposit/Upload.aspx', dataToSend, function (response) {
                    $("#uploadFile").attr("disabled", false);
                    $("#viewfile").attr("disabled", false);
                    $("#checkData").attr("disabled", false);
                    $('#fileUploadDiv').hide();
                    $('#excelfile').val('');
                    $('#finalResultDiv').show();
                    $('#exceltable').empty();
                    $('#hddCheck').val('N');

                    var table = $('#tblResponseSave');
                    table.find("tbody tr").remove();

                    var result = jQuery.parseJSON(response); //response;
                    var count = 1;
                    $.each(result, function (i, d) {
                        var row = '<tr>';
                        row += '<td>' + count + '</td>';
                        row += '<td>' + d['ERROR_CODE'] + '</td>';
                        row += '<td>' + d['MSG'] + '</td>';
                        row += '<td>' + d['ID'] + '</td>';
                        row += '</tr>';

                        table.append(row);
                        count++;
                    });
                });
            });
        });

        function ExportToTable() {
            var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.xlsx|.xls)$/;
            /*Checks whether the file is a valid excel file*/
            if (regex.test($("#excelfile").val().toLowerCase())) {
                var xlsxflag = false; /*Flag for checking whether excel is .xls format or .xlsx format*/
                if ($("#excelfile").val().toLowerCase().indexOf(".xlsx") > 0) {
                    xlsxflag = true;
                }
                /*Checks whether the browser supports HTML5*/
                if (typeof (FileReader) != "undefined") {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var data = e.target.result;
                        /*Converts the excel data in to object*/
                        if (xlsxflag) {
                            var workbook = XLSX.read(data, { type: 'binary' });
                        }
                        else {
                            var workbook = XLS.read(data, { type: 'binary' });
                        }
                        /*Gets all the sheetnames of excel in to a variable*/
                        var sheet_name_list = workbook.SheetNames;

                        var cnt = 0; /*This is used for restricting the script to consider only first sheet of excel*/
                        sheet_name_list.forEach(function (y) { /*Iterate through all sheets*/
                            /*Convert the cell value to Json*/
                            if (xlsxflag) {
                                var exceljson = XLSX.utils.sheet_to_json(workbook.Sheets[y]);
                            }
                            else {
                                var exceljson = XLS.utils.sheet_to_row_object_array(workbook.Sheets[y]);
                            }
                            if (exceljson.length > 0 && cnt == 0) {
                                BindTable(exceljson, '#exceltable');
                                cnt++;
                            }
                        });
                        $('#exceltable').show();
                    }
                    if (xlsxflag) {/*If excel file is .xlsx extension than creates a Array Buffer from excel*/
                        reader.readAsArrayBuffer($("#excelfile")[0].files[0]);
                    }
                    else {
                        reader.readAsBinaryString($("#excelfile")[0].files[0]);
                    }
                }
                else {
                    alert("Sorry! Your browser does not support HTML5!");
                }
            }
            else {
                alert("Please upload a valid Excel file!");
            }
        }

        function BindTable(jsondata, tableid) {/*Function used to convert the JSON array to Html Table*/
            $(tableid).empty();
            var columns = BindTableHeader(jsondata, tableid); /*Gets all the column headings of Excel*/
            for (var i = 0; i < jsondata.length; i++) {
                var row$ = $('<tr/>');
                for (var colIndex = 0; colIndex < columns.length; colIndex++) {
                    var cellValue = jsondata[i][columns[colIndex]];
                    if (cellValue == null)
                        cellValue = "";
                    row$.append($('<td/>').html(cellValue));
                }
                $(tableid).append(row$);
            }
        }

        function BindTableHeader(jsondata, tableid) {/*Function used to get all column names from JSON and bind the html table header*/
            var columnSet = [];
            var headerTr$ = $('<tr/>');
            for (var i = 0; i < jsondata.length; i++) {
                var rowHash = jsondata[i];
                for (var key in rowHash) {
                    if (rowHash.hasOwnProperty(key)) {
                        if ($.inArray(key, columnSet) == -1) {/*Adding each unique column names to a variable array*/
                            columnSet.push(key);
                            headerTr$.append($('<th/>').html(key));
                        }
                    }
                }
            }
            $(tableid).append(headerTr$);
            return columnSet;
        }

        function GetXMLData() {
            var xml = '<root>';
            var table = $('#exceltable > tbody > tr');

            if (table.length == 0) {
                return '';
            }

            $(table).each(function (index, tr) {
                xml += '<row DT="' + ConvertDate(tr.cells[0].innerText, '-') + '" AMT="' + tr.cells[1].innerText + '" NARRATION="' + tr.cells[2].innerText + '" />';
            });
            //xml += '<row id=\"'++'\"';
            xml += '</root>';
            return xml;
        }
        function ConvertDate(dt, seprator) {
            var d = new Date(dt),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

            return [year, month, day].join(seprator);
        }
    </script>
</body>
</html>
