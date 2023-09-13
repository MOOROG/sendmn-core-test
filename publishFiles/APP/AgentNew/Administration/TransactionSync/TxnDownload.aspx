<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="TxnDownload.aspx.cs" Inherits="Swift.web.AgentNew.Administration.TransactionSync.TxnDownload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Other Services </a></li>
                        <li><a href="#">Download Inficare Transaction</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab" runat="server" id="regUp">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="List">
                </div>
                <div role="tabpanel" id="Manage">
                    <div class="row">
                        <div class="col-sm-12 col-md-12">
                            <div class="register-form">
                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading">Download Inficare Transaction</div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-md-12 form-group">
                                                <asp:Button ID="downloadbtn" runat="server" CssClass="btn btn-primary m-t-25" Text="Download" OnClick="downloadbtn_Click" />
                                                <label style="color: red">Note: If you don't see transaction in the list, then only click on Download.</label>&nbsp;&nbsp;
                                                <label id="numberOfTxns" runat="server"></label>
                                            </div>
                                            <div class="col-md-4 form-group">
                                                <label>Show:</label>
                                                <asp:DropDownList ID="ddlMapped" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlMapped_SelectedIndexChanged">
                                                    <asp:ListItem Text="All" Value=""></asp:ListItem>
                                                    <asp:ListItem Text="Mapped" Value="M"></asp:ListItem>
                                                    <asp:ListItem Text="Un-Mapped" Value="U"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-12 form-group">
                                                <table class="table table-responsive table-bordered table-condensed">
                                                    <thead>
                                                        <tr>
                                                            <th>Tran ID</th>
                                                            <th>Control No</th>
                                                            <th>Teller</th>
                                                            <th>Sender Name</th>
                                                            <th>Receiver Name</th>
                                                            <th>Coll Mode</th>
                                                            <th>Receiver Country</th>
                                                            <th>Collect Amount</th>
                                                            <th>Sent Amount</th>
                                                            <th>Payout Amount</th>
                                                            <th>Referral</th>
                                                            <th>Actions</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="tranTable" runat="server">
                                                        <tr>
                                                            <td colspan="12" align="center">No data to display!</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
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
    </div>
    <script type="text/javascript">
        function ConfirmSave() {
            if (confirm('Do you want to continue with save?')) {
                return true;
            }
            return false;
        }
        function SavedClicked(tranId) {
            if (confirm('Do you want to continue with save?')) {
                if (tranId == '' || tranId == undefined || tranId == null) {
                    return false;
                }
                var reqField = tranId + '_aText,';
                if (ValidRequiredField(reqField) == false) {
                    return false;
                }
                var referralCode = $('#' + tranId + '_aValue').val();
                PostDate(tranId, referralCode);
            }
            else {
                return false;
            }
        }
        function PostDate(tranId, referralCode) {
            var dataToSend = {
                MethodName: "MapData"
                , TranId: tranId
                , ReferralCode: referralCode
            };
            $.ajax({
                type: "POST",
                url: "/AgentNew/Administration/TransactionSync/TxnDownload.aspx",
                data: dataToSend,
                success: function (response) {
                    if (response.ErrorCode == '0') {
                        alert(response.Msg);
                    }
                    else {
                        alert(response.Msg);
                    }
                },
                fail: function (response) {
                    alert(response.Msg);
                }
            });
        }
    </script>
</asp:Content>
