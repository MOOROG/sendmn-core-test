<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.CustomerInfo.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper" style="margin-top: -100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>Administration<small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Customer Setup</a></li>
                            <li class="active"><a href="#">Message</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" class="">
                <tr>
                    <td width="100%">
                        <table width="100%">
                            <tr>
                                <td height="20"><span class="welcome"><%=GetCustomerName()%></span></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="listtabs" width="100%">
                            <ul class="nav nav-tabs" role="tablist">
                                <li><a href="../Manage.aspx?customerId=<%=GetCustomerId()%>&mode=1">Customer </a></li>
                                <li><a href="DocumentUpload.aspx?customerId=<%=GetCustomerId()%>">Documents </a></li>
                                <li class="active"><a href="#" class="selected">Message </a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td height="524" valign="top">

                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>