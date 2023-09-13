<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommPay.aspx.cs" Inherits="Swift.web.AccountReport.TransitCashSettlement.CommPay" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Commission Pay</title>
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/css/intlTelInput.css" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <%--<script src="../../../js/jQuery/jquery-3.1.1.min.js"></script>--%>
    <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
    <%--<script src="/ui/bootstrap/js/bootstrap.min.js"></script>--%>
    <script src="../../../js/popper/popper.min.js"></script>
    <script src="../../../js/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/intlTelInput.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="Manage.aspx">Agent  Comm Entry</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="register-form">
                            <div class="panel panel-default clearfix m-b-20">
                                <div class="panel-heading">Agent Comm entry</div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-2">
                                                <label>Referal Code:</label>
                                            </div>
                                            <div class="col-md-3">
                                                <uc1:SwiftTextBox ID="introducerTxt" runat="server" Category="remit-referralCode" CssClass="form-control" Title="Blank for All" />
                                                <%--<asp:TextBox ID="introducerTxt" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                            </div>
                                            <div class="col-md-3">
                                                <label id="availableBal" style="color:red;">(Balance: 0.00)</label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-2">
                                                <label>Account</label>
                                            </div>
                                            <div class="col-md-3">
                                                <asp:DropDownList ID="bankOrBranchDDL" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-2">
                                                <label>Amount:<span class="errormsg">*</span></label>
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="amount" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-2">
                                                <label>Date:<span class="errormsg">*</span></label>
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox autocomplete="off" ID="transferDate" runat="server" onchange="return DateValidation('transferDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-2">
                                                <label>Narration:</label>
                                            </div>
                                            <div class="col-md-3">
                                                <asp:TextBox ID="narrationTxt" TextMode="MultiLine" runat="server" CssClass="form-control" placeholder="If no narration, please leave it blank!"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-offset-2 col-md-3">
                                                <input type="button" id="btnTramsferClick" value="Transfer" class="btn btn-primary m-t-25" />
                                                &nbsp;&nbsp;<asp:Label ID="msgSuccessError" runat="server"></asp:Label>
                                            </div>
                                            <div class="col-md-9">
                                            </div>
                                        </div>
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
            SetDatePicker();
        });

        var prm = Sys.WebForms.PageRequestManager.getInstance();

        if (prm != null) {
            prm.add_endRequest(function (sender, e) {
                if (sender._postBackSettings.panelsToUpdate != null) {
                    SetDatePicker();
                    //$(".datepicker-orient-bottom").hide();
                }
            });
        };

        function SetDatePicker() {
            ShowCalDefault("#transferDate");
        };

        $(document).ready(function () {
            $("body").on("click", "#btnTramsferClick", function () {
                $("#btnTramsferClick").attr("disabled", true);
                var reqField = "introducerTxt_aText,amount,bankOrBranchDDL";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnTramsferClick").attr("disabled", false);
                    return false;
                }
                SaveTransferToVault();
            });
        });

        function CallBackAutocomplete(id) {
            var dataToSend = {
                MethodName: 'GetAvailableBal',
                ReferralCode: GetItem('introducerTxt')[0]
            };
            $.post('/AccountReport/TransitCashSettlement/CommPay.aspx', dataToSend, function (response) {
                if (response.ErrorCode == '0') {
                    $('#availableBal').text('(Balance : ' + response.Msg + ' MNT)');
                }
                else {
                    alert(response.Msg);
                }
            });
        }

        function SaveTransferToVault() {
            var amount = $('#amount').val();
            amount = amount.replace(/,/g, "");

            if (!$.isNumeric(amount)) {
                alert('Invalid amount field!');
                $('#amount').val('');
                $('#amount').focus();
                $("#btnTramsferClick").attr("disabled", false);
                return false;
            }
            var dataToSend = {
                MethodName: 'CommPayAgent',
                IntroducerCode: $('#introducerTxt_aValue').val(),
                BankOrBranch: $('#bankOrBranchDDL').val(),
                Amount: amount,
                TranDate: $('#transferDate').val(),
                Narration: $('#narrationTxt').val()
            };
            $.post('/AccountReport/TransitCashSettlement/CommPay.aspx', dataToSend, function (response) {
                $("#btnTramsferClick").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#introducerTxt_aValue').val('');
                    $('#introducerTxt_aText').val('');
                    $('#paymentModeDDL').val('');
                    $('#amount').val('');
                    $('#narrationTxt').val('');
                    $('#introducerTxt_aText').focus();
                    $('#msgSuccessError').html(response.Msg);
                }
                else {
                    alert(response.Msg);
                }
            });
        };
    </script>
</body>
</html>
