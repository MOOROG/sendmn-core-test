<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MatrixReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CustomerReport.MatrixReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Matrix Report</title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h2 class="panel-title">Matrix Report
                        </h2>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <label>Filters Applied:</label><br />
                            <div class="filter">
                                <label>From Date: </label>
                                &nbsp;<asp:Label ID="fromDate" runat="server"></asp:Label>
                                &nbsp;<label>To Date: </label>
                                &nbsp;<asp:Label ID="toDate" runat="server"></asp:Label><br />
                                <label>Country:</label>&nbsp;<asp:Label ID="country" runat="server"></asp:Label>&nbsp;
                                <label>Branch:</label>&nbsp;<asp:Label ID="branch" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="form-group" style="overflow: auto;">
                            <div class="table table-responsive" id="tblMatrix" runat="server">
                                <table class="table table-responsive table-bordered">
                                    <thead>
                                        <tr>
                                            <td></td>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
