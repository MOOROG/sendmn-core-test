<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UcTransactionSend.ascx.cs" Inherits="Swift.web.Remit.UserControl.UcTransactionSend" %>

<head>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />

    <script type="text/javascript">

        function ShowHideAddComplainBox() {
            if (GetElement("divComplainAdd").style.display == "none")
                GetElement("divComplainAdd").style.display = "block";
            else
                GetElement("divComplainAdd").style.display = "none";
            window.parent.resizeIframe();
        }
    </script>

    <style>
        .infotext {
            color: #000;
            font-size: 14px;
            font-weight: 600;
        }

        label {
            font-size: 13px;
            color: #808080;
        }

        .send {
            margin-left: 200px;
        }
    </style>

</head>
<asp:Panel ID="pnlDetail" runat="server">
    <div class="row">
        <div class="col-md-12 container">
            <div id="divDetails">
                <div style="text-align: center;">

                    <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                    <asp:Label ID="lblControlNo" runat="server" CssClass="HeighlightTex"></asp:Label>
                    &nbsp;&nbsp;
                    Tran Ref. Id : 
                    <asp:Label ID="lblTranRefId" runat="server" CssClass="HeighlightTex"></asp:Label>
                    &nbsp;&nbsp;
                    Tran Id : 
                    <asp:Label ID="lblTranNo" runat="server" CssClass="HeighlightTex"></asp:Label>
                    &nbsp;&nbsp;
                    <span style="width: 100px;"></span>
                    &nbsp;Pay Status:
                
                <asp:Label ID="lblStatus" runat="server" CssClass="HeighlightTex"></asp:Label>
                    <asp:Label ID="tranStatus" runat="server" Style="display: none;"></asp:Label>

                </div>
                <div id="lockAudit" style="text-align: center; background-color: #808080; color: white; font-size: 11px; font-weight: bold;" runat="server" visible="false">
                </div>

                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4>MODIFICATION REQUEST</h4>
                    </div>
                    <div class="panel-body">
                        <div class="col-md-6 form" id="tblCreatedLog" runat="server" visible="false"  style="background-color:#f5f5f5;">
                            <div class="form-group">
                                <label>Created By:</label>
                                <asp:Label ID="createdBy" runat="server" CssClass="infotext" ></asp:Label>
                            </div>
                            <div class="form-group">
                                 <label>Created Date:</label>
                                <asp:Label ID="createdDate" runat="server" CssClass="infotext" ></asp:Label>
                            </div>
                        </div>
                        <div class="col-md-6 form" id="tblApprovedLog" runat="server" visible="false"  style="background-color:#f5f5f5;">
                            <div class="form-group">
                                <label>Approved By:</label>
                                <asp:Label ID="approvedBy" runat="server" CssClass="infotext" ></asp:Label>
                            </div>
                            <div class="form-group">
                                <label>Approved Date:</label>
                                <asp:Label ID="approvedDate" runat="server" CssClass="infotext" ></asp:Label>
                            </div>
                        </div>
                        <div class="col-md-6 form" id="tblPaidLog" runat="server" visible="false" style="background-color:#f5f5f5;">
                            <div class="form-group">
                                 <label>Paid By:</label>
                                <asp:Label ID="paidBy" runat="server" CssClass="infotext"></asp:Label>
                            </div>
                            <div class="form-group">
                                <label>Paid Date:</label>
                                  <asp:Label ID="paidDate" runat="server" CssClass="infotext"></asp:Label>
                            </div>
                        </div>
                        <div class="col-md-6 form" id="tblCancelRequestedLog" runat="server" visible="false"  style="background-color:#f5f5f5;">
                            <div class="form-group">
                                 <label>Cancel Requested By:</label>
                                <asp:Label ID="cancelRequestedBy" runat="server" CssClass="infotext"></asp:Label>
                            </div>
                            <div class="form-group">
                                <label>Cancel Requested Date:</label>
                                <asp:Label ID="cancelRequestedDate" runat="server" CssClass="infotext"></asp:Label>
                            </div>

                        </div>
                        <div class="col-md-6 form" id="tblCancelApprovedLog" runat="server" visible="false" style="background-color:#f5f5f5;">
                            <div class="form-group">
                                <label>Cancel Approved By:</label>
                                 <asp:Label ID="cancelApprovedBy" runat="server" CssClass="infotext"></asp:Label>
                            </div>
                            <div class="form-group">
                                <label>Cancel Approved Date:</label>
                                <asp:Label ID="cancelApprovedDate" runat="server" CssClass="infotext"></asp:Label>
                            </div>

                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Sender</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td width="200px;">
                                            <label>Name:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sName" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Address:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sAddress" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label >Country:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sCountry" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>City:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sCity" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Mobile No:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sContactNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr style="display:none">
                                        <td nowrap="nowrap" width="200px;">
                                            <label>Tel. No:</label>
                                        </td>
                                        <td nowrap="nowrap">
                                            <asp:Label ID="sTelNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td nowarp="nowrao" width="200px">
                                            <label>Id Type:</label>
                                        </td>
                                        <td nowrap="nowrap">
                                            <asp:Label ID="sIdType" runat="server" CssClass="infotext">Citizenship:</asp:Label>
                                        </td>
                                        </tr>
                                    <tr>
                                        <td nowarp="nowrao" width="200px">
                                            <label>Id No:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sIdNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>ID Validity Date:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sValidityDate" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Email:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sEmail" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Native Country:</label></td>
                                        <td class="text">
                                            <asp:Label ID="sNativeCountry" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="sDisMemId">
                                        <td width="200px;">
                                            <label>Membership Id:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sMemId" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Receiver</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td width="200px;">
                                            <label>Name: </label>
                                        </td>

                                        <td class="text">
                                            <asp:Label ID="rName" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Address:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rAddress" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Country:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rCountry" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>City:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rCity" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Mobile No:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rContactNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr style="display:none">
                                        <td width="200px;">
                                            <label>Tel. No:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rTelNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Id Type:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rIdType" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px">
                                            <label>Id No:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rIdNo" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>ID Validity Date: </label> 
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rValidityDate" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Relationship with Sender:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="relationship" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="rDisMemId">
                                        <td width="200px;">
                                            <label>Membership Id:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="rMemId" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Sending Information</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td width="200px;">
                                            <label>Agent:</label>
                                        </td>
                                        <td>
                                            <asp:Label ID="sAgentName" runat="server" CssClass="infotext "></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Branch:</label>
                                        </td>
                                        <td nowarp="nowarp">
                                            <asp:Label ID="sBranchName" runat="server" CssClass="infotext "></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Address:</label></td>
                                        <td>
                                            <asp:Label ID="sAgentAddress" runat="server" CssClass="infotext" ></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Country:</label>
                                        </td>
                                        <td>
                                            <asp:Label ID="sAgentCountry" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Receiving Information</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table">
                                    <tr>
                                        <td width="200px;">
                                            <label>Agent:</label>
                                        </td>
                                        <td>
                                            <asp:Label ID="pAgentName" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Branch:</label>
                                        </td>
                                        <td>
                                            <asp:Label ID="pBranchName" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Address:</label></td>
                                        <td>
                                            <asp:Label ID="pAgentAddress" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td width="200px;">
                                            <label>Country:</label>
                                        </td>
                                        <td>
                                            <asp:Label ID="pAgentCountry" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <table class="table">
                    <tr class="hightLightTranStatus" runat="server" id="showHideTranStatus" visible="false">
                        <td colspan="2">
                            <div id="highLightTranStatus" runat="server" class="hightLightTranStatus"></div>
                        </td>
                    </tr>
                </table>

                <div class="row">
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Payout Amount</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <td width="200px;">
                                            <label>Collection Amount:</label>
                                        </td>

                                        <td class="text-amount">
                                            <asp:Label ID="total" runat="server" CssClass="infotext"></asp:Label>
                                            <asp:Label ID="totalCurr" runat="server" CssClass="infotext"></asp:Label>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td width="200px;">
                                            <label>Service Charge:</label>
                                        </td>
                                        <td class="text-amount">
                                            <asp:Label ID="serviceCharge" runat="server" CssClass="infotext"></asp:Label>
                                            <asp:Label ID="scCurr" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td width="200px;">
                                            <label>Sent Amount:</label>
                                        </td>

                                        <td class="text-amount">
                                            <asp:Label ID="transferAmount" runat="server" CssClass="infotext"></asp:Label>
                                            <asp:Label ID="tAmtCurr" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>

                                    <asp:Panel ID="payAgentComm" runat="server" Visible="false">
                                        <tr>
                                            <td width="200px;">
                                                <label>Pay Agent Comm.:</label>
                                            </td>
                                            <td class="text-amount">
                                                <asp:Label ID="pAgentComm" runat="server" CssClass="infotext"></asp:Label>
                                                <asp:Label ID="pAgentCommCurr" runat="server" CssClass="infotext"></asp:Label>
                                            </td>
                                        </tr>
                                    </asp:Panel>


                                    <tr>
                                        <td width="200px;">
                                            <label>Customer Rate</label></td>
                                        <td class="text-amount">
                                            <asp:Label ID="custRate" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>


                                    <tr>
                                        <td width="200px;">
                                            <label>Payout Amount:</label>
                                        </td>
                                        <td class="text-amount DisFond">
                                            <asp:Label ID="payoutAmt" runat="server" CssClass="infotext"></asp:Label>
                                            <asp:Label ID="pAmtCurr" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Transaction Information</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table">
                                    <tr>
                                        <td width="200px;">
                                            <label>Mode of Payment:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="modeOfPayment" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td width="200px;">Txn. Status:</label></td>
                                        <td>
                                            <asp:Label ID="payStatus" runat="server" CssClass="infotext"></asp:Label>
                                            &nbsp;-
                                    <asp:Label ID="lbltrnsubStatus" runat="server" CssClass="infotext"></asp:Label></td>
                                    </tr>
                                    <div id="pnlShowBankDetail" runat="server" visible="false">
                                        <tr id="trAc">
                                            <td class="label">
                                                <label>Account Number: </label>
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="accountNo" runat="server" CssClass="infotext"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="trBank">
                                            <td class="label">
                                                <label>Bank: </label>
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="bankName" runat="server" CssClass="infotext"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="trBranch">
                                            <td class="label">
                                                <label>Branch: </label>
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="branchName" runat="server" CssClass="infotext"></asp:Label>
                                            </td>
                                        </tr>
                                    </div>
                                    <tr>
                                        <td class="label">
                                            <label>Source of Fund: </label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="sourceOfFund" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="label" nowrap="nowrap">
                                            <label>Reason For Remittance: </label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="reasonOfRemit" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="label">
                                            <label>Transaction Message:</label>
                                        </td>
                                        <td class="text">
                                            <asp:Label ID="payoutMsg" runat="server" CssClass="infotext"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                 </div>
                <div class="row">
                    <div class="col-md-12">

                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4>Deposit Information</h4>
                            </div>
                            <div class="panel-body">
                                <div id="Ddetail" runat="server" style="width: 500px"></div>
                            </div>
                        </div>

                        <asp:HiddenField ID="hddTranId" runat="server" />
                        <asp:HiddenField ID="hddPayTokenId" runat="server" />
                        <asp:HiddenField ID="pAgent" runat="server" />

                    </div>
                </div>
                </div>
            </div>
    </div>
</asp:Panel>

<asp:UpdatePanel ID="upnl1" runat="server">
    <ContentTemplate>
        <div id="div1" style="clear: both;">
            <table class="table">
                <asp:Panel ID="pnlLog" runat="server">
                    <tr>
                        <td>
                            <div class="panel panel-default">
                                <div class="panel-heading">
                                    <h4>Complain/Trouble Ticket</h4>
                                </div>
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
                            <a href="#" onclick="ShowHideAddComplainBox();" style="margin-left: 10px; cursor: pointer;" class="btn btn-primary">Add New Complain</a>
                            <br>
                        </div>

                        <div id="lblSettl" runat="server">
                            <%--<a href="../../../AgentPanel/Reports/SearchTransaction/settlementDetails.aspx" style="margin-left: 10px; cursor: pointer;">Settlement Details</a>--%>
                        </div>
                    </td>
                </tr>

                <asp:Panel ID="pnlComment" runat="server">
                    <tr>
                        <td>
                            <div id="divComplainAdd" style="display: none;">
                                <div class="headers">Transaction Complain (Trouble Ticket)</div>
                                <asp:TextBox runat="server" ID="comments" TextMode="MultiLine"
                                    Height="50px" Width="750px" CssClass="form-control"></asp:TextBox>
                                <br>
                                <br>
                                <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-primary" OnClick="btnAdd_Click"
                                    Text="Add New Complain" />
                            </div>
                        </td>
                    </tr>
                </asp:Panel>
            </table>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>