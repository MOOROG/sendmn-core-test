<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.SendingLimit.List" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Credit Risk Management </li>
                            <li>Transaction Limit  </li>
                            <li>Country Wise</li>
                            <li>Collection Limit </li>
                            <li class="active">List  </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <span id="spnCname" runat="server"><%=GetCountryName()%></span>
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>

