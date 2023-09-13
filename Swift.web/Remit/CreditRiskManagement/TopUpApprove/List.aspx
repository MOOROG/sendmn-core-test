<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TopUpApprove.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function Approve(id) {
            if (confirm("Are you sure to approve?")) {
                SetValueById("<%=hdnId.ClientID %>", id, "");
                SetValueById("<%=hdnAppAmt.ClientID %>", GetValue("topUp_" + id), "");
                GetElement("<%=btnApprove.ClientID %>").click();
            }
        }
        function Reject(id) {
            if (confirm("Are you sure to reject?")) {
                SetValueById("<%=hdnId.ClientID %>", id, "");
                GetElement("<%=btnReject.ClientID %>").click();
            }
        }
        function ViewDetail(btnId) {
            var url = "ViewDetail.aspx?btId=" + btnId;
            var ret = OpenDialog(url, 350, 500, 500, 100);
            if (ret) {
                window.location.replace("List.aspx");
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnAppAmt" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="List.aspx">Balance Top Up Approve</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Top Up Approval List</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Balance TopUp Approve </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
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
            </div>
        </div>
        <%--  <div class="bredCrom"> Credit Risk Management » Balance Topup Approve </div>
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
    <tr>
        <td width="100%" colspan="2">
        <table width="100%">
            <tr>
                <td height="10" width="100%">
                    <div class="tabs">
                        <ul>
                            <li> <a href="Javascript:void(0)" class="selected">Top Up Approval List</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td height="524" valign="top" colspan="2">
            <div id = "rpt_grid" runat = "server" class = "gridDiv" style="margin-left: 0px;"></div>
            <asp:HiddenField ID="hdnId" runat="server" />
            <asp:Button ID="btnApprove" runat="server" onclick="btnApprove_Click" style="display: none;" />
            <asp:Button ID="btnReject" runat="server" onclick="btnReject_Click" style="display: none;" />
            <asp:Button ID="btnCallBack" runat="server" onclick="btnCallBack_Click" style="display: none;" />
        </td>
    </tr>
    </table>--%>
    </form>
</body>
</html>