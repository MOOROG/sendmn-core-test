<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Confirm.aspx.cs" Inherits="Swift.web.AgentNew.SendTxn.Confirm" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="/AgentNew/css/ie9.css" rel="stylesheet" />
    <link href="/AgentNew/css/signature-pad.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/js/jquery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/browserDetect.js"></script>
    <script src="/AgentNew/js/signature_pad.umd.js"></script>
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

        .panel-blue > .panel-heading {
            color: #fff;
            background-color: #03a9f4;
            border-color: #03a9f4;
            padding: 5px;
        }

            .panel-blue > .panel-heading h4 {
                padding: 0;
            }
    </style>

    <script language="javascript">
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        var isSafari = navigator.userAgent.toLowerCase().indexOf('safari') > -1;
        var is_mobile = false;

        $(document).ready(function () {
            var value = sessionStorage.getItem("XmlDataForCDDI");
            if (value !== null && value !== "" && value !== undefined) {
                value = value.replace(/</g, '%3e');
                value = value.replace(/>/g, '%3c');
                $('#hddXMLCDDI').val(value);
            }

            var value1 = sessionStorage.getItem("XmlDataForQuestinnarie");
            if (value1 !== null && value1 !== "" && value1 !== undefined) {
                value1 = value1.replace(/</g, '%3e');
                value1 = value1.replace(/>/g, '%3c');
              $('#hddQuestinnarie').val(value1);
          }
        });

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
            if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                is_mobile = true;
            }

            window.returnValue = mes + '-:::-' + invoicePrintMode;
            if (is_mobile) {
                var s = GetBrowserDetails();
                if (s.osName == 'iPad' || s.osName == 'iPhone') {
                    if (s.browserVersion != '0') {
                        isSafari = true;
                        isChrome = false;
                    }
                    else {
                        isSafari = false;
                        isChrome = true;
                    }
                }
                if (isSafari) {
                    window.opener.document.getElementById("confirmHidden").value = mes + '-:::-' + invoicePrintMode;
                    window.opener.parent.focus();
                }
                if (isChrome) {
                    window.opener.document.getElementById("confirmHiddenChrome").value = mes + '-:::-' + invoicePrintMode;
                    window.opener.document.getElementById("ContentPlaceHolder1_txtPayMsg").focus();
                }

                window.close();
                return true;
            }

            if (isChrome) {
                window.opener.focus();
                window.opener.PostMessageToParent(window.returnValue);
            }
            else if (isSafari) {
                window.opener.document.getElementById("confirmHidden").value = mes + '-:::-' + invoicePrintMode;
            }
            window.close();
        }

        function CallBack(mes, invoicePrintMode) {
            var resultList = ParseMessageToArray(mes);

            if (resultList[0] == "0" || resultList[0] == "100" || resultList[0] == "101") { //100-Waiting for Approval,101-Under Compliance
                window.returnValue = resultList[0] + "|" + resultList[2] + "|" + invoicePrintMode;
                window.close();
            }
            alert(resultList[1]);
            return;
        }
        function ViewImage() {
            var url = "CustomerID.aspx?customerId=<%= _senderId %>";
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
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-39365077-1']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
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
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="panel panel-blue">
                                        <div class="panel-heading">
                                            Sender Information
                                        </div>
                                        <div class="panel-body">
                                            <div class="table-responsive">
                                                <table class="table table-bordered table-striped">
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
                                                        <td>Mobile No: </td>
                                                        <td>
                                                            <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr id="trSenTelNo">
                                                        <td>Phone No: </td>
                                                        <td>
                                                            <asp:Label ID="sTelNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <fieldset style="display: none">
                                                <legend>Sender Identity </legend>
                                                <div class="table-responsive">
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
                                                </div>
                                            </fieldset>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class="panel panel-blue">
                                        <div class="panel-heading">
                                            Receiver Information
                                        </div>
                                        <div class="panel-body">
                                            <div class="table-responsive">
                                                <table class="table table-bordered table-striped">
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
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="ridNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr style="display: none">
                                                        <td>DOB: </td>
                                                        <td>
                                                            <asp:Label ID="rdob" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Email: </td>
                                                        <td>
                                                            <asp:Label ID="remail" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Mobile No: </td>
                                                        <td>
                                                            <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr id="trRecTelNo">
                                                        <td>Phone No: </td>
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
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div class="panel panel-blue">
                                        <div class="panel-heading">
                                            Transaction Information
                                        </div>
                                        <div class="panel-body">
                                            <div class="table-responsive">
                                                <table class="table table-bordered table-striped">
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
                                                        <td>Description: </td>
                                                        <td class="text-amount">
                                                            <asp:Label ID="transactionDescript" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Payout Amount: </td>
                                                        <td class="text-amount">
                                                            <asp:Label ID="payoutAmt" runat="server" ForeColor="red"></asp:Label>
                                                            <asp:Label ID="pCurr2" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Payout Amount in Words: </td>
                                                        <td class="text-amount">
                                                            <asp:Label ID="payoutAmtInWords" runat="server" ForeColor="red"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div class="panel panel-blue">
                                        <div class="panel-heading">
                                            Payout Agent/Bank Information
                                        </div>
                                        <div class="panel-body">
                                            <div class="table-responsive">
                                                <table class="table table-bordered table-striped">
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
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <fieldset id="msgToReceiver" runat="server" visible="false">
                                        <legend>Message to Receiver</legend>
                                        <div id="payoutMsg" runat="server"></div>
                                    </fieldset>
                                </div>
                                <div class="col-sm-12">
                                    <div id="dvAlertSummary" runat="server">
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div id="spnCdd" runat="server" visible="false" style="color: white; background-color: rgb(3, 169, 244); font-family: Verdana; font-weight: bold; font-size: 18px;">
                                        As per AML Policy please conduct customer due diligence and transmit the accurate and meaningful originator information, Thanks.
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <span id="spnWarningMsg" runat="server" style="font-family: Verdana; font-weight: bold; font-size: 24px; color: Red;"></span>
                                    <div id="divOfac" runat="server"></div>
                                </div>
                                <div class="col-sm-12">
                                    <fieldset id="complianceField" runat="server" visible="false" style="margin: 15px 0;">
                                        <legend style="background-color: red;">Note: If are in compliance then you can not make the transaction !!!
                                        </legend>
                                        <div id="divCompliance" runat="server"></div>
                                    </fieldset>

                                    <div id="divComplianceMultipleTxn" runat="server" visible="false" style="width: 100%"></div>
                                </div>
                                <div class="col-sm-12">
                                    <div id="divEcdd" runat="server" visible="false">
                                        <br />
                                        <span runat="server" id="spnEcdd" style="font-family: Verdana; font-weight: bold; font-size: 14px; color: black; width: 780px;">Please note that this transaction requires <u>Enhance Customer Due Diligence</u>, please provide an explanation
                                                     below about the customer activity and source of funds.</span>
                                        <br />
                                        <asp:TextBox ID="eddRemarks" runat="server" TextMode="MultiLine" Width="500px" Height="75px" MaxLength="299"></asp:TextBox>
                                        <span class="ErrMsg">*</span>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div class="table-responsive">
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
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div class="form-inline">
                                        <span>Txn. Password:</span> &nbsp; &nbsp;&nbsp;&nbsp;
                                                <asp:TextBox ID="txnPassword" CssClass="form-control" placeholder="Enter Txn. Password" runat="server" Width="200px" TextMode="Password"></asp:TextBox>
                                        &nbsp;&nbsp;(Note: Please use your login password to confirm the transaction)
                                    </div>
                                </div>

                                <div class="col-sm-12" id="EnableDigitalSignature" runat="server">
                                    <div class="col-sm-6">
                                        <span>Customer Signature:</span>
                                        <div id="signature-pad" class="signature-pad">
                                            <div class="signature-pad--body">
                                                <canvas></canvas>
                                            </div>
                                            <div class="signature-pad--footer">
                                                <div class="description">Sign above</div>
                                                <div class="signature-pad--actions">
                                                    <div>
                                                        <button type="button" class="btn btn-default clear" data-action="clear">Clear</button>
                                                        <button type="button" class="btn btn-default" data-action="undo">Undo</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6" style="display: none">
                                        <label class="control-label">Customer Password:</label>
                                        <div>
                                            <asp:TextBox TextMode="Password" ID="customerPassword" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-12" style="display: none">
                                    <div class="form-group">
                                        <label>Receipt Print Mode</label>
                                        <asp:RadioButtonList ID="invoicePrintMode" CssClass="form-control" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="s">Single </asp:ListItem>
                                            <asp:ListItem Value="d"> Double</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <asp:UpdatePanel ID="updatePnl" runat="server">
                                        <ContentTemplate>
                                            <div class="table-responsive">
                                                <table class="table">
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
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                                <div class="col-sm-12" id="additionalDocumentDiv" runat="server" visible="false">
                                    <asp:CheckBox ID="additionDocumentConfirm" runat="server"
                                        Style="font-family: Verdana; font-weight: bold; font-size: 24px; color: Red;"
                                        Text="Additional document required for this transaction, do you want to proceed?" />
                                </div>
                                <div class="col-sm-12">
                                    <div class="form-group">
                                        <asp:Button ID="btnProceed" runat="server" onmousedown="return GetSignatureCustomer(this);" CssClass="btn btn-primary m-t-25" Text="Proceed" OnClick="btnProceed_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnProceedCc" runat="server"
                                            ConfirmText="" Enabled="True" TargetControlID="btnProceed">
                                        </cc1:ConfirmButtonExtender>
                                        <input type="button" value="Close" class="btn btn-clear m-t25" id="btnClose" onclick="CloseWindow();" />
                                        <asp:Button ID="btnProceed2" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnProceed2_Click" Style="display: none;" />
                                    </div>
                                </div>
                            </div>
                            <br />

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
                            <asp:HiddenField ID="hddImgURL" runat="server" />
                            <asp:HiddenField ID="isDisplaySignature" runat="server" />
                            <asp:HiddenField ID="hddQuestinnarie" runat="server" />
                            <asp:HiddenField ID="hddXMLCDDI" runat="server" />
<asp:HiddenField ID="hddJsonQuestinnarie" runat="server" />
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        var wrapper = document.getElementById("signature-pad");
        var clearButton = wrapper.querySelector("[data-action=clear]");
        var undoButton = wrapper.querySelector("[data-action=undo]");
        var canvas = wrapper.querySelector("canvas");
        var signaturePad = new SignaturePad(canvas, {
            backgroundColor: 'rgb(255, 255, 255)'
        });

        function resizeCanvas() {
            // When zoomed out to less than 100%, for some very strange reason,
            // some browsers report devicePixelRatio as less than 1
            // and only part of the canvas is cleared then.
            var ratio = Math.max(window.devicePixelRatio || 1, 1);

            // This part causes the canvas to be cleared
            canvas.width = canvas.offsetWidth * ratio;
            canvas.height = canvas.offsetHeight * ratio;
            canvas.getContext("2d").scale(ratio, ratio);

            // This library does not listen for canvas changes, so after the canvas is automatically
            // cleared by the browser, SignaturePad#isEmpty might still return false, even though the
            // canvas looks empty, because the internal data of this library wasn't cleared. To make sure
            // that the state of this library is consistent with visual state of the canvas, you
            // have to clear it manually.
            signaturePad.clear();
        }

        // On mobile devices it might make more sense to listen to orientation change,
        // rather than window resize events.
        window.onresize = resizeCanvas;
        resizeCanvas();

        function download(dataURL, filename) {
            if (navigator.userAgent.indexOf("Safari") > -1 && navigator.userAgent.indexOf("Chrome") === -1) {
                window.open(dataURL);
            } else {
                var blob = dataURLToBlob(dataURL);
                var url = window.URL.createObjectURL(blob);

                var a = document.createElement("a");
                a.style = "display: none";
                a.href = url;
                a.download = filename;

                document.body.appendChild(a);
                a.click();

                window.URL.revokeObjectURL(url);
            }
        }

        // One could simply use Canvas#toBlob method instead, but it's just to show
        // that it can be done using result of SignaturePad#toDataURL.
        function dataURLToBlob(dataURL) {
            // Code taken from https://github.com/ebidel/filer.js
            var parts = dataURL.split(';base64,');
            var contentType = parts[0].split(":")[1];
            var raw = window.atob(parts[1]);
            var rawLength = raw.length;
            var uInt8Array = new Uint8Array(rawLength);

            for (var i = 0; i < rawLength; ++i) {
                uInt8Array[i] = raw.charCodeAt(i);
            }

            return new Blob([uInt8Array], { type: contentType });
        }
        clearButton.addEventListener("click", function (event) {
            signaturePad.clear();
        });

        undoButton.addEventListener("click", function (event) {
            var data = signaturePad.toData();

            if (data) {
                data.pop(); // remove the last dot or line
                signaturePad.fromData(data);
            }
        });

        function GetSignatureCustomer(event) {
            if ($("#additionalDocumentDiv").is(":visible")) {
                if (!$("#additionDocumentConfirm").is(":checked")) {
                    alert('If you have customer Documents required then, please check on Additional document check box!');
                    return false;
                }
            }

            var password = $('#txnPassword').val();
            if (password === "" || password === null) {
                return alert("Txn Password Is Required");
            }
            var isdisplayDignature = $('#<%=isDisplaySignature.ClientID%>').val();
            if (isdisplayDignature.toLowerCase() === 'true') {
                var customerPassword = $('#<%=customerPassword.ClientID%>');
                if (signaturePad.isEmpty() && (customerPassword === "" || customerPassword === null)) {
                    alert("Customer signature or customer password is required");
                    document.getElementById('hddImgURL').value = '';
                    return false;
                } if (!signaturePad.isEmpty()) {
                    var dataURL = signaturePad.toDataURL('image/png');
                    document.getElementById('hddImgURL').value = dataURL.replace('data:image/png;base64,', '');
                    return true;
                }
                if (signaturePad.isEmpty()) {
                    document.getElementById('hddImgURL').value = '';
                    return true;
                }
            }
        }
    </script>
</body>
</html>
