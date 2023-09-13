<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayMg.aspx.cs" Inherits="Swift.web.Remit.Transaction.ThirdPartyTXN.Pay.PayMg" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        $.validator.messages.required = "Required!";
        function ConfirmPay() {
            $("#form1").validate();

            if(confirm("Are you sure to pay this Transaction?")) {
                if ($("#form1").valid()) {
                    Process();
                    return true;
                }                
            }
            return false;        
        }
    </script>
    <style type="text/css">
        label.error, .msg
        {
            color: red;
            float: none;
            font: bold 10px 'Verdana';
        }
        .style1
        {
            color: #FF3300;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div id="top" class="breadCrumb">
        Pay Money » Third Party Payment (Money Gram)
    </div>
    <div>
        <div style="clear: both;" class="panels">
            <div id="divDetails" style="clear: both;" class="panels" style="width: 900px;">
                <table width="100%" cellspacing="0" cellpadding="0">
                    <tr>
                        <td colspan="2"> <div runat="server" visible="false" id="errorMsg" class=" errorExplanation"></div></td>
                    </tr>
                    <tr>
                        <td colspan="2" class="tableForm">
                            <div id="displayBlock" runat="server" visible="false">
                                <table width="100%" cellspacing="0" cellpadding="0">
                                    <tr>
                                     <td valign="top" colspan="2" class="tableForm">
                                        <fieldset>
                                            <legend>Transaction Details</legend>
                                            <table style="width: 100%;" align="center">
                                                <tr>
                                                    <td>
                                                        MG Ref #:
                                                    </td>
                                                    <td>
                                                        <asp:Label style=" font-size:large" ID="lblControlNo" runat="server"></asp:Label>
                                                    </td>
                                                    <td>
                                                        Transaction Status:
                                                    </td>
                                                    <td>
                                                        <asp:Label style=" font-size:large"  ID="tranStatus" runat="server"></asp:Label>
                                                    </td>
                                                    <td>
                                                        Transaction Date:
                                                    </td>
                                                    <td>
                                                        <asp:Label style=" font-size:large" runat="server" ID="transactionDate"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>                                          
                                        </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" class="tableForm">
                                            <fieldset>
                                                <legend>Sender Details</legend>
                                                <table style="width: 100%">
                                                    <tr style="background-color: #FDF79D;">
                                                        <td class="label">
                                                            Sender's Name:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="sName" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Address:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Country:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            City:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="sCity" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Home Phone:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="homePhone" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Message:
                                                        </td>
                                                        <td class="text">
                                                            <label runat="server" id="message">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                        <td valign="top" class="tableForm">
                                            <fieldset>
                                                <legend>Receiver Details</legend>
                                                <table style="width: 100%">
                                                    <tr style="background-color: #F9CCCC;">
                                                        <td class="label">
                                                            Receiver's Name:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="rName" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Address:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            City:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="rCity" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Country:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Contact No:
                                                        </td>
                                                        <td class="text">
                                                            <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="tableForm" valign="top" colspan="2">
                                            <fieldset>
                                                <legend>Payout Amount</legend>
                                                <table style="width: 100%">
                                                    <tr>
                                                        <td class="label">
                                                            Payout Amount:
                                                        </td>
                                                        <td class="text-amount" style="text-align: left;">
                                                            <asp:Label ID="payoutAmount" runat="server" CssClass="amount"></asp:Label>
                                                            <asp:Label ID="payoutCurr" runat="server"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="label">
                                                            Payment Mode:
                                                        </td>
                                                        <td>
                                                            <asp:Label ID="deleveryOpt" runat="server">Cash Payment</asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" class="tableForm">
                            <div runat="server" id="payOutBlock" visible="false">
                                <fieldset>
                                    <legend>Payment Information</legend>
                                    <table class="tableForm" style="width: 878px;" border="0" cellpadding="0" cellspacing="0">
                                        <%--<tr>
                                            <td>
                                                Receiver Country:
                                            </td>
                                            <td>
                                                 <asp:DropDownList runat="server" ID="recCountry" Style="width: 135px" 
                                                     AutoPostBack="true" 
                                                     onselectedindexchanged="recCountry_SelectedIndexChanged"></asp:DropDownList>
                                            </td>
                                            <td>
                                                Receiver State:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="rState" Style="width: 135px;">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>--%>
                                        <tr>
                                            <td>
                                                Receiver PhotoID Country:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" CssClass="required" ID="photoIdCountry" AutoPostBack="true"
                                                    Style="width: 135px" OnSelectedIndexChanged="photoIdCountry_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <span class="ErrMsg">*</span>
                                            </td>
                                            <td>
                                                Receiver PhotoID State:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="photoIdState" Style="width: 135px;">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                Address:
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" CssClass="required" Width="150px" ID="recAddress"></asp:TextBox><span
                                                    class="ErrMsg">*</span>
                                            </td>
                                            <td>
                                                City:
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" Width="150px" CssClass="required" ID="recCity"></asp:TextBox><span
                                                    class="ErrMsg">*</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                Receiver ID Type:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" CssClass="required" ID="rIdType" Style="width: 135px">
                                                </asp:DropDownList>
                                                <span class="ErrMsg">*</span>
                                            </td>
                                            <td>
                                                Receiver ID Number:
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" Width="150px" CssClass="required" ID="rIdNumber"></asp:TextBox>
                                                <span class="ErrMsg">*</span>
                                                 <div style="color:Red; font-size:smaller;" ><em>Receiver ID Number should be at least 4 digit for nepal</em></div>
                                            </td>
                                        </tr>                                    
                                     <tr>
                                            <td>
                                                Receiver Occupatioin:
                                            </td>
                                            <td>
                                                <asp:TextBox ID = "occupation" runat = "server" Width = "200px"></asp:TextBox>
                                            </td>
                                            <td>
                                                Receiver Contact Number:
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" Width="150px" ID="recPhoneNo"></asp:TextBox>                                                                                                
                                            </td>
                                        </tr>

                                        <tr>
                                          
                                            <td>
                                                Date of Birth:
                                            </td>
                                            <td>
                                            <asp:DropDownList Width="60px" runat="server" ID="dobYear" CssClass="required">
                                                    <asp:ListItem Value="">Year</asp:ListItem>
                                                </asp:DropDownList>
                                                <asp:DropDownList Width="80px" runat="server" ID="dobMonth" CssClass="required">
                                                    <asp:ListItem Value="">Month</asp:ListItem>
                                                    <asp:ListItem Value="1">Baishak</asp:ListItem>
                                                    <asp:ListItem Value="2">Jestha</asp:ListItem>
                                                    <asp:ListItem Value="3">Ashar</asp:ListItem>
                                                    <asp:ListItem Value="4">Shrawan</asp:ListItem> 
                                                    <asp:ListItem Value="5">Bhadra</asp:ListItem>
                                                    <asp:ListItem Value="6">Ashwin</asp:ListItem>
                                                    <asp:ListItem Value="7">Kartik</asp:ListItem>
                                                    <asp:ListItem Value="8">Mangsir</asp:ListItem>
                                                    <asp:ListItem Value="9">Poush</asp:ListItem>                                                
                                                    <asp:ListItem Value="10">Magh</asp:ListItem>
                                                    <asp:ListItem Value="11">Falgun</asp:ListItem>
                                                    <asp:ListItem Value="12">Chaitra</asp:ListItem>                                        
                                                </asp:DropDownList>
                                                 <asp:DropDownList Width="60px" runat="server" ID="dobDay" CssClass="required">
                                                    <asp:ListItem Value="">Day</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                Amount to be Paid:
                                            </td>
                                            <td colspan="3">
                                                <asp:TextBox ID="amtTobePaid" runat="server" class="required" Width="150px"></asp:TextBox><span
                                                    class="ErrMsg">*</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                Remarks:
                                            </td>
                                            <td colspan="3">
                                                <asp:TextBox ID="remarks" TextMode="MultiLine" runat="server" Height="30px" Width="250px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <asp:Button runat="server" ID="btnPay" Text="Pay Transaction" ValidationGroup="pay"
                                                    CssClass="button" OnClick="btnPay_Click" OnClientClick="return ConfirmPay();" />
                                                <input type="button" id="btnBack" class="button" value="Back" onclick="window.history.back()" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    <asp:HiddenField runat="server" ID="tranId" />
        <asp:HiddenField runat="server" ID="hdnDelOpt" />
        <asp:HiddenField runat="server" ID="hddAmt" />
    </form>
</body>
</html>
