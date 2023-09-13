<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.BillVoucher.TreasuryDealBooking.DealingBank.List" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>

    <title></title>
    <script>
        function CheckFormValidation() {
            var reqField = "bankName,krwAcc_aText,usdAcc_aText,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
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
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Fund Dealing</a></li>
                            <li class="active"><a href="List.aspx">Bank List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Add New Bank
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">Bank Name:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <asp:TextBox ID="bankName" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">Sell JPY Ac:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="krwAcc" runat="server" Category="acInfo" autocomplete="off" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">Buy USD Ac:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="usdAcc" runat="server" Category="acInfo" autocomplete="off" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-12">
                                    <b>Has to settle on Payout Partner Currency: </b>
                                    <asp:CheckBox ID="chkPayCurrency" runat="server" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-offset-3 col-md-4">
                                    <asp:Button Text="Save" ID="btnSave" runat="server" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation()" OnClick="btnSave_Click" />
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