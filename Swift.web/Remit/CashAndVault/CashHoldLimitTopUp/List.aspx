<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.CashHoldLimitTopUp.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
      <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js"></script>
    <script src="/js/Swift_grid.js"></script>
    <script src="/js/swift_autocomplete.js"></script>

    <script type="text/javascript">
        function TopUp(id) {
            if (id == "undefined" || id == null)
                return;
            if (GetValue("topUp_" + id) == null || GetValue("topUp_" + id) == '' || GetValue("topUp_" + id) == '0') {
                alert('Topup amount can not be blank or 0!');
                return false;
            }
            SetValueById("<%=hdnAmount.ClientID %>", GetValue("topUp_" + id), "");
            SetValueById("<%=hdnAgentId.ClientID %>", id, "");
            GetElement("<%=btnTopUp.ClientID %>").click();
        }
    </script>
</head>
<body>
      <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li class="active"><a>Exchange Setup</a></li>
							<li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="List.aspx">Cash Hold Limit Top Up</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Cash Hold Limit Top Up List
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                          
                            <div class="form-group">
                                <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                                <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                                <asp:HiddenField ID="hdnAgentId" runat="server" />
                                <asp:HiddenField ID="hdnAmount" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>


