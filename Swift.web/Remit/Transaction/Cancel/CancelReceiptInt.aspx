<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelReceiptInt.aspx.cs" Inherits="Swift.web.Remit.Transaction.Cancel.CancelReceiptInt" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:HiddenField ID="hdnBranchEmail" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Cancel</a></li>
                            <li class="active"><a href="List.aspx">Cancel Request</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Cancel Receipt :
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                        </div>
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <tr>
                                        <td colspan="2">
                                            <h2><span style="color: Green">Transaction has been cancelled successfully</span></h2>
                                        </td>
                                    </tr>
                                    <tr style="margin-left: 0px; background: red; font-size: 1.8em; padding: 5px; font-weight: bold; color: White;">
                                        <td colspan="2">
                                            <span style="padding: 5px;">
                                                <%=GetStatic.GetTranNoName() %>:
                                             <asp:Label ID="controlNo" runat="server"></asp:Label>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Sending Branch:</td>
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
                                            [<asp:Label ID="scCurr1" runat="server"></asp:Label>]
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Payout Amount:</td>
                                        <td>
                                            <asp:Label ID="pAmt" runat="server"></asp:Label>
                                            <asp:Label ID="pCurr" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancellation Charge:</td>
                                        <td>
                                            <asp:Label ID="cancelCharge" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="DisFond" nowrap="nowrap">Refund Amount:</td>
                                        <td class="DisFond">
                                            <asp:Label ID="returnAmt" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Tran Send Date:</td>
                                        <td>
                                            <asp:Label ID="sendDate" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Tran Cancelled Date:</td>
                                        <td>
                                            <asp:Label ID="cancelDate" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancel Requested By:</td>
                                        <td>
                                            <asp:Label ID="cancelReqBy" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancel Requested Date:</td>
                                        <td>
                                            <asp:Label ID="cancelReqDate" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Cancellation Reason:</td>
                                        <td>
                                            <asp:Label ID="cancelReason" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td>
                                            <asp:Button ID="btnBack" CssClass="btn btn-primary m-t-25" runat="server" Text="Back To Pending List" OnClick="btnBack_Click"></asp:Button>
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