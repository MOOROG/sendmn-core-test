<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AgentSetup.List" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
      <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script type="text/javascript">
        function ManageFileFormat(agentId) {
            var url = "FileFormat/List.aspx?agentId=" + agentId;
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
        function ManageUser(agentId) {
            var url = "../../../SwiftSystem/UserManagement/AgentUserSetup/List.aspx?agentId=" + agentId + "&mode=1";
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            OpenInNewWindow(url);
        }
        function ManageAgent(agentId, agentType, parentId, actAsBranchFlag) {
            var url = "Manage.aspx?agentId=" + agentId + "&mode=2&aType=" + agentType + "&parent_id=" + parentId + "&actAsBranch=" + actAsBranchFlag;
            var param = "dialogHeight:600px;dialogWidth:1200px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
            CallBack();
        }
        function ManageAgentFunction(agentId, agentType, actAsBranchFlag) {
            var url = "/Remit/Administration/AgentSetup/Functions/BusinessFunction.aspx?agentId=" + agentId + "&mode=2&aType=" + agentType + "&actAsBranch=" + actAsBranchFlag;
            var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
        }
        //function ManageAgentInfo(agentId) {
        //    var url = "AgentInfo/List.aspx?agentId=" + agentId + "&mode=2";
        //    var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
        //    PopUpWindow(url, param);
        //}
        function CallBack() {
            GetElement("<%=btnLoadGrid.ClientID %>").click();
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
                        <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                        <li class="active"><a href="List.aspx">Agent Management</a></li>
                    </ol>
                </div>
            </div>
        </div>
     
        <div class="report-tab">
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li id="superAgent" runat="server"></li>
                    <li id="agent" runat="server"></li>
                    <li id="branch" runat="server"></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
               
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        Agents List
                                        <asp:Label ID="totalAgents" runat="server" Visible="false"></asp:Label>
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv">
                                    </div>
                                </div>
                                <asp:Button ID="btnLoadGrid" runat="server" OnClick="btnLoadGrid_Click" Style="display: none;" />
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
