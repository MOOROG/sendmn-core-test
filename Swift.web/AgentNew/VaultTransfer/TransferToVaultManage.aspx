<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="TransferToVaultManage.aspx.cs" Inherits="Swift.web.AgentNew.VaultTransfer.TransferToVaultManage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#transferDate");
            $('#<%=transferDate.ClientID%>').mask('0000-00-00');
        });

        function Transfer_Clicked() {
            if (confirm('Are you sure, you would like to save data?')) {
                var reqField = "ContentPlaceHolder1_amount,ContentPlaceHolder1_userAccountDDL,ContentPlaceHolder1_transferToDDL";
                if (ValidRequiredField(reqField) == false) {
                    return false;
                }
                var limitAmt = Number($('#ContentPlaceHolder1_cashAtCounter').text().replace(',', '').replace(',', '').replace(',', ''));
                var transferAmt = Number($('#ContentPlaceHolder1_amount').val());
                if (limitAmt < transferAmt) {
                    $('#ContentPlaceHolder1_amount').val('0');
                    $('#ContentPlaceHolder1_amount').focus();
                    alert("Transfer amount can't be greater than cash at counter");
                    return false;
                }
            }
            else {
                return false;
            }
        }
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
                        <li><a href="#">Cash Management</a></li>
                        <li><a href="#">Transfer To Vault</a></li>
                        <li class="active"><a href="TransferToVaultManage.aspx">Transfer Details</a></li>
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
                                    <div class="panel-heading">Transfer Details</div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>Cash at counter:</label>
                                                </div>
                                                <div class="col-md-3">
                                                    <b>
                                                        <asp:Label ID="cashAtCounter" runat="server"></asp:Label></b>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>From Acc:</label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:DropDownList ID="userAccountDDL" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-2">
                                                    <label>To Account (Vault):</label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:DropDownList ID="transferToDDL" runat="server" CssClass="form-control">
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
                                                    <asp:Button ID="Transfer" Text="Transfer" runat="server" OnClientClick="return Transfer_Clicked()" OnClick="Transfer_Click" CssClass="btn btn-primary m-t-25" />
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