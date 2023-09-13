<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VoucherEntry.aspx.cs" Inherits="Swift.web.BillVoucher.VoucherEntryWithTax.VoucherEntry" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!--new css and js -->
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <!--page plugins-->
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

</head>
<body>
    <form runat="server">
        <asp:HiddenField ID="hdnfileName1" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li class="active"><a href="List.aspx">voucher Entry</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div id="msg" visible="false" style="width: 74%;" class="alert alert-danger" runat="server">
                            <span runat="server" id="mes"></span>
                        </div>
                        <div class="form-group alert alert-danger" id="divuploadMsg" runat="server" visible="false">
                        </div>
                        <div class="panel-heading">
                            <h4 class="panel-title">Voucher Entry
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-3 form-group">
                                    <label>Tax Percentage: </label>
                                    <input type="text" id="percentageTxt" value="10" class="form-control" />
                                </div>
                                <div class="col-md-3 form-group">
                                    <label>Saved Voucher Details: </label>
                                    <label id="savedVoucherDetail"></label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 form-group">
                                    <table class="table table-responsive change">
                                        <tr>
                                            <th>Ledger</th>
                                            <th>Department</th>
                                            <th>Branch</th>
                                            <th>Amount</th>
                                            <th>Employee Name</th>
                                            <th>DR/CR</th>
                                            <th>Field1</th>
                                            <th></th>
                                        </tr>
                                        <tr>
                                            <td style="width: 300px !important">
                                                <uc1:SwiftTextBox ID="acInfo" runat="server" Category="acInfo" CssClass="autocomplete" Title="Blank for All" />
                                            </td>
                                            <td style="width: 155px !important">
                                                <asp:DropDownList ID="Department" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                            </td>
                                            <td style="width: 200px !important">
                                                <asp:DropDownList ID="Branch" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                            </td>
                                            <td style="width: 100px !important">
                                                <asp:TextBox ID="amt" placeholder="Enter Amount" runat="server" size="15" CssClass="form-control"></asp:TextBox>
                                            </td>
                                            <td style="width: 140px !important">
                                                <asp:TextBox ID="EmpName" placeholder="Enter Employee Name" runat="server" size="35" CssClass="form-control"></asp:TextBox>
                                            </td>
                                            <td style="width: 60px !important">
                                                <asp:DropDownList ID="dropDownDrCr" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="cr" Selected="True">CR</asp:ListItem>
                                                    <asp:ListItem Value="dr">DR</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td style="width: 85px !important">
                                                <asp:TextBox ID="Field1" placeholder="Enter Field" runat="server" CssClass="form-control"></asp:TextBox>
                                            </td>
                                            <td style="width: 60px !important">
                                                <input type="button" value=" Add " id="btnAdd" class="btn btn-primary m-t-25" onclick="CheckFormValidation2();" />
                                                <asp:HiddenField ID="hdnRowId" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>

                            <div class="row form-group ">
                                <div class="col-md-12">
                                    <table class="table table-bordered table-striped table-hover" id="tblTempData">
                                        <thead>
                                            <tr>
                                                <th>S. No</th>
                                                <th>AC information</th>
                                                <th>Department</th>
                                                <th>Branch</th>
                                                <th>EmployeeName</th>
                                                <th>Type</th>
                                                <th>Amount</th>
                                                <th>Select</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="row ">
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Voucher Type:
                                    </label>
                                    <asp:DropDownList ID="voucherType" runat="server" Width="100%" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Voucher Date:</label>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="transactionDate" onchange="return DateValidation('transactionDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Cheque Number:
                                    </label>
                                    <asp:TextBox ID="chequeNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Upload Image:
                                    </label>
                                    <asp:FileUpload ID="VImage" runat="server" />
                                </div>
                                <%--<div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Import CSV:
                                    </label>
                                    <asp:FileUpload ID="fileUpload" runat="server" />
                                    <a href="../../SampleFile/VoucherEntry.csv">Voucher Sample</a>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <br />
                                    <asp:Button ID="Button1" class="btn btn-primary" runat="server" Text="Upload File"/>
                                </div>--%>
                            </div>
                            <div class="row form-group">
                                <div class="col-md-12">
                                    <label class="control-label" for="">
                                        Narration:
                                    </label>
                                    <asp:TextBox ID="narrationField" runat="server" TextMode="MultiLine" MaxLength="300" Width="100%" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>

                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-4">
                                        <input type="button" value="Save voucher" id="btnSaveMainVoucher" class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                        <input type="button" value="Unsaved voucher" id="btnUnsavedVoucher" class="btn btn-primary m-t-25" onclick="PopulateTempData();" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#transactionDate");
            $('#transactionDate').mask('0000-00-00');
            var allowDate = "<%=AllowChangeDate() %>";
            if (allowDate == "True") {
                ShowCalFromTo("#<% =transactionDate.ClientID %>", 1);
            }
        });

        function CheckFormValidation2() {
            DisableAllButtons();
            var reqField = "acInfo_aText,amt,";
            if (ValidRequiredField(reqField) == false) {
                EnableAllButtons();
                return false;
            }
            var data = new FormData();
            var amount = $('#amt').val();

            data.append('acInfo', $('#acInfo_aValue').val());
            data.append('amt', amount);
            data.append('dropDownDrCr', $('#dropDownDrCr').val());
            data.append('Department', $('#Department').val());
            data.append('Branch', $('#Branch').val());
            data.append('EmpName', $('#EmpName').val());
            data.append('Field1', $('#Field1').val());
            data.append('Percent', $('#percentageTxt').val());
            data.append('MethodName', 'SaveTemp');

            $.ajax({
                type: "POST",
                enctype: 'multipart/form-data',
                url: "/BillVoucher/VoucherEntryWithTax/VoucherEntry.aspx",
                data: data,
                processData: false,
                contentType: false,
                cache: false,
                success: function (data) {
                    alert(data.Msg);
                    if (data.ErrorCode == '0') {
                        $('#acInfo_aSearch').val('');
                        $('#acInfo_aText').val('');
                        if ($('#dropDownDrCr').val() == 'cr') {
                            $('#amt').val(GetReturnAmount(amount));
                            $('#dropDownDrCr').val('dr');
                        }
                        else {
                            $('#dropDownDrCr').val('cr');
                            $('#amt').val('');
                        }
                        PopulateTempData();
                    }
                    EnableAllButtons();
                },
                error: function (e) {
                    EnableAllButtons();
                    alert(e);
                }
            });
        }

        function GetReturnAmount(amount) {
            amount = amount.replace(/,/g, "");
            var pcnt = $('#percentageTxt').val();
            var amt = parseFloat(amount) * (100 + parseFloat(pcnt)) / 100 * parseFloat(pcnt) / 100
            return CurrencyFormattedForTable(parseFloat(amount) - parseFloat(amt));
        }

        function PopulateTempData() {
            DisableAllButtons();
            var dataObject = {
                MethodName: 'PopulateTempData'
            };

            url = '';
            $.post(url, dataObject, function (data) {
                EnableAllButtons();
                var table = $('#tblTempData');
                table.find("tbody tr").remove();
                if (data.length == 0) {
                    return;
                }

                var result = data;//jQuery.parseJSON(data);
                var count = 1, totalDr = 0, totalCR = 0, drCount = 0, crCount = 0;
                $.each(result, function (i, d) {
                    if (d['part_tran_type'].toLowerCase() == 'dr') {
                        drCount++;
                        totalDr += parseFloat(d['tran_amt']);
                    }
                    else {
                        crCount++;
                        totalCR += parseFloat(d['tran_amt']);
                    }

                    var row = '<tr>';
                    row += '<td>' + count + '</td>';
                    row += '<td>' + d['acct_num'] + '</td>';
                    row += '<td>' + d['DepartmentName'] + '</td>';
                    row += '<td>' + d['agentName'] + '</td>';
                    row += '<td>' + d['emp_name'] + '</td>';
                    row += '<td>' + d['part_tran_type'] + '</td>';
                    row += '<td>' + CurrencyFormattedForTable(parseFloat(d['tran_amt'])) + '</td>';
                    row += '<td><div align="center"><span class="action-icon"><a class="btn btn-xs btn-primary" title="Delete" data-placement="top" data-toggle="tooltip" href="javascript:void(0)" data-original-title="Delete" style="text-decoration: none;" onclick="deleteRecord(\'' + d["tran_id"] + '\')" ><i class="fa fa-trash-o"></i></a></span></div></td>';
                    row += '</tr>';
                    table.append(row);

                    count++;
                });

                table.append('<tr><td nowrap="nowrap" align="right" colspan="7" ><div align="right" style="font-size:12px !important"><strong>Total Dr</strong><span style="text-align:right; font-weight: bold;"> (' + drCount + '): &nbsp; &nbsp;' + CurrencyFormatted(totalDr) + '</span></div> </td></tr>');
                table.append('<tr><td nowrap="nowrap" align="right" colspan="7" ><div align="right" style="font-size:12px !important"><strong>Total Cr</strong><span style="text-align:right; font-weight: bold;"> (' + crCount + '): &nbsp; &nbsp;' + CurrencyFormatted(totalCR) + '</span></div> </td></tr>');
            }).fail(function () {
                EnableAllButtons();
                alert(result.Msg);
            });
        }

        function CheckFormValidation() {
            DisableAllButtons();
            var reqField = "voucherType,narrationField,transactionDate,";
            if (ValidRequiredField(reqField) == false) {
                EnableAllButtons();
                return false;
            }

            var data = new FormData();

            var vImage = $("#VImage").get(0).files[0];

            data.append('voucherType', $('#voucherType').val());
            data.append('narrationField', $('#narrationField').val());
            data.append('transactionDate', $('#transactionDate').val());
            data.append('chequeNo', $('#chequeNo').val());
            data.append('vImage', vImage);
            data.append('MethodName', 'SaveMainData');

            $.ajax({
                type: "POST",
                enctype: 'multipart/form-data',
                url: "/BillVoucher/VoucherEntryWithTax/VoucherEntry.aspx",
                data: data,
                processData: false,
                contentType: false,
                cache: false,
                success: function (data) {
                    $('#savedVoucherDetail').html(data.Msg);
                    PopulateTempData();
                    EnableAllButtons();
                },
                error: function (e) {
                    EnableAllButtons();
                    alert(e);
                }
            });
        }

        function deleteRecord(rowId) {
            var dataObject = {
                MethodName: 'DeleteTemp',
                RowId: rowId
            };

            url = '';
            $.post(url, dataObject, function (data) {
                alert(data.Msg);
                PopulateTempData();
            }).fail(function () {
                alert(result.Msg);
            });
        }

        function DisableAllButtons() {
            $("#btnAdd").attr("disabled", true);
            $("#btnSaveMainVoucher").attr("disabled", true);
            $("#btnUnsavedVoucher").attr("disabled", true);
        }

        function EnableAllButtons() {
            $("#btnAdd").attr("disabled", false);
            $("#btnSaveMainVoucher").attr("disabled", false);
            $("#btnUnsavedVoucher").attr("disabled", false);
        }

        function CurrencyFormattedForTable(amount) {
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

            return CommaFormattedForTable(s, amount);
        }

        function CommaFormattedForTable(amount, amountMain) {
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

            if (amountMain < 0)
                return "(" + amount + ")";
            else
                return amount;
        }
    </script>
</body>
</html>
