<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommissionRuleList.aspx.cs" Inherits="Swift.web.Remit.ReferralSetup.CommissionRuleList" %>

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
   <script type="text/javascript">
       function CommissionRuleSetup(refId, refCode, partnerId, row_id) {
           const url = "CommisionRuleSetup.aspx?row_id='" + row_id + "'&referralCode='" + refCode + "'&referral_id='" + refId + "'&partnerId='" + partnerId + "'&edit=true";
           window.location.href = url;
       }
       function SetMessageBox(msg) {
           alert(msg);
       }
   </script>
</head>
<body>
    <form id="form1" runat="server" class="col-md-12">
        <asp:HiddenField ID="isActive" runat="server" />
        <asp:HiddenField ID="rowId" runat="server" />
        <asp:HiddenField ID="hdnReferralCode" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Adminstration</a></li>
                            <li><a href="#">Referral Setup</a></li>
                            <li class="active"><a href="#">Commission Rule List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="CommissionRuleList.aspx">Commission Rule List</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <%--<div class="panel-heading">
                                    <h4 class="panel-title">Referral List
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>--%>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                        </div>
                                    </div>
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
