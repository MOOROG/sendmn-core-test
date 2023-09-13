<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewReceiverPrint.aspx.cs" Inherits="Swift.web.Responsive.CustomerSetup.Benificiar.NewReceiverPrint" %>

<!DOCTYPE html>
<html>
<head>
    <link href="/css/receiver.css" rel="stylesheet">
    <style type="text/css">
        @media print {
            footer {
                page-break-after: always;
            }

            .no-margin {
                margin-top: 0% !important;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="receiveTable" runat="server" class="no-margin" style="margin-top: 10%;"></div>
    </form>
</body>
</html>
