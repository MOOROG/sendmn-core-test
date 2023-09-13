<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewDetail.aspx.cs" Inherits="Swift.web.ApplicationLog.ViewDetail" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ui/css/style.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper" style="margin-top: -100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('')">Application Log</a></li>
                            <li class="active"><a href="UserLog.aspx">User Log</a></li>
                            <li class="active"><a href="ViewDetail.aspx">Log Detail</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="logMsg" runat="server" style="margin-left: 5%;"></div>
        </div>
    </form>
</body>
</html>