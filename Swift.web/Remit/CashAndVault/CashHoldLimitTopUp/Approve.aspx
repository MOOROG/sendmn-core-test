<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Approve.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.CashHoldLimitTopUp.Approve" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
      <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js"></script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>

    <script type="text/javascript">
        function Approve(id) {
            if (confirm("Are you sure to approve?")) {
                SetValueById("<%=hdnId.ClientID %>", id, "");
                GetElement("<%=btnApprove.ClientID %>").click();
            }
        }

        function Reject(id) {
            if (confirm("Are you sure to reject?")) {
                SetValueById("<%=hdnId.ClientID %>", id, "");
                GetElement("<%=btnReject.ClientID %>").click();
            }
        }
    </script>
</head>
<body>
     <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li class="active"><a>Exchange Setup</a></li>
							<li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="Approve.aspx">Cash Hold Limit TopUp Approve</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Cash Hold Limt TopUp Approve
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <div id="rpt_grid" runat="server"></div>
                                <asp:HiddenField ID="hdnId" runat="server" />
                                <asp:Button ID="btnApprove" runat="server" OnClick="btnApprove_Click" Style="display: none;" />
                                <asp:Button ID="btnReject" runat="server" OnClick="btnReject_Click" Style="display: none;" />
                                <asp:Button ID="btnCallBack" runat="server" OnClick="btnCallBack_Click" Style="display: none;" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
