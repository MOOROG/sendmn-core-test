<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayReceipt.aspx.cs" Inherits="Swift.web.AgentPanel.Pay.PayTransaction.PayReceipt" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>BRN Payment Receipt</title>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
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
    <script type="text/javascript" language="javascript">

              $(document).ready(function () {
                  CheckAuth();
              });

              function PrintWindow() {
                  $(".mainTable").show();
                  $(".print_hide").hide();
                  window.print();
              }

              function LoadCashToCard() {
                  if (confirm("Are you sure to Load Cash To Card?")) {
                      var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
                      var controlNo = GetElement("<%=controlNo.ClientID %>").innerHTML;
                      var url = urlRoot + "/AgentPanel/Pay/PayTransaction/LoadCash/Manage.aspx?controlNo=" + controlNo;
                      window.location.replace(url);
                  }
              }
              function UploadDocument() {
                  var agentId = GetValue("<% = hdnAgentId.ClientID %>");
                  var type = document.getElementById("hdnTxnType").value;
                  if (type == "I") {
                      txnType = "pi";
                  } else
                      txnType = "pd";

                  var tranId = GetValue("<% = hdnTranId.ClientID %>");
                  var url = "../../../Remit/Administration/AgentCustomerSetup/UploadVoucher/BrowseDoc.aspx?id=" + tranId + '&agentId=' + agentId + '&txnType=' + txnType;
                  OpenInNewWindow(url);
                  return true;
              }
              function DoUpload(docDesc) {
                  var user = "<%=GetStatic.GetUser() %>";
                  var branch = "<%=GetStatic.GetBranch() %>";
                  var type = document.getElementById("hdnTxnType").value;
                  if (type == "I") {
                      txnType = "pi";
                  } else
                      txnType = "pd";

                  parent.UploadDocMain(user, txnType, branch, docDesc);
              }
              function ScanDocument() {
                  var icn = GetValue("<% = hdnIcn.ClientID %>");
                  var id = GetValue("<% = hdnTranId.ClientID %>");
                  parent.LoadScanner('0');
                  parent.ScanDocument(id, icn);
              }
              function CheckForDocument(Icn, Id) {
                  var agentId = document.getElementById("hdnAgentId").value;
                  var type = document.getElementById("hdnTxnType").value;

                  if (type == "I") {
                      vouType = "pi";
                  } else
                      vouType = "pd";

                  var dataToSend = { MethodName: 'docCheck', agentId: agentId, icn: Icn, tranId: Id, vouType: vouType };
                  var options =
                        {
                            url: '<%=ResolveUrl("PayReceipt.aspx") %>',
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                //var data = jQuery.parseJSON(response);
                                var data = response;
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
              function CheckAuth() {

                  var dataToSend = { MethodName: 'CheckAuth' };
                  var options =
                        {
                            url: '<%=ResolveUrl("PayReceipt.aspx") %>',
                            data: dataToSend,
                            dataType: 'JSON',

                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode = "0") {
                                    if (data[0].upload === "true") {
                                        document.getElementById('btnUpload').style.display = "";
                                    }

                                    if (data[0].scan === "true") {
                                        document.getElementById('btnScan').style.display = "";
                                    }
                                }
                                else {
                                    document.getElementById('btnUpload').style.display = "none";
                                    document.getElementById('btnScan').style.display = "none";
                                }
                            }
                        };
                  $.ajax(options);
                  return true;
              }
    </script>
</head>

<body style="margin-top: 100px; margin-left:15px;">
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnAgentId" runat="server" />
        <asp:HiddenField ID="hdnTranId" runat="server" />
        <asp:HiddenField ID="hdnTxnType" runat="server" />
        <asp:HiddenField ID="hdnIcn" runat="server" />
        <asp:HiddenField ID="hdnscanner" runat="server" />
        <div id="Printreceiptdetail" runat="server">
            <table class="mainTable">
                <tr>
                    <td valign="top">
                        <span style="float: left">
                            <img src="../../../ui/images/receipt_logo.png" />
                        </span>
                        <div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;"></div>
                    </td>
                    <td valign="top">
                        <table class="innerTableHeader">
                            <tr>
                                <td>
                                    <asp:Label ID="agentName" runat="server" Style="font-weight: 700"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="branchName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address:
                            <asp:Label ID="agentLocation" runat="server"></asp:Label>,
                                <asp:Label ID="agentCountry" runat="server"></asp:Label>
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
                    <td nowrap="nowrap">
                        <div align="left" class="highlightTextLeft">
                            <asp:Label ID="lblControlNo" runat="server">PIN No.</asp:Label>:<asp:Label ID="controlNo" runat="server" CssClass="fontColor"></asp:Label>&nbsp;&nbsp;
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
                            <tr style="font-weight: bold;">
                                <td>Sender's Name: </td>
                                <td class="text">
                                    <asp:Label ID="sName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Address: </td>
                                <td class="text">
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
                                <td>Membership Id:
                                </td>
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
                        </table>
                    </td>
                    <td>
                        <table class="innerTable">
                            <tr>
                                <td>Mode of Payment:
                                </td>
                                <td class="text">
                                    <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr id="trChequeNo" runat="server">
                                <td>Cheque No.:
                                </td>
                                <td>
                                    <asp:Label ID="chequeNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Status:
                                </td>
                                <td class="fontColor" align="left">PAID
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
                </div>
                <div id="divCompliance" runat="server" visible="false">
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
                        <table class="mainTable" cellpadding="5px" cellpadding="5px">
                            <tr>
                                <td valign="bottom" nowrap="nowrap">Authorized User</td>
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
                <%--             <tr>
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

        <div class="print_hide">
            <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>

            <div id="commonMsg" runat="server" class="commonMsg">
            </div>
            <%--<hr class="hrRuller" />
            <div style="font-weight:bold;">
                यदि तपाइलाई भुक्तानी लिदा वा दिदा  कुनै समस्या भएमा बेष्ट रेमिट नेपाल प्रा.ली को ग्राहक सेवा केन्द्रको प्रत्यक्ष
                <br />
                 फोन नं ०१–४२६४७१७ अथवा ०१–४२६५८४० र टोल फ्री नं १६६० – ०१ – ९९९८८ मा सम्पर्क गर्नुहोला ।
                धन्यवाद ।
            </div>--%>
            <hr class="hrRuller" />
            <button value="" id="btnPrint" onclick=" PrintWindow(); " class="btn btn-primary btn-sm">
                <i class="fa fa-print"></i>
            </button>
            <input type="button" value="Upload Doc" id="btnUpload" runat="server" onclick=" UploadDocument(); " class="btn btn-primary btn-sm" />
        </div>
    </form>
</body>
</html>