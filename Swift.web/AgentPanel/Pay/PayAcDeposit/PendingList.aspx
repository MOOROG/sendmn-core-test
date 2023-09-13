<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PendingList.aspx.cs"
    Inherits="Swift.web.AgentPanel.Pay.PayAcDeposit.PendingList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grdPendingIntl_approvedDate", "#grdPendingIntl_approvedDateTo");
        });
        function GridManager() {
            var ids = GetRowId("<% =GridName %>");
            SetValueById("<%=hddRowIds.ClientID %>", ids);
            var boolDisabled = (ids == "");
            EnableDisableBtn("<% =btnPayIntlTxn.ClientID %>", boolDisabled);
        }
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
                            <li><a href="#" onclick="return LoadModule('account')">PAY MONEY</a></li>
                            <li class="active"><a href="PendingList.aspx">Pay A/C Deposit Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active"><a href="Javascript:void(0)" aria-controls="home" role="tab" data-toggle="tab">International</a></li>
                        <li><a href="PendingListDom.aspx">Domestic</a></li>
                        <li><a href="PendingTxnListDom.aspx">Domestic Pending TXN</a></li>
                        <%-- <li role="presentation"><a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab"><a href="Manage.aspx">Manage</a>
                        </a></li>--%>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default recent-activites">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Pay A/C Deposit Transaction</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <asp:HiddenField ID="hddRowIds" runat="server" />
                                        <div id="rpt_grid" runat="server" class="form-group">
                                        </div>
                                        <div class="form-group">
                                            <asp:Button ID="btnPayIntlTxn" runat="server" Text="Pay Intl Bank Deposit" Enabled="false"
                                                OnClick="btnPayIntlTxn_Click" CssClass="btn btn-primary" />
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