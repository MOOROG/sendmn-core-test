<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendApprove.Manage" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target = "_self" runat = "server" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />
     <script type="text/javascript">
         function CallBack(mes, url) {
             var resultList = ParseMessageToArray(mes);
             alert(resultList[1]);

             if (resultList[0] != 0) {
                 return;
             }
             window.returnValue = resultList[0];
             window.location.replace(url);
         }
    </script>

    <style>
		legend
		{
			color:#FFFFFF;
			background:#FF0000;
			border-radius:2px;
		}	
				
		fieldset
		{
			border:1px solid #000000;
		}
		
		
		td
		{
			color:#000000;
		}
		
		.watermark
        {
            font-size: 14px;
        }
    </style> 
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID = "sm1" runat = "server"></asp:ScriptManager>      
        <div id="divControlno" runat="server">
            <table style="margin-left: 20px; width: 800px;" >                
                <tr>
                    <td>
                        <div id="divTranDetails" runat="server" visible="false">
                            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock = "true" ShowLogBlock = "false" ShowCompliance = "false" ShowOfac = "false" />
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Button ID = "btnApprove" runat = "server" Text = "Approve" 
                            onclick="btnApprove_Click" />
                    </td>
                </tr>            
            </table>
        </div> 
    </form>
</body>
</html>