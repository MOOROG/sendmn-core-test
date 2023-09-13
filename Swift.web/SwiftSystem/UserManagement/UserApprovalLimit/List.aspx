<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.UserApprovalLimit.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

</head>
<body>
        <form id="form2" runat="server">
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <ol class="breadcrumb">
                                <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                                <li><a href="../AgentUserSetup/List.aspx" >Agent User Setup</a></li>
                                <li class="active"><a href="List.aspx">Approval Limit </a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="listtabs">
                    <ul class="nav nav-tabs">
                        <li><a href="../ApplicationUserSetup/List.aspx?agentId=<%=GetAgentId() %>&mode=<%=GetMode() %>" target="_self">User List</a></li>
                        <li><a href="Manage.aspx?agentId=<%=GetAgentId() %>&userId=<%=GetUserId() %>&userName=<%=GetUserName()%>&mode=<%=GetMode() %>" target="_self">Manage</a></li>
                        <li class="active"><a href="List.aspx" class="selected" target="_self">Limit List</a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Approval Limit 
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="table table-responsive">
                                            <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                        </div>
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
