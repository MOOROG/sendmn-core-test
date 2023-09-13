<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.ReportPrintBankDeposit.List" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<%
            if (GetStatic.ReadQueryString("mode", "") == "")
            {
        %>

        <script src="../../../../js/functions.js" type="text/javascript"> </script>


        <% }%>
 <script>
     function PrintReceipt() {
         window.print();
         return false;
     }
 </script>
<style>
@media print 
{
    .noprint { display: none; }
}
.unpaidACdeposit table
{
    font-size:13px;
    border:1px solid black;
    width:700px;    		
}
.unpaidACdeposit th
{
    font-size:13px;
    color: Black;
    background-color:#F9CCCC;
    text-align:left;
}
.unpaidACdeposit div
{
    font-size:13px;
    color: Black;
} 
.unpaidACdeposit td
{
    font-size:13px;
    color: Black;
    text-align:left;
}
</style>
</head>
<body>
    <form id="form1" runat="server">
    <div runat = "server" id= "exportDiv" class = "noprint" style = "padding-top: 10px">
    <img alt = "Print" title = "Print" style = "cursor: pointer; width: 14px; height: 14px"  onclick = " PrintReceipt(); "  src="../../../../images/printer.png" border="0" />
    <img alt = "Export to Excel" title = "Export to Excel" style = "cursor: pointer" onclick = " javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');"  src="../../../../images/excel.gif" border="0" />
    </div>
    <div>
        <table class="">
            <tr>
                <td colspan="2"><div align="right"> Date: <asp:Label ID="lblDate" runat="server"></asp:Label></div></td>
            </tr>
            <tr>
                <td colspan="2"><div align="right"> Ref No#: .......................</div></td>
            </tr>
            <tr>
                <td colspan="2">To<br />
                    <asp:Label ID="lblBankName" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td><div style="width:100px;"> &nbsp;</div></td>
                <td>Subject: Payment Instruction!</td>
            </tr>
            <tr>
                <td colspan="2">
                Dear sir,<br /><br />
                Your are requested to arrange the payment to the beneficiary detailed below by debiting <br />
                our account number ........................ held with yourself as per the amount included in the <br />
                cheque no ...........................
                </td>
            </tr>
            <tr>
                <td colspan="2"><div id = "rpt_grid" runat = "server"></div></td>
            </tr>
            <tr>
                <td colspan="2"></td>
            </tr>
            <tr>
                <td colspan="2">Amount in Words: <b><asp:Label ID="lblAmtInWords" runat="server"></asp:Label></b> </td>
            </tr>
            <tr>
                <td colspan="2"></td>
            </tr>
            <tr>
                <td colspan="2">Thanking You!</td>
            </tr>
            
            <tr>
                <td colspan="2"><br />
            <br />Authorized Signature <br />
                IME Pvt. Ltd.</td>
            </tr>
         </table>
    </div>
    </form>
</body>
</html>
