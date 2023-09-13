<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReferralReport.aspx.cs" Inherits="Swift.web.AgentNew.Reports.ReferralReport.ReferralReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
        <!-- end .page title-->
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default recent-activites">
                    <!-- Start .panel -->
                    <div class="panel-heading">
                        <h4 class="panel-title">Referral Report
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12 form-group">
                                <b>Filters Applied:</b>&nbsp;&nbsp;As Of Date: <%=GetDate() %>
                            </div>
                        </div>
                        <div class="row" id="main" runat="server">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <div class="table-responsive">
                                        <table class="table table-bordered">
                                            <thead>
                                                <tr>
                                                    <th>S. No.</th>
                                                    <th>Agent Name</th>
                                                    <th>Opening Balance</th>
                                                    <th>In Amount</th>
                                                    <th>Out Amount</th>
                                                    <th>Closing Balance</th>
                                                </tr>
                                            </thead>
                                            <tbody id="cashCollectedList" runat="server">
                                                <tr>
                                                    <td colspan="6" align="center"><b>No record found</b></td>
                                                </tr>
                                            </tbody>
                                        </table>
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
