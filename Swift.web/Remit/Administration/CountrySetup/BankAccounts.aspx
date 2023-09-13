<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankAccounts.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.BankAccounts" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript">
        var gridName = "<% = GridName %>";
        function ResetForm() {
            SetValueById("<% = hddCountryBankId.ClientID%>", "");
            SetValueById("<% = bankName.ClientID%>", "");
            SetValueById("<% = accountNumber.ClientID%>", "");
            SetValueById("<% = remarks.ClientID%>", "");
            GetElement("<% = isActive.ClientID%>").checked = false;
            SetValueById("lblMsg","",true);

        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID%>").disabled = false;
            SetValueById("<% =hddCountryBankId.ClientID%>", "0");
            ClearAll(gridName);
        }

        function OpenInEditMode(id) {
            SetValueById("lblMsg", "", true);
            if (id != "") {
                SetValueById("<% =hddCountryBankId.ClientID%>", id);
                GetElement("<% =btnLoad.ClientID%>").click();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
            } else {
                GetElement("<% =btnSave.ClientID%>").disabled = true;
                ResetForm();
                ClearAll(gridName);
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="upnl1" runat="server">
            <ContentTemplate>
                <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Panel ID="pnl2" runat="server">
                                <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td height="26" class="bredCrom">
                                            <div><%= GetCountryName()%></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="20" class="welcome"><span id="spnCname" runat="server"></span></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" class="formTable" style="width: 500px; margin-left: 10px">
                                <tr>
                                    <th colspan="2" class="frmTitle">Bank Accounts Setup</th>
                                </tr>
                                <tr>
                                    <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                                </tr>
                                <tr>

                                    <td colspan="2">
                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text="" Style="width: 100%; text-align: center"></asp:Label></td>
                                </tr>

                                <tr>
                                    <td>Bank Name
                                    </td>
                                    <td>
                                        <asp:TextBox ID="bankName" runat="server" CssClass="formText" Width="200px" MaxLength="50"></asp:TextBox><span class="ErrMsg">*</span>
                                        <asp:RequiredFieldValidator ID="rv1" ControlToValidate="bankName" runat="server" ForeColor="Red" ErrorMessage="Required" ValidationGroup="cb"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Account Number
                                    </td>
                                    <td>
                                        <asp:TextBox ID="accountNumber" runat="server" CssClass="formText" Width="200px" MaxLength="50"></asp:TextBox><span class="ErrMsg">*</span>
                                        <asp:RequiredFieldValidator ID="rv2" ControlToValidate="accountNumber" runat="server" ForeColor="Red" ErrorMessage="Required" ValidationGroup="cb"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Remarks
                                    </td>
                                    <td>
                                        <asp:TextBox TextMode="MultiLine" ID="remarks" runat="server"
                                            CssClass="formText" Width="289px" MaxLength="50"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td valign="middle">
                                        <asp:CheckBox ID="isActive" runat="server" Text="Active" />
                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td>
                                        <input type="button" id="btnNew" value="New" onclick="NewRecord();" />
                                        <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="cb"
                                            OnClick="btnSave_Click" />
                                        <asp:Button ID="btnLoad" runat="server" Text="Edit" OnClick="btnLoad_Click" Style="display: none" />
                                        <asp:HiddenField ID="hddCountryBankId" runat="server" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <br />
                            <div id="rpt_grid" runat="server"
                                style="width: 500px; margin-left: 7px">
                            </div>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnLoad" EventName="click" />
                <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="click" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
</body>
</html>