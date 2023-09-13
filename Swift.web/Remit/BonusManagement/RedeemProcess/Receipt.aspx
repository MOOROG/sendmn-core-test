<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Receipt.aspx.cs" Inherits="Swift.web.Remit.BonusManagement.RedeemProcess.Receipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
	<link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
     <div style="margin-left:12px" id="officeReceipt" runat="server">
        <table cellspacing="0" cellpadding="0" style="width: auto;">
            <tr>
                <td valign="top" colspan="2">
                    <div style="float:left;">
                        <img src="../../../Images/IMELogo.jpg" style="height:70px;width:118px;"/>
                    </div>
                <div style="float:left; margin-left:60px;" runat="server" id="divHeadMsg">
                       
                </div>
                </td>
            </tr>
            <tr>
              <td colspan="8" style="height:20px">
              </td>
          </tr>
          <tr>
              <td colspan="8">
              </td>
          </tr>
          <tr>
              <td colspan="9" style="height:15px; width:950px !important;">
                  <div id="rptReport" runat="server" style="width:950px !important;"></div>
               </td>
          </tr>
          <tr>
              <td colspan="8">
              </td>
          </tr>
          <tr>
              <td colspan="8">
              </td>
          </tr>
          <tr>
            <td colspan="8" height="60px" style="vertical-align:bottom">
                Redeemed: <span id="red" runat="server" visible="false" style="font-weight:bold"><asp:Label ID="redeemed" runat="server"></asp:Label></span>
            </td>
          </tr>
          <tr>
            <td colspan="8">
            </td>
          </tr>
          <tr>
            <td width="450px" style="vertical-align:bottom">
                Prepared By:&nbsp;<span runat="server" id="prepareBy"></span>
            </td>
            <td>
               <div style="margin-left:270px">
                    <b><hr width="140px"/></b>
                    <center>Customer</center>
               </div> 
            </td>
          </tr>
          <tr>
            <td colspan="8"></td>
          </tr>
          <tr>
            <td colspan="8"></td>
          </tr>
          <tr>
            <td colspan="8" style="height:80px;vertical-align:bottom;text-align:center">                        
                Thank You,<br />
                <span runat="server" id="agentName"></span><br /> 
                Send Money and WIN BONUS with PRIZES
            </td>
          </tr>
        </table>
    </div>
    <div style="height:40px;"></div>
    <div style="height:50px;width:auto;" >
        <center><b>----------------------------------------------------------------------------------------------------</b></center>
    </div>
    <div id="customerReceipt" runat="server"></div>
    </form>
</body>
</html>
