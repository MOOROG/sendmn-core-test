<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PickBranchByAgent.aspx.cs" Inherits="Swift.web.AgentPanel.International.SendMoney.TxnHistory.PickBranchByAgent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Transaction</a></li>
                            <li class="active"><a href="#">Send Transaction Int'l</a></li>
                            <li><a href="#">Customer Search</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Search
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="table table-responsive" id="rpt_grid" runat="server" enableviewstate="false"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>