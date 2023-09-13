<%@ Page  Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.Manage" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
        <link href="../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../js/functions.js" type="text/javascript"> </script>
    </head>
    


<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
         <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom"> <div > Manual OFAC Entry >> Manage </div> </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG"></td>
        </tr>
        <tr>
            <td height="10"> 
                <div class="tabs" > 
                    <ul> 
                        <li> <a href="List.aspx" >OFAC List </a></li>
                        <li> <a href="#" class="selected"> OFAC Manage </a></li>
          
                    </ul> 
                </div>		
            </td>
        </tr>
        <tr>

        <td >
<table  border="0" cellspacing="0" cellpadding="0" class="formTable" style="margin-left: 15px;">
                            <tr>
                                <th colspan="5" class="frmTitle">OFAC Entry</th>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>                                </td>
                            </tr>
							
							
							<tr>
                                <td>ENTNUM (Unique Key)<br />
                                <asp:TextBox runat="server" ID="entNum"></asp:TextBox></td>
								<td>Type <span class="errormsg">*</span>
								  <asp:RequiredFieldValidator  ID="Rfd3" runat="server" ControlToValidate="vesselType" 
                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                  <br />
                                  <asp:DropDownList ID="vesselType" runat="server" Width="135px" CssClass="required">
                                    <asp:ListItem Value="Individual">Individual</asp:ListItem>
                                    <asp:ListItem Value="Company">Company</asp:ListItem>
                                    <asp:ListItem Value="Organization">Organization</asp:ListItem>
                                  </asp:DropDownList></td>
							  <td>&nbsp;</td>
							</tr>
							
        <tr>
        <td colspan="3">                Name
                <span class="errormsg">*</span>
                <asp:RequiredFieldValidator  ID="Rfd1" runat="server" ControlToValidate="Name" 
                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                <br />
              <asp:TextBox ID="Name" runat="server" Width="500px" CssClass="required"></asp:TextBox>                                       </td>
          </tr>
        <tr>
          <td colspan = "3"> Address <br />
              <asp:TextBox ID="Address" runat="server" CssClass="required" Width="500px" ></asp:TextBox>          </td>
          </tr>
        <tr>
            <td style="width: 180px;">
                City                
                <br />
                <asp:TextBox ID="City" runat="server" Width="135px" CssClass="required"></asp:TextBox>            </td>
            <td style="width: 180px;">
                State
                <br />
                <asp:TextBox ID="State" runat="server" Width="135px" CssClass="required"></asp:TextBox>            </td>
            <td style="width: 180px;">
                Zip
               <br />
                <asp:TextBox ID="Zip" runat="server" Width="135px" CssClass="required"></asp:TextBox>            </td>

        </tr>
        <tr>
            <td style="width: 180px;">
                Data Source<br/>
                <asp:TextBox ID="DataSource" runat="server" CssClass="input" Width="130px"></asp:TextBox>
                <br/>            </td>
            <td><span style="width: 180px;">Country <br />
                <asp:DropDownList ID="Country" runat="server" Width="135px" CssClass="required"> </asp:DropDownList>
            </span> </td>
            <td></td>
            
        </tr>
      
	   <tr>
          <td colspan = "3"> 
              Remarks<br />
                                                    <asp:TextBox ID="Remarks" runat="server" Height="50px" TextMode="MultiLine" 
                                                                 Width="500px"></asp:TextBox>
                                                    <cc1:TextBoxWatermarkExtender ID="TBWE2" runat="server"
                                                        TargetControlID="Remarks"
                                                        WatermarkText="Place of Birth ,Nationality ,Job ,Reference etc.."
                                                        WatermarkCssClass="watermark" />             </td>
          </tr>
		  
            <tr>
             <td colspan="4">
                                                    <asp:Button ID="bntSubmit" runat="server" Text=" Save " CssClass="button" ValidationGroup="agent"
                                                                onclick="bntSubmit_Click"/>

                                                    <asp:Button ID="Button1" runat="server" Text=" Back " CssClass="button" 
                                                        ValidationGroup="agent" onclick="Button1_Click" />
                                                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server" 
                                                                               ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">     
                                                     </cc1:ConfirmButtonExtender>  
                                                  
                                                    </td>
                                                </tr>
            <tr>
              <td colspan="4">&nbsp;</td>
            </tr>
                                        </table>
          </td>
                                        </tr>
                                        </table>
</form>
</body>
</html>
