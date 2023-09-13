<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MultipleReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.MultipleReceipt.MultipleReceipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../css/receipt.css" rel="stylesheet" />
    <%--    <style>
        @media print {
            footer {
                page-break-after: always;
            }

            .no-margin {
                margin-top: 0% !important;
            }
        }

        .details h4 {
            margin: 4px 0;
        }
    </style>--%>
</head>
<body>
    <form id="form1" runat="server">
        <div class="receipt">
            <div id="rpt_grid" runat="server" class="no-margin" style="margin-top: 10%;"></div>
        </div>
    </form>
</body>
</html>
