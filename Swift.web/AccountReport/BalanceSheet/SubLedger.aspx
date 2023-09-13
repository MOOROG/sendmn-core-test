<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubLedger.aspx.cs" Inherits="Swift.web.AccountReport.BalanceSheet.SubLedger" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <%-- <link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>

    <!--new css and js -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <!-- end -->
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="SubLedger.aspx?company_id=1&dt=<%= GetDate() %>&mapcode=<%= GetMapCode() %>&head%20=<%=GetHead() %>&treeSape=<%=GetTreeSape() %>">Balance Sheet</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <%-- <table class="TBLReport" >--%>
            <div class="row">
                <div class="form-group col-md-10 ">
                    <div class="table-responsive" align="center">
                        <table class="table table-striped table-bordered" cellspacing="0">
                            <tr>
                                <th nowrap="nowrap">
                                    <strong>SN</strong>
                                </th>
                                <th nowrap="nowrap" align="center">
                                    <strong>Sub Group Name </strong>
                                </th>
                                <th nowrap="nowrap" align="right">
                                    <strong>DR&nbsp;</strong>
                                </th>
                                <th nowrap="nowrap" align="right">
                                    <strong>CR</strong>
                                </th>
                                <th nowrap="nowrap" align="right">
                                    <strong>Balance&nbsp;</strong>
                                </th>
                            </tr>
                            <tbody id="rptBody" runat="server">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-10 ">
                    <div class="table-responsive" align="center">
                        <table class="table table-striped table-bordered" cellspacing="0">
                            <br />
                            <br />
                            <div id="bottomRptBody" runat="server"></div>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>