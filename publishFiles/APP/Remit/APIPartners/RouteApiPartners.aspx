<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RouteApiPartners.aspx.cs" Inherits="Swift.web.Remit.APIPartners.RouteApiPartners" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>

    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        function EnableDisable(id, agent, country, isActive) {
            var verifyText = 'Are you sure to enable ' + agent + ' for ' + country + '?';
            if (id != '') {
                $('#isActive').val(isActive);
                $('#rowId').val(id);
                if (isActive == 'YES') {
                    verifyText = 'Are you sure to disable ' + agent + ' for ' + country + '?';
                }
                if (confirm(verifyText)) {
                    $('#btnUpdate').click();
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" class="col-md-12">
        <asp:HiddenField ID="isActive" runat="server" />
        <asp:HiddenField ID="rowId" runat="server" />
        <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">API Partner Settings</a></li>
                            <li class="active"><a href="#">API Partner Routing List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="RouteApiPartners.aspx">API Partner</a></li>
                    <li><a href="AddApiPartner.aspx">ADD API Partner </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">API Partner Routing List
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                        </div>
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