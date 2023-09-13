<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="MultipleReceipt.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.MultipleReceipt.MultipleReceipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .receipt {
            margin-top: -150px;
        }

        .testing {
            margin-top: 30px !important;
        }

        @media print {
            .receipt {
                margin-top: 0px !important;
            }

            .testing {
                margin-top: 0px !important;
            }

            .footer {
                display: none;
            }

            .no-margin {
                margin-top: 0px !important;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="receipt" id="printArea">
        <div id="rpt_grid" runat="server" class="no-margin" style="margin-top: 10%;"></div>
    </div>
</asp:Content>
