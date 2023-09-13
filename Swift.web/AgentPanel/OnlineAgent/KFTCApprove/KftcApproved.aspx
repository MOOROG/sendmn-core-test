<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="KftcApproved.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.KFTCApprove.KftcApproved" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="List.aspx">Account Statement</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="ApproveKFTCPending.aspx">Pending List</a></li>
                        <li role="presentation" class="active"><a href="Javascript:void(0)" aria-controls="home" role="tab" data-toggle="tab">Approved List</a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                            </div>
                        </div>
                    </div>
                    <div role="tabpanel" class="tab-pane" id="Manage">
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddType" runat="server" />
        <asp:HiddenField ID="hddCustomerId" runat="server" />
        <asp:Button ID="buttonApproveReject" runat="server" OnClick="buttonApproveReject_Click" Style="display: none;" />
    </form>
    <script type="text/javascript">
        function ApproveReject(customerId, type) {
            $('#hddType').val(type);
            $('#hddCustomerId').val(customerId);
            if (customerId.length != 0 && type.length != 0) {
                if (confirm('Are you sure you want to ' + type + ' customer KFTC registration?')) {
                    $('#buttonApproveReject').click();
                } else {
                    return false;
                }

            }
            else {
                alert('Error occured while Approve/Reject, please contact JME HQ!');
            }
        }
    </script>
</body>
</html>