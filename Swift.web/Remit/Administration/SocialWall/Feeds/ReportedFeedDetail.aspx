<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportedFeedDetail.aspx.cs" Inherits="Swift.web.Remit.SocialWall.Feeds.ReportedFeedDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/menu.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/sweetalert.css" rel="stylesheet" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/Swift_grid.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="../../../../css/datatables/datatables.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel-body" style="width: 600px;">
            <table id="reported-feed" cellspacing="0" class="table table-striped">
                <thead>
                    <tr>
                        <th>Reporter Name</th>
                        <th>Reporter DpUrl</th>
                        <th style="width: 400px;">Reported Message</th>
                        <th style="width:400px;">Report Date</th>
                    </tr>
                </thead>
                <tbody id="rpt" runat="server">
                </tbody>
            </table>
        </div>
        <script src="../../../../js/datatables/datatables.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                $('#reported-feed').DataTable();
            });
        </script>
    </form>
</body>
</html>
