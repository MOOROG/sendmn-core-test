<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Confirm.aspx.cs" Inherits="Swift.web.AgentPanel.International.SendMoneyv2.Confirm" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <script src="/js/jquery/jquery.min.js" type="text/javascript"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--    <style>
        .label
        {
            font-family:Verdana;
            font-size:13px;
        }
        .text
        {
            font-family:Verdana;
            font-size:13px;
            font-weight:bolder;
        }
        .text-amount
        {
            font-family:Verdana;
            font-size:13px;
            text-align:right;
             font-weight:bold;
        }
    </style>--%>
    <style>
        .text-amount {
            font-family: Verdana;
            font-size: 13px;
            text-align: right;
            font-weight: bold;
        }

        .table .table {
            background-color: #f5f5f5;
        }

        legend {
            background-color: rgb(3, 169, 244);
            color: white;
            margin-bottom: 0 !important;
        }
    </style>

    <script language="javascript">
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        document.onkeypress = function (e) {
            var e = window.event || e;

            if (e.keyCode == 27)
                window.close();
        };

        function CloseWindow() {
            if (confirm("Are you sure to want to close this confirmation page?")) {
                window.close();
            }
        }

        function ManageMessage(mes, invoicePrintMode) {
            window.returnValue = mes + '-:::-' + invoicePrintMode;
            if (isChrome) {
                window.opener.PostMessageToParent(window.returnValue);
            }
            window.close();
        }

        function CallBack(mes, invoicePrintMode) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] == "0" || resultList[0] == "100" || resultList[0] == "101") { //100-Waiting for Approval,101-Under Compliance
                window.returnValue = resultList[0] + "|" + resultList[2] + "|" + invoicePrintMode;
                window.close();
            }
            return;
        }
        function ViewImage() {
            var url = "CustomerID.aspx?customerId=<% = _senderId %>";
            OpenDialog(url, 500, 620, 100, 100);
        }

        function ProceedOfac() {
            var confirmText = "Confirmation:\n_____________________________________";
            confirmText += "\n\nYou are confirming to send this OFAC suspicious transaction!!!";
            confirmText += "\n\nPlease note if this customer is found to be valid person from OFAC List then Teller will be charged fine from management";
            confirmText += "\n\n\nPlease make sure you have proper evidence that show this customer is not from OFAC List";
            if (confirm(confirmText)) {
                GetElement("<%=btnProceed2.ClientID %>").click();
            }
        }
        function EnableButton() {
            var isBtnEnabled = "<%= isProcessedBtnEnabled %>";
        if (isBtnEnabled.toLowerCase() == "false") return;
        GetElement("<%=btnProceed.ClientID %>").disabled = false;
        }
        function LoadCalendars() {
            ShowCalDefault("#<% =voucherDate1.ClientID%>");
            ShowCalDefault("#<% =voucherDate2.ClientID%>");
        }
        LoadCalendars();
    </script>
</head>
<body onload="EnableButton()">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('account_report')">Send Money </a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Sending Money Information
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <table class="table table-responsive ">
                                    <tr>
                                        <td>
                                            <table class="table table-responsive ">
                                                <tr>
                                                    <td valign="top">
                                                        <fieldset>
                                                            <legend>Sender Information</legend>
                                                            <table class="table table-responsive table-bordered table-striped">
                                                                <tr>
                                                                    <td>Sender's Name: </td>
                                                                    <td>
                                                                        <asp:Label ID="sName" runat="server" ForeColor="red"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Address: </td>
                                                                    <td>
                                                                        <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:Label ID="sIdType" runat="server"></asp:Label>
                                                                        : </td>
                                                                    <td>
                                                                        <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>ID Expiry Date: </td>
                                                                    <td>
                                                                        <asp:Label ID="sIdValidty" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>DOB: </td>
                                                                    <td>
                                                                        <asp:Label ID="sdob" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>City: </td>
                                                                    <td>
                                                                        <asp:Label ID="sCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Country: </td>
                                                                    <td>
                                                                        <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Email: </td>
                                                                    <td>
                                                                        <asp:Label ID="sEmail" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>

                                                                <tr>
                                                                    <td>Contact No: </td>
                                                                    <td>
                                                                        <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trSenTelNo">
                                                                    <td>Tel No: </td>
                                                                    <td>
                                                                        <asp:Label ID="sTelNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                        <br />
                                                        <fieldset style="display: none">
                                                            <legend>Sender Identity </legend>
                                                            <table class="table table-responsive table-bordered table-striped">
                                                                <tr>
                                                                    <td>Customer ID Card Image: </td>
                                                                    <td style="padding-left: 5px; height: 20px; width: 50px;">

                                                                        <div runat="server" id="custId" style="float: left; cursor: pointer;">
                                                                            <img alt="Customer Identity" title="Click to Add Document"
                                                                                onclick="ViewImage();"
                                                                                style="height: 50px; width: 50px;" src="../../../Images/na.gif" />
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                    <td valign="top">
                                                        <fieldset>
                                                            <legend>Receiver Information</legend>
                                                            <table class="table table-responsive table-bordered table-striped">
                                                                <tr>
                                                                    <td>Receiver's Name: </td>
                                                                    <td>
                                                                        <asp:Label ID="rName" runat="server" ForeColor="red"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Address: </td>
                                                                    <td>
                                                                        <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:Label ID="rIdtype" runat="server"></asp:Label>
                                                                        : </td>
                                                                    <td>
                                                                        <asp:Label ID="ridNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>ID Expiry Date: </td>
                                                                    <td>
                                                                        <asp:Label ID="ridvalidity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>DOB: </td>
                                                                    <td>
                                                                        <asp:Label ID="rdob" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>City: </td>
                                                                    <td>
                                                                        <asp:Label ID="rCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Country: </td>
                                                                    <td>
                                                                        <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Email: </td>
                                                                    <td>
                                                                        <asp:Label ID="remail" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Contact No: </td>
                                                                    <td>
                                                                        <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trRecTelNo">
                                                                    <td>Tel No: </td>
                                                                    <td>
                                                                        <asp:Label ID="rTelNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trRnc" runat="server">
                                                                    <td>Receiver Name Code: </td>
                                                                    <td>
                                                                        <asp:TextBox ID="ttName" runat="server" Width="250px"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trWp" runat="server">
                                                                    <td>Withdrawal Password: </td>
                                                                    <td>
                                                                        <asp:TextBox ID="cwPwd" runat="server" TextMode="Password" MaxLength="6"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" colspan="2">
                                                        <fieldset>
                                                            <legend>Transaction Information</legend>
                                                            <table class="table table-responsive table-bordered table-striped">
                                                                <tr>
                                                                    <td>Collection Amount: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="total" runat="server" ForeColor="red"></asp:Label>
                                                                        <asp:Label ID="sCurr3" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td>Sent Amount: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="transferAmount" runat="server" ForeColor="red"></asp:Label>
                                                                        <asp:Label ID="sCurr1" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Service Charge: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                                                        <asp:Label ID="sCurr2" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td id="tdSchemeLbl" runat="server">Scheme/Offer: </td>
                                                                    <td id="tdSchemeTxt" runat="server" style="text-align: right;">
                                                                        <span id="spnSchemeOffer" runat="server"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Customer Rate: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="exchangeRate" runat="server"></asp:Label>
                                                                        <asp:Label ID="pCurr1" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Payout Amount: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="payoutAmt" runat="server" ForeColor="red"></asp:Label>
                                                                        <asp:Label ID="pCurr2" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" colspan="2" style="width: 100%">
                                                        <fieldset>
                                                            <legend>Payout Agent/Bank Information</legend>
                                                            <table class="table table-responsive table-bordered table-striped">
                                                                <tr>
                                                                    <td>Country: </td>
                                                                    <td>
                                                                        <asp:Label ID="pCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td>Mode of Payment:
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label ID="modeOfPayment" runat="server" ForeColor="red"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Payout Agent/Branch: </td>
                                                                    <td>
                                                                        <asp:Label ID="pAgentBranch" runat="server" ForeColor="red"></asp:Label>
                                                                    </td>
                                                                    <td id="tdAccountNoLbl" runat="server" visible="false">Account Number
                                                                    </td>
                                                                    <td id="tdAccountNoTxt" runat="server" visible="false">
                                                                        <span class="text">
                                                                            <asp:Label ID="accountNo" runat="server"></asp:Label></span>
                                                                    </td>
                                                                </tr>
                                                                <tr id="pLocationDetail" runat="server" visible="false">
                                                                    <td>State: </td>
                                                                    <td>
                                                                        <asp:Label ID="pLocation" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td>District
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label ID="pSubLocation" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trPaymentThrough" runat="server" visible="false">
                                                                    <td>Payment Through:
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label ID="paymentThrough" runat="server" CssClass="text"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <fieldset style="width: 825px;" id="msgToReceiver" runat="server" visible="false">
                                                <legend>Message to Receiver</legend>
                                                <div id="payoutMsg" runat="server"></div>
                                            </fieldset>
                                            <br />
                                            <div id="dvAlertSummary" runat="server">
                                            </div>
                                            <br />
                                            <div id="spnCdd" runat="server" visible="false" style="color: white; background-color: rgb(3, 169, 244); font-family: Verdana; font-weight: bold; font-size: 18px;">
                                                As per AML Policy please conduct customer due diligence and transmit the accurate and meaningful originator information, Thanks.
                                            </div>
                                            <span id="spnWarningMsg" runat="server" style="font-family: Verdana; font-weight: bold; font-size: 24px; color: Red;"></span>
                                            <div id="divOfac" runat="server"></div>
                                            <br />
                                            <fieldset id="complianceField" runat="server" visible="false">
                                                <legend style="background-color: red">Note: If are in compliance then you can not make the transaction !!!
                                                </legend>
                                                <div id="divCompliance" runat="server"></div>
                                            </fieldset>

                                            <div id="divComplianceMultipleTxn" runat="server" visible="false" style="width: 100%"></div>
                                            <br />
                                            <div id="divEcdd" runat="server" visible="false">
                                                <br />
                                                <span runat="server" id="spnEcdd" style="font-family: Verdana; font-weight: bold; font-size: 14px; color: black; width: 780px;">Please note that this transaction requires <u>Enhance Customer Due Diligence</u>, please provide an explanation
                            below about the customer activity and source of funds.</span>
                                                <br />
                                                <asp:TextBox ID="eddRemarks" runat="server" TextMode="MultiLine" Width="500px" Height="75px" MaxLength="299"></asp:TextBox>
                                                <span class="ErrMsg">*</span>
                                            </div>
                                            <table class="table table-responsive table-bordered table-condensed" style="display: none;">
                                                <thead>
                                                    <tr>
                                                        <td>Primary Bank Name</td>
                                                        <td>Primary Account No</td>

                                                        <td>Amount Deposited</td>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td>
                                                            <asp:DropDownList ID="bankList1" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="voucherNo1" placeholder="Enter Primary Account No" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>

                                                        <td>
                                                            <asp:TextBox ID="voucherAmount1" placeholder="Enter Amount Deposited" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>

                                                        <asp:TextBox ID="voucherDate1" Style="display: none" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:DropDownList ID="bankList2" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="voucherNo2" placeholder="Enter Primary Account No" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="voucherAmount2" placeholder="Enter Amount Deposited" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>

                                                        <asp:TextBox ID="voucherDate2" Style="display: none" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </tr>
                                                </tbody>
                                            </table>
                                            <div class="form-inline">
                                                <span>Txn. Password:</span> &nbsp; &nbsp;&nbsp;&nbsp;
                                                <asp:TextBox ID="txnPassword" CssClass="form-control" placeholder="Enter Txn. Password" runat="server" Width="200px" TextMode="Password"></asp:TextBox>
                                                &nbsp;&nbsp;(Note: Please use your login password to confirm the transaction)
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <h3>Receipt Print Mode
                                            <asp:RadioButtonList ID="invoicePrintMode" CssClass="form-control" runat="server" RepeatDirection="Horizontal">
                                                <asp:ListItem Value="s">Single </asp:ListItem>
                                                <asp:ListItem Value="d"> Double</asp:ListItem>
                                            </asp:RadioButtonList></h3>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel ID="updatePnl" runat="server">
                                                <ContentTemplate>
                                                    <table>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="chkCdd" Visible="false" runat="server" Style="font-family: Verdana; font-weight: bold; font-size: 20px; color: red;"
                                                                    Text="We have conducted Due Diligence by filling up CDD (Customer Due Diligence) Form with the customer details." AutoPostBack="true"
                                                                    OnCheckedChanged="chkCdd_CheckedChanged" />
                                                                <br />

                                                                <asp:CheckBox ID="chkMultipleTxn" Visible="false" runat="server"
                                                                    Style="font-family: Verdana; font-weight: bold; font-size: 24px; color: Red;"
                                                                    Text="We have verified this sender's previous transaction and want to proceed this transaction."
                                                                    AutoPostBack="true" OnCheckedChanged="chkMultipleTxn_CheckedChanged" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="btnProceed" runat="server" CssClass="btn btn-primary m-t-25" Text="Proceed" OnClick="btnProceed_Click" />
                                <cc1:ConfirmButtonExtender ID="btnProceedCc" runat="server"
                                    ConfirmText="" Enabled="True" TargetControlID="btnProceed">
                                </cc1:ConfirmButtonExtender>
                                <input type="button" value="Close" class="btn btn-primary m-t25" id="btnClose" onclick="CloseWindow();" />
                                <asp:Button ID="btnProceed2" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnProceed2_Click" Style="display: none;" />
                                <asp:HiddenField ID="hdnOfacRes" runat="server" />
                                <asp:HiddenField ID="hdnOfacReason" runat="server" />
                                <asp:HiddenField ID="hdnAgentRefId" runat="server" />
                                <asp:HiddenField ID="hdnRBATxnRisk" runat="server" />
                                <asp:HiddenField ID="hdnRBACustomerRisk" runat="server" />
                                <asp:HiddenField ID="hddSenderIdType" runat="server" />
                                <asp:HiddenField ID="hddSenderNationalityCode" runat="server" />
                                <asp:HiddenField ID="hddReceiverIdType" runat="server" />
                                <asp:HiddenField ID="hddrBankCode" runat="server" />
                                <asp:HiddenField ID="hddrBankBranchCode" runat="server" />
                                <asp:HiddenField ID="hddReceiverNationalityCode" runat="server" />
                                <asp:HiddenField ID="hddSourceOfFund" runat="server" />
                                <asp:HiddenField ID="hddReasonOfRemittance" runat="server" />
                                <asp:HiddenField ID="hddremitType" runat="server" />
                                <asp:HiddenField ID="hddCustomerId" runat="server" />
                                <asp:HiddenField ID="hddSenderOccCode" runat="server" />
                                <asp:HiddenField ID="hddReceiverId" runat="server" />
                                <asp:HiddenField ID="hddhddpAgentCode" runat="server" />
                                <asp:HiddenField ID="hdnRBACustomerRiskValue" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>