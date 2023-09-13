<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyCustomer.aspx.cs" Inherits="Swift.web.KJBank.CustomerSetup.ModifyCustomer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Customer Setup</title>
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/swift_calendar.js"></script>

    <script type="text/javascript">
        function ResetPwd(customerId) {
            if (confirm("Are you sure to reset the password?")) {
                if (customerId != '') {
                    $('#hddCustomerId').val(customerId);
                    $('#btnReset').click();
                }
            }

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hddCustomerId" runat="server" />
        <%--<asp:Button ID="btnReset" runat="server" OnClick="btnReset_Click" style="display:none;" />--%>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="List.aspx">Customer Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Modification</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
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