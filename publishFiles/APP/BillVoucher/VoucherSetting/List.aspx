<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.BillVoucher.VoucherSetting.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <link href="../../css/style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="breadCrumb">
            Bill & Voucher » Voucher Setting » List
        </div>
        <br />
        <div id="rpt_grid" runat="server" class="gridDiv">
        </div>
    </form>
</body>
</html>