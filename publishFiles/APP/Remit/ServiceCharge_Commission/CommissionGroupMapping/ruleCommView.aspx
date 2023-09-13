<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ruleCommView.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionGroupMapping.ruleCommView" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
        <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../../js/functions.js" type="text/javascript"> </script>
        <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <table>
        <tr>
            <td align="left" valign="top" class="bredCrom"><asp:Label runat="server" ID="lblHeading"></asp:Label></td>
        </tr>

    <tr>
        <td height="10" class="shadowBG"></td>
    </tr>
        <div id="domestic" Visible="false" runat="server">

        <tr>
            <td align="left" valign="top" class="welcome">Domestic Commission</td>
        </tr>
        <tr>                
            <td>
                <div id="rpt_domestic" runat="server" ></div>
            </td>                            
        </tr>
    </div>
    <div id="serviceCharge" Visible="false" runat="server">
        <tr>
            <td align="left" valign="top" class="welcome">International Service Charge</td>
        </tr>
        <tr>                
            <td>
                <div id="rpt_sc" runat="server" ></div>
            </td>                            
        </tr>
    </div>
    <div id="payComm" Visible="false" runat="server">
    <tr>
        <td align="left" valign="top" class="welcome">International Pay Commission</td>
    </tr>
    <tr>                
        <td>
            <div id="rpt_cp" runat="server" ></div>
        </td>                            
    </tr>
    </div>
    <div id="sendComm" Visible="false" runat="server">
    <tr>
        <td align="left" valign="top" class="welcome">International Send Commission</td>
    </tr>
    <tr>                
        <td>
            <div id="rpt_cs" runat="server" ></div>
        </td>                            
    </tr>
    </div>
    </table>
    </form>
</body>
</html>
