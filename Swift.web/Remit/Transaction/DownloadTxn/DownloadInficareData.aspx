<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DownloadInficareData.aspx.cs" Inherits="Swift.web.Remit.Transaction.DownloadTxn.DownloadInficareData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
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
                url: "/Remit/Transaction/DownloadTxn/DownloadInficareData.aspx",
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
        $(document).ready(function () {
            ShowCalFromTo("#fromDate", "#toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');

            // the selector will match all input controls of type :checkbox
            // and attach a click event handler 
            $("input:checkbox").on('click', function () {
                // in the handler, 'this' refers to the box clicked on
                var $box = $(this);
                if ($box.is(":checked")) {
                    // the name of the box is retrieved using the .attr() method
                    // as it is assumed and expected to be immutable
                    var group = "input:checkbox[name='" + $box.attr("name") + "']";
                    // the checked state of the group/box on the other hand will change
                    // and the current value is retrieved using .prop() method
                    $(group).prop("checked", false);
                    $box.prop("checked", true);
                } else {
                    $box.prop("checked", false);
                }
            });
        });
    </script>
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
                            <li><a href="#">OtherServices </a></li>
                            <li><a href="#">Download Inficare Data</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <%--    <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="List.aspx">Customer List</a></li>
                        <li role="presentation" class="active"><a href="#">Customer KYC Operation</a></li>
                    </ul>
                </div>--%>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Download Inficare Data</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label>From Date:</label>
                                                    <asp:TextBox ID="fromDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>To Date:</label>
                                                    <asp:TextBox ID="toDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-12 form-group">
                                                    <asp:Button ID="downloadbtn" runat="server" CssClass="btn btn-primary m-t-25" Text="Import" OnClick="downloadbtn_Click" />
                                                    <label style="color: red">Note: Data for today's date can only be downloaded</label>&nbsp;&nbsp;
                                                    <label id="numberOfTxns" runat="server"></label>
                                                </div>
                                                <div class="col-md-12 form-group">
                                                    <input type="checkbox" value="1" name="checkBoxSync" id="checkBoxForTxnApprove"/>
                                                    <label for="checkBoxForTxnApprove">Txn Approve Job</label>
                                                    <input type="checkbox" value="2" name="checkBoxSync" id="checkBoxForVaultTransfer"/>
                                                    <label for="checkBoxForVaultTransfer">Vault Transfer</label>
                                                    <asp:Button ID="btnExecuteSelected" runat="server" CssClass="btn btn-primary m-t-25" Text="Execute" OnClick="btnExecuteSelected_Click" />
                                                    <label style="color: red">Note: Txn Approve Job can take more time.</label>
                                                    &nbsp;&nbsp;<label id="txnNeedToBeApproved" runat="server"></label>
                                                    <%--<asp:Button ID="btnSyncCancel" runat="server" CssClass="btn btn-primary m-t-25" Text="Sync Cancel" OnClick="btnSyncCancel_Click" />--%>
                                                    <%--<asp:Button ID="btnSyncPaid" runat="server" CssClass="btn btn-primary m-t-25" Text="Sync Paid" OnClick="btnSyncPaid_Click" />--%>
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
                                                    <label>Upload Referral File:</label>
                                                    <asp:FileUpload ID="fileReferral" runat="server" />
                                                    <asp:Button ID="btnMapReferral" runat="server" Text="Upload Referral" CssClass="btn btn-primary" OnClick="btnMapReferral_Click" />
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
                                                <div class="col-md-12 form-group">
                                                    <asp:Button ID="btnFinalSave" Text="Final Save" runat="server" OnClick="btnFinalSave_Click" CssClass="btn btn-primary" />&nbsp;&nbsp;
                                                    <asp:Button ID="btnClear" Text="Clear Temp Data" runat="server" OnClick="btnClear_Click" CssClass="btn btn-primary" />
                                                    <asp:Button ID="btnClearTemp" Text="Clear Remit Tran Temp Data" runat="server" OnClick="btnClearTemp_Click" CssClass="btn btn-primary" />
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
    </form>
</body>
</html>
