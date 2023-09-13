<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListAgent.aspx.cs" Inherits="Swift.web.Remit.AgentOperation.UserManagement.ListAgent" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />

    <script type="text/javascript">
        function ManageUser(agentId) {
            var url = "../../../Remit/AgentOperation/UserManagement/List.aspx?agentId=" + agentId + "&mode=1";
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="ListAgent.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table class="table table-condensed">
                <tr>
                    <td height="20" class="welcome"><span id="spnName" runat="server"></span></td>
                </tr>
                <tr>
                    <td height="10">
                        <div class="tabs">
                            <ul>
                                <li><a href="#" class="selected">Branch List</a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td height="524" valign="top">
                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                        <asp:Button ID="btnLoadGrid" runat="server" OnClick="btnLoadGrid_Click" Style="display: none;" />
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>