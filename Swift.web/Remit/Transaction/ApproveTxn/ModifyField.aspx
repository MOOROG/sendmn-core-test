<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyField.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveTxn.ModifyField" %>

<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target = "_self" runat = "server" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
     <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
     <script src="../../../js/functions.js" type="text/javascript"> </script>
     <script type="text/javascript">
         function CallBack(mes) {
             var resultList = ParseMessageToArray(mes);
             alert(resultList[1]);

             if (resultList[0] != 0) {
                 return;
             }

             window.returnValue = resultList[0];
             window.close();
         }
     </script>
</head>
<body>
    <form id="form1" runat="server">
       <asp:ScriptManager runat="server" id="sc"></asp:ScriptManager>
    <div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td height="26" class="bredCrom"> <div >Modify Transaction » Modify Field</div> </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG"></td>
        </tr>
      
        <tr>
            <td>
                    <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                    <asp:HiddenField ID = "hddField" runat = "server" />
                    <asp:HiddenField ID = "hddOldValue" runat = "server" />
                    <asp:HiddenField ID = "hdnValueType" runat="server" />
                        <tr>
                            <td>
                                <div align="right">Field Name : </div>
                            </td>
                            <td>
                                <asp:Label ID="lblFieldName" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">Old Value : </div>
                            </td>
                            <td>
                                <asp:Label ID="lblOldValue" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <div id="rptShowOther" runat="server" > 
                        <tr>
                            <td>
                                <div align="right">New Value : </div>
                            </td>
                            <td>
                                <asp:TextBox ID = "txtNewValue" runat = "server" CssClass="input" MaxLength="200"></asp:TextBox>
                                <asp:TextBox ID = "txtContactNo" runat = "server" CssClass="input" MaxLength="200"></asp:TextBox>
                                <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender" 
                                    runat="server" Enabled="True" FilterType="Numbers" TargetControlID="txtContactNo">
                                </cc1:FilteredTextBoxExtender> 
                                <asp:DropDownList ID="ddlNewValue" runat="server" CssClass="input"></asp:DropDownList>
                            </td>
                        </tr>
                        </div>
                         <div id="rptName" runat="server" visible="false">
                         <tr>
                            <td><div align="right">First Name : </div></td>
                            <td><asp:TextBox ID = "txtFirstName" runat = "server" CssClass="input" MaxLength="50"></asp:TextBox></td>
                         </tr>
                        <tr>
                            <td><div align="right">Middle Name : </div></td>
                            <td><asp:TextBox ID = "txtMiddleName" runat = "server" CssClass="input" MaxLength="50"></asp:TextBox></td>
                         </tr>
                        <tr>
                            <td><div align="right">First Last Name : </div></td>
                            <td><asp:TextBox ID = "txtLastName1" runat = "server" CssClass="input" MaxLength="50"></asp:TextBox></td>
                        </tr>
                        <tr>
                            <td><div align="right">Second Last Name : </div></td>
                            <td><asp:TextBox ID = "txtLastName2" runat = "server" CssClass="input" MaxLength="50"></asp:TextBox></td>
                         </tr>
                        </div>
                       
                        <tr>
                            <td>&nbsp;</td>
                            <td>
                            <asp:Button ID="btnUpdate" runat="server" Text=" Update " CssClass="button" 
                                        onclick="btnUpdate_Click" />
                            </td>
                        </tr>
                    </table>
            </td>
        </tr>
    </table>  
    </div>
    </form>
</body>


</html>
