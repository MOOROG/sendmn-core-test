<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Authentication.aspx.cs" Inherits="Swift.web.Authentication" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper" style="margin: 150px;">
            <table>
                <tr>
                    <td style="text-align: center">
                        <b>
                            <font color="red" size="">Sorry! you are not authorized to view this page.</font></b> </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>