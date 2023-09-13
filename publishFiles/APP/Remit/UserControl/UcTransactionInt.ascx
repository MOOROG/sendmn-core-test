<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UcTransactionInt.ascx.cs" Inherits="Swift.web.Remit.UserControl.UcTransactionInt" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<head>
    <title></title>
    <style>
        legend {
            font-weight: bold;
            font-family: Verdana, Arial;
            font-size: 12px;
            padding: 1px;
            margin-left: 2em;
            color: black;
            border-radius: 5px;
        }

        fieldset {
            border: 1px solid #A8A8A8;
        }

        td {
            color: #000000;
        }

        .watermark {
            font-size: 14px;
        }

        .hightLightTranStatus {
            font-size: 14px;
            padding: 2px;
            background-color: Red;
            color: Yellow;
            font-size: 20px;
            text-align: center;
            font-weight: bold;
        }

        .HeighlightTex {
            font-size: 1.4em;
            font-weight: bold;
            color: red;
        }

        .text {
            font-weight: 600;
            font-size: 13px;
        }
    </style>

    <script type="text/javascript">
        function ShowHideAddComplainBox() {
            if (GetElement("divComplainAdd").style.display == "none")
                GetElement("divComplainAdd").style.display = "block";
            else
                GetElement("divComplainAdd").style.display = "none";
            window.parent.resizeIframe();
        }
    </script>
</head>

<div style="">
    <asp:Panel ID="pnlDetail" runat="server">
        <div id="divDetails" class="panels">
            <div class="">
                <table class="table table-bordered">
                    <tr>
                        <td>
                            <div align="left">
                                <span class="controlNoDis">
                                    <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                    <asp:Label ID="lblControlNo" runat="server" CssClass="controlNoDis text" Style="font-size: 16px"></asp:Label>
                                </span>
                            </div>
                        </td>
                        <td>
                            <span class="tranNoDis" style="text-align: right;">Tran No :
                    <asp:Label ID="lblTranNo" runat="server" CssClass="HeighlightTex"></asp:Label></span>
                            <span style="width: 100px;"></span>
                        </td>
                        <td>
                            <div align="right">
                                <span class="tranStatusDis">Transaction Status:
                    <asp:Label ID="lblStatus" runat="server" CssClass="tranStatusDis text" Style="font-size: 16px"></asp:Label>
                                </span>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div id="lockAudit" style="text-align: center; background-color: red; color: white; font-size: 11px; font-weight: bold;" runat="server" visible="false">
            </div>
            <asp:Label ID="lblTranRefId" runat="server" CssClass="tranNoDis" Visible="false"></asp:Label>
            <asp:Label ID="tranStatus" runat="server" Style="display: none;"></asp:Label>
            <table class="table">
                <tr>
                    <td class="tableForm" colspan="2">
                        <div class="panel  panel-default">
                            <div class="panel-body">
                                <table style="width: 100%; background-color: #F5F5F5;" class="table">
                                    <tr>
                                        <td>
                                            <table id="tblCreatedLog" runat="server" visible="false" class="table  table-bordered">
                                                <tr>
                                                    <td>Created By:</td>
                                                    <td>
                                                        <asp:Label ID="createdBy" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Created Date:</td>
                                                    <td>
                                                        <asp:Label ID="createdDate" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table id="tblApprovedLog" runat="server" visible="false" class="table  table-bordered">
                                                <tr>
                                                    <td>Approved By:</td>
                                                    <td>
                                                        <asp:Label ID="approvedBy" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Approved Date:</td>
                                                    <td>
                                                        <asp:Label ID="approvedDate" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table id="tblPaidLog" runat="server" visible="false" class="table  table-bordered">
                                                <tr>
                                                    <td>Paid By:</td>
                                                    <td>
                                                        <asp:Label ID="paidBy" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Paid Date:</td>
                                                    <td>
                                                        <asp:Label ID="paidDate" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table id="tblCancelRequestedLog" runat="server" visible="false" class="table  table-bordered">
                                                <tr>
                                                    <td>Cancel Requested By:</td>
                                                    <td>
                                                        <asp:Label ID="cancelRequestedBy" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Cancel Requested Date:</td>
                                                    <td>
                                                        <asp:Label ID="cancelRequestedDate" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table id="tblCancelApprovedLog" runat="server" visible="false" class="table  table-bordered">
                                                <tr>
                                                    <td>Cancel Approved By:</td>
                                                    <td>
                                                        <asp:Label ID="cancelApprovedBy" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Cancel Approved Date:</td>
                                                    <td>
                                                        <asp:Label ID="cancelApprovedDate" runat="server" CssClass="text"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td valign="top" class="tableForm" style="width: 50%;">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Sender</div>
                            <div class="panel-body">
                                <table style="width: 100%; background-color: #F5F5F5;" class="table table-bordered">
                                    <tr>
                                        <td>Name: </td>
                                        <td class="text">
                                            <asp:Label ID="sName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Address: </td>
                                        <td class="text">
                                            <asp:Label ID="sAddress" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Country: </td>
                                        <td class="text">
                                            <asp:Label ID="sCountry" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>City/State: </td>
                                        <td class="text">
                                            <asp:Label ID="sCity" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Mobile No: </td>
                                        <td class="text">
                                            <asp:Label ID="sContactNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Tel. No: </td>
                                        <td class="text">
                                            <asp:Label ID="sTelNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap">
                                            <asp:Label ID="sIdType" runat="server"></asp:Label>: </td>
                                        <td class="text">
                                            <asp:Label ID="sIdNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>ID Validity Date: </td>
                                        <td class="text">
                                            <asp:Label ID="sValidityDate" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Email: </td>
                                        <td class="text">
                                            <asp:Label ID="sEmail" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Native Country:</td>
                                        <td class="text">
                                            <asp:Label ID="sNativeCountry" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="sDisMemId">
                                        <td>Membership Id: </td>
                                        <td class="text">
                                            <asp:Label ID="sMemId" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                    <td valign="top" class="tableForm" style="width: 50%">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Receiver</div>
                            <div class="panel-body">
                                <table style="width: 100%; background-color: #F5F5F5;" class="table  table-bordered">
                                    <tr>
                                        <td>Name: </td>

                                        <td class="text">
                                            <asp:Label ID="rName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Address: </td>
                                        <td class="text">
                                            <asp:Label ID="rAddress" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Country: </td>
                                        <td class="text">
                                            <asp:Label ID="rCountry" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>City/State: </td>
                                        <td class="text">
                                            <asp:Label ID="rCity" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Mobile No: </td>
                                        <td class="text">
                                            <asp:Label ID="rContactNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Tel. No: </td>
                                        <td class="text">
                                            <asp:Label ID="rTelNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap">
                                            <asp:Label ID="rIdType" runat="server" CssClass="text"></asp:Label>:
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rIdNo" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>ID Validity Date: </td>
                                        <td class="text">
                                            <asp:Label ID="rValidityDate" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Relationship with Sender: </td>
                                        <td class="text">
                                            <asp:Label ID="relationship" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="rDisMemId">
                                        <td>Membership Id: </td>
                                        <td class="text">
                                            <asp:Label ID="rMemId" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Sending Agent</div>
                            <div class="panel-body">

                                <table style="width: 100%; background-color: #F5F5F5;" class="table table-bordered">
                                    <tr>
                                        <td>Agent: </td>
                                        <td class="text">
                                            <asp:Label ID="sAgentName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Branch: </td>
                                        <td class="text">
                                            <asp:Label ID="sBranchName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>Address:</td>
                                        <td class="text">
                                            <asp:Label ID="sAgentAddress" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>Country: </td>
                                        <td class="text">
                                            <asp:Label ID="sAgentCountry" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                    <td valign="top" class="tableForm">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Receiving Agent</div>
                            <div class="panel-body">
                                <table style="width: 100%; background-color: #F5F5F5;" class="table table-bordered">
                                    <tr>
                                        <td>Agent: </td>
                                        <td class="text">
                                            <asp:Label ID="pAgentName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Branch: </td>
                                        <td class="text">
                                            <asp:Label ID="pBranchName" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>Address:</td>
                                        <td class="text">
                                            <asp:Label ID="pAgentAddress" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>Country: </td>
                                        <td class="text">
                                            <asp:Label ID="pAgentCountry" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr runat="server" id="showHideTranStatus" visible="false">
                    <td colspan="2">
                        <div id="highLightTranStatus" runat="server" class="alert alert-danger" cssclass="text"></div>
                    </td>
                </tr>
                <tr>
                    <td class="tableForm" valign="top">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Payout Amount</div>
                            <div class="panel-body">
                                <table class="table table-bordered" cellspacing="0" cellpadding="2" style="background-color: #F5F5F5;">
                                    <tr>
                                        <td>Collection Amount: </td>

                                        <td class="text-amount">
                                            <asp:Label ID="total" runat="server" CssClass="text"></asp:Label>
                                            <asp:Label ID="totalCurr" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Service Charge: </td>
                                        <td class="text-amount">
                                            <asp:Label ID="serviceCharge" runat="server" CssClass="text"></asp:Label>
                                            <asp:Label ID="scCurr" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Send Agent Commission: </td>
                                        <td class="text-amount">
                                            <asp:Label ID="sAgentComm" runat="server" CssClass="text"></asp:Label>
                                            <asp:Label ID="sAgentCommCurr" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <asp:Panel ID="payAgentComm" runat="server" Visible="false">
                                        <tr>
                                            <td>Pay Agent Comm.: </td>
                                            <td class="text-amount">
                                                <asp:Label ID="pAgentComm" runat="server" CssClass="text"></asp:Label>
                                                <asp:Label ID="pAgentCommCurr" runat="server" CssClass="text"></asp:Label>
                                            </td>
                                        </tr>
                                    </asp:Panel>

                                    <tr>
                                        <td>Customer Rate</td>
                                        <td class="text-amount">
                                            <asp:Label ID="custRate" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Settlement Rate</td>
                                        <td class="text-amount">
                                            <asp:Label ID="settRate" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Sent Amount: </td>

                                        <td class="text-amount">
                                            <asp:Label ID="transferAmount" runat="server" CssClass="text"></asp:Label>
                                            <asp:Label ID="tAmtCurr" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Payout Amount: </td>
                                        <td class="text-amount DisFond">
                                            <asp:Label ID="payoutAmt" runat="server" CssClass="text"></asp:Label>
                                            <asp:Label ID="pAmtCurr" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                    <td valign="top">
                        <div class="panel panel-danger">
                            <div class="panel-heading">Transaction Information</div>
                            <div class="panel-body">
                                <table style="width: 100%; background-color: #F5F5F5;" class="table table-bordered">
                                    <tr>
                                        <td>Mode of Payment: </td>
                                        <td class="text">
                                            <asp:Label ID="modeOfPayment" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="DisFond">Txn. Status:</td>
                                        <td>
                                            <asp:Label ID="payStatus" runat="server" CssClass="HeighlightTex"></asp:Label>
                                            &nbsp;-
                                            <asp:Label ID="lbltrnsubStatus" runat="server" CssClass="HeighlightTex"> </asp:Label>
                                        </td>
                                    </tr>
                                    <div id="pnlShowBankDetail" runat="server" visible="false">
                                        <tr id="trAc">
                                            <td>Account Number: </td>
                                            <td class="text">
                                                <asp:Label ID="accountNo" runat="server" CssClass="text"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="trBank">
                                            <td>Bank: </td>
                                            <td class="text">
                                                <asp:Label ID="bankName" runat="server" CssClass="text"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="trBranch">
                                            <td>Branch: </td>
                                            <td class="text">
                                                <asp:Label ID="branchName" runat="server" CssClass="text"></asp:Label>
                                            </td>
                                        </tr>
                                    </div>
                                    <tr>
                                        <td>Source of Fund: </td>
                                        <td class="text">
                                            <asp:Label ID="sourceOfFund" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap">Reason For Remittance: </td>
                                        <td class="text">
                                            <asp:Label ID="reasonOfRemit" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Transaction Message: </td>
                                        <td class="text">
                                            <asp:Label ID="payoutMsg" runat="server" CssClass="text"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </td>
                </tr>
                <%--<tr>
                    <td colspan="2">
                        <div class="panel panel-default">
                            <div class="panel-heading">Deposit Information</div>
                            <div class="panel-body">
                                <div id="Ddetail" runat="server" style="width: 500px"></div>
                            </div>
                        </div>
                    </td>
                    <td></td>
                </tr>--%>
                <tr>
                    <td colspan="2">
                        <asp:HiddenField ID="hddTranId" runat="server" />
                        <asp:HiddenField ID="hddPayTokenId" runat="server" />
                        <asp:HiddenField ID="pAgent" runat="server" />
                        <asp:HiddenField ID="hddTrnSatusBeforeCnlReq" runat="server" />
                        <asp:HiddenField ID="hdnSName" runat="server" />
                        <asp:HiddenField ID="hdnRName" runat="server" />
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>
    <div style="float: right; display: none;">
        <asp:LinkButton ID="lbtnTxnAuditTrail" runat="server" ToolTip="Transaction Audit Trail"
            OnClick="lbtnTxnAuditTrail_Click">Txn Audit Trail</asp:LinkButton>
    </div>
    <asp:UpdatePanel ID="upnl1" runat="server">
        <ContentTemplate>
            <div id="div1" class="panels">
                <table class="table">
                    <asp:Panel ID="pnlLog" runat="server">
                        <tr>
                            <td>
                                <div class="panel panel-danger">
                                    <div class="panel-heading">Complain/Trouble Ticket</div>
                                    <div class="panel-body">
                                        <div id="rptLog" runat="server"></div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </asp:Panel>

                    <tr>
                        <td>
                            <div id="lblAddComp" runat="server">
                                <a href="#" onclick="ShowHideAddComplainBox();" style="margin-left: 10px; cursor: pointer;">Add New Complain</a>
                                <br>
                            </div>
                            <div id="lblSettl" runat="server">
                                <a href="#" style="margin-left: 10px; cursor: pointer;">Settlement Details</a>
                            </div>
                        </td>
                    </tr>

                    <asp:Panel ID="pnlComment" runat="server">
                        <tr id="divComplainAdd" style="display: none;">
                            <td>
                                <div class="headers">Transaction Complain (Trouble Ticket)</div>

                                <asp:TextBox runat="server" ID="comments" TextMode="MultiLine"
                                    Height="50px" Width="750px"></asp:TextBox>
                                <br>
                                <br>
                                <asp:Button ID="btnAdd" runat="server" CssClass="button" OnClick="btnAdd_Click"
                                    Text="Add New Complain" />
                            </td>
                        </tr>
                    </asp:Panel>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Panel ID="pnlOFAC" runat="server">
        <div class="headers">OFAC </div>
        <div id="div3" style="clear: both;" class="panels">
            <div id="displayOFAC" runat="server" style="height: 250px; overflow: auto;"></div>
            <br />
            <div><b>OFAC Approved Remarks</b></div>

            <asp:TextBox runat="server" ID="remarksOFAC" TextMode="MultiLine"
                Height="50px" Width="750px"></asp:TextBox>
            <br>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCompliance" runat="server">
        <div class="headers">Compliance </div>
        <div id="div4" style="clear: both;" class="panels">
            <div id="displayCompliance" style="height: 150px; overflow: auto;" runat="server"></div>
            <br />
            <div><b>Compliance Approved Remarks</b></div>

            <asp:TextBox runat="server" ID="remarksCompliance" TextMode="MultiLine"
                Height="50px" Width="750px"></asp:TextBox>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCashLimitHold" runat="server">
        <div class="headers">Cash Limit Hold </div>
        <div id="div55" style="clear: both;" class="panels">
            <div id="displayCashLimitHold" style="height: 150px; overflow: auto;" runat="server"></div>
            <br />
            <div><b>Cash Limit Hold Approved Remarks</b></div>

            <asp:TextBox runat="server" ID="remarksCashLimitHold" TextMode="MultiLine"
                Height="50px" Width="750px"></asp:TextBox>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlReleaseBtn" runat="server">

        <br></br>
        <div id="div5" style="clear: both;" class="panels">
            <asp:CheckBox ID="CheckBox1" runat="server" Text="I acknowledge that this Transaction is not done by any customer which are listed in OFAC/COMPLIANCE List" CssClass=" ErrMsg" />
            <br>
            <br>
                <asp:Button ID="btnApproveCompliance" runat="server" CssClass="button"
                    OnClick="btnApproveCompliance_Click" Text="Release Transaction" />

                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender" runat="server"
                    ConfirmText="Are you sure to release transaction?" Enabled="True" TargetControlID="btnApproveCompliance">
                </cc1:ConfirmButtonExtender>
            </br>
        </div>
    </asp:Panel>
</div>