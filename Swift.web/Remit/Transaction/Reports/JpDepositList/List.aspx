<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.JpDepositList.List" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/ui/js/jquery.validate.js" type="text/javascript"></script>

    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/AgentNew/js/swift_calender.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
</head >
<body>
    <form id="form1" runat="server">
       <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Transaction </a></li>
                        <li><a href="#">Unpost Transaction</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">UnPost Transactions
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
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