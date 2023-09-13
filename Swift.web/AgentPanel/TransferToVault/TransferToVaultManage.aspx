<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TransferToVaultManage.aspx.cs" Inherits="Swift.web.AgentPanel.TransferToVault.TransferToVault" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#transferDate");
            $('#transferDate').mask('0000-00-00');
        });

        function Transfer_Clicked() {
            var reqField = "amount,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var limitAmt = Number($('#cashAtCounter').text().replace(',', '').replace(',', '').replace(',', ''));
            var transferAmt = Number($('#amount').val());
            if (limitAmt < transferAmt) {
                $('#amount').val('0');
                $('#amount').focus();
                alert("Transfer amount can't be greater than cash at counter");
                return false;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="TransferToVaultManage.aspx">Transfer To Vault</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="">
                            <div class="register-form">
                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading">Transfer Details</div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-1">
                                                    <label>Cash at counter:</label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:Label ID="cashAtCounter" runat="server"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-1">
                                                    <label>Amount:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:TextBox ID="amount" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="form-group">
                                                <div class="col-md-1">
                                                    <label>Date:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="col-md-3">
                                                    <asp:TextBox ReadOnly="true" autocomplete="off" ID="transferDate" runat="server" onchange="return DateValidation('transferDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>

                                        <asp:Button ID="Transfer" Text="Transfer" runat="server" OnClientClick="return Transfer_Clicked()" OnClick="Transfer_Click" CssClass="btn btn-primary m-t-25" />
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