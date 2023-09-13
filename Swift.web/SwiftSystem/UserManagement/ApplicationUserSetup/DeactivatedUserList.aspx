<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeactivatedUserList.aspx.cs"
    Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.DeactivatedUserList" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
     <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
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

<%--    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />--%>
    <script type="text/javascript">
        function RestoreUser(id) {
            if (confirm("Are you sure to restore the user?")) {
                SetValueById("<%=hddUserId.ClientID %>", id, "");
                GetElement("<%=btnRestoreUser.ClientID %>").click();
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
                        <h1>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li ><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="DeactivatedUserList.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx">User List </a></li>
                    <li><a href="Manage.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">Manage User </a></li>
                    <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Deactived User</a></li>
                </ul>
            </div>
            
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        Deactivated User List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                    <asp:HiddenField ID="hddUserId" runat="server" />
                                    <asp:Button ID="btnRestoreUser" runat="server" Style="display: none;" OnClick="btnRestoreUser_Click" />
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
        <!--end .col--> </div><!--end .row--> 
        </div>
                <%-- <div role="tabpanel" class="tab-pane" id="Manage">
                     </div>--%>
            </div>
        </div>
    
    <asp:HiddenField ID="hdnParentId" runat="server" />
    <asp:HiddenField ID="hdnUserType" runat="server" />
    <asp:HiddenField ID="hdnAgentId" runat="server" />
    <asp:ScriptManager ID="ScriptManger1" runat="server">
    </asp:ScriptManager>

    <asp:UpdatePanel ID="upnl1" runat="server">
        <ContentTemplate>
            <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                <table cellpadding="0" cellspacing="0" style="background: white;">
                    <tr>
                        <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                            User Lock Reason
                        </td>
                        <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                            <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick="RemoveDiv();">
                                <b>x</b></span>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="showSlab" style="overflow: scroll; width: 300px;">
                                N/A</div>
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <!-- Flot -->
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.tooltip.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.resize.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.pie.js"></script>
    <script type="text/javascript" src="../../../ui/js/chartjs/Chart.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/pace.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/waves.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>
       <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
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
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../../Autocomplete.asmx/GetAgentNameList";
        var urlb = "../../../Autocomplete.asmx/GetBranchNameList";
        var urlu = "../../../Autocomplete.asmx/GetUserNameList";

        $("#grdDelUsr_parentName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urla,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdDelUsr_parentName", result[0], "");
            }

        });





        $("#grdDelUsr_branchName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urlb,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");

                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdDelUsr_branchName", result[0], "");
            }

        });


        $("#grdDelUsr_userName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urlu,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");

                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdDelUsr_userName", result[0], "");
            }
        });
    }

    Autocomplete();
</script>
</html>
