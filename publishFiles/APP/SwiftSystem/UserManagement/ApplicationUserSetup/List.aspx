<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs"
    Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

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

    <script language="javascript">
        var oldId = 0;
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
        function RemoveDiv() {
            $("#newDiv").slideToggle("fast");
        }
        function ShowSlab(id, userName) {
            //        alert('test');
            //        return;
            $.get(urlRoot + "/SwiftSystem/UserManagement/ApplicationUserSetup/LockReason.aspx", { userName: userName }, function (data) {
                GetElement("showSlab").innerHTML = data;
                ShowHideServiceCharge(id);
            });
        }
        function ShowHideServiceCharge(id) {
            var pos = FindPos(GetElement("showSlab_" + id));
            var left = pos[0] + 5;
            var top = pos[1] - 230;
            GetElement("newDiv").style.left = left + "px";
            GetElement("newDiv").style.top = top + "px";
            GetElement("newDiv").style.border = "1px solid black";
            if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "") {
                $("#newDiv").slideToggle("fast");
            }
            else {
                if (id == oldId) {
                    $("#newDiv").slideToggle("fast");
                }
                else {
                    GetElement("newDiv").style.display = "none";
                    $("#newDiv").slideToggle("fast");
                }
            }
            oldId = id;
        }

        function HideDiv() {
            document.getElementById("showSlab").style.display = "none";
            document.getElementById("delImg").style.display = "none";
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="List.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">User List</a></li>
                    <li><a href="Manage.aspx">Manage User </a></li>
                    <li><a href="DeactivatedUserList.aspx">Deactived User </a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">User List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                    </div>
                                    <asp:HiddenField ID="hddUserName" runat="server" />
                                    <asp:HiddenField ID="hddUserId" runat="server" />
                                    <asp:HiddenField ID="hdnchangeType" runat="server" />
                                    <asp:Button ID="btnSendEmail" runat="server" Style="display: none;" OnClick="btnSendEmail_Click" />
                                    <asp:Button ID="btnLockUnlockUser" runat="server" Style="display: none;" OnClick="LockUnlockUser_Click" />
                                </div>
                            </div>
                            <asp:UpdatePanel ID="upnl1" runat="server">
                                <ContentTemplate>
                                    <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                                        <table cellpadding="0" cellspacing="0" style="background: white;">
                                            <tr>
                                                <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">User Lock Reason</td>
                                                <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                                                    <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick="RemoveDiv();"><b>x</b></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div id="showSlab" style="overflow: scroll; width: 400px;">N/A</div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                </div>
                <div role="tabpanel" class="tab-pane" id="Manage">
                </div>
            </div>
        </div>
        <script type="text/javascript">
            function ManageUserLoginScreen(user) {
                window.location.replace("RedirectLoginScreen.aspx?userName=" + user);
            }

        </script>
        <script type="text/javascript" language="javascript">
            function LockUnlock(user, changeType) {
                if (user == "" || user == null)
                    return;
                if (changeType == "l") {
                    if (confirm("Are you sure to lock/Unlock the user?")) {
                        GetElement("hddUserId").value = user;
                        GetElement("hdnchangeType").value = changeType;
                        GetElement("btnLockUnlockUser").click();
                    }
                }
                else if (changeType == "r") {
                    if (confirm("Are you sure to Reset the user Password?")) {
                        GetElement("hddUserId").value = user;
                        GetElement("hdnchangeType").value = changeType;
                        GetElement("btnLockUnlockUser").click();
                    }
                }
            }
            function SendEmail(userId, userName) {
                if (userId == null || userId == '' || userId == undefined) {
                    alert('Invalid user selected!');
                    return false;
                }
                $('#hddUserId').val(userId);
                $('#hddUserName').val(userName);
                $('#btnSendEmail').click();
            }
        </script>
    </form>
    <!--script--->
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>
