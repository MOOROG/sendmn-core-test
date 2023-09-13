<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendIntlReceipt.aspx.cs" Inherits="Swift.web.Responsive.Send.SendMoneyv2.SendIntlReceipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/css/receipt.css" rel="stylesheet" />
    <style>
        @media print {
            footer {
                page-break-after: always;
            }

            .no-margin {
                margin-top: 0% !important;
            }
        }

        .details h4 {
            margin: 4px 0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <table border="0" width="100%" style="margin-top: 10%;" class="no-margin">
            <!--Header-->
            <tr>
                <td>
                    <table width="100%;" border="0">
                        <tr>
                            <td width="20%;">
                                <div class="logo">
                                    <img src="/images/jme.png" />
                                </div>
                                <p>Kanto Finance Bureau License</p>
                                <p>
                                    Number:<span>0006</span>
                            </td>
                            <td width="80%;">
                                <h3><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Japan</h3>
                                <p>
                                    169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07
                                <p>
                                    <p>
                                        Shinjuku-ku, Tokyo, japan
                                        <p>
                                            <p>
                                                Tel:03-5475-3913, <span>Fax:03-5475-3913</span>
                                                <p>
                                                    <p>
                                                        email:info@japanremit.com
                                                        <p>
                            </td>

                        </tr>
                    </table>
                </td>
                <td>

                    <table width="100%;" border="0">
                        <tr>
                            <td colspan="2" class="copy" width="100%;">
                                <p style="text-decoration: underline;">Customer Copy</p>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>
            <!--body-->
            <tr valign="top">
                <td width="80%;">
                    <table width="100%;">
                        <!--sender information-->
                        <tr>
                            <td>
                                <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                    <tr>
                                        <td colspan="4 " class="details">
                                            <h4>SENDER INFORMATION</h4>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="16% " valign="top">
                                            <label>Senders Name</label>
                                        </td>
                                        <td width="38% " valign="top">
                                            <span class="sender-value ">
                                                <asp:Label ID="senderName" runat="server"></asp:Label></span>
                                        </td>
                                        <td width="18% " valign="top" >
                                            <label>Membership Card</label>
                                        </td>
                                        <td width="28% ">
                                            <span class="sender-value ">
                                                <asp:Label ID="sMemId" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Address</label>
                                        </td>
                                        <td colspan="3 ">
                                            <span class="sender-value ">
                                                <asp:Label ID="sAddress" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Nationality</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sNativeCountry" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Purpose</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="purpose" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Date of birth</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sDob" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Mobile No.</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sContactNo" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <!--Receiver information-->
                        <tr style="">
                            <td>
                                <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                    <tr>
                                        <td colspan="4" class="details">
                                            <h4>RECEIVER INFORMATION</h4>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Payout Country</label>
                                        </td>
                                        <td colspan="3">
                                            <span class="sender-value">
                                                <asp:Label ID="pAgentCountry" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td width="16%" valign="top">
                                            <label>Receiver's Name</label>
                                        </td>
                                        <td width="38%" valign="top">
                                            <span class="sender-value">
                                                <asp:Label ID="receiverName" runat="server"></asp:Label></span>
                                        </td>
                                        <td width="18%">
                                            <label>Payment Mode</label>
                                        </td>
                                        <td width="28%"><span class="sender-value">
                                            <span class="sender-value">
                                                <asp:Label ID="paymentMode" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Contact No</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">Mobile
                                                <asp:Label ID="rContactNo" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Correspondent</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pAgent" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Address</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="rAddress" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Bank Name</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pBankName" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label>&nbsp;</label>
                                        </td>

                                        <td>
                                            <label>Branch</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pBranchName" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label>&nbsp;</label>
                                        </td>

                                        <td>
                                            <label>Account No</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="accountNo" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <p>
                                                <em>Receive Amount NPR: <span>
                                                    <asp:Label ID="rAmtWords" runat="server"></asp:Label></span></em>
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>

                <td width="20%" class="amount-info">
                    <table width="100%;" border="1" cellspacing="0 " cellpadding="0 ">
                        <tr>
                            <td>
                                <h2>PINNO:<span><asp:Label ID="controlNo" runat="server"></asp:Label></span></h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>User:<span><asp:Label ID="createdBy" runat="server"></asp:Label></span></p>
                                <p>
                                    <span>
                                        <asp:Label ID="approvedDate" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Collected Amount</p>
                                <h3><span>
                                    <asp:Label ID="cAmt" runat="server"></asp:Label></span></h3>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Service Charge</p>
                                <p>
                                    <span>
                                        <asp:Label ID="serviceCharge" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Transfer Amount</p>
                                <p>
                                    <span>
                                        <asp:Label ID="tAmt" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Exchange Rate</p>
                                <p>
                                    <span>
                                        <asp:Label ID="exRate" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Receive Amount</p>
                                <h3><span>
                                    <asp:Label ID="pAmt" runat="server"></asp:Label></span></h3>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Serial:<span>315631</span></p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Deposite Type</p>
                                <p><span>Cash</span></p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!--information section-->
            <tr valign="top">
                <td colspan="2">
                    <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                        <tr valign="top" style="height: 30px;">
                            <td colspan="4">
                                <p>THE ABOVE INFORMATION IS CORRECT AND I DELARE THAT I READ TERMS AND CONDITIONS</p>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <label>Customer's Signature</label>
                            </td>
                            <td>..................................................
                            </td>
                            <td>
                                <label>Operator:(<asp:Label ID="operator1" runat="server"></asp:Label>)</label>
                            </td>
                            <td>..................................................
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <table width="100%;" style="margin: 15px 0;">
            <tr>
                <td>
                    <center>-----------------------------------------------------------------Cut From Here-----------------------------------------------------------------</center>
                </td>
            </tr>
        </table>

        <table border="0" width="100%">
            <!--Header-->
            <tr>
                <td>
                    <table width="100%;" border="0">
                        <tr>
                            <td width="20%;">
                                <div class="logo">
                                    <img src="../../../Images/jme.png" />
                                </div>
                                <p>Kanto Finance Bureau License</p>
                                <p>
                                    Number:<span>0006</span>
                            </td>
                            <td width="55%;">
                                <h3><%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Japan</h3>
                                <p>
                                    169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07
                                <p>
                                    <p>
                                        Shinjuku-ku, Tokyo, japan
                                        <p>
                                            <p>
                                                Tel:03-5475-3913, <span>Fax:03-5475-3913</span>
                                                <p>
                                                    <p>
                                                        email:info@japanremit.com
                                                        <p>
                            </td>

                        </tr>
                    </table>
                </td>
                <td>
                    <table width="100%;" border="0">
                        <tr>
                               <td colspan="2" class="copy" width="100%;">
                                <p style="text-decoration: underline;">Office Copy</p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!--body-->
            <tr valign="top">
                <td width="80%;">
                    <table width="100%;">
                        <!--sender information-->
                        <tr>
                            <td>
                                <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                    <tr>
                                        <td colspan="4 " class="details">
                                            <h4>SENDER INFORMATION</h4>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="16% " valign="top">
                                            <label>Sender Name</label>
                                        </td>
                                        <td width="38% " valign="top">
                                            <span class="sender-value ">
                                                <asp:Label ID="senderName1" runat="server"></asp:Label></span>
                                        </td>
                                        <td width="18% " valign="top">
                                            <label>Membership Card</label>
                                        </td>
                                        <td width="28% ">
                                            <span class="sender-value ">
                                                <asp:Label ID="sMemId1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Address</label>
                                        </td>
                                        <td colspan="3 ">
                                            <span class="sender-value ">
                                                <asp:Label ID="sAddress1" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Nationality</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sNativeCountry1" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Purpose</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="purpose1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Date of birth</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sDob1" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Mobile No.</label>
                                        </td>
                                        <td>
                                            <span class="sender-value ">
                                                <asp:Label ID="sContactNo1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <!--Receiver information-->
                        <tr style="">
                            <td>
                                <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                    <tr>
                                        <td colspan="4" class="details">
                                            <h4>RECEIVER INFORMATION</h4>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Payout Country</label>
                                        </td>
                                        <td colspan="3">
                                            <span class="sender-value">
                                                <asp:Label ID="pAgentCountry1" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td width="16%" valign="top">
                                            <label>Receiver's Name</label>
                                        </td>
                                        <td width="38%" valign="top">
                                            <span class="sender-value">
                                                <asp:Label ID="receiverName1" runat="server"></asp:Label></span>
                                        </td>
                                        <td width="18%">
                                            <label>Payment Mode</label>
                                        </td>
                                        <td width="28%"><span class="sender-value">
                                            <span class="sender-value">
                                                <asp:Label ID="paymentMode1" runat="server"></asp:Label></span>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Contact No</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">Mobile
                                                <asp:Label ID="rContactNo1" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Correspondent</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pAgent1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Address</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="rAddress1" runat="server"></asp:Label></span>
                                        </td>
                                        <td>
                                            <label>Bank Name</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pBankName1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label>&nbsp;</label>
                                        </td>

                                        <td>
                                            <label>Branch</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="pBranchName1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label>&nbsp;</label>
                                        </td>

                                        <td>
                                            <label>Account No</label>
                                        </td>
                                        <td>
                                            <span class="sender-value">
                                                <asp:Label ID="accountNo1" runat="server"></asp:Label></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <p>
                                                <em>Receive Amount NPR: <span>
                                                    <asp:Label ID="rAmtWords1" runat="server"></asp:Label></span></em>
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>

                <td width="20%" class="amount-info">
                    <table width="100%;" border="1" cellspacing="0 " cellpadding="0 ">
                        <tr>
                            <td>
                                <h2>PINNO:<span><asp:Label ID="controlNo1" runat="server"></asp:Label></span></h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>User:<span><asp:Label ID="createdBy1" runat="server"></asp:Label></span></p>
                                <p>
                                    <span>
                                        <asp:Label ID="approvedDate1" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Collected Amount</p>
                                <h3><span>
                                    <asp:Label ID="cAmt1" runat="server"></asp:Label></span></h3>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Service Charge</p>
                                <p>
                                    <span>
                                        <asp:Label ID="serviceCharge1" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Transfer Amount</p>
                                <p>
                                    <span>
                                        <asp:Label ID="tAmt1" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Exchange Rate</p>
                                <p>
                                    <span>
                                        <asp:Label ID="exRate1" runat="server"></asp:Label></span>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Receive Amount</p>
                                <h3><span>
                                    <asp:Label ID="pAmt1" runat="server"></asp:Label></span></h3>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Serial:<span>315631</span></p>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <p>Deposite Type</p>
                                <p><span>Cash</span></p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!--information section-->
            <tr valign="top">
                <td colspan="2">
                    <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                        <tr valign="top" style="height: 30px;">
                            <td colspan="4">
                                <p>THE ABOVE INFORMATION IS CORRECT AND I DELARE THAT I READ TERMS AND CONDITIONS</p>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <label>Customer's Signature</label>
                            </td>
                            <td>..................................................
                            </td>
                            <td>
                                <label>Operator:(<asp:Label ID="operator2" runat="server"></asp:Label>)</label>
                            </td>
                            <td>..................................................
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <footer></footer>
    </form>
</body>
</html>
