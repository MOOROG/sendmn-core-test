<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js"></script>


    <script type="text/javascript" language="javascript">
        function LockUnlock(user, changeType) {
            if (user == "" || user == null)
                return;
            if (changeType == "l") {
                if (confirm("Are you sure to lock/Unlock the user?")) {
                    GetElement("hddUserId").value = user;
                    GetElement("hdnchangeType").value = changeType;
                    GetElement("LockUnlockUser").click();
                }
            }
            else if (changeType == "r") {
                if (confirm("Are you sure to Reset the user Password?")) {
                    GetElement("hddUserId").value = user;
                    GetElement("hdnchangeType").value = changeType;
                    GetElement("LockUnlockUser").click();
                }
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="List.aspx">Admin User Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="active"><a href="#list" target="_self">User List</a></li>
                    <li><a href="Manage.aspx" target="_self">Manage User </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Admin Users List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                    <asp:HiddenField ID="hddUserId" runat="server" />
                                    <asp:HiddenField ID="hdnchangeType" runat="server" />
                                    <asp:Button ID="LockUnlockUser" runat="server" Text="Lock User" Style="display: none" OnClick="LockUnlockUser_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
