<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EOD.aspx.cs" Inherits="Swift.web.AccountReport.EOD" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function AskConfirmation() {
            if (confirm('Are you sure you want to perform EOD?')) {
                return true;
            }
            return false;
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="Manage.aspx">End Of Day</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="register-form">
                            <div class="panel panel-default clearfix m-b-20">
                                <div class="panel-heading">End Of Day</div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-12">
                                                <asp:Button ID="Transfer" Text="Perform EOD" runat="server" OnClientClick="return AskConfirmation();" OnClick="Transfer_Click" CssClass="btn btn-primary m-t-25" />
                                                <label style="color: red;">(Note: Once EOD is performed you can not revert back the changes and can not perform cash activities for the day.)</label>
                                            </div>
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