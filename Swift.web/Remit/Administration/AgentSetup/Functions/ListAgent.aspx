<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListAgent.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.ListAgent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/Swift_grid.js" type="text/javascript"></script>
    <script>
        function ManageAgent(agentId, agentType, parentId, actAsBranchFlag) {
            var url = "../../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?PageType=agentDetail&agentId=" + agentId + "&mode=2&aType=" + agentType + "&parent_id=" + parentId + "&actAsBranch=" + actAsBranchFlag;
            var param = "dialogHeight:600px;dialogWidth:1200px;dialogLeft:300;dialogTop:100;center:yes";
            PopUpWindow(url, param);
            CallBack();
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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('administration')">Account</a></li>
                            <li class="active"><a href="ListAgent.aspx">Agent Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent Details List
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
