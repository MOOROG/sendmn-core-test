<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.ReceivingLimit.Manage" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Credit Risk Management » Transaction Limit » Country Wise » Receiving Limit » Manage </div> </td>
                        </tr>
                        <tr>
                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetCountryName()%></span></td>
                        </tr>
                        <%--<tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul> 
                                        <li> <a href="../List.aspx">Country Wise </a></li>
                                        <li> <a href="../SendingLimit/List.aspx?countryId=<%=GetCountryId()%>">Collection Limit</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Payment Limit</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Manage</a></li>
                                    </ul> 
                                </div>		
                            </td>
                        </tr>--%>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top" >       
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left" >
                    <tr>
                        <th colspan="2" class="frmTitle">Receiving Limit Details</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset>
                                <legend>Collection Limit(Country Wise)</legend>
                                <table>
                                    <tr>
                                        <td class="frmLable">
                                            Sending Country:
                                            <%--<span class="ErrMsg">*</span>--%>
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="sendingCountry" runat="server" Width="153px" CssClass="input"></asp:DropDownList> 
                                            <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="sendingCountry" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>--%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Receiving Mode</td>
                                        <td>
                                            <asp:DropDownList ID="receivingMode" runat="server" Width="153px" CssClass="input"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">
                                            Max Limit
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="maxLimitAmt" runat="server"></asp:TextBox>  
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">
                                            Max Limit for all Agent
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="agMaxLimitAmt" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="agMaxLimitAmt" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">
                                            Currency
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="currency" runat="server" Width="153px"></asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Customer Type</td>
                                        <td>
                                            <asp:DropDownList ID="customerType" runat="server" Width="153px"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">Branch Selection</td>
                                        <td colspan="2">
                                            <asp:DropDownList ID="branchSelection" runat="server" Width="153px">
                                            <asp:ListItem Value="Not Required">Not Required</asp:ListItem>
                                            <asp:ListItem Value="Manual Type">Manual Type</asp:ListItem>
                                            <asp:ListItem Value="Select">Select</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">Beneficiary Id Required</td>
                                        <td colspan="2">
                                            <asp:DropDownList ID="benificiaryIdreq" runat="server" Width="153px">
                                            <asp:ListItem Value="H">Hide</asp:ListItem>
                                            <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                            <asp:ListItem Value="O">Optional</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">Relationship Required</td>
                                        <td colspan="2">
                                            <asp:DropDownList ID="relationshipReq" runat="server" Width="153px">
                                            <asp:ListItem Value="H">Hide</asp:ListItem>
                                            <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                            <asp:ListItem Value="O">Optional</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">Beneficiary Contact Required</td>
                                        <td colspan="2">
                                            <asp:DropDownList ID="benificiaryContactReq" runat="server" Width="153px">
                                            <asp:ListItem Value="H">Hide</asp:ListItem>
                                            <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                            <asp:ListItem Value="O">Optional</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td><asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country" 
                                                        CssClass="button" onclick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>&nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" 
                                                        onclick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                       ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender> &nbsp; 
                                            <input id="btnBack" type="button" value="Back" class="button" onClick=" Javascript:history.back(); " />
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
