<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveModification.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function PostMessageToParent(controlNo) {
            $("#controlNo").text = controlNo;
            $("#btnSearchDetail").click();
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="List.aspx">Pending Txn Modification List</a></li>
                        </ol>
                        <li class="active">
                            <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                        </li>
                    </div>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading">Pending Txn Modification List</div>
                <div class="panel-body">
                    <table class="table table-bordered">
                        <tr>
                            <td height="524" valign="top">

                                <div id="rpt_grid" runat="server" class="gridDiv"></div>

                            </td>
                        </tr>
                    </table>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
