<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.LoginLogs.List" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function UnlockUser(id) {
            if (confirm("Are you sure?")) {
                SetValueById("<%=hddUserId.ClientID %>", id, "");
                GetElement("<%=btnLockUnlockUser.ClientID %>").click();
            }
        }
       
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grdLoginLog_createdDate", 1);
        });
    </script>
</head>
<body>

    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <% var sl = new RemittanceLibrary();%>
    <%--  <% sl.BeginHeaderForGrid("Login View Logs"); %>--%>
           <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                              <li><a href="#" onclick="return LoadModule('system_security')">System Security</a></li>
                            <li class="active"><a href="List.aspx">Login-Logs</a></li>
                        </ol>
                    </div>
                </div>
            </div>
                  <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title"> Login View Logs</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="table-responsive">
                                          <div id = "rpt_grid" runat = "server"></div>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
       <%--  <div class="page-wrapper">
         <div class="panel-body">
        <div id = "rpt_grid" runat = "server"></div>
           --%>
        <% sl.EndHeaderForGrid();%>
        <asp:HiddenField ID="hddUserId" runat="server" />
        <asp:Button ID="btnLockUnlockUser" runat="server" style="display: none;" onclick="btnLockUnlockUser_Click" />
        <asp:UpdatePanel ID="upnl1" runat="server">
        <ContentTemplate>
            <div id="newDiv" style="position:absolute;margin-top: 17px; margin-left: 0px; display:none;">
                <table cellpadding="0" cellspacing="0" style="background: white;">
                    <tr>
                        <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">User Lock Reason</td>
                        <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                            <span title = "Close" style = "cursor:pointer;margin:2px;float:right;" onclick = "RemoveDiv();"><b>x</b></span>
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
          </div>  
   </form>
</body>
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
        var left = pos[0];
        var top = pos[1];
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
</html>
