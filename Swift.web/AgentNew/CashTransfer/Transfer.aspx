<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Transfer.aspx.cs" Inherits="Swift.web.AgentNew.CashTransfer.Transfer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        //$(document).ready(function () {
        //    ShowCalFromToUpToToday("#transferDate");
        //});

        function Transfer_Clicked() {
            if (confirm('Are you sure, you would like to save data?')) {
                var reqField = "ContentPlaceHolder1_fromAccount,ContentPlaceHolder1_amount,ContentPlaceHolder1_paymentModeDDL,ContentPlaceHolder1_toAccDDL";
                if (ValidRequiredField(reqField) == false) {
                    return false;
                }
                var limitAmt = Number($('#ContentPlaceHolder1_availableBalance').text().replace(',', '').replace(',', '').replace(',', ''));
                var transferAmt = Number($('#ContentPlaceHolder1_amount').val());
                if (limitAmt < transferAmt) {
                    $('#ContentPlaceHolder1_amount').val('0');
                    $('#ContentPlaceHolder1_amount').focus();
                    alert("Transfer amount can't be greater than cash in Vault");
                    return false;
                }
            }
            else {
                return false;
            }
        };
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li class="active"><a href="Transfer.aspx">Transfer From Vault</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab" runat="server" id="regUp">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="List">
                </div>
                <div role="tabpanel" id="Manage">
                    <asp:UpdatePanel ID="up1" runat="server">
                        <ContentTemplate>
                            <div class="register-form">
                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading">Transfer From Vault</div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>Available Balance:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:Label ID="availableBalance" runat="server"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>From Account (Vault):<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:DropDownList ID="fromAccountDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>Choose Payment Mode:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:DropDownList ID="paymentModeDDL" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="paymentModeDDL_SelectedIndexChanged">
                                                        <asp:ListItem Text="Select" Value=""></asp:ListItem>
                                                        <asp:ListItem Text="Bank" Value="b"></asp:ListItem>
                                                        <asp:ListItem Text="Cash Teller" Value="ct"></asp:ListItem>
                                                        <asp:ListItem Text="Cash Vault" Value="cv"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>To Account:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:DropDownList ID="toAccDDL" runat="server" CssClass="form-control">
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
                                                    <asp:TextBox ReadOnly="true" autocomplete="off" ID="transferDate" runat="server" onchange="return DateValidation('transferDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-offset-2 col-md-3">
                                                    <asp:Button ID="transferButton" Text="Transfer" runat="server" OnClientClick="return Transfer_Clicked()" OnClick="transferButton_Click" CssClass="btn btn-primary m-t-25" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>
</asp:Content>