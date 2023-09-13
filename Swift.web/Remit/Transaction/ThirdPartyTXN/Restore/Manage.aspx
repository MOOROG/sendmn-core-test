<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.ThirdPartyTXN.Restore.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <div class="bredCrom">
                        Third Party Transaction » Restore Transaction</div>
                    <div>
                        <asp:HiddenField ID="hddControlNo" runat="server" />
                        <asp:HiddenField ID="hddRowId" runat="server" />
                    </div>
                </td>
            </tr>
            <tr>
                <td height="10" class="shadowBG">
                </td>
            </tr>
            <tr>
                <td>
                    <table border="0" cellspacing="0" cellpadding="0" width="350px" class="formTable">
                        <tr>
                            <th colspan="2" class="frmTitle">
                                Restore Txn
                            </th>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" class="formLabel">
                                Partner:
                            </td>
                            <td nowrap="nowrap">
                                <asp:DropDownList ID="partner" runat="server" Width="200px">
                                    <asp:ListItem Value="">Select Partner</asp:ListItem>
                                    <asp:ListItem Value="2054" Text="Global Bank"></asp:ListItem>
                                   <%-- <asp:ListItem Value="1009" Text="Instant Cash"></asp:ListItem>--%>
                                    <asp:ListItem Value="1096" Text="Cash Express"></asp:ListItem>
                                    <asp:ListItem Text="Easy Remit" Value="4726"></asp:ListItem>
                                    <asp:ListItem Text="Ria Remit" Value="4869"></asp:ListItem>
                                </asp:DropDownList>
                                &nbsp;<span class="ErrMsg">*</span>
                                <asp:RequiredFieldValidator ID="rfv1" runat="server" ErrorMessage="!Required" ForeColor="Red"
                                    ControlToValidate="partner" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" class="formLabel">
                                Control No:
                            </td>
                            <td>
                                <asp:TextBox ID="controlNo" runat="server" Width="192px"></asp:TextBox>&nbsp;<span
                                    class="ErrMsg">*</span>
                                <asp:RequiredFieldValidator ID="rfv2" runat="server" ErrorMessage="!Required" ForeColor="Red"
                                    ControlToValidate="controlNo" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <div id="txnDetails" runat="server" style="padding: 5px;">
                        <table width="800px" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td colspan="2">
                                    <fieldset>
                                        <legend>Payment Details</legend>
                                        <table>
                                            <tr>
                                                <td width="23%" nowrap="nowrap">
                                                    Control No:
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblControlNo" runat="server" CssClass="text-amount"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    Payout Amount:
                                                </td>
                                                <td>
                                                    <asp:Label ID="pAmt" runat="server" CssClass="text-amount"></asp:Label>
                                                    <asp:Label ID="pCurr" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    Payout Branch:
                                                </td>
                                                <td>
                                                    <asp:Label ID="pBranch" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td valign="top">
                                                <fieldset style="width: 400px;">
                                                    <legend>Sender Details</legend>
                                                    <table width="100%" border="0">
                                                        <tr>
                                                            <td width="22%">
                                                                Name:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="sName" runat="server" CssClass="text-heighlight"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                Address:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                City:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="sCity" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                Country:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="sIdType" runat="server"></asp:Label>No:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="sIdNumber" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td valign="top">
                                                <fieldset style="width: 400px;">
                                                    <legend>Receiver Details</legend>
                                                    <table width="100%" border="0">
                                                        <tr>
                                                            <td width="30%">
                                                                Name:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rName" runat="server" CssClass="text-heighlight"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                Address:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                City:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rCity" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                Country:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                Contact No:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rPhone" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="rIdType" runat="server"></asp:Label>
                                                                No:
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="rIdNumber" runat="server"></asp:Label>
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
                                <td colspan="2" align="center">
                                    <asp:Button ID="btnRestore" runat="server" CssClass="button" Text="Restore Transaction"
                                        OnClick="btnRestore_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
