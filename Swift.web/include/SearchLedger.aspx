<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchLedger.aspx.cs" Inherits="Swift.web.include.SearchLedger" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../ajax_func.js" type="text/javascript"></script>
    <style>
        #filterList {
            margin: 20px 0px 0px 10px;
            ;
        }

            #filterList table {
                border-collapse: collapse;
            }

        filterList tr {
            border: solid thin;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="filterList" runat="server">
        </div>
    </form>
</body>
</html>