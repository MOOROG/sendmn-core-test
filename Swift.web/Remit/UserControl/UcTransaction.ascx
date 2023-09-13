<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UcTransaction.ascx.cs" Inherits="Swift.web.Remit.UserControl.UcTransaction" %>
<head>
    <%--<link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <style>
        .btn-primary {
            color: #fff;
            background-color: #0E96EC;
            border-color: #0E96EC !important;
        }

            .btn-primary:hover {
                color: #fff;
                background-color: #286090 !important;
                border-color: #286090 !important;
            }

        .modal {
            position: absolute;
            top: 55%;
        }
    </style>
</head>

<asp:Panel ID="pnlDetail" runat="server">
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <div class="row table-responsive">
                        <table class="table">
                            <tr>
                                <td>
                                    <span style="font-size: 1.2em; font-weight: bold;">
                                        <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                    <span style="color: red;">
                        <asp:Label ID="lblControlNo" runat="server"></asp:Label></span></span>
                                </td>
                                <td id="payoutPartnerPinDiv" runat="server" visible="false">
                                    <span style="font-size: 1.2em; font-weight: bold;">Partner (Payout/General) Pin:
                    <span style="color: red;">
                        <asp:Label ID="lblPartnerPayoutPin" runat="server"></asp:Label></span></span>
                                </td>
                              <td>
                                <div align="center">
                                  <span style="font-size: 1.2em; font-weight: bold;">Control No 2:
                    <span style="color: red;">
                      <asp:Label ID="lblControlNo2" runat="server"></asp:Label></span>
                                  </span>
                                </div>
                              </td>
                                <td>
                                    <div align="center">
                                        <span style="font-size: 1.2em; font-weight: bold;">Tran No :
                    <span style="color: red;">
                        <asp:Label ID="lblTranNo" runat="server"></asp:Label></span>
                                        </span>
                                    </div>
                                </td>
                                <td style="align-items">
                                    <div align="right">
                                        <span style="font-size: 1.2em; font-weight: bold;">Transaction Status:
                     <span style="color: red;">
                         <asp:Label ID="tranStatus" runat="server"></asp:Label>
                     </span>
                                    </div>
                                    </span>
                                </td>
                            </tr>
                          <tr>
                            <td colspan="2">
                              <div id ="statusChange" runat="server">
                              <div style="float: left; width: 100px">
                                <asp:DropDownList ID="chStatus" runat="server" CssClass="form-control">
                                  <asp:ListItem Enabled="true" Text="Select" Value="-1"></asp:ListItem>
                                  <asp:ListItem Text="Paid" Value="paid"></asp:ListItem>
                                  <asp:ListItem Text="Error" Value="error"></asp:ListItem>
                                </asp:DropDownList>
                              </div>
                              <div style="float: left; width: 60px">
                                <asp:Button ID="chStatusBtn" runat="server" Text="Change" CssClass="btn btn-primary" OnClick="chStatusBtn_Click" OnClientClick="this.disabled='true';" UseSubmitBehavior="false" />
                              </div>
                              </div>
                            </td>
                            <td>
                              <div style="float: left; width: 60px">
                                <asp:Button ID="btnPaidTxn" runat="server" Text="Pay Bank Deposit" CssClass="btn btn-primary" OnClick="btnPaidTxn_Click" OnClientClick="this.disabled='true';" UseSubmitBehavior="false" />
                              </div>
                            </td>
                          </tr>
                        </table>
                    </div>
                </div>
                <div class="panel-body">
                    <div id="lockAudit" style="text-align: center; background-color: blue; color: white; font-size: 11px; font-weight: bold;" runat="server" visible="false">
                    </div>
                    <table style="width: 100%">
                        <tr>
                            <td>
                                <table class="table table-bordered table-striped" id="tblCreatedLog" runat="server" visible="false">
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
                                <table class="table table-bordered table-striped" id="tblApprovedLog" runat="server" visible="false">
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
                                <table class="table table-bordered table-striped" id="tblPaidLog" runat="server" visible="false">
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
                                <table class="table table-bordered table-striped" id="tblCancelRequestedLog" runat="server" visible="false">
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
                                <table class="table table-bordered table-striped" id="tblCancelApprovedLog" runat="server" visible="false">
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
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">
                    Sender
                </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped" style="width: 100%">
                        <tr>
                            <th>Name: </th>
                            <th class="text" colspan="3">
                                <asp:Label ID="sName" runat="server"></asp:Label>
                            </th>
                        </tr>
                        <tr>
                            <td>Membership No: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="customerId" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Address: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="sAddress" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Country: </td>
                            <td class="text" style="width: 150px">
                                <asp:Label ID="sCountry" runat="server"></asp:Label>
                            </td>
                            <td style="width: 60px;">DOB: </td>
                            <td class="text">
                                <asp:Label ID="sDOB" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Contact No: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="sContactNo" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Id Type: </td>
                            <td class="text" style="width: 150px">
                                <asp:Label ID="sIdType" runat="server"></asp:Label>
                            </td>
                            <td style="width: 60px;">Id No: </td>
                            <td class="text">
                                <asp:Label ID="sIdNo" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Email: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="sEmail" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr runat="server" id="sCId">
                            <td>Customer ID: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="sCustomerId" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">
                    Receiver
                </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped">
                        <tr>
                            <th>Name: </th>
                            <th class="text" colspan="3">
                                <asp:Label ID="rName" runat="server"></asp:Label></th>
                        </tr>
                        <tr>
                            <td>Address: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="rAddress" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Country: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="rCountry" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Mobile No: </td>
                            <td class="text" colspan="3">
                                <asp:Label ID="rContactNo" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Id Type: </td>
                            <td class="text" style="width: 150px">
                                <asp:Label ID="rIdType" runat="server"></asp:Label>
                            </td>
                            <td style="width: 60px;">Id No: </td>
                            <td class="text">
                                <asp:Label ID="rIdNo" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Relationship with sender: </td>
                            <td class="text" colspan="3">
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
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">
                    Sending Agent
                </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped">
                        <tr>
                            <td>Agent: </td>
                            <td class="text">
                                <asp:Label ID="sAgentName" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Branch: </td>
                            <td class="text">
                                <asp:Label ID="sBranchName" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>S. Agent Location: </td>
                            <td class="text">
                                <asp:Label ID="sAgentLocation" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>District:</td>
                            <td class="text">
                                <asp:Label ID="sAgentDistrict" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>City: </td>
                            <td class="text">
                                <asp:Label ID="sAgentCity" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Country: </td>
                            <td class="text">
                                <asp:Label ID="sAgentCountry" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">
                    Payout Agent
                </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped">
                        <tr>
                            <td>Agent: </td>
                            <td class="text">
                                <asp:Label ID="pAgentName" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Branch: </td>
                            <td class="text">
                                <asp:Label ID="pBranchName" runat="server"></asp:Label>
                            </td>
                        </tr>
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
                            <td>City: </td>
                            <td class="text">
                                <asp:Label ID="pAgentCity" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Country: </td>
                            <td class="text">
                                <asp:Label ID="pAgentCountry" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        <div style="margin-left: 25px" class="hightLightTranStatus" runat="server" id="showHideTranStatus" visible="false">
            <div id="highLightTranStatus" runat="server" class="hightLightTranStatus"></div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">Transaction Amount</div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped">
                        <tr>
                            <td>Collection Mode: </td>
                            <td class="amt">
                                <asp:Label ID="lblCollMode" runat="server"></asp:Label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <%--<a href="javascript:void(0);" onclick="ShowModal();" id="bankDetails" runat="server">View Details</a>--%>
                            </td>
                        </tr>
                        <tr>
                            <td>Collection Amount: </td>
                            <td class="amt">
                                <asp:Label ID="total" runat="server"></asp:Label>
                                <asp:Label ID="totalCurr" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Service Charge: </td>
                            <td class="amt">
                                <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                <asp:Label ID="scCurr" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr style="display: none">
                            <td>Send Agent Commission: </td>
                            <td class="amt">
                                <asp:Label ID="sAgentComm" runat="server"></asp:Label>
                                <asp:Label ID="sAgentCommCurr" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <asp:Panel ID="payAgentComm" runat="server" Visible="false">
                            <tr>
                                <td>Pay Agent Comm.: </td>
                                <td class="amt">
                                    <asp:Label ID="pAgentComm" runat="server"></asp:Label>
                                    <asp:Label ID="pAgentCommCurr" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </asp:Panel>
                        <asp:Panel ID="pnlExRate" runat="server" Visible="false">
                            <tr>
                                <td>Handling</td>
                                <td class="amt">
                                    <asp:Label ID="handling" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Exchange Rate</td>
                                <td class="amt">
                                    <asp:Label ID="exRate" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </asp:Panel>
                        <tr>
                            <td>Sent Amount: </td>
                            <td class="amt">
                                <asp:Label ID="transferAmount" runat="server"></asp:Label>
                                <asp:Label ID="tAmtCurr" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>Payout Amount: </td>
                            <td class="highlightText">
                                <asp:Label ID="payoutAmt" runat="server"></asp:Label>
                                <asp:Label ID="pAmtCurr" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">Other </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped" style="width: 100%">

                        <tr>
                            <td>Mode of Payment: </td>
                            <td class="text">
                                <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                            </td>
                        </tr>

                        <tr>
                            <td class="DisFond">Pay Status:</td>
                            <td class="DisFond">
                                <asp:Label ID="payStatus" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr style="display: none">
                            <td colspan="2">Customer Signature:</td>
                        </tr>
                        <tr style="display: none">
                            <td colspan="2">
                                <asp:Image ID="customerSignatureImg" runat="server" ImageUrl="/ckeditor/plugins/image/images/noimage.png" Style="height: 50%;" />
                            </td>
                        </tr>
                        <div id="pnlShowBankDetail" runat="server" visible="false">
                            <tr id="trAc">
                                <td>Account Number: </td>
                                <td class="text">
                                    <asp:Label ID="accountNo" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr id="trBank">
                                <td>Bank Name: </td>
                                <td class="text">
                                    <asp:Label ID="bankName" Visible="false" runat="server"></asp:Label>
                                  <asp:DropDownList Visible="true" ID="bankListDdl" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="bankListDdl_SelectedIndexChanged" AppendDataBoundItems="false"></asp:DropDownList>
                                </td>
                            </tr>
                            <tr id="trBranch" style="display: none">
                                <td>Branch Name: </td>
                                <td class="text">
                                    <asp:Label ID="branchName" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </div>
                    </table>
                </div>
            </div>
        </div>
      <div>
      </div>
        <div class="col-md-12" style="display: none">
            <div class="panel panel-default">
                <div class="panel-heading" style="font-weight: bolder;">Voucher Details </div>
                <div class="panel-body">
                    <table class="table table-bordered table-striped" style="width: 100%">
                        <thead>
                            <tr>
                                <td>S. No.</td>
                                <td>Voucher No.</td>
                                <td>Voucher Date</td>
                                <td>Voucher Amt.</td>
                                <td>Bank Name.</td>
                            </tr>
                        </thead>
                        <tbody id="voucherDetailDiv" runat="server">
                            <tr>
                                <td colspan="5" align="center">No data to display.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div id="trpMsg" runat="server">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <table class="panels">
                            <tr>
                                <td nowrap="nowrap">
                                    <b>Payout Message</b>:&nbsp;<asp:Label ID="payoutMsg" runat="server"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hddTranId" runat="server" />
        <asp:HiddenField ID="hddPayTokenId" runat="server" />
        <asp:HiddenField ID="pAgent" runat="server" />
        <asp:HiddenField ID="hdnSName" runat="server" />
        <asp:HiddenField ID="hdnRName" runat="server" />
        <asp:HiddenField ID="hddTrnSatusBeforeCnlReq" runat="server" />
        <asp:HiddenField ID="hddSAgentEmail" runat="server" />
        <asp:HiddenField ID="hddIsPartnerRealTime" runat="server" />
        <asp:HiddenField ID="hddPartnerId" runat="server" />
        <asp:HiddenField ID="isRealTime" runat="server" />
        <asp:HiddenField ID="remarksId" runat="server" />
      <asp:HiddenField ID="fromWhere" runat="server" />
      <asp:HiddenField ID="hddRealTranId" runat="server" />
      <asp:HiddenField ID="hddSagentId" runat="server" />
    </div>
</asp:Panel>

<asp:UpdatePanel ID="upnl1" runat="server">
    <ContentTemplate>

        <asp:Panel ID="pnlLog" runat="server">
            <div class="headers">Transaction Complain (Trouble Ticket)</div>
            <div id="div1" style="clear: both;" class="panels">
                <table>
                    <div class="table table-responsive">
                        <tr>
                            <td>
                                <div id="rptLog" runat="server"></div>
                            </td>
                        </tr>
                    </div>
                    <asp:Panel ID="pnlComment" runat="server">
                        <tr>
                            <td>
                                <asp:TextBox runat="server" ID="comments" TextMode="MultiLine"
                                    Height="50px" Width="750px"></asp:TextBox>
                                <br />
                                <asp:CheckBox ID="chkSms" runat="server" Text="Send SMS to Sender" />
                                <asp:CheckBox ID="chkEmail" runat="server" Text="Send Email to Agent" />
                                <br>
                                <br>
                                <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-primary" OnClick="btnAdd_Click"
                                    Text="Add New Complain" />
                            </td>
                        </tr>
                    </asp:Panel>
                </table>
            </div>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>

<asp:Panel ID="pnlOFAC" runat="server" EnableViewState="false">
    <div class="headers">OFAC </div>
    <div id="div3" style="clear: both;" class="panels">
        <div id="displayOFAC" runat="server" style="overflow: auto;" enableviewstate="false"></div>
        <br />
        <div id="ofacApproveRemarks" runat="server">
            <b>OFAC Approved Remarks</b>
            <br />
            <asp:TextBox runat="server" ID="remarksOFAC" TextMode="MultiLine"
                Height="50px" Width="750px"></asp:TextBox>
            <br />
            <br />
        </div>
    </div>
</asp:Panel>
<asp:Panel ID="pnlCompliance" runat="server" EnableViewState="false">
    <div class="headers">Compliance </div>
    <div id="div4" style="clear: both;" class="panels">
        <div id="displayCompliance" style="height: 150px; overflow: auto;" runat="server" enableviewstate="false"></div>
        <br />
        <div id="complianceApproveRemarks" runat="server">
            <b>Compliance Approved Remarks</b>
            <br />
            <asp:TextBox runat="server" ID="remarksCompliance" TextMode="MultiLine"
                Height="50px" Width="750px"></asp:TextBox>
        </div>
    </div>
</asp:Panel>
<asp:Panel ID="pnlPartnerRemarks" runat="server" EnableViewState="false" Visible="false">
    <div class="panels" id="partnerRemarksDiv" runat="server">
        <div class="form-group">
            <label>Remarks For Partner:  <span class="errormsg">*</span></label>
            <asp:DropDownList ID="ddlRemarks" runat="server" class="form-control"></asp:DropDownList>
        </div>
    </div>
</asp:Panel>
<asp:Panel ID="pnlReleaseBtn" runat="server" EnableViewState="false">
    <div id="div5" style="clear: both;" class="panels">
        <asp:Button ID="btnApproveCompliance" runat="server" CssClass="btn btn-primary" OnClick="btnApproveCompliance_Click"
            Text="Release Transaction" />
        &nbsp;&nbsp;
        <asp:Button ID="btnRejectTxn" runat="server" CssClass="btn btn-danger" OnClick="btnRejectTxn_Click" Text="Reject Transaction" />
    </div>
</asp:Panel>

<asp:Panel ID="pnlCashLimitHold" runat="server" EnableViewState="false">
    <div class="headers">Cash Limit Hold </div>
    <div id="div50" style="clear: both;" class="panels">
        <div id="displayCashLimitHold" style="height: 150px; overflow: auto;" runat="server" enableviewstate="false"></div>
        <br />
        <div><b>Cash Limit Hold Approved Remarks</b></div>

        <asp:TextBox runat="server" ID="remarksCashLimitHold" TextMode="MultiLine"
            Height="50px" Width="750px"></asp:TextBox>
    </div>
</asp:Panel>
<asp:Panel ID="pnlReleaseBtnCashHold" runat="server" EnableViewState="false">
    <div id="div6" style="clear: both;" class="panels">
        <asp:Button ID="btnReleaseCashHoldLimit" runat="server" CssClass="btn btn-primary" OnClick="btnReleaseCashHoldLimit_Click"
            Text="Release Transaction" />
    </div>
</asp:Panel>

<!-- Modal -->
<div class="modal fade" id="modalCollModeDetails" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" style="font-size: 18px; font-weight: 600;">Bank Deposit Details</h5>
                <%--<button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>--%>
            </div>
            <div class="modal-body">
                <div class="table table-responsive">
                    <table class="table table-responsive table-bordered table-condensed table-hover">
                        <thead>
                            <tr>
                                <td>S. No.</td>
                                <td>Particulars</td>
                                <td>Deposited Date</td>
                                <td>Amount</td>
                            </tr>
                        </thead>
                        <tbody id="bankDpositDetails" runat="server">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="btnHaveDocumentYes" data-dismiss="modal">Ok</button>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    function ShowModal() {
        $("#modalCollModeDetails").modal('show');
    }

    $('#ucTran_btnRejectTxn').click(function () {
        var remarksId = $('#ucTran_ddlRemarks option:selected').val();
        if (remarksId == '') {
            alert('Remarks is compulsory if you reject transaction');
            return false;
        } else {
            $('#ucTran_remarksId').val(remarksId);
        }

    });
</script>