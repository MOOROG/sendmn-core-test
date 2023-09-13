<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageList.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.CustomerControls.ManageList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Setup</title>
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
    <script src="/ui/js/custom.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script type="text/javascript">
        function EnableDisable(id, email, isActive) {
            var verifyText = 'Are you sure to enable ' + email + '?';
            if (id != '') {
                $('#isActive').val(isActive);
                $('#customerId').val(id);
                if (isActive == 'Y') {
                    verifyText = 'Are you sure to disable ' + email + '?';
                }
                if (confirm(verifyText)) {
                    $('#btnUpdate').click();
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="isActive" runat="server" />
        <asp:HiddenField ID="customerId" runat="server" />
        <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Online Agent</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer Setup</a></li>
                            <li class="active"><a href="List.aspx">List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active"><a href="Javascript:void(0)" aria-controls="home" role="tab" data-toggle="tab">Customer List</a></li>
                        <li><a href="ManageCustomer.aspx">Customer Operation</a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default recent-activites">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Online Customer List</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <asp:HiddenField ID="hddRowIds" runat="server" />
                                        <div id="rpt_grid" runat="server" class="form-group" enableviewstate="false">
                                        </div>
                                        <div class="form-group">
                                            <%--<asp:Button ID="btnPayDomTxn" runat="server" Text="Pay Dom Bank Deposit" Enabled="false"
                                                    OnClick="btnPayDomTxn_Click" />--%>
                                        </div>
                                    </div>
                                </div>
                                <!-- End .panel -->
                            </div>
                            <!--end .col-->
                        </div>
                        <!--end .row-->
                    </div>
                    <div role="tabpanel" class="tab-pane" id="Manage">
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>