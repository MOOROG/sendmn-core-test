<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelTxn.aspx.cs" Inherits="Swift.web.Remit.Administration.ChangeReferral.CancelTxn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/css/intlTelInput.css" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
    <script src="/js/popper/popper.min.js"></script>
    <script src="/js/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalDefault("#cancelDate");
            $('#cancelDate').mask('0000-00-00');

            $('#btnSearchTxn').click(function () {
                $("#btnSearchTxnWithStatus").attr("disabled", true);
                $("#btnSearchTxn").attr("disabled", true);
                var reqField = "controlNo,";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnSearchTxnWithStatus").attr("disabled", false);
                    $("#btnSearchTxn").attr("disabled", false);
                    return false;
                }
                SearchTransactionDetails('n');
            });

            $('#btnSearchTxnWithStatus').click(function () {
                $("#btnSearchTxn").attr("disabled", true);
                $("#btnSearchTxnWithStatus").attr("disabled", true);
                var reqField = "controlNo,";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnSearchTxnWithStatus").attr("disabled", false);
                    $("#btnSearchTxn").attr("disabled", false);
                    return false;
                }
                SearchTransactionDetails('y');
            });

            $('#btnClear').click(function () {
                $('#controlNo').val('');
                $('#controlNo').focus();
                $('#step1').show();
                $('#step2').hide();
                $('#tblPartnerResponse').find("tbody tr").remove();
                $('#partnerResponse').hide();
            });
            $('#btnCancelTxn').click(function () {
                $("#btnCancelTxn").attr("disabled", true);
                var reqField = "cancelDate,";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnCancelTxn").attr("disabled", false);
                    return false;
                }
                if (confirm('Are you sure? you would like to cancel txn')) {
                    $("#btnCancelTxn").attr("disabled", false);
                    SaveReferral();
                }
                else {
                    $("#btnCancelTxn").attr("disabled", false);
                    return false;
                }
            });
        });

        function SaveReferral() {
            var dataToSend = {
                MethodName: 'CancelTxn',
                ControlNo: $('#hddControlno').val(),
                CancelDate: $('#cancelDate').val(),
                CancelReason: $('#cancelReason').val()
            };

            $.post('/Remit/Administration/ChangeReferral/CancelTxn.aspx', dataToSend, function (response) {
                $("#btnCancelTxn").attr("disabled", false);
                $("#btnSearchTxnWithStatus").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#controlNo').val('');
                    $('#controlNo').focus();
                    $('#hddControlno').val('');
                    $('#hddTranId').val('');

                    $('#step1').show();
                    $('#step2').hide();
                    alert(response.Msg);
                }
                else {
                    alert(response.Msg);
                }
            });
        }

        function SearchTransactionDetails(includePartnerSearch) {
            var dataToSend = {
                MethodName: 'SearchTransaction',
                ControlNo: $('#controlNo').val(),
                IncludePartnerSearch: includePartnerSearch
            };

            $.post('/Remit/Administration/ChangeReferral/CancelTxn.aspx', dataToSend, function (response) {
                $("#btnSearchTxn").attr("disabled", false);
                $("#btnSearchTxnWithStatus").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#step1').hide();
                    $('#step2').show();
                    ShowTxnDetails(response, includePartnerSearch);
                }
                else {
                    alert(response.Msg);
                }
            });

            function ShowTxnDetails(response, includePartnerSearch) {
                $('#txtSName').text(response.SenderName);
                $('#txtReceiverName').text(response.SenderName);
                $('#txtReferralName').text(response.ReferralName + ' (' + response.ReferralCode + ')');
                $('#txtCollectAmount').text(response.CollectAmount + ' (JPY)');
                $('#txtPayoutAmount').text(response.PayoutAmount + ' (' + response.PayoutCurr + ')');
                $('#txtpayoutCountry').text(response.PayoutCountry);
                $('#hddTranId').val(response.TranId);
                $('#hddControlno').val(response.ControlNo);
                $('#txtControlNo').text(response.ControlNo)

                $('#partnerResponse').hide();
                if (includePartnerSearch === 'y') {
                    $("#btnCancelTxn").attr("disabled", true);
                    $('#partnerResponse').show();
                    var table = $('#tblPartnerResponse');
                    table.find("tbody tr").remove();

                    var result = response.InvoiceTxnStatus;//jQuery.parseJSON(response.InvoiceTxnStatus); //response;
                    var count = 1;
                    $.each(result, function (i, d) {
                        var row = '<tr>';
                        row += '<td>' + count + '</td>';
                        row += '<td>' + d['FlagName'] + '</td>';
                        row += '<td>' + d['FlagId'] + '</td>';
                        row += '<td>' + d['ChangeStatusDate'] + '</td>';
                        row += '</tr>';

                        table.append(row);
                        count++;
                    });

                    if (response.LatestStatus.toLowerCase() === 'cancel') {
                        $('#cancelReason').val(response.CancelReason);
                        $("#btnCancelTxn").attr("disabled", false);
                        $('#cancelDate').val(response.LatestDate);
                    }
                    else {
                        alert('You can not cancel this transaction, because this transaction is in status: ' + response.LatestStatus + ', at partner side');
                    }
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <input type="hidden" id="hddTranId" />
        <input type="hidden" id="hddControlno" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Transaction </a></li>
                            <li class="active"><a href="Manage.aspx">Cancel Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Cancel Transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body" id="step1">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-3 col-md-3 control-label" for="">
                                    <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Control No.: <font color="red">*</font>
                                </label>
                                <div class="col-lg-9 col-md-9">
                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-3 control-label" for="">
                                </label>
                                <div class="col-lg-9 col-md-9">
                                    <input type="button" id="btnSearchTxn" value="Search Transaction" style="display:none;" class="btn btn-primary m-t-25" />
                                    <input type="button" id="btnSearchTxnWithStatus" value="Search Transaction Partner" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                        <div class="panel-body" id="step2" style="display: none;">
                            <div class="row">
                                <div class="col-md-12 form-group">
                                    <div class="panel panel-default">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Transaction Information</h4>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> No:</label>
                                                </div>
                                                <div class="col-md-10 form-group">
                                                    <label id="txtControlNo"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Sender Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtSName"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Receiver Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtReceiverName"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Referral Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtReferralName"></label>
                                                </div>
                                                <div class="col-md-2 form-group payout-branch">
                                                    <label>Collect Amount:</label>
                                                </div>
                                                <div class="col-md-4 form-group payout-branch">
                                                    <label id="txtCollectAmount"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Payout Amount:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtPayoutAmount"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Payout Country:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtpayoutCountry"></label>
                                                </div>
                                                <div class="col-md-12 form-group" id="partnerResponse">
                                                    <table class="table table-responsive table-bordered table-hover" id="tblPartnerResponse">
                                                        <thead>
                                                            <tr>
                                                                <th>S.No.</th>
                                                                <th>Status Name</th>
                                                                <th>Status Code</th>
                                                                <th>Status Update Date</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>

                                                        </tbody>
                                                    </table>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Cancel Reason:</label>
                                                </div>
                                                <div class="col-md-10 form-group">
                                                    <input type="text" class="form-control" id="cancelReason" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-2 col-xs-2 form-group">
                                    <label>Cancel Date: <font color="red">*</font></label>
                                </div>
                                <div class="col-md-6 col-xs-6 form-group">
                                    <asp:TextBox ID="cancelDate" runat="server" CssClass="form-control" title="Blank for All" />
                                </div>
                                <div class="col-md-4 col-xs-6 form-group">
                                    <input type="button" id="btnCancelTxn" class="btn btn-primary m-t-25" value="Cancel Txn" />&nbsp;&nbsp;
                                    <input type="button" id="btnClear" class="btn btn-danger m-t-25" value="Clear" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
