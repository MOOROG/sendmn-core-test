<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.BillVoucher.RefundWalletAmt.List" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <!--page plugins-->
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">

        function CheckFormValidation() {
            var reqField = "CustomerInfo_aText,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
        function CheckFinalSave() {
            var reqField = "CustomerInfo_aText,refundAmt,chargeAmt,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <form id="Form1" name="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Customer Management </a></li>
                            <li class="active"><a href="List.aspx">Refund Wallet Balance</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Refund Wallet Balance
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Customer Name/Wallet No:<span class="errormsg">*</span></label>
                                <div class="col-lg-6 col-md-6">
                                    <uc1:SwiftTextBox ID="CustomerInfo" runat="server" Category="remit-CustomerInfoWallet" CssClass="form-control" Title="Enter Customer Name/Id Number" />
                                </div>
                                <div class="col-md-2">
                                    <asp:Button ID="btnSearch" Text="Search" runat="server" OnClientClick="return CheckFormValidation();" CssClass="btn btn-primary m-t-25" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                            <div id="searchDetail" runat="server" visible="false">
                                <div class="form-group">
                                    <div class="col-md-12">
                                        <div class="table">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>Name</th>
                                                        <th>ID Number</th>
                                                        <th>Available Balance</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="tblHistory" runat="server">
                                                    <tr>
                                                        <td colspan="3" align="center">No data to display!!</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-lg-5 col-md-5 control-label" for="">
                                                Refund Amount:<span class="errormsg">*</span></label>
                                            <div class="col-lg-7 col-md-7">
                                                <asp:TextBox ID="refundAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="*" ForeColor="Red"
                                                    ControlToValidate="refundAmt" ValidationGroup="refundAmount"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-lg-5 col-md-5 control-label" for="">
                                                Charge Amount:<span class="errormsg">*</span></label>
                                            <div class="col-lg-7 col-md-7">
                                                <asp:TextBox ID="chargeAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="*" ForeColor="Red"
                                                    ControlToValidate="chargeAmt" ValidationGroup="refundBalance"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-md-2">
                                        <asp:Button ID="btnRefund" Text="Refund" ValidationGroup="refundBalance" Visible="false" runat="server" OnClientClick="return CheckFinalSave();" CssClass="btn btn-primary m-t-25" OnClick="btnRefund_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddAvailableBalance" runat="server" />
    </form>
</body>
</html>