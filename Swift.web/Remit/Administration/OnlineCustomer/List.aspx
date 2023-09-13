<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.OnlineCustomer.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
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
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grid_list_fromDate", "#grid_list_toDate");
        });
        //function DeleteData() {
        //    var res = confirm("Are you sure you want to delete this customer?");
        //    debugger
        //    if (res == true) {
        //        $('#deleteBtn').click();
        //    }

        //}
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li><a href="#">Online Customers</a></li>
                            <li class="active"><a href="List.aspx">Approve Pending</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Approve Pending </a></li>
                    <li><a href="ApprovedList.aspx">Approved List </a></li>
                    <li><a href="ApproveEditedCustomerDataList.aspx">Approve Edited Customer Data Pending</a></li>
                    <%--<li><a href="VerifyPendingList.aspx">Verify Pending</a></li>
                    <li><a href="AuditList.aspx">Audit List</a></li>--%>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
