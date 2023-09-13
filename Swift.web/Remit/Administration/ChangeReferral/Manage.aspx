<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.ChangeReferral.Manage" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>

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
            ShowCalFromTo("#fromDate", "#toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');

            $('#btnSearchTxn').click(function () {
                $("#btnSearchTxn").attr("disabled", true);
                var reqField = "controlNo,";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnSearchTxn").attr("disabled", false);
                    return false;
                }
                SearchTransactionDetails();
            });
            $('#btnClear').click(function () {
                $('#controlNo').val('');
                $('#introducerTxt_aText').val('');
                $('#introducerTxt_aValue').val('');
                $('#controlNo').focus();
                $('#step1').show();
                $('#step2').hide();
            });
            $('#btnSaveReferral').click(function () {
                $("#btnSaveReferral").attr("disabled", true);
                var reqField = "introducerTxt_aText,";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnSaveReferral").attr("disabled", false);
                    return false;
                }
                if (confirm('Are you sure? you would like to change referral')) {
                    $("#btnSaveReferral").attr("disabled", false);
                    SaveReferral();
                }
                else {
                    $("#btnSaveReferral").attr("disabled", false);
                    return false;
                }
            });
        });

        function SaveReferral() {
            var dataToSend = {
                MethodName: 'SaveReferral',
                NewReferral: $('#introducerTxt_aValue').val(),
                ControlNo: $('#hddControlno').val()
            };

            $.post('/Remit/Administration/ChangeReferral/Manage.aspx', dataToSend, function (response) {
                $("#btnSaveReferral").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#controlNo').val('');
                    $('#controlNo').focus();
                    $('#hddControlno').val('');
                    $('#hddTranId').val('');
                    $('#introducerTxt_aValue').val('');
                    $('#introducerTxt_aText').val('');

                    $('#step1').show();
                    $('#step2').hide();
                    alert(response.Msg);
                }
                else {
                    alert(response.Msg);
                }
            });
        }

        function SearchTransactionDetails() {
            var dataToSend = {
                MethodName: 'SearchTransaction',
                ControlNo: $('#controlNo').val()
            };

            $.post('/Remit/Administration/ChangeReferral/Manage.aspx', dataToSend, function (response) {
                $("#btnSearchTxn").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#step1').hide();
                    $('#step2').show();
                    ShowTxnDetails(response);
                }
                else {
                    alert(response.Msg);
                }
            });

            function ShowTxnDetails(response) {
                $('#txtSName').text(response.SenderName);
                $('#txtReceiverName').text(response.SenderName);
                $('#txtReferralName').text(response.ReferralName + ' (' + response.ReferralCode + ')');
                $('#txtCollectAmount').text(response.CollectAmount + ' (JPY)');
                $('#txtPayoutAmount').text(response.PayoutAmount + ' (' + response.PayoutCurr + ')');
                $('#txtpayoutCountry').text(response.PCOUNTRY);
                $('#hddTranId').val(response.TranId);
                $('#hddControlno').val(response.ControlNo);
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
                            <li class="active"><a href="Manage.aspx">Change Referral</a></li>
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
                            <h4 class="panel-title">Change Referral
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
                                    <input type="button" id="btnSearchTxn" value="Search Transaction" class="btn btn-primary m-t-25" />
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
                                                    <label>Sender Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtSName">Arjun Dhami</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Receiver Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtReceiverName">Raman KC</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Referral Name:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtReferralName">Mizanoor Mizanoor(JME00001)</label>
                                                </div>
                                                <div class="col-md-2 form-group payout-branch">
                                                    <label>Collect Amount:</label>
                                                </div>
                                                <div class="col-md-4 form-group payout-branch">
                                                    <label id="txtCollectAmount">20,000</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Payout Amount:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtPayoutAmount">21,000</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>Payout Country:</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <label id="txtpayoutCountry">Nepal</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-2 col-xs-2 form-group">
                                    <label>New Referral: <font color="red">*</font></label>
                                </div>
                                <div class="col-md-6 col-xs-6 form-group">
                                    <uc1:SwiftTextBox ID="introducerTxt" runat="server" Category="remit-referralChange" cssclass="form-control" title="Blank for All" />
                                </div>
                                <div class="col-md-4 col-xs-6 form-group">
                                    <input type="button" id="btnSaveReferral" class="btn btn-primary m-t-25" value="Save Referral" />&nbsp;&nbsp;
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
