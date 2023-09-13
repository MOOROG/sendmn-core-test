<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.ReprintVoucher.List" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">

    <base id="Base2" runat="server" target="_self" />
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>

    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnSearch').click(function () {
                var reqField = "controlNo,";
                if (ValidRequiredField(reqField) == false) {
                    return false;
                };
                var controlNo = $('#controlNo').val();
                var url = "SendIntlReceipt.aspx?controlNo=" + controlNo;
                window.location.href = url;
                return false;
            });
        });
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
                            <li><a href="/Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Other Services</a></li>
                            <li class="active"><a href="SearchTransaction.aspx">Reprint Receipt</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div id="divSearch" class="col-md-7" runat="server">
                    <div class="panel panel-default">
                        <div class="panel-heading">Search Transaction</div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-2 form-group">
                                    <label><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>.<span style="color: red;">*</span></label>
                                </div>
                                <div class="col-md-4 form-group">
                                    <input type="text" class="form-control" id="controlNo" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 form-group col-md-offset-2">
                                    <input type="button" id="btnSearch" value="View Receipt" class="btn btn-primary m-t-25" />
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