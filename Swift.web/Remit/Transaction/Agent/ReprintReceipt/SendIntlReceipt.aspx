<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendIntlReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ReprintReceipt.SendIntlReceipt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title> Send Receipt</title>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <style>
        .mainTable {
            width: 600px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }

        .label {
            color: black;
            border: none !important;
            
        }

        .innerTable {
            width: 300px;
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
            height:60px;
        }

            .innerTable td {
                text-align: left;
                width: 150px;
                vertical-align: top;
                margin-bottom:5px !important;
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
        function ManageMessage(mes) {
            alert(mes);
            window.returnValue = '0|' + mes;
            if (isChrome) {
                window.opener.PostMessageToParent(window.returnValue);
            }
            window.close();
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <div class="page-wrapper" style="padding-top:20px !important">
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
                                    <table style="font-size:11px;">
                                        <tr>
                                            <td >
                                                <asp:Label ID="sAgentName" runat="server" Style="font-weight: 700"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:Label ID="sBranchName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >Address:
                            <asp:Label ID="sAgentLocation" runat="server"></asp:Label>, 
                            <asp:Label ID="sAgentCountry" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >Contact No: 
                                <asp:Label ID="sContact" runat="server"></asp:Label>

                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="left" class="highlightTextLeft">
                                        <asp:Label ID="lblControlNo" runat="server">Control No.</asp:Label> : <asp:Label ID="controlNo" style="background-color:red !important" runat="server"></asp:Label>
                                    </div>
                                </td>
                                <td>
                                    <div align="right" class="highlightTextRight">
                                        Send Date:
                            <asp:Label ID="lblDate" runat="server"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="innerTable">
                                        <tr style="font-weight: bold;">
                                            <td class="label">Sender's Name: </td>
                                            <td class="text">
                                                <asp:Label ID="sName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Address: </td>
                                            <td class="text">
                                                <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                &nbsp; ,   
                                    <asp:Label ID="sCountry" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Contact No: </td>
                                            <td class="text">
                                                <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Id Type: </td>
                                            <td class="text">
                                                <asp:Label ID="sIdType" runat="server"></asp:Label>
                                                &nbsp; &nbsp; <b>No</b>:
                                    <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>

                                    </table>
                                </td>
                                <td>
                                    <table class="innerTable">
                                        <tr style="font-weight: bold;">
                                            <td class="label">Receiver's Name: </td>
                                            <td class="text">
                                                <asp:Label ID="rName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr style="display:none">
                                            <td class="label">Address: </td>
                                            <td class="text">
                                                <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                &nbsp;,
                                    <asp:Label ID="rCountry" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Contact No: </td>
                                            <td class="text">
                                                <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Id Type: </td>
                                            <td class="text">
                                                <asp:Label ID="rIdType" runat="server"></asp:Label>
                                                &nbsp; &nbsp; No:<asp:Label ID="rIdNo" runat="server"></asp:Label>

                                                &nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="label">Relationship with sender: </td>
                                            <td class="text">
                                                <asp:Label ID="relationship" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>

                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="innerTable">
                                        <tr>
                                            <td class="label">Total Collection Amount: </td>

                                            <td class="text-amount">
                                                <asp:Label ID="total" runat="server"></asp:Label>
                                                <asp:Label ID="collCurr" runat="server"></asp:Label>

                                            </td>

                                        </tr>
                                        <tr>
                                            <td class="label">Service Charge: </td>
                                            <td class="text-amount">
                                                <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                                <asp:Label ID="scCurr" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Handling:</td>
                                            <td class="text-amount">
                                                <asp:Label ID="handling" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Exchange Rate:</td>
                                            <td class="text-amount">
                                                <asp:Label ID="exRate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Total Sent Amount: </td>
                                            <td class="text-amount">
                                                <asp:Label ID="transferAmount" runat="server"></asp:Label>
                                                <asp:Label ID="transCurr" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Payout Amount: </td>
                                            <td class="text-amount redHighlight">
                                                <asp:Label ID="payoutAmt" runat="server"></asp:Label>
                                                <asp:Label ID="PCurr" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    <table class="innerTable">
                                        <tr>
                                            <td class="label">Payout Location: </td>
                                            <td class="text">
                                                <asp:Label ID="pAgentLocation" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">District:</td>
                                            <td class="text">
                                                <asp:Label ID="pAgentDistrict" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">Country: </td>

                                            <td class="text">
                                                <asp:Label ID="pAgentCountry" runat="server"></asp:Label>
                                            </td>

                                        </tr>
                                        <tr>
                                            <td class="label">Mode of Payment: </td>
                                            <td class="text">
                                                <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
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
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
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
                                                &nbsp;
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
                    <br /><br /><br /><br /><br />
                    
                    <div id="multreceipt" runat="server"></div>
                    <div>
                        <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>
                        <div id="commonMsg" runat="server" class="commonMsg">
                        </div>
                        <input type="button" value="Print" id="btnPrint" onclick=" PrintWindow(); " class="noPrint btn btn-primary m-t-25" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>


<script type="text/javascript">
    function PrintWindow() {
        //window.parent.mainFrame.focus();
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
