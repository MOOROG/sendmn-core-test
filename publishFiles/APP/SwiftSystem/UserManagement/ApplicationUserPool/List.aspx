<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserPool.List" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js"></script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <%--<script src="../../../js/functions.js" type="text/javascript"> </script>--%>

    <style>
        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
            text-transform: capitalize;
        }

            .page-title h1 {
                color: #656565;
                font-size: 20px;
                text-transform: uppercase;
                font-weight: 400;
            }

            .page-title .breadcrumb {
                background-color: transparent;
                margin: 0;
                padding: 0;
            }

        .breadcrumb > li {
            display: inline-block;
        }

            .breadcrumb > li a {
                color: #0E96EC;
            }

            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }

        .table .table {
            background-color: #F5F5F5;
        }

        .responsive-table {
            width: 1134px;
            overflow-x: scroll;
        }

        .table-scroll {
            overflow-x: scroll;
        }
    </style>
    <script type="text/javascript">
        var seconds = 60;
        var tim1;
        f1();
        function FlushUser(username) {
            if (confirm("Are you sure to force logout this user?")) {
                GetElement("<%=hddUsername.ClientID%>").value = username;
                GetElement("<%=btnFlushUser.ClientID%>").click();
            }
        }

        function UserDetail(userId, url) {

            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            var url = url + "?userId=" + userId + "&mode=1";
            var id = PopUpWindow(url, param);
        }

        function f1() {
            seconds = parseInt(seconds) - 1;
            if (seconds == 0) {
                GetElement("btnSubmit").click();
                seconds = 60;
            }
            tim1 = setTimeout("f1()", 1000);
        }

        function Sort(sortBy, sortOrder) {
            var sortBy_hdd = GetElement("<%=hdnSortBy.ClientID %>");
            //            if (sortBy_hdd != null)
            sortBy_hdd.value = sortBy;
            var sortOrder_hdd = GetElement("<%=hdnSortOrder.ClientID %>");
            //            if (sortOrder_hdd != null)
            sortOrder_hdd.value = sortOrder;
            GetElement("btnSubmit").click();
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">

        <div style="margin-top: 125px;"></div>
        <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
                <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                <li class="active"><a href="List.aspx">User Monitor</a></li>
            </ol>
        </div>

        <asp:ScriptManager runat="server">
        </asp:ScriptManager>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title">User Monitor</h4>
                <div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                </div>
            </div>
            <div class="panel-body">
                <div style="margin-left: 20px;">
                    <asp:Button ID="btnFlushAllUser" runat="server" Text="Force Logout All Users"
                        OnClick="btnFlushAllUser_Click" CssClass="btn btn-primary" />
                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                        ConfirmText="Are you sure to force logout all users?" Enabled="True" TargetControlID="btnFlushAllUser">
                    </cc1:ConfirmButtonExtender>
                </div>

                <asp:UpdatePanel ID="upnl1" runat="server">
                    <ContentTemplate>
                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnFlushUser" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                <asp:Button ID="btnFlushUser" runat="server" OnClick="btnFlushUser_Click" Style="display: none;" />
                <asp:HiddenField ID="hddUsername" runat="server" />
                <asp:HiddenField ID="hdnSortOrder" runat="server" />
                <asp:HiddenField ID="hdnSortBy" runat="server" />
                <asp:Button ID="btnManagePageSize" runat="server" Style="display: none;"
                    OnClick="btnManagePageSize_Click" />

                <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />

            </div>
        </div>
    </form>
</body>
<script type="text/javascript">
    function nav(page) {
        var hdd = document.getElementById("hdd_curr_page");
        if (hdd != null)
            hdd.value = page;

        submit_form();
    }
    function submit_form() {
        var btn = document.getElementById("<%=btnHidden.ClientID %>");
        if (btn != null)
            btn.click();
    }

    function ClearFilter() {
        GetElement("userName").value = "";
        GetElement("agentName").value = "";
        submit_form();
    }
</script>
</html>
