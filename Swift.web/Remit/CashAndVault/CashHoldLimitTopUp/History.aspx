<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="History.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.CashHoldLimitTopUp.History" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
      <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>

    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
</head>
<body>
   <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
							<li class="active"><a>Exchange Setup</a></li>
							<li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="List.aspx">Cash Hold Limit TopUp</a></li>
							<li class="active"><a >Cash Hold Limit History</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Credit Limit History
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <div id="rpt_grid" runat="server"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
