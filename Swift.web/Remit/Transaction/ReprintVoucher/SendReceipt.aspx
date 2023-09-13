<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.ReprintVoucher.SendReceipt" EnableViewState="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Payment Receipt</title>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <style>
        .mainTable {
            width: 600px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }

        .innerTable {
            width: 300px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }

            .innerTable td {
                text-align: left;
                width: 150px;
                vertical-align: top;
            }

        .innerTableHeader {
            width: 300px;
            padding: 2px;
        }

            .innerTableHeader td {
                text-align: right;
            }

        .highlightTextLeft {
            font-size: 11px;
            xcolor: #999999;
            color: Black;
            font-weight: bold;
            text-transform: uppercase;
            vertical-align: top;
            margin-left: 10px;
        }

        .highlightTextRight {
            font-size: 11px;
            xcolor: #999999;
            color: Black;
            font-weight: bold;
            text-transform: uppercase;
            vertical-align: top;
            margin-left: 10px;
            text-align: right;
        }

        .AmtCss {
            text-transform: uppercase;
            font-weight: bold;
            margin-left: 5px;
        }

        .hrRuller {
            text-align: left;
            width: 600px;
            margin-left: 5px;
        }

        .fontColor {
            color: Red;
            font-weight: bold;
            font-size: 13px;
        }
    </style>
</head>

<body style="margin-top: 0px;">
    <form id="form1" runat="server">
        <div id="Printreceiptdetail" runat="server">
            <table class="mainTable">
                <tr>
                    <td valign="top">
                        <span style="float: left">
                            <img src="../../../ui/Images/receipt_logo.png" />
                        </span>
                        <div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;"></div>
                    </td>
                    <td valign="top">
                        <table class="innerTableHeader">
                            <tr>
                                <td class="label">
                                    <asp:Label ID="sAgentName" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="sBranchName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address:
                            <asp:Label ID="sAgentLocation" runat="server"></asp:Label>, 
                            <asp:Label ID="sAgentCountry" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No: 
                                <asp:Label ID="sContact" runat="server"></asp:Label>

                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="left" class="highlightTextLeft">
                            <asp:Label ID="lblControlNo" runat="server">Control No.</asp:Label>:<asp:Label ID="controlNo" CssClass="fontColor" runat="server"></asp:Label>&nbsp;&nbsp;
                            Tran No:
                            <asp:Label ID="tranNo" CssClass="fontColor" runat="server"></asp:Label>
                        </div>
                    </td>
                    <td nowrap="nowrap">
                        <div align="right" class="highlightTextRight">
                            Send Date:
                            <asp:Label ID="lblDate" CssClass="fontColor" runat="server"></asp:Label>
                        </div>
                    </td>

                </tr>
                <tr>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td><b>Sender's Name: </b></td>
                                <td class="formLabel">
                                    <asp:Label ID="sName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td class="text">
                                    <asp:Label ID="sAddress" runat="server"></asp:Label>
                                    ,  
                                        &nbsp;
                                        <asp:Label ID="sCountry" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No: </td>
                                <td class="text">
                                    <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Type: </td>
                                <td class="text">
                                    <asp:Label ID="sIdType" runat="server"></asp:Label>
                                    &nbsp; &nbsp;
                                        <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="sDisMemId">
                                <td>Membership Id: </td>
                                <td class="text">
                                    <asp:Label ID="sMemId" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td><b>Receiver's Name: </b></td>
                                <td class="formLabel">
                                    <asp:Label ID="rName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td class="text">
                                    <asp:Label ID="rAddress" runat="server"></asp:Label>
                                    ,
                                &nbsp;
                                    <asp:Label ID="rCountry" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No: </td>
                                <td class="text">
                                    <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Type: </td>
                                <td class="text">
                                    <asp:Label ID="rIdType" runat="server"></asp:Label>
                                    &nbsp; &nbsp;
                            <asp:Label ID="rIdNo" runat="server"></asp:Label>

                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td>Relationship with sender: </td>
                                <td class="text">
                                    <asp:Label ID="relationship" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="rDisMemId">
                                <td>Membership Id: </td>
                                <td class="text">
                                    <asp:Label ID="rMemId" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblRemarks" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td>Total Collection Amount: </td>

                                <td class="text-amount">
                                    <asp:Label ID="total" runat="server"></asp:Label>
                                    <asp:Label ID="collCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Service Charge: </td>
                                <td class="text-amount">
                                    <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                    <asp:Label ID="scCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Total Sent Amount: </td>
                                <td class="fontColor">
                                    <asp:Label ID="transferAmount" runat="server"></asp:Label>
                                    <asp:Label ID="transCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Payout Amount: </td>
                                <td class="text-amount redHighlight">
                                    <asp:Label ID="payoutAmt" runat="server"></asp:Label>
                                    <asp:Label ID="PCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="trBonus">
                                <td>Pending Bonus: </td>
                                <td class="text">
                                    <asp:Label ID="pBonus" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td>Payout Location: </td>
                                <td class="text">
                                    <asp:Label ID="pAgentLocation" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>District:</td>
                                <td class="text">
                                    <asp:Label ID="pAgentDistrict" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Country: </td>

                                <td class="text">
                                    <asp:Label ID="pAgentCountry" runat="server"></asp:Label>
                                </td>

                            </tr>
                            <tr>
                                <td>Mode of Payment: </td>
                                <td class="text">
                                    <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr runat="server" id="trBonus1">
                                <td>Earned Bonus: </td>
                                <td class="text">
                                    <asp:Label ID="eBonus" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>

                        </table>
                    </td>
                </tr>
                <div id="bankShowHide" runat="server" visible="false">
                    <tr>
                        <td colspan="2">
                            <table class="innerTable">
                                <tr>
                                    <td nowrap="nowrap" align="right">Bank: </td>
                                    <td nowrap="nowrap" align="left">
                                        <asp:Label ID="bankName" runat="server"></asp:Label></td>
                                    <td nowrap="nowrap" align="right">Branch: </td>
                                    <td nowrap="nowrap" align="left">
                                        <asp:Label ID="BranchName" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" align="right">Account No.: </td>
                                    <td nowrap="nowrap" align="left">
                                        <asp:Label ID="accNum" runat="server"></asp:Label></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </div>
                <tr>
                    <td colspan="2">
                        <div class="AmtCss">
                            Payout amount in words: 
                   <span class="fontColor">
                       <asp:Label ID="payoutAmtFigure" runat="server"></asp:Label></span>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table class="mainTable">
                            <tr>
                                <td valign="bottom" nowrap="nowrap">Authorized User</td>
                                <td rowspan="2">
                                    <div align="center">
                                    </div>
                                </td>
                                <td align="right">Sender's Signature</td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="userFullName" runat="server"></asp:Label></td>
                                <td align="right">_______________</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <hr class="hrRuller" />
        <div id="multreceipt" runat="server"></div>

        <div>
            <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>

            <div id="commonMsg" runat="server" class="commonMsg">
            </div>
            <hr class="hrRuller" />
            <div style="font-weight: bold;">
                यदि तपाइलाई भुक्तानी लिदा वा दिदा  कुनै समस्या भएमा बेष्ट रेमिट नेपाल प्रा.ली को ग्राहक सेवा केन्द्रको प्रत्यक्ष<br />
                फोन नं ०१–४२६४७१७ अथवा ०१–४२६५८४० र टोल फ्री नं १६६० – ०१ – ९९९८८ मा सम्पर्क गर्नुहोला ।
            धन्यवाद ।
            </div>
            <hr class="hrRuller" />
        </div>
        <input type="button" value="Print" id="btnPrint" onclick=" PrintWindow(); " class="noPrint" />
    </form>
    <script type="text/javascript">
        function PrintWindow() {
            window.print();
        }
    </script>
</body>
</html>