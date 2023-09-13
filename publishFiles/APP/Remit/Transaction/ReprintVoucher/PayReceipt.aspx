<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.ReprintVoucher.PayReceipt" EnableViewState="false" %>

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

<body style="margin-top: 0px; width: 600px;">
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
                                    <asp:Label ID="agentName" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <asp:Label ID="branchName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Address:
                                    <asp:Label ID="agentLocation" runat="server"></asp:Label>, 
                                     <asp:Label ID="agentCountry" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Contact No: 
                                     <asp:Label ID="agentContact" runat="server"></asp:Label>

                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="left" class="highlightTextLeft">
                            <asp:Label ID="lblControlNo" runat="server">BRN No.</asp:Label>:<asp:Label ID="controlNo" CssClass="fontColor" runat="server"></asp:Label>&nbsp;&nbsp;
                            Tran No:
                            <asp:Label ID="tranNo" CssClass="fontColor" runat="server"></asp:Label>
                        </div>
                    </td>
                    <td nowrap="nowrap">
                        <div align="right" class="highlightTextRight">Paid Date:
                            <asp:Label ID="lblDate" CssClass="fontColor" runat="server"></asp:Label></div>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <table class="innerTable">
                            <tr>
                                <td><b>Sender's Name: </b></td>
                                <td>
                                    <b>
                                        <asp:Label ID="sName" runat="server"></asp:Label>
                                    </b>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td>
                                    <asp:Label ID="sAddress" runat="server"></asp:Label>
                                    &nbsp; ,   
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
                                <td>Relationship with sender: </td>
                                <td class="text">
                                    <asp:Label ID="relationship" runat="server"></asp:Label>
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
                    <td valign="top">
                        <table class="innerTable">
                            <tr style="font-weight: bold;">
                                <td>Receiver's Name: </td>
                                <td class="text">
                                    <asp:Label ID="rName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address:</td>
                                <td class="text">
                                    <asp:Label ID="rAddress" runat="server"></asp:Label>
                                    &nbsp;,
                                    <asp:Label ID="rCountry" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Contact No:</td>
                                <td class="text">
                                    <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Id Type:</td>
                                <td class="text">
                                    <asp:Label ID="rIdType" runat="server"></asp:Label>
                                    &nbsp; &nbsp; No:<asp:Label ID="rIdNo" runat="server"></asp:Label>

                                    &nbsp;</td>
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
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td>Amount: </td>
                                <td class="fontColor">
                                    <asp:Label ID="payoutAmt" runat="server"></asp:Label>
                                    <asp:Label ID="payoutCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="fontColor" colspan="2">
                                    <asp:Label ID="payoutAmtFigure" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td>Mode of Payment: </td>
                                <td class="text">
                                    <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Status:</td>
                                <td class="fontColor" align="left">PAID</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table class="mainTable" cellpadding="5px" cellspacing="5px">
                            <tr>
                                <td valign="bottom" nowrap="nowrap">Authorized User</td>
                                <td rowspan="2">
                                    <div align="center">
                                    </div>
                                </td>
                                <td align="right">Receiver's Signature</td>
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
            <input type="button" value="Print" id="btnPrint" onclick=" PrintWindow(); " class="noPrint" />

        </div>
    </form>
    <script type="text/javascript">
        function PrintWindow() {
            window.print();
        }
    </script>
</body>
</html>

