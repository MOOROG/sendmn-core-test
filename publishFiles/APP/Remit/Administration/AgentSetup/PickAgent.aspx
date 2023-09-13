<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PickAgent.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.PickAgent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script type="text/javascript">
        function CallBack(res) {
            window.returnValue = res;
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="524" valign="top">

                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                    <asp:Button ID="btnPick" runat="server" Text="Pick" CssClass="btn btn-primary" Style="margin-left: 50px;"
                        OnClick="btnPick_Click" />
                </td>
            </tr>
        </table>
    </form>
</body>
</html>