<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.ThirdPartyTXN.Pay.PayReceipt" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
        <title>IME Payment Receipt</title>
        <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../../js/functions.js" type="text/javascript"></script>
        <style>
             .mainTable
             {
                 width:600px;
                 padding:2px;        
                 font-size:11px; 
                 vertical-align:top;   
             }
             .innerTable
             {
                 width:300px;
                 padding:2px;
                 font-size:11px;   
                 vertical-align:top;  
                          
             }
            .innerTable td
             {
                  text-align: left;
                  width:150px;
                  vertical-align:top;                    
             }
             .innerTableHeader
             {
                 width:300px;
                 padding:2px; 
             }
            .innerTableHeader td
             {
                text-align: right;
             }
            .highlightTextLeft
            {
                font-size:11px;
                xcolor: #999999;
                color:Black;
                font-weight:bold;
                text-transform:uppercase;	
                vertical-align:top;	
                margin-left:10px;
            }
            .highlightTextRight
            {
                font-size:11px;
                xcolor: #999999;
                color:Black;
                font-weight:bold;
                text-transform:uppercase;	
                vertical-align:top;	
                margin-left:10px;
                text-align:right;
            }
            .AmtCss
            {
                text-transform:uppercase;
                font-weight:bold;
                margin-left:5px;
            }
            .hrRuller
            {
                text-align:left;
                width:600px;
                margin-left:5px;
            }
            .fontColor
            {
                color:Red;
                font-weight:bold;
                 font-size:13px;
            }
         </style>      
        <script type="text/javascript">
            function CallBackForFreeSim(url) {
                if (confirm("Go To Free Ncell SIM Registration! Enter customer details and give Free Ncell SIM.")) {
                    PopUpWindow(url, "");
                }
                else
                    return false;
            }
            function FreeNcellSim(url) {
                PopUpWindow(url, "");
            }
            
        </script>   
    </head>

    <body style=" margin-top:0px;">
        <form id="form1" runat="server">
        <div id="divFreeSim" runat="server" class="noprint">
            <asp:LinkButton ID="btnFreeSim" runat="server" visible="false" Text="Free Ncell SIM Registration"  class="noprint" CssClass="ButtonFreeSim"  
                onclick="btnFreeSim_Click"/>
        </div>
        <div id="Printreceiptdetail" runat="server" > 
        <table class="mainTable">
            <tr>
                <td valign="top">  
                    <span style="float:left"> <img src="../../../../Images/IME.png" /> </span>
                    <div id="headMsg" runat="server" style="text-align:right; margin-top:5px; font-size:11px; text-align:left;"></div> 
                </td>                 
                <td  valign="top">
                     <table class="innerTableHeader">
                        <tr>
                            <td class="label">
                                <asp:Label ID="agentName" runat="server" style="font-weight: 700"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">
                                <asp:Label ID = "branchName" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">Address:
                            <asp:Label ID = "agentLocation" runat = "server"></asp:Label>, 
                                <asp:Label ID = "agentCountry" runat = "server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">Contact No: 
                                <asp:Label ID = "agentContact" runat = "server"></asp:Label>
                                        
                            </td>
                        </tr>
                    </table>
                </td>                
            </tr>
            <tr>
                    <td nowrap="nowrap">
                        <div align="left" class="highlightTextLeft">
                            <asp:Label ID="lblControlNo" runat="server">Control No.</asp:Label>:<asp:Label ID="controlNo" runat="server" CssClass="fontColor"></asp:Label>&nbsp;&nbsp;
                            Tran No:<asp:Label ID="tranNo" runat="server" CssClass="fontColor"></asp:Label>
                        </div>
                    </td>
                    <td nowrap="nowrap"><div align="right" class="highlightTextRight">Paid Date: <asp:Label ID = "lblDate" CssClass="fontColor" runat="server"></asp:Label></div> </td>
               
            </tr>
            <tr>
                <td>
                    <table class="innerTable">
                        <tr style="font-weight: bold;">
                            <td class = "label">Sender's Name: </td>
                            <td class = "text">
                                <asp:Label ID = "sName" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">Address: </td>
                            <td class = "text">
                                <asp:Label ID = "sAddress" runat = "server"></asp:Label>&nbsp;<asp:Label ID = "sCountry" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">Contact No: </td>
                            <td class = "text">
                                <asp:Label ID = "sContactNo" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                                                               
                        <tr runat="server" id = "sRel">
                            <td class = "label">Relationship with sender: </td>
                            <td class = "text">
                                <asp:Label ID = "relationship" runat = "server"></asp:Label>  </td>
                        </tr>   
                        <tr runat="server" id = "sDisMemId">
                            <td>Membership Id: </td>
                            <td class = "text">
                                <asp:Label ID = "sMemId" runat = "server"></asp:Label> 
                            </td>
                        </tr>                                                            
                        </table>                  
                </td>
                <td valign="top">                      
                     <table class="innerTable">
                                <tr style="font-weight: bold;">
                                    <td class = "label">Receiver's Name: </td>
                                    <td class = "text">
                                        <asp:Label ID = "rName" runat = "server"></asp:Label> 
                                    </td>
                                </tr>
                                <tr>
                                    <td class = "label">Address:</td>
                                    <td class = "text">
                                        <asp:Label ID = "rAddressCountry" runat = "server"></asp:Label> 
                                    </td>
                                </tr>
                                <tr>
                                    <td class = "label">Contact No.:</td>
                                    <td class = "text">
                                        <asp:Label ID = "rContactNo" runat = "server"></asp:Label> 
                                    </td>
                                </tr>
                                <tr>
                                    <td class = "label"><asp:Label ID = "rIdType" runat = "server" Text="Id Type"></asp:Label>&nbsp;No.:</td>
                                    <td class = "text"><asp:Label ID = "rIdNo" runat = "server"></asp:Label></td>
                                </tr>
                                <tr runat="server" id = "rDisMemId">
                                    <td>Membership Id: </td>
                                    <td class = "text">
                                        <asp:Label ID = "rMemId" runat = "server"></asp:Label> 
                                    </td>
                                </tr>
                                </table>                   
                </td>
            </tr>
            <tr>
                <td>    
                    <table class="innerTable">  
                        <tr>
                            <td class = "label">Amount: </td>
                            <td class = "fontColor" >
                                <asp:Label ID = "payoutAmt" runat = "server"></asp:Label> 
                                    <asp:Label ID = "payoutCurr" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table class="innerTable">
                        <tr>
                            <td class = "label">Mode of Payment: </td>
                            <td class = "text">
                                <asp:Label ID = "modeOfPayment" runat = "server"></asp:Label> 
                            </td>
                        </tr>
                        <tr>
                            <td class = "label">Status:</td>
                            <td class = "fontColor" align="left">
                                PAID</td>
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
                            <td nowrap="nowrap" align="left"><asp:Label ID = "pBankName" runat = "server"></asp:Label></td>
                            <td nowrap="nowrap" align="right">Branch: </td>
                            <td nowrap="nowrap" align="left"><asp:Label ID = "pBankBranchName" runat = "server"></asp:Label> </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" align="right">Account No.: </td>
                            <td nowrap="nowrap" align="left"><asp:Label ID = "accNum" runat = "server"></asp:Label></td>
                        </tr>
                    </table>
                </td>
            </tr>
            </div>
            <tr>
                <td colspan="2"><div class="AmtCss"> Payout amount in words: 
                   <span class="fontColor"><asp:Label ID="payoutAmtFigure" runat="server"></asp:Label></span> </div>
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
                            <td valign="top"><asp:Label ID="userFullName" runat="server"></asp:Label></td>
                            <td align="right">_______________</td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        </div>
        <hr class="hrRuller" />
        <div id="multreceipt" runat="server" ></div>

        <div>
                    <div id="countrySpecificMsg" runat="server" class="countrySpecificMsg"></div>

                    <div id="commonMsg" runat="server" class="commonMsg">
                    *******   THANK YOU FOR SENDING MONEY THROUGH IME   ********<br /><br />
                    If you are satisfied with our service, refer your friend and family and get rewarded
                    </div>
                    <input type = "button" value = "Print" id = "btnPrint" onclick = " PrintWindow(); " class="noprint" />
               
         </div>
        </form>
    </body>
</html>
<script type="text/javascript">

    function keypressed() { ; return false; } document.onkeydown = keypressed; // End  –>

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

