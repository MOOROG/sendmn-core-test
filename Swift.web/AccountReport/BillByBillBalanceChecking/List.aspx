<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.BillByBillBalanceChecking.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">AC Balance Vs Bill By Bill Balance</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">AC Balance Vs Bill By Bill Balance List</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive table-striped table-bordered">
                                <thead>
                                    <tr>
                                        <th><strong>SN </strong></th>
                                        <th><strong>AC Name</strong></th>
                                        <th><strong>AC No </strong></th>
                                        <th><strong>AC Balance </strong></th>
                                        <th><strong>Bill By Bill Balance</strong></th>
                                    </tr>
                                </thead>
                                <tbody id="tblMain" runat="server">
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>