<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.JpBankDetails.List" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <style type="text/css">
        .modal-body .table th {
            color: #888888;
        }

        .modal-body .table td {
            color: #000;
            font-weight: 600;
        }
    </style>
    <script type="text/javascript">
        function CallBackAutocomplete(id) {
            $(id + "_aValue").val($(id + '_aValue').val());
            $(id + "_aText").val($(id + '_aText').val().split('|')[0]);
        };

        function ProcessData(rowId, status) {
            if (status == 'skip') {
                SkipCustomerDeposits(rowId);
            } else if (status == 'refund') {
                RefundCustomerDeposits(rowId);
            }
            else if (status == 'map') {
                var autoCompleteText = rowId + '_aText';
                var reqField = autoCompleteText + ",";
                if (ValidRequiredField(reqField) == false) {
                    return false;
                }
                MapCustomerDeposits(rowId);

            }
            else if (status == 'mapexisting') {
                $('#hddRowId').val(rowId);
                PopuateTxnList();
            }
            else {
                UnMapCustomerDeposits(rowId);
            }
        }

        function MapTxn(rowId, amt, particulars) {
            $('#lblDetails').text(particulars + ' (' + amt + ')')
            $('#hddRowId').val(rowId);
            PopuateTxnList();
        }

        function PopuateTxnList() {
            $("#modalPendingTxnList").modal('show');
            var dataToSend = { MethodName: 'PopulateHoldTxnList' };
            $.post('List.aspx', dataToSend, function (erd) {
                var table = $('#tblTxnList');
                table.find("tbody tr").remove();

                var result = erd; //jQuery.parseJSON(erd); //response;
                $.each(result, function (i, d) {
                    var row = '<tr>';
                    row += '<td>' + d['id'] + '</td>';
                    row += '<td>' + d['controlNo'] + '</td>';
                    row += '<td>' + d['country'] + '</td>';
                    row += '<td>' + d['sender'] + '</td>';
                    row += '<td>' + d['receiver'] + '</td>';
                    row += '<td>' + d['amt'] + '</td>';
                    row += '<td>' + d['collMode'] + '</td>';
                    row += '<td>' + d['txncreatedBy'] + '</td>';
                    row += '<td align="center"><a title="Edit" href="javascript:void(0);">'
                        + '<span class="action-icon">'
                        + '<btn class="btn btn-xs btn-success" onclick="return MapData(' + d['id'] + ')" data-toggle="tooltip" data-placement="top" title="Map Transaction">'
                        + '<i class="fa fa-check-circle"></i>'
                        + '</btn>'
                        + '</span>'
                        + '</a></td>';
                    //row += '<td><input type="button" value="' + d['ANSWER_TEXT'] + '" id="complianceQuestionnare_' + d['ID'] + '" class="form-control ' + d['isRequired'] + '"/></td>';
                    row += '</tr>';

                    table.append(row);
                });
            }).fail(function () {
                alert('Oops!!! something went wrong, please try again.');
            });
        }

        function MapData(id) {
            var tranId = $('#hddRowId').val();

            var dataToSend = { MethodName: 'SaveMapping', id: id, tranId: tranId };
            $.post('List.aspx', dataToSend, function (erd) {
                if (erd.ErrorCode == '0') {
                    window.location.reload();
                    alert(erd.Msg);
                }
                else if (erd.ErrorCode == '1') {
                    alert(erd.Msg);
                }
            }).fail(function () {
                alert('Oops!!! something went wrong, please try again.');
            });
        }

        function MapCustomerDeposits(rowId) {
            if (confirm('Are you sure want to map?')) {
                var autoCompleteValue = '#' + rowId + '_aValue';
                var bankId = $("#<%=bankList.ClientID%>").val();
                var dataToSend = { MethodName: 'MapCustomerDeposits', rowId: rowId, customerId: $(autoCompleteValue).val() };
                $.post('List.aspx', dataToSend, function (erd) {
                    if (erd.ErrorCode == '0') {
                        window.location.reload();
                        alert(erd.Msg);
                    }
                    else if (erd.ErrorCode == '1') {
                        alert(erd.Msg);
                    }
                }).fail(function () {
                    alert('Oops!!! something went wrong, please try again.');
                });
            };
        }

        function UnMapCustomerDeposits(rowId) {
            if (confirm('Are you sure want to Unmap?')) {
                var dataToSend = { MethodName: 'UnMapCustomerDeposits', rowId: rowId };
                $.post('List.aspx', dataToSend, function (erd) {
                    if (erd.ErrorCode == '0') {
                        window.location.reload();
                        alert(erd.Msg);
                    }
                    else if (erd.ErrorCode == '1') {
                        alert(erd.Msg);
                    }
                }).fail(function () {
                    alert('Oops!!! something went wrong, please try again.');
                });
            };
        }

        function RefundCustomerDeposits(rowId) {
            if (confirm('Are you sure want to refund?')) {
                var autoCompleteValue = '#' + rowId + '_aValue';
                var dataToSend = { MethodName: 'RefundCustomerDeposits', rowId: rowId, customerId: $(autoCompleteValue).val() };
                $.post('List.aspx', dataToSend, function (erd) {
                    if (erd.ErrorCode == '0') {
                        window.location.reload();
                        alert(erd.Msg);
                    }
                    else if (erd.ErrorCode == '1') {
                        alert(erd.Msg);
                    }
                }).fail(function () {
                    alert('Oops!!! something went wrong, please try again.');
                });
            };
        }
        function SkipCustomerDeposits(rowId) {
            if (confirm('Are you sure want to skip?')) {
                var autoCompleteValue = '#' + rowId + '_aValue';
                var dataToSend = { MethodName: 'SkipCustomerDeposits', rowId: rowId, customerId: $(autoCompleteValue).val() };
                $.post('List.aspx', dataToSend, function (erd) {
                    if (erd.ErrorCode == '0') {
                        window.location.reload();
                        alert(erd.Msg);
                    }
                    else if (erd.ErrorCode == '1') {
                        alert(erd.Msg);
                    }
                }).fail(function () {
                    alert('Oops!!! something went wrong, please try again.');
                });
            };
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <input type="hidden" id="hddRowId" />
        <div class="page-wrapper">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Customer Deposit Mapping</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row form-group" id="mapped" runat="server">
                                        <div class="col-md-12 table-responsive">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th width="2%">S.NO.</th>
                                                        <th width="23%">Particulars</th>
                                                        <th width="10%">Deposit Date</th>
                                                        <th width="10%">Deposit Amount</th>
                                                        <th width="10%">Withdraw Amount</th>
                                                        <th width="10%">Transaction Id</th>
                                                        <th width="25%">Customer Name</th>
                                                        <th width="20%">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="mappedDeposits" runat="server">
                                                    <tr>
                                                        <td colspan="7" align="center">No Data To Display </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    <%--   <div class="row form-group" id="unmapped" runat="server">
                                        <div class="col-md-12 table-responsive">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th width="2%">S.NO.</th>
                                                        <th width="23%">Particulars</th>
                                                        <th width="10%">Deposit Date</th>
                                                        <th width="10%">Deposit Amount</th>
                                                        <th width="10%">Withdraw Amount</th>
                                                        <th width="35%">Choose Customer</th>
                                                        <th width="10%">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="unMappedDeposits" runat="server">
                                                    <tr>
                                                        <td colspan="7" align="center">No Data To Display </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>--%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="modal fade" id="myModal1" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-header" id="modelUserForSave">
                                    <center> <h2 class="modal-title">Choose Bank<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                                </div>
                                <div class="modal-body">
                                    <div class="table-responsive">
                                        <asp:HiddenField ID="hdnType" runat="server" />
                                        <table class="table">
                                            <tr>
                                                <asp:HiddenField ID="LogId" runat="server" />
                                                <th width="20%">Bank Name:</th>
                                                <th width="80%">
                                                    <label id="bankName" runat="server"></label>
                                                </th>
                                            </tr>
                                            <tr>
                                                <th>Bank List:</th>
                                                <td>
                                                    <asp:DropDownList ID="bankList" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <button class="btn btn-primary" onclick="return MapCustomerDeposits()" data-toggle="tooltip" data-placement="top">Save</button>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="modal fade" id="myModal" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-md" role="document">
                        <div class="modal-content">
                            <div class="modal-header">

                                <center> <h2 class="modal-title">
                                                <label id="name"></label>
                                                (<label id="membership"></label>)<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                            </div>
                            <div class="modal-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">

                                        <tr class="success">
                                            <th>Mobile No:</th>
                                            <td>
                                                <label id="mobile"></label>
                                            </td>
                                            <th>Id Type:</th>
                                            <td>
                                                <label id="idtype"></label>
                                            </td>
                                        </tr>
                                        <tr class="info">
                                            <th>Id No:</th>
                                            <td>
                                                <label id="idNumber"></label>
                                            </td>
                                            <th>Address:</th>
                                            <td>
                                                <label id="address"></label>
                                            </td>
                                        </tr>
                                        <tr class="warning">
                                            <th>DOB:</th>
                                            <td>
                                                <label id="dob"></label>
                                            </td>
                                            <th>Email:</th>
                                            <td>
                                                <label id="email"></label>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Modal -->
    <div class="modal fade" id="modalPendingTxnList" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog" role="document" style="width: 80% !important">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" style="font-size: 18px; font-weight: 600;">Pending Transaction List&nbsp;>>&nbsp;<span style="font-size: 15px; font-weight: 500; background-color: yellow;"><label id="lblDetails">This is test</label></span></h5>

                    <%-- <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>--%>
                </div>
                <div class="modal-body">
                    <div class="table table-responsive">
                        <table class="table table-responsive table-bordered table-condensed table-hover" id="tblTxnList">
                            <thead>
                                <tr>
                                    <td>Tran ID</td>
                                    <td>JME No.</td>
                                    <td>Country</td>
                                    <td>Sender Name</td>
                                    <td>Receiver Name</td>
                                    <td>Collect Amt.</td>
                                    <td>Coll Mode</td>
                                    <td>User</td>
                                    <td>Action</td>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="btnHaveDocumentYes" data-dismiss="modal">Ok</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
