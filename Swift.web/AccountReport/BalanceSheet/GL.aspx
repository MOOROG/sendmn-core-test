<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GL.aspx.cs" Inherits="Swift.web.AccountReport.BalanceSheet.GL" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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
    <script src="../../ui/js/metisMenu.min.js" type="text/javascript"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js" type="text/javascript"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js" type="text/javascript"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script> -->
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
                            <li class="active"><a href="GL.aspx?company_id=1&dt=<%= GetDate() %>&mapcode=<%= GetMapCode() %>&head=<%= GetHead() %>">Balance Sheet</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-8">
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                            <tr class="bg-gray-light">
                                <th nowrap="nowrap"><strong>SN</strong></th>
                                <th nowrap="nowrap" align="center"><strong>Sub Group Name </strong></th>
                                <th nowrap="nowrap" align="right"><strong>DR&nbsp;</strong></th>
                                <th nowrap="nowrap" align="right"><strong>CR</strong></th>
                                <th nowrap="nowrap" align="right"><strong>Balance&nbsp;</strong></th>
                            </tr>
                            <tbody id="rptBody" runat="server">
                                <%--<tr>
                        <td nowrap="nowrap">1</td>
                        <td nowrap="nowrap">PL</td>
                        <td nowrap="nowrap">1222</td>
                        <td nowrap="nowrap">0</td>
                        <td nowrap="nowrap">1222</td>
                    </tr>--%>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>