<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.PayTransaction.PayReceipt" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>BRN Payment Receipt</title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>

    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/metisMenu.min.js" type="text/javascript"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../ui/js/custom.js"></script>
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

<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel">
                        <div id="Printreceiptdetail" runat="server">
                            <table class="mainTable">
                                <tr>
                                    <td valign="top">
                                        <span style="float: left">
                                            <img src="../../../../ui/Images/receipt_logo.png" />
                                        </span>
                                        <div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;"></div>
                                    </td>
                                    <td valign="top">
                                        <table class="innerTableHeader">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="agentName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="branchName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Address:</label>
                                                    <asp:Label ID="agentLocation" runat="server"></asp:Label>, 
                                                    <asp:Label ID="agentCountry" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Contact No: </label>
                                                    <asp:Label ID="agentContact" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="highlightTextLeft">
                                            <asp:Label ID="lblControlNo" runat="server">Control No.</asp:Label>:
                                    <asp:Label ID="controlNo" runat="server" CssClass="fontColor"></asp:Label>&nbsp;&nbsp;
                                            Tran No:<asp:Label ID="tranNo" runat="server" CssClass="fontColor"></asp:Label>
                                        </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <div align="right" class="highlightTextRight">
                                            Paid Date:
                                        <asp:Label ID="lblDate" CssClass="fontColor" runat="server"></asp:Label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table class="innerTable">
                                            <tr>
                                                <td>
                                                    <label>Sender's Name: </label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="sName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Address:</label></td>
                                                <td>
                                                    <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                    &nbsp; ,   
                                    <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Contact No:</label></td>
                                                <td>
                                                    <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Relationship with sender:</label></td>
                                                <td>
                                                    <asp:Label ID="relationship" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Amount:</label></td>
                                                <td>
                                                    <asp:Label ID="payoutAmt" runat="server" CssClass="fontColor"></asp:Label>
                                                    <asp:Label ID="payoutCurr" runat="server" CssClass="fontColor"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <table class="innerTable">
                                            <tr>
                                                <td>
                                                    <label>Receiver's Name:</label></td>
                                                <td>
                                                    <asp:Label ID="rName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Address:</label></td>
                                                <td>
                                                    <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                    &nbsp;,
                                    <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Contact No:</label></td>
                                                <td>
                                                    <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <label>Id Type:</label></td>
                                                <td>
                                                    <asp:Label ID="rIdType" runat="server"></asp:Label>
                                                    &nbsp; &nbsp; No:<asp:Label ID="rIdNo" runat="server"></asp:Label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <label>Mode of Payment:</label></td>
                                                <td>
                                                    <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <div id="trChequeNo" runat="server">
                                                <tr>
                                                    <td>

                                                        <label>Cheque No.:</label></td>
                                                    <td>
                                                        <asp:Label ID="chequeNo" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                            </div>
                                            <tr>
                                                <td>
                                                    <label>Status:</label></td>
                                                <td>
                                                    <asp:Label ID="paystatus" runat="server" CssClass="fontColor" Text="PAID"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <label>Payout amount in words: </label>
                                        <asp:Label ID="payoutAmtFigure" runat="server" CssClass="fontColor"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <label>Authorized User</label>
                                        <br />
                                        Receiver's Signature
                                    </td>
                                    <td>
                                        <div align="right">
                                            <label>
                                                <asp:Label ID="userFullName" runat="server"></asp:Label></label>
                                        </div>
                                        <div align="right">
                                            <label>_______________</label>
                                        </div>
                                    </td>
                                </tr>
                                <div id="bankShowHide" runat="server" visible="false">
                                    <tr>
                                        <td colspan="2">
                                            <table>
                                                <tr>
                                                    <td colspan="2">
                                                        <table class="innerTable">
                                                            <tr>
                                                                <td nowrap="nowrap" align="right">Bank: </td>
                                                                <td nowrap="nowrap" align="left">
                                                                    <asp:Label ID="pBankName" runat="server"></asp:Label></td>
                                                                <td nowrap="nowrap" align="right">Branch: </td>
                                                                <td nowrap="nowrap" align="left">
                                                                    <asp:Label ID="pBankBranchName" runat="server"></asp:Label>
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
                                            </table>
                                        </td>
                                    </tr>
                                </div>
                                <div id="divCompliance" runat="server" visible="false">
                                    <tr>
                                        <td colspan="2">
                                            <table>
                                                <tr>
                                                    <td colspan="2">
                                                        <fieldset>
                                                            <legend>Bank/Cheque Information</legend>
                                                            <table class="innerTable">
                                                                <tr id="trRBank" runat="server" visible="false">
                                                                    <td nowrap="nowrap" align="right">Bank Name: </td>
                                                                    <td nowrap="nowrap" align="left">
                                                                        <asp:Label ID="rBank" runat="server"
                                                                            Style="font-weight: 700"></asp:Label></td>
                                                                    <td nowrap="nowrap" align="right">Branch: </td>
                                                                    <td nowrap="nowrap" align="left">
                                                                        <asp:Label ID="rBankBranch" runat="server"
                                                                            Style="font-weight: 700"></asp:Label>
                                                                    </td>
                                                                    <td nowrap="nowrap" align="right">Cheque No.: </td>
                                                                    <td nowrap="nowrap" align="left">
                                                                        <asp:Label ID="rChequeNo" runat="server"
                                                                            Style="font-weight: 700"></asp:Label></td>
                                                                </tr>
                                                                <tr id="trRBank1" runat="server" visible="false">
                                                                    <td nowrap="nowrap" align="right">Account No.: </td>
                                                                    <td nowrap="nowrap" align="left">
                                                                        <asp:Label ID="rAccountNo" runat="server"
                                                                            Style="font-weight: 700"></asp:Label></td>
                                                                    <td nowrap="nowrap" align="right">Cheque No.: </td>
                                                                    <td nowrap="nowrap" align="left">
                                                                        <asp:Label ID="rChqNo" runat="server"
                                                                            Style="font-weight: 700"></asp:Label></td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </div>
                                <tr>
                                    <td colspan="2"></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div id="multreceipt" runat="server"></div>
                </div>
            </div>
        </div>
        <%--<table class="mainTable" style="margin-top:-60px; padding:-2px;">
            <tr>
                <td colspan="2">
                    <hr class="hrRuller" />
                    <div align="center" style="font-weight: bold;">
                        यदि तपाइलाई भुक्तानी लिदा वा दिदा  कुनै समस्या भएमा बेष्ट रेमिट नेपाल प्रा.ली को ग्राहक सेवा केन्द्रको प्रत्यक्ष<br />
                        फोन नं ०१–४२६४७१७ अथवा ०१–४२६५८४० र टोल फ्री नं १६६० – ०१ – ९९९८८ मा सम्पर्क गर्नुहोला ।
                                                                धन्यवाद ।
                    </div>
                    <hr class="hrRuller" />
                </td>
            </tr>
        </table>--%>
        <div>
            <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>

            <div id="commonMsg" runat="server" class="commonMsg">
            </div>

        </div>
        <a onclick="PrintFrame();" class="btn btn-primary print noPrint"><i class="fa fa-print"></i></a>
    </form>
    <script type="text/javascript">
        function PrintFrame() {
            window.parent.mainFrame.focus();
            window.print();
        }
    </script>
</body>
</html>
