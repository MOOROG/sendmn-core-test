<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.BlockTransaction.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
   <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<form id="form1" runat="server">
    <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                          <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="List.aspx">Block  Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction » Block List
                            </h4>
                            <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                        </div>
                        <div class="panel-body">
                            <div class="table-responsive" id = "rpt_grid" runat = "server">
                            </div>
                        </div>
                    
                    </div>
                </div>
            </div>
        </div>

</form>
</body>
</html>