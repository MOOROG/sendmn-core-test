<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Modify.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendApprove.Modify" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <style>
		legend
		{
			color:#FFFFFF;
			background:#FF0000;
		}	
				
		fieldset
		{
			border:1px solid #000000;
		}
			
		td
		{
			color:#000000;
		}
		.watermark
        {
            font-size: 14px;
        }
    </style> 
   <base id="Base1" target = "_self" runat = "server" />

    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />

<script type="text/javascript">
    function ShowHideAddComplainBox() {
        if (GetElement("divComplainAdd").style.display == "none")
            GetElement("divComplainAdd").style.display = "block";
        else
            GetElement("divComplainAdd").style.display = "none";
//        window.parent.resizeIframe();
    }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
    <asp:HiddenField ID="hdnSName" runat="server" />
    <asp:HiddenField ID="hdnRName" runat="server" />
<asp:Panel ID = "pnlDetail" runat = "server">
    <div id="divDetails" style="clear: both; text-align:" class="panels">
        <div style=" text-align:center;">
                <span style="font-size: 1.4em; font-weight: bold;">
                    <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                    <span style="color: red;"><asp:Label ID="lblControlNo" runat="server"></asp:Label></span>
                </span>
                <span style="font-size: 1.4em; font-weight: bold;">
                    Tran No : 
                    <span style="color: red;"><asp:Label ID="lblTranNo" runat="server"></asp:Label></span>
                </span>

                 <span style="width:100px;"></span>

                   <span style="font-size: 1.4em; font-weight: bold;"> 
                     Transaction Status: 
                     <span style="color: red;"> <asp:Label ID = "lblStatus" runat = "server"></asp:Label> </span>

                     <asp:Label ID = "tranStatus" runat = "server" style=" display:none;"></asp:Label>
                   </span>
        </div>
        <div id="lockAudit" style=" text-align:center; background-color:red; color:white; font-size: 11px; font-weight: bold;" runat="server" Visible="false">
        </div>
        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td class="tableForm" colspan="2">
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
                <td valign="top" class="tableForm" style="width: 50%;">
                    <fieldset>
                        <legend>Sender</legend>
                        <table style="width: 100%">
                            <tr style="background-color: #FDF79D;">
                                <td class = "label">Name: </td>
                                <td class = "text">                                    
                                    <asp:Label ID = "sName" runat = "server"></asp:Label>
                                </td>                               
                            </tr>
                            <tr>
                                <td class = "label">Address: </td>
                                <td class = "text">
                                    <asp:Label ID = "sAddress" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Country: </td>
                                <td class = "text">
                                    <asp:Label ID = "sCountry" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">City: </td>
                                <td class = "text">
                                    <asp:Label ID = "sCity" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Mobile No: </td>
                                <td class = "text">
                                    <asp:Label ID = "sContactNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Tel. No: </td>
                                <td class = "text">
                                    <asp:Label ID = "sTelNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label"  nowrap="nowrap"><asp:Label ID = "sIdType" runat = "server"></asp:Label>: </td>
                                <td class = "text">
                                    <asp:Label ID = "sIdNo" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>ID Validity Date: </td>
                                <td class = "text">
                                     <asp:Label ID = "sValidityDate" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Email: </td>
                                <td class = "text">
                                    <asp:Label ID = "sEmail" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Membership ID: </td>
                                <td class = "text">
                                    <asp:Label ID = "sCustomerId" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Sender Native Country:</td>
                                <td class="text">
                                    <asp:Label ID="sNativeCountry" runat="server"></asp:Label>
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
                                
                                <td class = "text">
                                    <asp:Label ID = "rName" runat = "server"></asp:Label>

                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Address: </td>
                                <td class = "text">
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
                                <td class = "label">City: </td>
                                <td class = "text">
                                    <asp:Label ID = "rCity" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Mobile No: </td>
                                <td class = "text">
                                    <asp:Label ID = "rContactNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Tel. No: </td>
                                <td class = "text">
                                    <asp:Label ID = "rTelNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td class = "label" style="white-space:nowrap;">
                                    <asp:Label ID = "rIdType" runat = "server"></asp:Label>: 
                                </td>
                                <td class = "text">
                                    <asp:Label ID = "rIdNo" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr>
                                <td>ID Validity Date: </td>
                                <td class = "text">
                                     <asp:Label ID = "rValidityDate" runat = "server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Relationship with Sender: </td>
                                <td class = "text">
                                    <asp:Label ID = "relationship" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td valign="top" class="tableForm">
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
                                <td class = "label">Address:</td>
                                <td class = "text">                                    
                                    <asp:Label ID = "sAgentAddress" runat = "server"></asp:Label>
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
                <td valign="top" class="tableForm">
                    <fieldset>
                        <legend>Receiving Agent</legend>
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
                                <td class = "label">Address:</td>
                                <td class = "text">                                    
                                    <asp:Label ID = "pAgentAddress" runat = "server"></asp:Label>
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
                <td class = "tableForm" valign="top">
                    <fieldset>
                        <legend>Payout Amount </legend>

                        <table class="rateTable" cellspacing="0" cellpadding="2" style="width: 400px;">
                            <tr>
                                <td class = "label">Collection Amount: </td>

                                <td class = "text-amount">
                                    <asp:Label ID = "total" runat = "server"></asp:Label> 
                                    <asp:Label ID = "totalCurr" runat="server"></asp:Label>
                                </td>

                            </tr>
                            <tr>
                                <td class = "label">Service Charge: </td>
                                <td class = "text-amount">
                                    <asp:Label ID = "serviceCharge" runat = "server"></asp:Label> 
                                    <asp:Label ID="scCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Send Agent Commission: </td>
                                <td class = "text-amount">
                                    <asp:Label ID = "sAgentComm" runat = "server"></asp:Label> 
                                    <asp:Label ID="sAgentCommCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <asp:Panel ID="payAgentComm" runat="server" Visible="false">
                            <tr>
                                <td class = "label">Pay Agent Comm.: </td>
                                <td class = "text-amount">
                                    <asp:Label ID = "pAgentComm" runat = "server"></asp:Label> 
                                    <asp:Label ID="pAgentCommCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            </asp:Panel>
                           
                           
                            <tr>
                                <td class="label">Customer Rate</td>
                                <td class="text-amount">
                                    <asp:Label ID="custRate" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Settlement Rate</td>
                                <td class="text-amount">
                                    <asp:Label ID="settRate" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Sent Amount: </td>
                                
                                <td class = "text-amount">
                                    <asp:Label ID = "transferAmount" runat = "server"></asp:Label> 
                                    <asp:Label ID="tAmtCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class = "label">Payout Amount: </td>
                                <td class = "text-amount DisFond">
                                    <asp:Label ID = "payoutAmt" runat = "server"></asp:Label> 
                                    <asp:Label ID = "pAmtCurr" runat="server" ></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                <td valign="top" class="tableForm">
                    <fieldset>
                        <legend>Transaction Information </legend>
                        <table style="width: 100%">
                           
                           
                            <tr>
                                <td class = "label">Mode of Payment: </td>
                                <td class = "text">
                                    <asp:Label ID = "modeOfPayment" runat = "server"></asp:Label> 
                                </td>
                            </tr>

                            <tr>
                                <td class = "DisFond">Txn. Status:</td>
                                <td>
                                    <asp:Label ID = "payStatus" runat = "server"></asp:Label>
                                    [<asp:Label ID = "lbltrnsubStatus" runat = "server"></asp:Label>]
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
                                <td class = "label">Bank: </td>
                                <td class = "text">
                                    <asp:Label ID = "bankName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            <tr id="trBranch">
                                <td class = "label">Branch: </td>
                                <td class = "text">
                                    <asp:Label ID = "branchName" runat = "server"></asp:Label> 
                                </td>
                            </tr>
                            </div>
                            <tr>
                                <td class="label">Source of Fund: </td>
                                <td class="text">
                                    <asp:Label ID="sourceOfFund" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label" nowrap="nowrap">Reason For Remittance: </td>
                                <td class="text">
                                    <asp:Label ID="reasonOfRemit" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">Transaction Message: </td>
                                <td class="text">
                                    <asp:Label ID="payoutMsg" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <fieldset  >
				     	<legend>Deposit Information</legend>
                    	<div id="Ddetail" runat="server" style="width:500px">     </div>
                        </fieldset>
                    </td>
                <td></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:HiddenField ID="hddTranId" runat="server" />
                    <asp:HiddenField ID="hddPayTokenId" runat="server" />
                    <asp:HiddenField ID="pAgent" runat="server" />
                </td>
            </tr>
        </table>
    </div>
</asp:Panel>

<asp:UpdatePanel ID="upnl1" runat="server">
 <ContentTemplate>
    <div id="div1" style="clear: both;" class="panels">
    <table>        
        <asp:Panel ID = "pnlLog" runat = "server">
        <tr>
            <td>
             <fieldset >
				     	<legend>Complain/Trouble Ticket</legend>
                    <div id="rptLog" runat="server"></div>
            </fieldset>
            </td>
        </tr>
        </asp:Panel>
         <tr>
            <td>  
              <div id="lblAddComp" runat="server">
                 <a href="#" onclick="ShowHideAddComplainBox();" style="margin-left: 10px; cursor: pointer;">Add New Complain</a>
                 <br>
             </div>
        </tr>

        <asp:Panel ID = "pnlComment" runat = "server">
        <tr id="divComplainAdd" style="display: none;">
            <td>
             <div class="headers">Transaction Complain (Trouble Ticket)</div>

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
   
</ContentTemplate>
</asp:UpdatePanel>

    <asp:Panel ID = "pnlOFAC" runat = "server">
        <div class="headers">OFAC </div>
        <div id="div3" style="clear: both;" class="panels">
            <div id="displayOFAC" runat="server" style=" height:250px; overflow:auto;"></div>
        </div>
    </asp:Panel>

    <asp:Panel ID = "pnlCompliance" runat = "server">
        <div class="headers">Compliance </div>
        <div id="div4" style="clear: both;" class="panels">
            <div id="displayCompliance" style=" height:150px; overflow:auto;" runat="server"></div>
        </div>
    </asp:Panel>

               <asp:Button ID="btnReloadDetail" runat="server" 
                onclick="btnReloadDetail_Click" style="display: none;" />
    </form>
</body>
</html>
<script language = "javascript">
    function EditData(label, fieldName, oldValue, tranId) {
        var url = "ModifyField.aspx?label=" + label +
                                "&fieldName=" + fieldName +
                                "&oldValue=" + oldValue +
                                "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnReloadDetail.ClientID %>").click();
        }
        return false;
    }    
    </script>