                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          <%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Setting.aspx.cs" Inherits="Swift.web.BillVoucher.JMEFundTransfer.Setting" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>


    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            //ShowCalFromToUpToToday("#from", "#to");
            From("#from");
            To("#to");
            $('#from').mask('0000-00-00');
            $('#to').mask('0000-00-00');
            window.onunload = window.opener.location.reload();
        });
        
        function FundTransfer() {
            var reqField = "description,currency,debitAc,creditAc,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Account</li>
                            <li>Bill & Voucher</li>
                            <li>Fund Transfer</li>
                            <li>Setting</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Fund Transfer Setting</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-4">Description: </label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="description" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Currency: </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="currency" runat="server" AutoPostBack="true" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Debit A/c : </label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="debitAc"  runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Credit A/c : </label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="creditAc" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="save" Text="Save" class="btn btn-primary m-t-25" OnClientClick="return FundTransfer('save');" OnClick="save_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
