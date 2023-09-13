<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.GridAutoDemo.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../ui/js/custom.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3>Employee List</h3>
            </div>
        </div>
        <div>
            <div id="employeeGrid" runat="server">
            </div>
        </div>
    </form>
</body>
</html>