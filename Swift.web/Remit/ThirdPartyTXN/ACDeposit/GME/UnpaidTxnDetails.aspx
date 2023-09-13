<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UnpaidTxnDetails.aspx.cs" Inherits="Swift.web.Remit.ThirdPartyTXN.ACDeposit.GME.UnpaidTxnDetails" %>

<!DOCTYPE html>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base target="_self" runat="server" />
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
   
    <style type="text/css">
        .tranSearchStyle legend
        {
            background-color: White;
            border: 1px solid #CACACA;
            margin-left: 10px;
            padding: 4px 8px;
        }
        .color-red
        {
            color: Red;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hdnControlNo" runat="server" />
    <asp:HiddenField ID="hdnPaymentMode" runat="server" />
    <asp:HiddenField ID="hdnRowId" runat="server" />
    <asp:HiddenField ID="hdnContactNo" runat="server" />
    <asp:HiddenField ID="hdnRidType" runat="server" />
    <asp:HiddenField ID="hdnRidNo" runat="server" />
    <asp:HiddenField ID="hdnDestAmt" runat="server" />
    <asp:HiddenField ID="hdnPbankId" runat="server" />
    <asp:HiddenField ID="downloadTokenId" runat="server" />
    <asp:HiddenField ID="idType" runat="server" />
    <asp:HiddenField ID="idNo" runat="server" />
    <asp:HiddenField ID="hdnPbranchId" runat="server" />
    <asp:ScriptManager runat="server" ID="sm">
    </asp:ScriptManager>
    <div class="bredCrom">
        Pay Unpaid A/C Deposit</div>
    <div>
        <fieldset class="tranSearchStyle">
            <legend>Transaction Details</legend>
            <asp:UpdatePanel runat="server" ID="up">
                <ContentTemplate>
                    <a href="../../../Transaction/ReprintVoucher/PayIntlReceipt.aspx"></a>
                    <table style="width: 100%;">
                        <tr>
                            <td style="font-weight: bold; font-size: 15px; padding: 5px 10px;">
                                <span>Control No:</span>
                                <asp:Label ID="controlNo" runat="server" CssClass="color-red"></asp:Label>
                            </td>
                            <td style="font-weight: bold; font-size: 15px; padding: 5px 10px;">
                                <span>Tran Status:</span>
                                <asp:Label ID="tranStatus" Text="Unpaid" runat="server" CssClass="color-red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top" class="tableForm" style="width: 50%;">
                                <fieldset>
                                    <legend>Sender</legend>
                                    <table style="width: 100%" cellpadding="3" cellspacing="0">
                                        <tr style="background-color: #FDF79D;">
                                            <td class="label" style="font-weight: bold;">
                                                Name:
                                            </td>
                                            <td class="text" colspan="3" style="font-weight: bold;">
                                                <asp:Label ID="sName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Address:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="sAddress" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Country:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="sCountry" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Contact No:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Id Type:
                                            </td>
                                            <td class="text" style="width: 150px">
                                                <asp:Label ID="sIdType" runat="server"></asp:Label>
                                            </td>
                                            <td style="width: 60px;">
                                                Id No:
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label" nowrap="nowrap">
                                                Id Validity Date:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="sIdValidDate" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Nationality:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="sNationality" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                            <td valign="top" class="tableForm" style="width: 50%">
                                <fieldset>
                                    <legend>Receiver</legend>
                                    <table style="width: 100%" cellpadding="3" cellspacing="0">
                                        <tr style="background-color: #F9CCCC;">
                                            <td class="label" style="font-weight: bold; width: 25%;">
                                                Name:
                                            </td>
                                            <td class="text" colspan="3" style="font-weight: bold;">
                                                <asp:TextBox ID="rName" runat="server" Width="200px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Address:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="rAddress" runat="server"></asp:Label>
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
                                            <td class="label" nowrap="nowrap">
                                                Contact No:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 60px;">
                                                Id No:
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="rIdNo" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Button ID="btnRecNameUpdate" runat="server" Text="Update Receiver Name" class="button"
                                                    OnClick="btnRecNameUpdate_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <fieldset>
                                    <legend>Bank Deposit Details</legend>
                                    <table style="width: 100%">
                                        <tr>
                                            <td class="label">
                                                Bank Name:
                                            </td>
                                            <td class="text">
                                                <asp:TextBox runat="server" ID="rBankName" Width="200px"></asp:TextBox>
                                            </td>
                                            <td class="text">
                                                New Beneficiary Bank:
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="rBank" runat="server" Width="250" AutoPostBack="true" OnSelectedIndexChanged="rBank_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Bank Branch Name:
                                            </td>
                                            <td class="text" nowrap="nowrap">
                                                <asp:TextBox ID="rBranchName" runat="server" Width="200px"></asp:TextBox>
                                            </td>
                                            <td>
                                                New Beneficiary Branch:
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="rBankBranch" runat="server" Width="250">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Bank A/C No:
                                            </td>
                                            <td class="text">
                                                <asp:TextBox ID="rBankAcNo" runat="server" Width="200px"></asp:TextBox>
                                                
                                            </td>
                                            <td>
                                            </td>
                                            <td>
                                                <asp:Button runat="server" ID="updateBank" Text="Update Bank" OnClick="updateBank_Click" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Recieving Amount:
                                            </td>
                                            <td class="text">
                                                <asp:Label ID="rAmount" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="label">
                                                Recieving Currency:
                                            </td>
                                            <td class="text" colspan="3">
                                                <asp:Label ID="rCurrency" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Button ID="btnUpdateBank" runat="server" Text="Update Bank Details" OnClick="btnUpdateBank_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <%--<asp:Button ID="btnPay" runat="server" CssClass="button" Text="Pay Ac Deposit" OnClick="btnPay_Click" />--%>
                                &nbsp;
                                <input type="button" value="Do Not Pay Ac Deposit" onclick="window.close();" class="button" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </fieldset>
    </div>
    </form>
</body>
</html>
