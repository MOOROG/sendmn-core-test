<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UcTranEduPay.ascx.cs" Inherits="Swift.web.Remit.UserControl.UcTranEduPay" %>
 <head>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
</head>
<asp:Panel ID = "pnlDetail" runat = "server">
    <div id="divDetails" style="clear: both; text-align:" class="panels">
        <div style=" text-align:center;">
                <span style="font-size: 1.2em; font-weight: bold;">
                    <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                    <span style="color: red;"><asp:Label ID="lblControlNo" runat="server"></asp:Label></span>
                </span>
                <span style="font-size: 1.2em; font-weight: bold;">
                    Tran No : 
                    <span style="color: red;"><asp:Label ID="lblTranNo" runat="server"></asp:Label></span>
                </span>

                 <span style="width:100px;"></span>

                   <span style="font-size: 1.2em; font-weight: bold;"> 
                     Transaction Status: 
                     <span style="color: red;"> <asp:Label ID = "tranStatus" runat = "server"></asp:Label> </span>
                   </span>
        </div>
        <div id="lockAudit" style=" text-align:center; background-color:blue; color:white; font-size: 11px; font-weight: bold;" runat="server" Visible="false">
        </div>
        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td class="uc" colspan="2">
                    <fieldset>
                        <table  style="width: 100%">
                            <tr>
                                <td>
                                    <table id="tblCreatedLog" runat="server" Visible="false">
                                        <tr>
                                            <td>Created By:</td>
                                            <td>
                                                <asp:Label ID="createdBy" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Created Date:</td>
                                            <td>
                                                <asp:Label ID="createdDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    <table id="tblApprovedLog" runat="server" Visible="false">
                                        <tr>
                                            <td>Approved By:</td>
                                            <td>
                                                <asp:Label ID="approvedBy" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Approved Date:</td>
                                            <td>
                                                <asp:Label ID="approvedDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    <table id="tblPaidLog" runat="server" Visible="false">
                                        <tr>
                                            <td>Paid By:</td>
                                            <td>
                                                <asp:Label ID="paidBy" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Paid Date:</td>
                                            <td>
                                                <asp:Label ID="paidDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>   
                                </td>
                                <td>
                                    <table id="tblCancelRequestedLog" runat="server" Visible="false">
                                        <tr>
                                            <td>Cancel Requested By:</td>
                                            <td>
                                                <asp:Label ID="cancelRequestedBy" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Cancel Requested Date:</td>
                                            <td>
                                                <asp:Label ID="cancelRequestedDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>   
                                </td>
                                <td>
                                    <table id="tblCancelApprovedLog" runat="server" Visible="false">
                                        <tr>
                                            <td>Cancel Approved By:</td>
                                            <td>
                                                <asp:Label ID="cancelApprovedBy" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Cancel Approved Date:</td>
                                            <td>
                                                <asp:Label ID="cancelApprovedDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>   
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td valign="top" class="uc" style="width: 50%;">
                    <fieldset>
                        <legend>Sender</legend>
                        <table style="width: 100%">
                            <tr>
                                <th class = "label">Name: </th>
                                <th class = "text" colspan="3">                                    
                                    <asp:Label ID = "sName" runat = "server"></asp:Label>
                                </th>                               
                            </tr>
                            <tr>
                                <td class = "label">Address: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "sAddress" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Country: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "sCountry" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Contact No: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "sContactNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Id Type: </td>
                                <td class = "text" style="width: 150px">
                                    <asp:Label ID = "sIdType" runat = "server"></asp:Label> 
                                </td>
                                <td style="width: 60px;">Id No: </td>
                                <td class = "text">
                                    <asp:Label ID = "sIdNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Email: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "sEmail" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr runat="server" id = "sCId">
                                <td class = "label">Customer ID: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "sCustomerId" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr runat="server" id = "sDisMemId">
                                <td>Membership Id: </td>
                                <td class = "text">
                                    <asp:Label ID = "sMemId" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                <td valign="top" class="tableForm" style="width: 50%">
                    <fieldset>
                        <legend>Receiver</legend>
                        <table style="width: 100%">
                            <tr style="background-color: #F9CCCC;">
                                <td class = "label">Name: </td>          
                                
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "rName" runat = "server"></asp:Label>

                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Address: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "rAddress" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Country: </td>
                                <td class = "text">
                                    <asp:Label ID = "rCountry" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Contact No: </td>
                                <td class = "text" colspan="3">
                                    <asp:Label ID = "rContactNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Student Name: </td>
                                <td class = "text" style="width: 150px">
                                    <asp:Label ID = "stdName" runat = "server"></asp:Label> 
                                </td>
                                <td style="width: 60px;">Class/Level: </td>
                                <td class = "text">
                                    <asp:Label ID = "stdLevel" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Reg. No./Roll No.: </td>
                                <td class = "text">
                                    <asp:Label ID = "stdRollRegNo" runat = "server"></asp:Label> 
                                </td>
                                <td style="width: 60px;">Fee Type: </td>
                                <td class = "text">
                                    <asp:Label ID = "feeTypeId" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Semester/Year: </td>
                                <td class = "text">
                                    <asp:Label ID = "stdSemYr" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td valign="top" class="uc">
                    <fieldset>
                        <legend>Sending Agent</legend>
                        <table style="width: 100%">
                            <tr>
                                <td class = "label">Agent: </td>
                                <td class = "text">
                                    <asp:Label ID = "sAgentName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Branch: </td>
                                <td class="text">
                                    <asp:Label ID="sBranchName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">S. Agent Location: </td>
                                <td class = "text">
                                    <asp:Label ID = "sAgentLocation" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">District:</td>
                                <td class = "text">
                                    <asp:Label ID = "sAgentDistrict" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">City: </td>
                                <td class = "text">
                                    <asp:Label ID = "sAgentCity" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Country: </td>
                                <td class = "text">
                                    <asp:Label ID = "sAgentCountry" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                <td valign="top" class="uc">
                    <fieldset>
                        <legend>Payout Agent</legend>
                        <table style="width: 100%">
                            <tr>
                                <td class = "label">Agent: </td>
                                <td class = "text">
                                    <asp:Label ID = "pAgentName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Branch: </td>
                                <td class = "text">
                                    <asp:Label ID = "pBranchName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Payout Location: </td>
                                <td class = "text">
                                    <asp:Label ID = "pAgentLocation" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">District:</td>
                                <td class = "text">
                                    <asp:Label ID = "pAgentDistrict" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">City: </td>
                                <td class = "text">
                                    <asp:Label ID = "pAgentCity" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Country: </td>
                                <td class = "text">
                                    <asp:Label ID = "pAgentCountry" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr class="hightLightTranStatus" runat="server" id="showHideTranStatus" visible="false">
                <td colspan="2">
                    <div id="highLightTranStatus" runat="server" class="hightLightTranStatus"></div>
                </td>
            </tr>
            <tr>
                <td class = "uc" valign="top">
                    <fieldset>
                        <legend>Transaction Amount </legend>

                        <table class="rateTable" cellspacing="0" cellpadding="2" style="width: 400px;">
                            <tr>
                                <td class = "label">Collection Amount: </td>
                                <td class = "amt">
                                    <asp:Label ID = "total" runat = "server"></asp:Label> 
                                    <asp:Label ID = "totalCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Service Charge: </td>
                                <td class = "amt">
                                    <asp:Label ID = "serviceCharge" runat = "server"></asp:Label> 
                                    <asp:Label ID="scCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Send Agent Commission: </td>
                                <td class = "amt">
                                    <asp:Label ID = "sAgentComm" runat = "server"></asp:Label> 
                                    <asp:Label ID="sAgentCommCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <asp:Panel ID="payAgentComm" runat="server" Visible="false">
                            <tr>
                                <td class = "label">Pay Agent Comm.: </td>
                                <td class = "amt">
                                    <asp:Label ID = "pAgentComm" runat = "server"></asp:Label> 
                                    <asp:Label ID="pAgentCommCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            </asp:Panel>
                            <asp:Panel ID="pnlExRate" runat="server">
                            <tr>
                                <td class="label">Handling</td>
                                <td class="amt">
                                    <asp:Label ID="handling" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Exchange Rate</td>
                                <td class="amt">
                                    <asp:Label ID="exRate" runat="server"></asp:Label>
                                </td>
                            </tr>
                            </asp:Panel>
                            <tr>
                                <td class = "label">Sent Amount: </td>
                                
                                <td class = "amt">
                                    <asp:Label ID = "transferAmount" runat = "server"></asp:Label> 
                                    <asp:Label ID="tAmtCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Payout Amount: </td>
                                <td class = "highlightText">
                                    <asp:Label ID = "payoutAmt" runat = "server"></asp:Label> 
                                    <asp:Label ID = "pAmtCurr" runat="server" ></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                <td valign="top" class="uc">
                    <fieldset>
                        <legend>Other </legend>
                        <table style="width: 100%">
                            <tr>
                                <td class = "label">Mode of Payment: </td>
                                <td class = "text">
                                    <asp:Label ID = "modeOfPayment" runat = "server"></asp:Label> 
                                </td>
                            </tr>

                            <tr>
                                <td class = "DisFond">Pay Status:</td>
                                <td class = "DisFond">
                                    <asp:Label ID = "payStatus" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <div id="pnlShowBankDetail" runat="server" visible="false">
                            <tr id="trAc">
                                <td class = "label">Account Number: </td>
                                <td class = "text">
                                    <asp:Label ID = "accountNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr id="trBank">
                                <td class = "label">Bank Name: </td>
                                <td class = "text">
                                    <asp:Label ID = "bankName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr id="trBranch">
                                <td class = "label">Branch Name: </td>
                                <td class = "text">
                                    <asp:Label ID = "branchName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            </div>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr id="trpMsg" runat="server">
                <td colspan="2">
                    <fieldset>
                        <table class="panels">
                            <tr>
                                <td nowrap="nowrap">
                                    <b>Payout Message</b>:&nbsp;<asp:Label ID="payoutMsg" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:HiddenField ID="hddTranId" runat="server" />
                    <asp:HiddenField ID="hddPayTokenId" runat="server" />
                </td>
            </tr>
        </table>
    </div>
</asp:Panel>

 <asp:UpdatePanel ID="upnl1" runat="server">
 <ContentTemplate>

<asp:Panel ID = "pnlLog" runat = "server">
    <div class="headers">Transaction Complain (Trouble Ticket)</div>
    <div id="div1" style="clear: both;" class="panels">
    <table>
        <tr>
            <td><div id="rptLog" runat="server"></div></td>
        </tr>
        <asp:Panel ID = "pnlComment" runat = "server">
        <tr>
            <td>
                <asp:TextBox runat = "server" ID = "comments" TextMode = "MultiLine" 
                Height="50px" Width="750px"></asp:TextBox>
                <br>
                <br>
                <asp:Button ID="btnAdd" runat="server" CssClass="button" onclick="btnAdd_Click" 
                Text="Add New Complain" />
            
            </td>
        </tr>
        </asp:Panel>
    </table>
        
    </div>
</asp:Panel>
</ContentTemplate>
</asp:UpdatePanel>

<asp:Panel ID = "pnlOFAC" runat = "server">
    <div class="headers">OFAC </div>
    <div id="div3" style="clear: both;" class="panels">
    <div id="displayOFAC" runat="server" style=" height:250px; overflow:auto;"></div>
      <br />
        <div><b>OFAC Approved Remarks</b></div>
 
        <asp:TextBox runat = "server" ID = "remarksOFAC" TextMode = "MultiLine" 
            Height="50px" Width="750px"></asp:TextBox>
            <br>
            <br>
        </br>
    </div>
</asp:Panel>
<asp:Panel ID = "pnlCompliance" runat = "server">
    <div class="headers">Compliance </div>
    <div id="div4" style="clear: both;" class="panels">
    <div id="displayCompliance" style=" height:150px; overflow:auto;" runat="server"></div>
    <br />
    <div><b>Compliance Approved Remarks</b></div>
 
        <asp:TextBox runat = "server" ID = "remarksCompliance" TextMode = "MultiLine" 
            Height="50px" Width="750px"></asp:TextBox>
    </div>  

</asp:Panel>
<asp:Panel ID = "pnlCashLimitHold" runat = "server">
    <div class="headers">Cash Limit Hold </div>
    <div id="div44" style="clear: both;" class="panels">
    <div id="displayCashLimitHold" style=" height:150px; overflow:auto;" runat="server"></div>
    <br />
    <div><b>Cash Limit Approved Remarks</b></div>
 
        <asp:TextBox runat = "server" ID = "remarksCashLimitHold" TextMode = "MultiLine" 
            Height="50px" Width="750px"></asp:TextBox>
    </div>  

</asp:Panel>
<asp:Panel ID = "pnlReleaseBtn" runat = "server">
    <div id="div5" style="clear: both;" class="panels">
        <asp:Button ID="btnApproveCompliance" runat="server" CssClass="button" onclick="btnApproveCompliance_Click" 
            Text="Release Transaction" />

    </div>
</asp:Panel>
