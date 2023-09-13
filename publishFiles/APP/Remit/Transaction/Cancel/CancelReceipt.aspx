<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.Cancel.CancelReceipt" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style type="text/css">
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            border-top: none !important;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="CancelReceipt.aspx">Cancell Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Cancel Receipt
                            </h4>
                            <%-- <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>--%>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group" style="margin-left: 8px;">
                                <b><%=GetStatic.GetTranNoName() %>:
                                <asp:Label ID="controlNo" runat="server"></asp:Label></b>
                            </div>
                            <div class="form-group table table-responsive">

                                <table class="table" style="width: 500px;">
                                    <tr>
                                        <td>Posted By:</td>
                                        <td>
                                            <asp:Label ID="postedBy" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Sender:</td>
                                        <td>
                                            <asp:Label ID="sender" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Receiver:</td>
                                        <td>
                                            <asp:Label ID="receiver" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Contact No:</td>
                                        <td>
                                            <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Collected Amount:</td>
                                        <td>
                                            <asp:Label ID="cAmt" runat="server"></asp:Label>
                                            [<asp:Label ID="collCurr" runat="server"></asp:Label>]
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Service Charge:</td>
                                        <td>
                                            <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Payout Amount:</td>
                                        <td>
                                            <asp:Label ID="pAmt" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancellation Charge:</td>
                                        <td>
                                            <asp:Label ID="cancelCharge" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="DisFond">Return Amount:</td>
                                        <td class="DisFond">
                                            <asp:Label ID="returnAmt" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Send Date:</td>
                                        <td>
                                            <asp:Label ID="sendDate" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancelled Date:</td>
                                        <td>
                                            <asp:Label ID="cancelDate" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr id="autoDebitTR" runat="server" visible="false">
                                        <td colspan="2">
                                            <fieldset>
                                                <legend>Auto Debit Detail</legend>
                                                <table class="table" style="width: 500px;">
                                                    <tr>
                                                        <td>Account Name:</td>
                                                        <td>
                                                            <asp:Label ID="accName" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Account Number:</td>
                                                        <td>
                                                            <asp:Label ID="accNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Bank Name:</td>
                                                        <td>
                                                            <asp:Label ID="bankName" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
