<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApproveList.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.ExtraLimit.ApproveList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js"></script>

    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>

    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />

    <script type="text/javascript">
        function Approve(id) {
            if (id == "undefined" || id == null)
                return;
            if (confirm("Are you sure to approve?")) {
                SetValueById("<%=hdnId.ClientID %>", id, "");
                        GetElement("<%=btnApprove.ClientID %>").click();
                    }
                    else {
                        return false;
                    }
                }
                function Reject(id) {
                    if (id == "undefined" || id == null)
                        return;
                    if (confirm("Are you sure to reject?")) {
                        SetValueById("<%=hdnId.ClientID %>", id, "");
                        GetElement("<%=btnReject.ClientID %>").click();
                    }
                    else {
                        return false;
                    }
                }
    </script>
    <script type="text/javascript">

        $(document).ready(function () {
            ShowCalFromTo("#gridExtraLimitApproved_approvedDate", 1);

        });
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="ApproveList.aspx">Extra Limit Approve</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Extra Limit Approval List  </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="table-responsive">
                                <asp:Button ID="btnApprove" runat="server" OnClick="btnApprove_Click" Style="display: none;" />
                                <asp:Button ID="btnReject" runat="server" OnClick="btnReject_Click" Style="display: none;" />
                                <asp:HiddenField ID="hdnId" runat="server" />
                                <div id="rpt_grid" runat="server" class="gridDiv"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>