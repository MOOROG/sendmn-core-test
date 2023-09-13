<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerList.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.CustomerList" %>

<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
         <script type="text/javascript">
             var gridName = "<% =GridName%>";

             function GridCallBack() {
                 var id = GetRowId(gridName);

                 if (id != "") {
                     GetElement("<% =btnEdit.ClientID%>").click();
                     GetElement("<% =btnAddNew.ClientID%>").disabled = false;
                 } else {
                     GetElement("<% =btnAddNew.ClientID%>").disabled = true;
                     ResetForm();
                     ClearAll(gridName);
                 }
             }

             function ResetForm() {
                 SetValueById("<% =customerName.ClientID%>", "");
                 SetValueById("<% =customerAddress.ClientID%>", "");
                 SetValueById("<% =email.ClientID%>", "");
                 SetValueById("<% =mobile.ClientID%>", "");
             }

             function NewRecord() {
                 ResetForm();
                 GetElement("<% =btnAddNew.ClientID%>").disabled = false;
                 SetValueById("<% =hdnId.ClientID%>", "0");
                 ClearAll(gridName);
             }

     </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <div>
       <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:Panel ID="pnl2" runat="server" >
                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Messsage Setting » Customer Contact List</div> </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul> 
                                        <li> <a href="CategoryList.aspx">Category List</a></li>
                                         <li> <a href="Javascript:void(0)" class="selected">Customer Contact List</a></li>
                                    </ul> 
                                </div>		
                            </td>
                        </tr>
                     </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <asp:UpdatePanel ID="upnl1" runat="server">
                    <ContentTemplate>
                        <table border="0" cellspacing="0" cellpadding="0" class="formTable" style="width: 500px;" >
                            <tr>
                                <th colspan="2" class="frmTitle">Contact Category</th>
                            </tr>
                            <tr>
                                <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                            </tr>
                            <tr>
                                <td class="frmLable" nowrap="nowrap">Category Name: </td>
                                <td><asp:Label runat="server" ID="lblCategoryName"></asp:Label> </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td><asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                </td>
                            </tr>
                             <tr>
                                <td class="frmLable" nowrap="nowrap">Customer Name :</td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="customerName" runat="server" CssClass="input" Width="300px"></asp:TextBox>  
                                    <span class="errormsg">*</span>  
                                    <asp:RequiredFieldValidator  ID="RequiredFieldValidator2" runat="server" ControlToValidate="customerName" 
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="money" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>         
                                </td>
                            </tr> 
                            <tr>
                                <td class="frmLable" nowrap="nowrap">Customer Address :</td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="customerAddress" runat="server" CssClass="input" Width="300px"></asp:TextBox>
                                    <span class="errormsg">*</span>  
                                    <asp:RequiredFieldValidator  ID="RequiredFieldValidator1" runat="server" ControlToValidate="customerAddress" 
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="money" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="frmLable" nowrap="nowrap">Email :</td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="email" runat="server" CssClass="input" Width="300px"></asp:TextBox>
                                    <span class="errormsg">*</span>  
                                    <asp:RequiredFieldValidator  ID="RequiredFieldValidator3" runat="server" ControlToValidate="email" 
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="money" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="frmLable" nowrap="nowrap">Mobile :</td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="mobile" runat="server" CssClass="input" Width="300px"></asp:TextBox>
                                    <span class="errormsg">*</span>  
                                    <asp:RequiredFieldValidator  ID="RequiredFieldValidator4" runat="server" ControlToValidate="mobile" 
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="money" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>
                                      <asp:Button runat="server" ID="btnAddNew" Text=" Save " CssClass="button" 
                                            onclick="btnAddNew_Click" ValidationGroup="money"/> 

                                      <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="button" style="display: none;"
                                                onclick="btnEdit_Click"  />  

                                      <input id="btnBack" type="button" class="button" value="Back" onclick=" Javascript:history.back(); " />
                                    <input type = "button" value = "New" onclick = " NewRecord(); " class = "button" />
                                </td>
                            </tr>
                            <tr>                
                                <td colspan="2">
                                    <div id="rpt_grid" runat="server" style = "margin-left: 5px;"></div>
                                </td>                            
                            </tr>
                        </table>
                        <asp:HiddenField ID="hdnId" runat="server" />
                    </ContentTemplate>
                    <Triggers>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    </div>
    </form>
</body>
</html>
