<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ReprintReceipt.SendReceipt" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Send Receipt</title>
    <%--<link href="../../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" ></script>
    <script src="../../../../js/functions.js" > </script>
    <style>
        .mainTable {
            width: 600px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }

        .label{
            color:black;
            border:none !important;
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
    <script type="text/javascript">
        //function CallBackForFreeSim(url) {
        //    if (confirm("Go To Free Ncell SIM Registration! Enter customer details and give Free Ncell SIM.")) {
        //        PopUpWindow(url, "");
        //    }
        //    else
        //        return false;
        //}

        function UploadDocument() {
            var agentId = GetValue("<% = hdnAgentId.ClientID %>");
            var txnType = "sd";
            var tranId = GetValue("<% = hdnTranId.ClientID %>");
            var url = "../../../Administration/AgentCustomerSetup/UploadVoucher/BrowseDoc.aspx?id=" + tranId + '&agentId=' + agentId + '&txnType=' + txnType;
            OpenInNewWindow(url);
            return true;
        }
        function DoUpload(docDesc) {
            var user = "<%=GetStatic.GetUser() %>";
            var branch = "<%=GetStatic.GetBranch() %>";
            var txnType = "sd";
            parent.UploadDocMain(user, txnType, branch, docDesc);
        }
        function ScanDocument() {
            var icn = GetValue("<% = hdnIcn.ClientID %>");
            var id = GetValue("<% = hdnTranId.ClientID %>");
            parent.ScanDocument(id, icn);
        }
        function CheckForDocument(Icn, Id) {
            var agentId = document.getElementById("hdnAgentId").value;
            var vouType = "sd";

            var dataToSend = { MethodName: 'docCheck', agentId: agentId, icn: Icn, tranId: Id, vouType: vouType };
            var options =
                    {
                        url: '<%=ResolveUrl("SendReceipt.aspx") %>',
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode = "0") {
                                    var sum = data[0].id;
                                    if (sum == 0) {
                                        parent.Disable(0); //enable all
                                    } else if (sum == 1) {
                                        parent.Disable(1); //enable voucher only
                                    } else if (sum == 2) {
                                        parent.Disable(2); //enable id only 
                                    } else if (sum >= 3) {
                                        parent.Disable(4); //enable both
                                    }
                                    return;
                                }
                            }
                        };
                $.ajax(options);
                return true;
            }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnAgentId" runat="server" />
        <asp:HiddenField ID="hdnTranId" runat="server" />
        <asp:HiddenField ID="hdnIcn" runat="server" />
        <asp:HiddenField ID="hdnTxnType" runat="server" />
        <asp:HiddenField ID="hdnscanner" runat="server" />
        <%-- <div id="divFreeSim" runat="server" class="noprint" visible="false">
                <asp:LinkButton ID="btnFreeSim" runat="server" Text="Free Ncell SIM Registration" class="noprint" CssClass="ButtonFreeSim"
                    OnClick="btnFreeSim_Click" />
            </div>--%>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-8">
                    <div id="Printreceiptdetail" runat="server" class="table-responsive">
                        <table class="table">
                            <tr>
                                <td valign="top">
                                    <span style="float: left">
                                        <img src="../../../../ui/images/logo-red.png"/>
                                    </span>
                                    <div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;"></div>
                                </td>
                                <td valign="top">
                                    <table class="innerTableHeader">
                                        <tr>
                                            <td class="label">
                                                <asp:Label ID="sAgentName" runat="server" Style="font-weight: 700" Text="Fast Remit"></asp:Label>
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
                                <td colspan="2" align="center">
                                    <div class="highlightTextLeft">
                                        <asp:Label ID="lblControlNo" runat="server">
                            Control No.</asp:Label>:<asp:Label ID="controlNo" CssClass="fontColor" runat="server"></asp:Label>&nbsp;&nbsp;
                            Tran No:
                                <asp:Label ID="tranNo" CssClass="fontColor" runat="server"></asp:Label>
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
                                                <%--<div align="center">
                                                        In Association with:<br>
                                                        <img src="../../../../Images/GlobalIMEBankLogo.gif" style="height: 30px; width: 200px" />
                                                    </div>--%>
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
                            <%-- <tr>
                <td colspan="2">
                    <span style="background-color: Yellow; color: red; font-weight: bold; font-size: 11px;">
        IME बचत १० लाख योजना ।  यही असोज १ गते देखि कार्तिक ३० गते सम्म IME गर्नुहोस् र हरेक दिन Lucky Draw मार्फत रु ५,०००/- र हरेक हप्ता रु ५०,०००/- को बचत खाता र बम्परमा रु १० लाखको मुद्दती खाता खोल्ने अवसर प्राप्त गर्नुहोस् ।
        </span>
                </td>
            </tr>--%>
                        </table>
                    </div>
                    <hr class="hrRuller" />
                    <div id="multreceipt" runat="server"></div>

                    <div>
                        <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>

                        <div id="commonMsg" runat="server" class="commonMsg">
                        </div>
                        <hr />
                        <div align="center" style="font-weight:bold;">
                            यदि तपाइलाई भुक्तानी लिदा वा दिदा  कुनै समस्या भएमा बेष्ट रेमिट नेपाल प्रा.ली को ग्राहक सेवा केन्द्रको प्रत्यक्ष फोन नं ०१–४२६४७१७ <br />अथवा ०१–४२६५८४०
                            र टोल फ्री नं १६६० – ०१ – ९९९८८ मा सम्पर्क गर्नुहोला । धन्यवाद ।
                            
                        </div>
                        <hr />
                        <input type="button" value="Print" id="btnPrint" onclick="PrintWindow();" class="noPrint" />
                        <input type="button" value="Upload Doc" id="btnUpload" runat="server" onclick=" UploadDocument(); "
                            class="noPrint" style="display:none;" />
                        <input type="button" style="display:none;" value="Scan Doc" id="btnScan" runat="server" onclick=" ScanDocument(); " class="noPrint" />

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

<script type="text/javascript">
    function PrintWindow()
    {
        window.parent.mainFrame.focus();
        window.print();
    }
    function keypressed()
    {; return false; }
    document.onkeydown = keypressed; // End  –>

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
