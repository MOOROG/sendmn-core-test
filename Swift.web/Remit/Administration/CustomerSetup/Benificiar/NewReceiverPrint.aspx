<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewReceiverPrint.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.Benificiar.NewReceiverPrint" %>

<!DOCTYPE html>
<html>
<head>
    <link href="/css/receiver.css" rel="stylesheet">
    <style type="text/css">
        @media print {
            footer {
                page-break-after: always;
            }

            .no-margin,
            #form1{
                margin-top: 0% !important;
            }
        }
        #form1 {
            margin-top : -120px;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="receiveTable" runat="server" class="no-margin receiverPrint" style="margin-top: 10%;"></div>
    </form>
</body>
</html>