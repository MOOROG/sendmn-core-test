<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewBenificiarList.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.Benificiar.NewBenificiarList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        function checkCount() {
            isChecked = false;
            $('input[type=checkbox]').each(function () {
                if ($(this).is(":checked")) {
                    isChecked = true;
                }
            });
            if (!isChecked) {
                alert("At least one record must be selected");
                return false;
            }
            return true;
        }
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
			ShowCalFromToUpToToday("#newBenificiar_grid_fromDate", "#newBenificiar_grid_toDate");
			$('#newBenificiar_grid_fromDate').mask('0000-00-00');
			$('#newBenificiar_grid_toDate').mask('0000-00-00');
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <asp:HiddenField ID="hideCustomerId" runat="server" />
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="NewBenificiarList.aspx?customerId=<%=hideCustomerId.Value %>">New Beneficiary List </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Beneficiary List:
                                <%--<label runat="server" id="customerName"></label>
                                (<label runat="server" id="txtMembershipId"></label>
                                )--%></h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                            <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass=" btn btn-primary m-t-25 fa fa-print" OnClientClick="return checkCount()" OnClick="btnPrint_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>