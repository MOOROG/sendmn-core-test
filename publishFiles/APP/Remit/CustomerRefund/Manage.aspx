<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Customer_Refund.List" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.collMode-chk').click(function () {
                if ($(this).val() == 'Bank Deposit') {
                    var customerId = $('#txtSearchData_aValue').val();
                    if (customerId == "" || customerId == null || customerId == undefined) {
                        alert('Please Choose Existing Sender for Coll Mode: Bank Deposit');
                        return false;
                    }
                    $('.deposited-bank').show();
                }
                else {
                    $('.deposited-bank').hide();
                }
                $('.collMode-chk').not(this).prop('checked', false);
            });
        });
        $(document).ready(function () {
            $('#refundDiv').hide();
            $("#ddlCustomerType").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
                <% = txtSearchData.InitFunction() %>;
            });
            $("#Proceed").click(function () {
                var customerId = $('#HiddenCustomerId').val();
                if (customerId == null || customerId == '' || customerId == undefined) {
                    alert('Please select customer first!');
                    return false;
                }
                var availableBal = parseFloat($('#availableBalance').text());
                if (availableBal <= 0) {
                    alert('Customer do not have balance for refund!');
                    return false;
                }
                $('#refundDiv').show();
                $('#Proceed').css('display', 'none');
            });
        });

        function GetCustomerSearchType() {
            return $('#ddlCustomerType').val();
        };

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            SetItem("<% =txtSearchData.ClientID%>", d);
            SetValueById("<%=HiddenCustomerId.ClientID %>", GetItem("<%=txtSearchData.ClientID %>")[0], "");
        };

        function ValidateTxn() {
            var reqField = "refundAmount,additionalCharge,";
            if ($('#11063').is(":checked")) {
                reqField = "refundAmount,additionalCharge,depositedBankDDL,";
            }
            hddSelectedBank = $("#depositedBankDDL").val();
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var availableBal = parseFloat($('#availableBalance').text().replace(',', '').replace(',', '').replace(',', ''));
            var totalRefund = parseFloat($('#refundAmount').val()) + parseFloat($('#additionalCharge').val());

            if (availableBal < totalRefund) {
                alert('Customer do not have sufficient balance for refund!');
                return false;
            }
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">

            <div class="row">
                <div class="col-md-offset-1 col-md-10">
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-10">
                                    <div class="page-title">
                                        <h1></h1>
                                        <ol class="breadcrumb">
                                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                            <li><a href="#">Remit </a></li>
                                            <li><a href="#">Customer Refund</a></li>
                                        </ol>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-10">
                                    <div class="report-tab" runat="server" id="regUp">
                                        <!-- Nav tabs -->
                                        <div class="listtabs">
                                            <ul class="nav nav-tabs" role="tablist">
                                                <li role="presentation"><a href="List.aspx">Customer Refund List</a></li>
                                                <li class="active" role="presentation"><a href="#">Manage Customer Refund</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-10">
                                    <div class="panel panel-default ">
                                        <!-- Start .panel -->
                                        <asp:HiddenField ID="HiddenCustomerId" runat="server" />
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Refund</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2">
                                                    <label class="control-label">
                                                        &nbsp;</label>
                                                    <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="accountNo" Text="Account No."></asp:ListItem>
                                                        <asp:ListItem Value="email" Text="Email ID" Selected="True"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="control-label">
                                                        &nbsp;</label>
                                                    <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="control-label">
                                                        &nbsp;</label><br />
                                                    <asp:Button ID="searchButton" Text="Search" class="btn btn-primary" runat="server" OnClick="searchButton_Click" />
                                                    <%-- <input name="button4" type="button" id="btnClear" value="Clear List" class="btn btn-primary" onclick="ClearAllCustomerInfo();" />--%>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row" id="customerDetailDiv" runat="server">
                                <div class="col-md-10">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Details</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label id="Label1" runat="server" class="control-label">Name </label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label id="lblName" runat="server" class="control-label"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label id="Label2" runat="server" class="control-label">Address</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label id="lblAddress" runat="server" class="control-label"></label>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label id="Label3" runat="server" class="control-label">Native Country</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label id="lblNativeCountry" runat="server" class="control-label"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label id="lblIdType" runat="server" class="control-label"></label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label id="lblIdNo" runat="server" class="control-label"></label>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label class="control-label" id="Label5" runat="server">Mobile</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label class="control-label" id="lblMobile" runat="server"></label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label class="control-label" id="Label6" runat="server">Available Balance</label>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <span class="control-label">:</span>&nbsp;&nbsp;<label class="control-label" id="availableBalance" runat="server" style="background-color: yellow; font-size: 14px; font-weight: 800; padding: 2px;"></label>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 form-group">
                                                    <input type="button" class="btn btn-primary" value="Proceed" id="Proceed" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row" id="refundDiv">
                                <div class="col-md-10">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Refund Details</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-6 form-group" style="display:none">
                                                    <label class="control-label">Collection Mode: <span class="ErrMsg">*</span></label>
                                                    <label id="collModeTd" runat="server" class="control-label"></span></label>
                                                    <%--     <asp:TextBox runat="server" ID="TextBox1" CssClass="required form-control"></asp:TextBox>--%>
                                                    <%--  <asp:TextBox ID="mobile" ValidationGroup="customer" runat="server" CssClass="required form-control"></asp:TextBox>--%>
                                                </div>
                                                <div class="col-md-6 form-group deposited-bank" >
                                                    <label class="control-label">Payment Method: <span class="notifyRequired">*</span></label>
                                                    <asp:DropDownList ID="depositedBankDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    <asp:HiddenField ID="hddSelectedBank" runat="server" />
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 form-group">
                                                    <label class="control-label">Refund Amount: <span class="notifyRequired">*</span></label>
                                                    <asp:TextBox runat="server" ID="refundAmount" CssClass="required form-control"></asp:TextBox>
                                                    <%--  <asp:TextBox ID="mobile" ValidationGroup="customer" runat="server" CssClass="required form-control"></asp:TextBox>--%>
                                                </div>
                                                <div class="col-md-6 form-group">
                                                    <label class="control-label">Additional charge: <span class="notifyRequired">*</span></label>
                                                    <asp:TextBox runat="server" ID="additionalCharge" CssClass="required form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12 form-group">
                                                    <label class="control-label">Remarks:</label>
                                                    <asp:TextBox runat="server" ID="refunRemarks" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12 form-group">
                                                    <label class="control-label">Additional Charge Remarks:</label>
                                                    <asp:TextBox runat="server" ID="additionalChargeRemarks" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12 form-group">
                                                    <asp:Button ID="Button2" Text="Refund" OnClientClick="return ValidateTxn();" class="btn btn-primary" runat="server" OnClick="Refund_Click" />
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