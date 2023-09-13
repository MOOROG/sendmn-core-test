<%@ Page Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="SendTntlReceipt.aspx.cs" Inherits="Swift.web.AgentNew.ReprintReceipt.SendTntlReceipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%--<link href="/css/receipt.css" rel="stylesheet" />--%>
    <style type="text/css">
        .receipt {
            margin-top: -130px;
        }

        #buttonRow {
            margin: 10px;
        }

        .no-margin{
            margin-top:10%;
        }
        @media only screen and (max-width: 991px) {
          .no-margin{
            margin-top:17%;
          }
        }
        @media print {
            .receipt {
                margin-top: 0% !important;
            }

            .footer {
                display: none;
            }

            .no-margin {
                margin-top: 0px !important;
            }

            .buttonDiv {
                display: none;
            }

            .officeDiv {
                margin-top: 0% !important;
            }
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {

            $("#<%=office.ClientID%>").on("click", function () {
                $("#<%=hide.ClientID%>").val('customer');
            });
            $("#<%=customer.ClientID%>").on("click", function () {
                $("#<%=hide.ClientID%>").val('office');
            });
            $("#<%=both.ClientID%>").on("click", function () {
                $("#<%=hide.ClientID%>").val('both');
            });

        });
        function Print() {
            window.print();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="buttonDiv" id="buttonDiv" runat="server">
        <asp:HiddenField runat="server" ID="hide" />
        <div class="row" id="buttonRow">
            <asp:Button ID="office" runat="server" Text="Print Office Copy" CssClass="btn btn-primary" />
            <asp:Button ID="customer" runat="server" Text="Print Customer Copy" CssClass="btn btn-primary" />
            <asp:Button ID="both" runat="server" Text="Print Both Copy" CssClass="btn btn-primary" />
            <div id="tranDiv" style="float:right;font-weight:bold;font-size:16px;background-color:yellow">
                <asp:Label ID="lblfiled" Text="Transaction Status :" runat="server"></asp:Label>
                 <asp:Label ID="tranStatus"  runat="server" ></asp:Label>
            </div>

        </div>
    </div>
    <div class="receipt">
        <div class="row" id="receiptRow">
            <div id="customerDiv" runat="server">
                <table border="0" width="100%" class="no-margin">
                    <!--Header-->
                    <tr>
                        <td>
                            <table width="100%;" border="0">
                                <tr>
                                    <td width="20%;">
                                        <div class="logo">
                                            <img src="/images/jme.png" />
                                        </div>
                                        <p>Kanto Finance Bureau License</p>
                                        <p>
                                            Number:<span>0006</span>
                                    </td>
                                    <td width="80%;" style="padding: 0 10px;">
                                        <h3>JME Japan</h3>
                                        <p>
                                            169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07
                                <p>
                                        <p>
                                            Shinjuku-ku, Tokyo, japan
                                        <p>
                                        <p>
                                            Tel:03-5475-3913, <span>Fax:03-5475-3913</span>
                                        <p>
                                        <p>
                                            email:info@japanremit.com
                                                        <p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>

                            <table width="100%;" border="0">
                                <tr>
                                    <td colspan="2" class="copy" width="100%;">
                                        <p style="text-decoration: underline; color: #ff0000;">Customer Copy</p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <!--body-->
                    <tr valign="top">
                        <td width="80%;">
                            <table width="100%;">
                                <!--sender information-->
                                <tr>
                                    <td>
                                        <table width="100%;" style="border: 1px solid #ccc; padding: 0 5px;">
                                            <tr>
                                                <td colspan="4 " class="details" style="padding: 0 5px;">
                                                    <h4>SENDER INFORMATION</h4>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="16% " valign="top" style="padding: 0 5px;">
                                                    <label>Senders Name</label>
                                                </td>
                                                <td width="38% " valign="top">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="senderName" runat="server"></asp:Label></span>
                                                </td>
                                                <td width="18% " valign="top">
                                                    <label>Membership Card</label>
                                                </td>
                                                <td width="28% ">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sMemId" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Address</label>
                                                </td>
                                                <td colspan="3 ">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sAddress" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Nationality</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sNativeCountry" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Purpose</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="purpose" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Date of birth</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sDob" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Mobile No.</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sContactNo" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Visa Status</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="visaStatus" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <!--Receiver information-->
                                <tr style="">
                                    <td>
                                        <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                            <tr>
                                                <td colspan="4" class="details" style="padding: 0 5px;">
                                                    <h4>RECEIVER INFORMATION</h4>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Payout Country</label>
                                                </td>
                                                <td colspan="3">
                                                    <span class="sender-value">
                                                        <asp:Label ID="pAgentCountry" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="16%" valign="top" style="padding: 0 5px;">
                                                    <label>Receiver's Name</label>
                                                </td>
                                                <td width="38%" valign="top">
                                                    <span class="sender-value">
                                                        <asp:Label ID="receiverName" runat="server"></asp:Label></span>
                                                </td>
                                                <td width="18%">
                                                    <label>Payment Mode</label>
                                                </td>
                                                <td width="28%"><span class="sender-value">
                                                    <span class="sender-value">
                                                        <asp:Label ID="paymentMode" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Contact No</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="rContactNo" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Correspondent</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="pAgent" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Address</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="rAddress" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label id="bankLable" runat="server">Bank Name</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="pBankName" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Relationship</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="relationShip" runat="server"></asp:Label></span>
                                                </td>

                                                <td id="bank7" runat="server">
                                                    <label>Branch</label>
                                                </td>
                                                <td id="bank8" runat="server">
                                                    <span class="sender-value">
                                                        <asp:Label ID="pBranchName" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="padding: 0 5px;">
                                                    <label>&nbsp;</label>
                                                </td>

                                                <td id="bank9" runat="server">
                                                    <label>Account No</label>
                                                </td>
                                                <td id="bank10" runat="server">
                                                    <span class="sender-value">
                                                        <asp:Label ID="accountNo" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" style="padding: 5px;">
                                                    <p>
                                                        <em>Receive Amount NPR: <span>
                                                            <asp:Label ID="rAmtWords" runat="server"></asp:Label></span></em>
                                                    </p>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>

                        <td width="20%" class="amount-info">
                            <table width="100%;" border="1" cellspacing="0 " cellpadding="0 ">
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <h2>JME NO:<span><asp:Label ID="controlNo" runat="server"></asp:Label></span></h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>User:<span><asp:Label ID="createdBy" runat="server"></asp:Label></span></p>
                                        <p>
                                            <span>
                                                <asp:Label ID="approvedDate" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Collected Amount</p>
                                        <h3><span>
                                            <asp:Label ID="cAmt" runat="server"></asp:Label></span></h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Service Charge</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="serviceCharge" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Transfer Amount</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="tAmt" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Exchange Rate</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="exRate" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Receive Amount</p>
                                        <h3><span>
                                            <asp:Label ID="pAmt" runat="server"></asp:Label></span></h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Serial:<span><asp:Label ID="serial1" runat="server"></asp:Label></span></p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Deposit Type</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="depositType" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <!--information section-->
                    <tr valign="top">
                        <td colspan="2">
                            <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                <tr valign="top" style="height: 80px;">
                                    <td colspan="4" style="padding: 5px;">
                                        <p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style="padding: 5px;">
                                        <label>Customer's Signature</label>
                                    </td>
                                    <td>..................................................
                                    </td>
                                    <td>
                                        <label>Operator:(<asp:Label ID="operator1" runat="server"></asp:Label>)</label>
                                    </td>
                                    <td>..................................................
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

                <table width="100%;" style="margin: 50px 0;" id="divInvoiceSecond" runat="server">
                    <tr>
                        <td>
                            <center>-----------------------------------------------------------------Cut From Here-----------------------------------------------------------------</center>
                        </td>
                    </tr>
                </table>
            </div>
            <div id="officeDiv" class="officeDiv" runat="server">
                <table border="0" width="100%" id="divInvoiceSecond1" runat="server">
                    <!--Header-->
                    <tr>
                        <td>
                            <table width="100%;" border="0">
                                <tr>
                                    <td width="20%;">
                                        <div class="logo">
                                            <img src="../../../Images/jme.png" />
                                        </div>
                                        <p>Kanto Finance Bureau License</p>
                                        <p>
                                            Number:<span>0006</span>
                                    </td>
                                    <td width="80%;" style="padding: 0 10px;">
                                        <h3>JME Japan</h3>
                                        <p>
                                            169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07
                                <p>
                                        <p>
                                            Shinjuku-ku, Tokyo, japan
                                        <p>
                                        <p>
                                            Tel:03-5475-3913, <span>Fax:03-5475-3913</span>
                                        <p>
                                        <p>
                                            email:info@japanremit.com
                                                        <p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table width="100%;" border="0">
                                <tr>
                                    <td colspan="2" class="copy" width="100%;">
                                        <p style="text-decoration: underline; color: #ff0000;">Office Copy</p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <!--body-->
                    <tr valign="top">
                        <td width="80%;">
                            <table width="100%;">
                                <!--sender information-->
                                <tr>
                                    <td>
                                        <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                            <tr>
                                                <td colspan="4 " class="details" style="padding: 0 5px;">
                                                    <h4>SENDER INFORMATION</h4>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="16% " valign="top" style="padding: 0 5px;">
                                                    <label>Sender Name</label>
                                                </td>
                                                <td width="38% " valign="top">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="senderName1" runat="server"></asp:Label></span>
                                                </td>
                                                <td width="18% " valign="top">
                                                    <label>Membership Card</label>
                                                </td>
                                                <td width="28% ">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sMemId1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Address</label>
                                                </td>
                                                <td colspan="3 ">
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sAddress1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Nationality</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sNativeCountry1" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Purpose</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="purpose1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Date of birth</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sDob1" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Mobile No.</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="sContactNo1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Visa Status</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value ">
                                                        <asp:Label ID="visaStatus1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <!--Receiver information-->
                                <tr style="">
                                    <td>
                                        <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                            <tr>
                                                <td colspan="4" class="details" style="padding: 0 5px;">
                                                    <h4>RECEIVER INFORMATION</h4>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Payout Country</label>
                                                </td>
                                                <td colspan="3">
                                                    <span class="sender-value">
                                                        <asp:Label ID="pAgentCountry1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="16%" valign="top" style="padding: 0 5px;">
                                                    <label>Receiver's Name</label>
                                                </td>
                                                <td width="38%" valign="top">
                                                    <span class="sender-value">
                                                        <asp:Label ID="receiverName1" runat="server"></asp:Label></span>
                                                </td>
                                                <td width="18%">
                                                    <label>Payment Mode</label>
                                                </td>
                                                <td width="28%"><span class="sender-value">
                                                    <span class="sender-value">
                                                        <asp:Label ID="paymentMode1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Contact No</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="rContactNo1" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label>Correspondent</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="pAgent1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Address</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="rAddress1" runat="server"></asp:Label></span>
                                                </td>
                                                <td>
                                                    <label id="bankLable1" runat="server">Bank Name</label>
                                                </td>
                                                <td id="bank2" runat="server">
                                                    <span class="sender-value">
                                                        <asp:Label ID="pBankName1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding: 0 5px;">
                                                    <label>Relationship</label>
                                                </td>
                                                <td>
                                                    <span class="sender-value">
                                                        <asp:Label ID="relationShip1" runat="server"></asp:Label></span>
                                                </td>

                                                <td id="bank3" runat="server">
                                                    <label>Branch</label>
                                                </td>
                                                <td id="bank4" runat="server">
                                                    <span class="sender-value">
                                                        <asp:Label ID="pBranchName1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="padding: 0 5px;">
                                                    <label>&nbsp;</label>
                                                </td>

                                                <td id="bank5" runat="server">
                                                    <label>Account No</label>
                                                </td>
                                                <td id="bank6" runat="server">
                                                    <span class="sender-value">
                                                        <asp:Label ID="accountNo1" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" style="padding: 5px;">
                                                    <p>
                                                        <em>Receive Amount NPR: <span>
                                                            <asp:Label ID="rAmtWords1" runat="server"></asp:Label></span></em>
                                                    </p>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>

                        <td width="20%" class="amount-info">
                            <table width="100%;" border="1" cellspacing="0 " cellpadding="0 ">
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <h2>JME NO:<span><asp:Label ID="controlNo1" runat="server"></asp:Label></span></h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>User:<span><asp:Label ID="createdBy1" runat="server"></asp:Label></span></p>
                                        <p>
                                            <span>
                                                <asp:Label ID="approvedDate1" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Collected Amount</p>
                                        <h3><span>
                                            <asp:Label ID="cAmt1" runat="server"></asp:Label></span></h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Service Charge</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="serviceCharge1" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Transfer Amount</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="tAmt1" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Exchange Rate</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="exRate1" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Receive Amount</p>
                                        <h3><span>
                                            <asp:Label ID="pAmt1" runat="server"></asp:Label></span></h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Serial:<span><asp:Label ID="serial2" runat="server"></asp:Label></span></p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0 5px;">
                                        <p>Deposit Type</p>
                                        <p>
                                            <span>
                                                <asp:Label ID="depositType1" runat="server"></asp:Label></span>
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <!--information section-->
                    <tr valign="top">
                        <td colspan="2">
                            <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                                <tr valign="top" style="height: 80px;">
                                    <td colspan="4" style="padding: 5px;">
                                        <p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style="padding: 5px;">
                                        <label>Customer's Signature</label>
                                    </td>
                                    <td>..................................................
                                    </td>
                                    <td>
                                        <label>Operator:(<asp:Label ID="operator2" runat="server"></asp:Label>)</label>
                                    </td>
                                    <td>..................................................
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

                <div id="officeCenterDiv" runat="server">
                    <table width="100%;" style="margin: 50px 0;" id="Table1" runat="server">
                        <tr>
                            <td>
                                <center>-----------------------------------------------------------------Cut From Here-----------------------------------------------------------------</center>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
