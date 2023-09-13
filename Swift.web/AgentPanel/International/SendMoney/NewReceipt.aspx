<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewReceipt.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendTransactionIRH.NewReceipt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<head id="Head1">
    <title>Send Receipt
    </title>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <style type="text/css">
        @page {
            size: auto;
            margin: 5mm;
        }

        .text-heighlight1 {
            text-align: left;
            font-size: 13px;
            font-weight: bold;
            color: #004D20;
            font-family: Arial;
            color: #FF0000;
        }

        .label2 {
            font-size: 10px;
        }
    </style>

    <style type="text/css">

           .text-heighlight {
               text-align: left;
               font-size: 13px;
               font-weight: bold;
               color: #004D20;
               font-family: Arial;
               color: #FF0000;
           }

           .BoldFont1 {
               font-size: 18px;
               font-weight: bold;
               font-family: Arial;
           }

           .BoldFont2 {
               font-size: 15px;
               font-weight: bold;
               font-family: Arial;
           }

           legend {
               color: #FFFFFF;
               background: #FF0000;
               font-size: 11px;
           }

           fieldset {
               border: 1px solid #000000;
           }

           td {
               color: #000000;
               font-size: 10px;
           }

           .mainTable {
               width: 600px;
               padding: 2px;
               font-size: 10px;
               vertical-align: top;
           }

           .label {
               font-size: 10px;
           }

           .label1 {
               font-size: 10px;
               font-weight: bold;
           }

           #HeadAddress {
               font-size: 10px;
           }

           #HeadAddress1 {
               font-size: 10px;
           }

           .Border {
               border: 1px solid grey;
           }

           .premiumFont {
               font-size: 10px;
           }
           </s
       tyle>
</head>
<body>
    <form id="Form1" runat="server">
        <div style="height: 520px; overflow: hidden; padding-left: 5px; padding-top: 15px;">
            <div class="noprint" style="font-size: 16px; width: 100%; font-weight: bold;">
                <a href="Send.aspx">Go to Send Page</a>
            </div>

            <input type="button" id="Button1" name="btnPrint" value="Print" class="noprint" style="cursor: pointer;" onclick="PrintReceipt()" />
            <table width="90%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td height="78" colspan="2">
                        <div style="float: left;">
                            <img src="../../../Images/IME.png" width="108" height="70" />
                        </div>
                        <div id="HeadAddress" style="float: left; width: 300px;" runat="server">
                        </div>

                        <div id="trControNo" style="float: left; padding-left: 20px;">
                            <span><b style="text-decoration: underline">Customer Copy</b></span>

                            <br>
                            ICN (IME CONTROL NUMBER)
                            <br />

                            <span id="controlNo" runat="server" class="BoldFont1"></span>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td height="23" colspan="2" class="Border">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>RECEIVING MODE:
		<span id="tPaymentMode" runat="server" class="BoldFont2"></span></td>
                                <td>RECEIVING COUNTRY:
                                <span id="tReceivingCountry" runat="server" class="BoldFont2"></span></td>
                                <td>DATE:
                                <span id="tDate" runat="server" class="label1"></span></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="49%" height="162" valign="top">

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>SENDER'S DETAILS</legend>

                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="25%">CUSTOMER ID</td>
                                    <td colspan="3">: <span id="sCustomerId" runat="server" class="text-heighlight2"></span></td>
                                </tr>
                                <tr>
                                    <td>NAME</td>
                                    <td colspan="3">: <span id="sName" runat="server" class="label1"></span></td>
                                </tr>
                                <tr>
                                    <td>COMPANY NAME</td>
                                    <td colspan="3">: <span id="sCompanyName" runat="server" class="text-heighlight2"></span></td>
                                </tr>
                                <tr>
                                    <td>ADDRESS</td>
                                    <td colspan="3">: <span id="sAddress" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">NATIVE COUNTRY </td>
                                    <td style="width: 120px;" colspan="3">: <span id="sNativeCountry" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td style="width: 66px;" nowrap="nowrap">MOBILE NO</td>
                                    <td>: <span id="sContactNo" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" style="width: 156px;"><span id="sIdType" runat="server">PASSPORT</span> </td>
                                    <td style="width: 120px;">: <span id="sIdNo" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top" nowrap="nowrap">EMAIL ID </td>
                                    <td nowrap="nowrap" colspan="3">: <span id="sEmail" runat="server"></span></td>
                                </tr>
                            </table>
                        </fieldset>

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>PAYOUT BANK/AGENT DETAILS</legend>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td class="label2" width="25%">BANK/AGENT </td>
                                    <td class="text">: <span id="bankName" runat="server" style="font-weight: 700"></span></td>
                                </tr>
                                <tr>
                                    <td class="label2">BANK/AGENT DETAIL </td>
                                    <td class="text">: <span id="BranchName" runat="server"></span></td>
                                </tr>
                                <tr id="trAccno" runat="server" visible="false">
                                    <td class="label">ACCOUNT NO</td>
                                    <td class="text">:
                                        <asp:Label ID="accountNo" runat="server"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                    <td width="51%" valign="top">

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>RECEIVER'S DETAILS</legend>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="25%">NAME</td>
                                    <td colspan="3">: <span id="rName" runat="server" class="label1"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">COUNTRY </td>
                                    <td style="width: 120px;" colspan="3">: <span id="rCountry" runat="server"></span></td>
                                </tr>

                                <tr>
                                    <td>ADDRESS</td>
                                    <td colspan="3">: <span id="rAddress" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">PHONE </td>
                                    <td style="width: 120px;" colspan="3">: <span id="rPhone" runat="server"></span></td>
                                </tr>
                            </table>
                        </fieldset>

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>AMOUNT DETAILS</legend>

                            <table cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                    <td class="label2" width="30%">DEPOSIT AMOUNT</td>
                                    <td colspan="5">: <span id="dAmt" runat="server" class="BoldFont2"></span><span id="sCurr1" runat="server" class="BoldFont2">[MYR]</span> </td>
                                </tr>
                                <tr>
                                    <td class="label2">SERVICE CHARGE </td>
                                    <td colspan="5" nowrap="nowrap">: <span id="netServiceCharge" runat="server"></span><span id="sCurr2" runat="server">MYR</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">SENDING AMOUNT </td>
                                    <td colspan="5">: <span id="sAmt" runat="server"></span><span id="sCurr5" runat="server">MYR</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">EXCHANGE RATE </td>
                                    <td colspan="5">: <span id="exRate" runat="server"></span><span id="pCurr1" runat="server">BDT</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">RECEIVING AMOUNT </td>
                                    <td colspan="5">: <span id="pAmt" class="BoldFont2" runat="server"></span><span id="pCurr3" class="BoldFont2" runat="server">[BDT]</span>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <fieldset id="divPendingBonus" runat="server" visible="false">
                            <legend>CUSTOMER'S BONUS POINT</legend>
                            <table cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                    <td class="label" width="26%">PENDING BONUS </td>
                                    <td width="25%" class="text">:
                    <asp:Label ID="pendBonus" runat="server"></asp:Label>
                                    </td>
                                    <td width="22%" class="text"><span>EARNED BONUS</span></td>
                                    <td width="27%" class="text">:
                        <asp:Label ID="bonus" runat="server"></asp:Label></td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td height="55">
                        <%--<span style="background-color: Yellow; color: red; font-weight: bold; font-size: 11px;">
       IME बचत १० लाख योजना ।  यही सेप्टेम्बर १८ देखि नोभेम्बर १६ सम्म  IME मार्फत नेपाल  रकम पठाउनुहोस् र हरेक दिन Lucky Draw मार्फत रु ५,०००/- र हरेक हप्ता रु ५०,०००/- को बचत खाता र बम्परमा रु १० लाखको मुद्दती खाता खोल्ने अवसर प्राप्त गर्नुहोस् ।
        </span>--%>
                        <div id="spnMsg" style="font-size: 10px; height: 105px; overflow: hidden;" runat="server">
                        </div>
                    </td>

                    <td valign="baseline">

                        <div style="height: 25px"></div>
                        <hr class="hrRuller" />
                        <table width="100%">
                            <tr>
                                <td valign="baseline">SENDER'S SIGNATURE </td>
                                <td valign="baseline">PREPARED BY (<b style="font-size: 10px;"><span runat="server" id="preparedBy"></span></b>) </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <hr align="left" width="90%">

        <div style="height: 430px; overflow: hidden; padding-left: 5px;" id="multreceipt" runat="server" visible="false">

            <table width="90%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td height="78" colspan="2">
                        <div style="float: left;">
                            <img src="../../../Images/IME.png" width="113" height="67" />
                        </div>

                        <div id="HeadAddress1" runat="server" style="float: left; width: 300px;"></div>

                        <div style="padding-left: 50px; float: left;">
                            <span><b style="text-decoration: underline">Office Copy</b></span>

                            <br>
                            Transaction Number
                              <br />

                            <span id="controlNo1" runat="server" class="BoldFont1"></span>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td height="23" colspan="2" class="Border">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>RECEIVING MODE:
		<span id="tPaymentMode1" runat="server" class="BoldFont2"></span></td>
                                <td>RECEIVING COUNTRY:
        <span id="tReceivingCountry1" runat="server" class="BoldFont2"></span></td>
                                <td>DATE:
     <span id="tDate1" runat="server" class="label1"></span></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="49%" height="162" valign="top">

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>SENDER'S DETAILS</legend>

                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="25%">CUSTOMER ID</td>
                                    <td colspan="3">: <span id="sCustomerId1" runat="server" class="text-heighlight2"></span></td>
                                </tr>
                                <tr>
                                    <td>NAME</td>
                                    <td colspan="3">: <span id="sName1" runat="server" class="label1"></span></td>
                                </tr>
                                <tr>
                                    <td>COMPANY NAME</td>
                                    <td colspan="3">: <span id="sCompanyName1" runat="server" class="text-heighlight2"></span></td>
                                </tr>
                                <tr>
                                    <td>ADDRESS</td>
                                    <td colspan="3">: <span id="sAddress1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">NATIVE COUNTRY </td>
                                    <td style="width: 120px;" colspan="3">: <span id="sNativeCountry1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td style="width: 66px;" nowrap="nowrap">MOBILE NO</td>
                                    <td>: <span id="sContactNo1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" style="width: 156px;"><span id="sIdType1" runat="server">PASSPORT</span> </td>
                                    <td style="width: 120px;">: <span id="sIdNo1" runat="server"></span></td>
                                </tr>
                                <tr id="trIdexpiry" runat="server">
                                    <td class="label" style="width: 66px;">VISA EXPIRY DATE</td>
                                    <td>:
                                        <asp:Label ID="idExpiry" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top" nowrap="nowrap">EMAIL ID </td>
                                    <td nowrap="nowrap" colspan="3">: <span id="sEmail1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td class="label">OCCUPATION</td>
                                    <td colspan="3">:
                                        <asp:Label ID="Occupation" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">SOURCE OF FUND</td>
                                    <td colspan="3">:
                                        <asp:Label ID="sof" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label" nowrap="nowrap">PURPOSE OF REMITTANCE</td>
                                    <td colspan="3">:
                                        <asp:Label ID="purpose" runat="server"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>PAYOUT BANK/AGENT DETAILS</legend>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr id="trBankAgent1" runat="server">
                                    <td class="label2" width="25%">BANK/AGENT </td>
                                    <td class="text">: <span id="bankName1" runat="server" style="font-weight: 700"></span></td>
                                </tr>
                                <tr id="trpbranch">
                                    <td class="label2">BANK/AGENT DETAIL </td>
                                    <td class="text">: <span id="BranchName1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td class="label">ACCOUNT NO</td>
                                    <td class="text">:
                                        <asp:Label ID="accountNo1" runat="server"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                    <td width="51%" valign="top">

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>RECEIVER'S DETAILS</legend>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="25%">NAME</td>
                                    <td colspan="3">: <span id="rName1" class="label1" runat="server"></span></td>
                                </tr>

                                <tr>
                                    <td>ADDRESS</td>
                                    <td colspan="3">: <span id="rAddress1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">COUNTRY </td>
                                    <td style="width: 120px;" colspan="3">: <span id="rCountry1" runat="server"></span></td>
                                </tr>
                                <tr>
                                    <td valign="top">PHONE </td>
                                    <td style="width: 120px;" colspan="3">: <span id="rPhone1" runat="server"></span></td>
                                </tr>
                            </table>
                        </fieldset>

                        <fieldset>
                            <!---Sender's Details--->
                            <legend>AMOUNT DETAILS</legend>

                            <table cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                    <td class="label2" width="30%">DEPOSIT AMOUNT</td>
                                    <td colspan="5">: <span id="dAmt1" class="BoldFont2" runat="server"></span><span id="sCurr11" runat="server" class="BoldFont2">[MYR]</span> </td>
                                </tr>
                                <tr>
                                    <td class="label2">SERVICE CHARGE </td>
                                    <td colspan="5" nowrap="nowrap">: <span id="netServiceCharge1" runat="server"></span><span id="sCurr21" runat="server">MYR</span>
                                        <br>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">SENDING AMOUNT </td>
                                    <td colspan="5">: <span id="sAmt1" runat="server"></span><span id="sCurr51" runat="server">MYR</span>
                                        <br>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">EXCHANGE RATE </td>
                                    <td colspan="5">: <span id="exRate1" runat="server"></span><span id="pCurr11" runat="server">BDT</span>
                                        <span style="font-size: 10px;" id="prem21" runat="server"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label2">RECEIVING AMOUNT </td>
                                    <td colspan="5">: <span id="pAmt1" class="BoldFont2" runat="server"></span><span id="pCurr31" class="BoldFont2" runat="server">[BDT]</span>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                        <fieldset id="divPendingBonus1" runat="server" visible="false">
                            <legend>CUSTOMER'S BONUS POINT</legend>
                            <table cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                    <td class="label" width="26%">PENDING BONUS </td>
                                    <td width="25%" class="text">:
                    <asp:Label ID="pendBonus1" runat="server"></asp:Label>
                                    </td>
                                    <td width="22%" class="text"><span class="label1">EARNED BONUS</span></td>
                                    <td width="27%" class="text">:
                        <asp:Label ID="bonus1" runat="server"></asp:Label></td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td width="49%">
                        <%-- <div id = "depInfo" runat = "server" style="width:95%" >     --%>
                        <fieldset style="width: 96%;">
                            <legend>COLLECTION INFORMATION</legend>
                            <div id="Ddetail" runat="server" style="width: 100%"></div>
                        </fieldset>
                        <%--    </div>--%>
                    </td>

                    <td valign="baseline">

                        <div style="height: 25px;"></div>
                        <table width="90%" align="right" cellpadding="0" cellspacing="0" style="border-top: 1px solid black;">
                            <tr>
                                <td valign="baseline">SENDER'S SIGNATURE </td>
                                <td valign="baseline">PREPARED BY (<b style="font-size: 10px;"><span id="preparedBy1" runat="server"></span></b>) </td>
                                <td style="font-size: 11px; width: 36%">APPROVED BY (<b style="font-size: 10px;"><span id="approvedBy" runat="server"></span></b>)
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <input type="button" id="btnPrint" name="btnPrint" value="Print" class="noprint" style="cursor: pointer;" onclick="PrintReceipt();" />
    </form>
</body>
</html>

<script type="text/javascript">

    function PrintReceipt() {
        window.print();
    }

    //function keypressed() { ClickBtn(); return false; } document.onkeydown = keypressed; // End  –>

    //function keypressed() { ClickBtn(); return false; } document.onkeydown = keypressed; // End  –>
    //
    //    var message = "Function Disabled!";
    //    function clickIE4() { if (event.button == 2) { alert(message); return false; } }
    //    function clickNS4(e) {
    //        if (document.layers || document.getElementById && !document.all)
    //        { if (e.which == 2 || e.which == 3) { alert(message); return false; } }
    //    }
    //    if (document.layers) { document.captureEvents(Event.MOUSEDOWN); document.onmousedown = clickNS4; }
    //    else if (document.all && !document.getElementById) { document.onmousedown = clickIE4; }
    //    document.oncontextmenu = new
    //        Function("alert(message);return false");
    //

    document.getElementById("btnPrint").focus();

    function ClickBtn() {
        if (window.event.keyCode == 13)
            PrintReceipt();
        else if (window.event.keyCode == 113)
            window.location.href = "Send.aspx";
    }

    PrintReceipt();
</script>