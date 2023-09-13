<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DomesticAgentList.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AgentSetup.DomesticAgentList" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript">
        function ManageUser(agentId) {
            var url = "../../../SwiftSystem/UserManagement/ApplicationUserSetup/List.aspx?agentId=" + agentId + "&mode=1";
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
        function ManageAgent(agentId, agentType, parentId, actAsBranchFlag) {
            var url = "Manage.aspx?agentId=" + agentId + "&mode=2&aType=" + agentType + "&parent_id=" + parentId + "&actAsBranch=" + actAsBranchFlag;
            var param = "dialogHeight:600px;dialogWidth:1200px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
            CallBack();
        }
        function ManageAgentFunction(agentId, agentType, actAsBranchFlag) {
            var url = "Functions/BusinessFunction.aspx?agentId=" + agentId + "&mode=2&aType=" + agentType + "&actAsBranch=" + actAsBranchFlag;
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
        function ManageAgentInfo(agentId) {
            var url = "AgentInfo/List.aspx?agentId=" + agentId + "&mode=2";
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
        function CallBack() {
            GetElement("<%=btnLoadGrid.ClientID %>").click();
        }
    </script>

</head>
<body>
<form id="form1" runat="server">
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">Domestic Operation » Setup Nepal Agents » List </td>
        </tr>
        <tr>
            <td height="20" class="welcome"><span id="spnName" runat="server"></span></td>
        </tr>
        <tr>
            <td height="10"> 
                <div class="tabs" > 
                    <ul> 
                        <li id="superAgent" runat="server"></li>
                        <li id="agent" runat="server"></li>
                        <li id="branch" runat="server"></li>
                    </ul> 
                </div> 
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">

                <div id = "rpt_grid" runat = "server" class = "gridDiv"></div>
                <asp:Button ID="btnLoadGrid" runat="server" onclick="btnLoadGrid_Click" style = "display: none;" />
            </td>
        </tr>
    </table>
</form>
</body>
</html>
