<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PackageAdd.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionGroupMapping.PackageAdd" %>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
            <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
            <script src="../../../js/functions.js" type="text/javascript"> </script>
        <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    </head>

<body>
    <form id="form1" runat="server">

                <table id="Table1" runat="server" style="margin-top:120px">                      
                        <tr>
                            <td height="26" class="bredCrom"> <div> Commission Group Mapping  » Commission Package Detail</div> </td>
                        </tr>
                        <tr>
                            <td height="20" class="welcome"><span id="spnCname" runat="server">NAME</span></td>
                        </tr>
                        <tr>
                            <td>
                                <div id = "rpt_grid" runat = "server"></div> 
                            </td>
                        </tr>  
                        <tr>
                            <td>
                                <asp:Button ID="btnAdd" runat="server" Text="Add Selected" CssClass="button" 
                                    onclick="btnAdd_Click" />
                                <asp:HiddenField ID="hddFlag" runat="server" />
                            </td>
                        </tr>                             
                       
                </table>
  
    </form>
</body>
</html>
