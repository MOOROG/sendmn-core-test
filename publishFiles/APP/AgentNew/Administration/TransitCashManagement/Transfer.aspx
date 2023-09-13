<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Transfer.aspx.cs" Inherits="Swift.web.AgentNew.Administration.TransitCashManagement.Transfer" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Customer Operation</title>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Cash Management</a></li>
                        <li class="active"><a href="Manage.aspx">Transit Cash Management</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab" runat="server" id="regUp">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="List">
                </div>
                <div class="register-form">
                    <div class="panel panel-default clearfix m-b-20">
                        <div class="panel-heading">Transit Cash Management</div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label>Referal Code:</label>
                                    </div>
                                    <div class="col-md-5">
                                        <uc1:swifttextbox id="introducerTxt" runat="server" category="remit-referralCode" cssclass="form-control" title="Blank for All" />
                                        <%--<asp:TextBox ID="introducerTxt" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label>Choose Payment Mode</label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:DropDownList ID="paymentModeDDL" runat="server" CssClass="form-control">
                                            <asp:ListItem Text="Cash" Value="cv"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label>Bank/Branch Name</label>
                                    </div>
                                    <div class="col-md-5">
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
                                    <div class="col-md-5">
                                        <asp:TextBox ID="amount" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label>Date:<span class="errormsg">*</span></label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:TextBox autocomplete="off" ID="transferDate" runat="server" onchange="return DateValidation('transferDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label>Narration:</label>
                                    </div>
                                    <div class="col-md-5">
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
            ShowCalDefault("#ContentPlaceHolder1_transferDate");
        };

        $(document).ready(function () {
            $('#btnTramsferClick').click(function () {
                $("#btnTramsferClick").attr("disabled", true);
                var reqField = "ContentPlaceHolder1_introducerTxt_aText,ContentPlaceHolder1_amount,ContentPlaceHolder1_paymentModeDDL,ContentPlaceHolder1_bankOrBranchDDL";
                if (ValidRequiredField(reqField) == false) {
                    $("#btnTramsferClick").attr("disabled", false);
                    return false;
                }
                SaveTransferToVault();
            });
        });

        function SaveTransferToVault() {
            var amount = $('#ContentPlaceHolder1_amount').val();
            amount = amount.replace(/,/g, "");

            if (!$.isNumeric(amount)) {
                alert('Invalid amount field!');
                $('#ContentPlaceHolder1_amount').val('');
                $('#ContentPlaceHolder1_amount').focus();
                $("#btnTramsferClick").attr("disabled", false);
                return false;
            }
            var dataToSend = {
                MethodName: 'TransitSettle',
                IntroducerCode: $('#ContentPlaceHolder1_introducerTxt_aValue').val(),
                PaymentMode: $('#ContentPlaceHolder1_paymentModeDDL').val(),
                BankOrBranch: $('#ContentPlaceHolder1_bankOrBranchDDL').val(),
                Amount: amount,
                TranDate: $('#ContentPlaceHolder1_transferDate').val(),
                Narration: $('#ContentPlaceHolder1_narrationTxt').val()
            };
            $.post('/AgentNew/Administration/TransitCashManagement/Transfer.aspx', dataToSend, function (response) {
                $("#btnTramsferClick").attr("disabled", false);
                if (response.ErrorCode == '0') {
                    $('#ContentPlaceHolder1_introducerTxt_aValue').val('');
                    $('#ContentPlaceHolder1_introducerTxt_aText').val('');
                    $('#ContentPlaceHolder1_amount').val('');
                    $('#ContentPlaceHolder1_narrationTxt').val('');
                    $('#ContentPlaceHolder1_introducerTxt_aText').focus();
                    $('#ContentPlaceHolder1_msgSuccessError').html(response.Msg);
                }
                else {
                    alert(response.Msg);
                }
            });
        };
    </script>
</asp:Content>
