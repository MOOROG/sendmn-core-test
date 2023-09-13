<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ReprintReceipt.PayReceipt" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title> Payment Receipt</title>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <style>
        .mainTable {
            width: 600px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }
        .label{
            color:black;
            border:none;
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

        .text {
            font-weight: bold;
        }
    </style>
    <script type="text/javascript">
        //function CallBackForFreeSim(url) {
        //    if (confirm("Go To Free Ncell SIM Registration! Enter customer details and give Free Ncell SIM.")) {
        //        PopUpWindow(url, "");
        //    }
        //    else
        //        return false;
        //}

        function PrintFrame() {
            window.parent.mainFrame.focus();
            window.print();
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <%-- <div id="divFreeSim" runat="server" class="noprint" Visible="false">
            <asp:LinkButton ID="btnFreeSim" runat="server" Text="Free Ncell SIM Registration"  class="noprint" CssClass="ButtonFreeSim"
                onclick="btnFreeSim_Click"/>
        </div>--%>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-8">
                    <div id="Printreceiptdetail" runat="server">

                        <table class="mainTable">
                            <tr>
                                <td valign="top">
                                    <span style="float: left">
                                        <img src="../../../../ui/images/logo-red.png" />

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
                                            <td>Address:
                                    <asp:Label ID="agentLocation" runat="server" CssClass="text"></asp:Label>, 
                                     <asp:Label ID="agentCountry" runat="server" CssClass="text"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Contact No: 
                                     <asp:Label ID="agentContact" runat="server"></asp:Label>

                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center">
                                    <div class="highlightTextLeft">
                                        <asp:Label ID="lblControlNo" runat="server">
                            Control No.</asp:Label>:<asp:Label ID="controlNo" CssClass="fontColor" runat="server"></asp:Label>&nbsp;&nbsp;
                            Tran No:
                                        <asp:Label ID="tranNo" CssClass="fontColor" runat="server"></asp:Label>
                                        Paid Date:
                                        <asp:Label ID="lblDate" CssClass="fontColor" runat="server"></asp:Label>
                                    </div>
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
                                                <asp:Label ID="sAddress" runat="server" CssClass="text"></asp:Label>
                                                &nbsp; ,   
                                                <asp:Label ID="sCountry" runat="server" CssClass="text"></asp:Label>
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
                                        <tr id="trChequeNo" runat="server">
                                            <td>Cheque No.:</td>
                                            <td>
                                                <asp:Label ID="chequeNo" runat="server"></asp:Label>
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
                                            <td rowspan="2"></td>
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
                        <hr />
                        <div align="center" style="font-weight: bold;">
                            यदि तपाइलाई भुक्तानी लिदा वा दिदा  कुनै समस्या भएमा बेष्ट रेमिट नेपाल प्रा.ली को ग्राहक सेवा केन्द्रको प्रत्यक्ष फोन नं ०१–४२६४७१७
                            <br />
                            अथवा ०१–४२६५८४०
                            र टोल फ्री नं १६६० – ०१ – ९९९८८ मा सम्पर्क गर्नुहोला । धन्यवाद ।
                            
                        </div>
                        <hr />
                        <a onclick="PrintFrame();" class="btn btn-primary print noPrint"><i class="fa fa-print"></i></a>

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function PrintWindow() {
        window.parent.mainFrame.focus();
        window.print();
    }
    function keypressed() {; return false; } document.onkeydown = keypressed; // End  –>

    var message = "Function Disabled!";
    function clickIE4() { if (event.button == 2) { alert(message); return false; } }
    function clickNS4(e) {
        if (document.layers || document.getElementById && !document.all)
        { if (e.which == 2 || e.which == 3) { alert(message); return false; } }
    }
    if (document.layers) { document.captureEvents(Event.MOUSEDOWN); document.onmousedown = clickNS4; }
    else if (document.all && !document.getElementById) { document.onmousedown = clickIE4; }

    document.oncontextmenu = new
        Function("alert(message);return false");

    document.getElementById("btnPrint").focus();
</script>
