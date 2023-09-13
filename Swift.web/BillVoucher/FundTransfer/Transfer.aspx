<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Transfer.aspx.cs" Inherits="Swift.web.BillVoucher.FundTransfer.Transfer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript">
        function Calculate(ids) {
            var total = parseFloat(0.00);
            var arr = ids.split(',');
            for (var i = 0; i < arr.length; i++) {
                var amount = $('#txt_' + arr[i]).val();

                var remainingamount = document.getElementById('amt_' + arr[i]).innerText;
                remainingamount = RemoveComma(remainingamount);
                if (parseFloat(amount) > parseFloat(remainingamount)) {
                    alert("Transfer Amount should not be greater than Remaining To Transfer Amount");
                    $('#txt_' + arr[i]).val('');
                    $('#txt_' + arr[i]).focus();
                    $('#lblTransferAmt').html(total);
                    return;
                }
                if (amount != "") {
                    total += parseFloat(amount);
                }
            }
            $('#lblTransferAmt').html(total);
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Treasury Deal Booking</a></li>
                            <li class="active"><a href="Transfer.aspx">Treasury Deal Booking</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Treasury Deal Booking
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row" id="divMsg" runat="server" visible="false">
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6 form-group">
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-md-3">
                                                        Transfer From:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-6">
                                                        <asp:DropDownList ID="ddlTransferFrom" CssClass="form-control" runat="server"></asp:DropDownList>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                                                            CssClass="btn btn-primary m-t-25" OnClick="btnSearch_Click" />
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-md-3">
                                                        Transfer Fund To:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-6">
                                                        <asp:DropDownList ID="ddlTransferFundTo" CssClass="form-control" runat="server"></asp:DropDownList>
                                                        <asp:RequiredFieldValidator
                                                            ID="RequiredFieldValidator2" runat="server" ControlToValidate="ddlTransferFundTo" ForeColor="Red"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="transfer" SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <input type="button" class="btn btn-primary m-t-25" onclick="OpenPopupWindow()" value="Settings" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div runat="server" id="remainToTransfer"></div>
                                            <br />
                                            <br />
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-6">
                                                        Transfer Amount :
                                                        <asp:Label ID="lblTransferAmt" ForeColor="Red" Font-Bold="true" runat="server" Text=""></asp:Label>
                                                    </div>
                                                    <div class="col-md-6">
                                                        Transfer Date :
                                                        <asp:TextBox ID="date" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                        <%--<asp:RequiredFieldValidator
                                                        ID="RequiredFieldValidator4" runat="server" ControlToValidate="date" ForeColor="Red"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="transfer" SetFocusOnError="True">
                                                    </asp:RequiredFieldValidator>--%>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-offset-3 col-md-8">
                                                        <asp:Button ID="btnTransfer" runat="server" Text="Transfer" ValidationGroup="transfer"
                                                            CssClass="btn btn-primary m-t-25" OnClick="btnTransfer_Click" />
                                                        <asp:HiddenField ID="hdnBankId" runat="server" />
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
        </div>
    </form>
    <script type="text/javascript">
        function OpenPopupWindow() {
            var url = '/BillVoucher/FundTransfer/Setting/List.aspx';
            OpenInNewWindow(url);
        }
    </script>
</body>
</html>