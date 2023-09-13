<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankSetup.aspx.cs" Inherits="Swift.web.Remit.Transaction.BankRateSetup.BankSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script>
        function CheckFormValidation() {
            var reqField = "custRate,sc,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
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
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="BankSetup.aspx">Set Bank Rate</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Set Bank Rate
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    Customer Rate:</label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox ID="custRate" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    Service Charge:</label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox ID="sc" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-3 col-md-offset-3">
                                    <asp:Button ID="changePass" runat="server" CssClass="btn btn-primary" OnClientClick="return CheckFormValidation();" OnClick="changePass_Click" Text="Update" />
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
