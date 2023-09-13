<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Confirm.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendRegional.Confirm" %>
<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript" language = "javascript">
        document.onkeypress = function (e) {
            var e = window.event || e;

            if (e.keyCode == 27)
                window.close();
        };

        function CloseWindow() {
            if (confirm("Are you sure to want to close this confirmation page?")) {
                window.close();
            }
        }

        function ManageMessage(mes) {
            window.returnValue = '1|' + mes;
            window.close();
        }

        function CallBack(mes, invoicePrintMode) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] == "0" || resultList[0] == "100" || resultList[0] == "101") { //100-Waiting for Approval,101-Under Compliance
                window.returnValue = resultList[0] + "|" + resultList[2] + "|" + invoicePrintMode;
                window.close();
            }
            return;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" ID="sm"></asp:ScriptManager>
        <div class="page-wrapper" style="margin-top:-50px; margin-left:25px;">
            <div class="row">
                <div class="col-md-9">
                    <div>
        <table class="table table-bordered table-condensed">
            <tr>
                <td colspan="2"><h4>Sending Branch: <asp:label ID="sBranchName" runat="server"></asp:label> </h4></td>
            </tr>
            <tr>
                <td>
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading panel-title">Sender Information</div>
                        <div class="panel-body">
                        <table class="table table-condensed table-bordered">
                            <tr>
                                <td>Sender's Name: </td>
                                <td>
                                    <asp:Label ID = "sName" runat = "server" ForeColor="red"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td>
                                    <asp:Label ID = "sAddress" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No: </td>
                                <td>
                                    <asp:Label ID = "sContactNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Type:</td>
                                <td>
                                    <asp:Label ID = "sIdType" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Number </td>
                                <td>
                                    <asp:Label ID = "sIdNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Email: </td>
                                <td>
                                    <asp:Label ID = "sEmail" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Membership Id: </td>
                                <td>
                                    <asp:Label ID = "sMemId" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        </div>
                    </div>
                </td>
                <td>
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading panel-title">Receiver Information</div>
                        <div class="panel-body">
                        <table class="table table-condensed table-bordered">
                            <tr>
                                <td>Receiver's Name: </td>
                                <td>
                                    <asp:Label ID = "rName" runat = "server" ForeColor="red"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td>
                                    <asp:Label ID = "rAddress" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No: </td>
                                <td>
                                    <asp:Label ID = "rContactNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Type: </td>
                                <td>
                                    <asp:Label ID = "rIdType" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Number: </td>
                                <td>
                                    <asp:Label ID = "rIdNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Relationship with Sender: </td>
                                <td>
                                    <asp:Label ID = "rRel" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Membership Id: </td>
                                <td>
                                    <asp:Label ID = "rMemId" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                            </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading panel-title">Payout Information</div>
                        <div class="panel-body">
                        <table class="table table-bordered table-condensed">
                            <tr>
                                <td>Payout Location: </td>
                                <td>
                                    <asp:Label ID = "pLocation" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>District:</td>
                                <td>
                                    <asp:Label ID = "pDistrict" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Country: </td>
                                <td>
                                    <asp:Label ID = "pCountry" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Mode of Payment: </td>
                                <td>
                                    <asp:Label ID = "payMode" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        </div>
                    </div>
                </td>
                <td  valign="top">
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading panel-title">Amount Infromation</div>
                        <div class="panel-body">
                        <table class="table table-bordered table-condensed"">
                            <tr>
                                <td>Payout Amount: </td>
                                <td>
                                    <asp:Label ID = "tAmt" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Service Charge: </td>
                                <td>
                                    <asp:Label ID = "serviceCharge" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Collection Amount: </td>
                                <td">
                                    <asp:Label ID = "cAmt" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Payout Amount: </td>
                                <td>
                                    <asp:Label ID = "pAmt" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        </div>
                    </div>
                </td>
            </tr>
            <tr id="trBankDetail" runat="server" Visible="false">
                <td colspan="2">
                    <div class="panel panel-default margin-b-30 ">
                        <div class="panel-heading panel-title">Bank Information</div>
                        <div class="panel-body">
                        <table style="width: 100%" class="table table-bordered table-condensed"">
                            <tr>
                                <td class="label">
                                    Bank Name
                                    <br />
                                    <asp:Label ID = "bankName" runat = "server"></asp:Label>
                                </td>
                                <td class="label">
                                    Branch Name
                                    <br />
                                    <asp:Label ID = "branchName" runat = "server"></asp:Label>
                                </td>
                                <td class="label">
                                    Account Number
                                    <br />
                                    <asp:Label ID = "accountNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                            </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading panel-title">Customer Due Diligence Information -(CDDI)</div>
                        <div class="panel-body">
                        <table class="table table-bordered table-condensed">
                            <tr>
                                <td>
                                    Source of fund:
                                </td>
                                <td>
                                    <asp:Label ID = "lblSof" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Purpose of Remittance:
                                </td>
                                <td>
                                    <asp:Label ID = "lblPor" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    Occupation:
                                </td>
                                <td>
                                     <asp:Label ID = "lblOccupation" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Message To Receiver:
                                </td>
                                <td>
                                    <asp:Label ID = "pMsg" runat = "server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>

        <div class="panel panel-default margin-b-30"><div class="panel-heading panel-title">Other Information</div>
            <div class="panel-body">
        <table class="table table-condensed table-bordered">
            <tr>
                <td><span class="text"> Enter Collection Amount to Proceed:</span></td>
                <td>
                    <div class="form-group form-inline">
                    <asp:TextBox id="txtCollAmt" runat="server" CssClass="form-control" Width="40%" />
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator
                        ID="RequiredFieldValidator3" runat="server" ControlToValidate="txtCollAmt" ForeColor="Red"
                        Display="Dynamic"  ErrorMessage="Required!" ValidationGroup="send"  SetFocusOnError="True">
                    </asp:RequiredFieldValidator>
                        </div>
                </td>
            </tr>
            <tr>
                <td valign="top"><span class="text">Txn. Password:</span></td>
                <td>
                     <div class="form-group form-inline">
                    <asp:TextBox ID="txnPassword" runat="server"  CssClass="form-control" TextMode="Password" Width="40%"></asp:TextBox>
                <span class="errormsg">*</span></div>
                <asp:RequiredFieldValidator
                    ID="RequiredFieldValidator1" runat="server" ControlToValidate="txnPassword" ForeColor="Red"
                    Display="Dynamic"  ErrorMessage="Required!" ValidationGroup="send"  SetFocusOnError="True">
                </asp:RequiredFieldValidator>
                <br />
                <i>(Note: Please enter your password for the transaction confirmation)</i></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID = "btnProceed" runat = "server" ValidationGroup="send" Text = "Proceed" onclick="btnProceed_Click" />
                    <%--<cc1:ConfirmButtonExtender ID="btnProceedCc" runat="server"
                        ConfirmText = "" Enabled="True" TargetControlID="btnProceed">
                    </cc1:ConfirmButtonExtender>
                    <input type = "button" value = "Close" id = "Button1" onclick = "CloseWindow();" />--%>
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