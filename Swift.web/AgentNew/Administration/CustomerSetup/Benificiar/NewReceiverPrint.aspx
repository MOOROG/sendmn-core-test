<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="NewReceiverPrint.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.Benificiar.NewReceiverPrint" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" class="receiverPrint" runat="server">
      <div id="receiveTable" runat="server" class="no-margin" style="margin-top: 10%;"></div>
</asp:Content>
