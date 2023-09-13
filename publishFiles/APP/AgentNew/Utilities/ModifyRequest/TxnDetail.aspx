<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="TxnDetail.aspx.cs" Inherits="Swift.web.AgentNew.Utilities.ModifyRequest.TxnDetail" %>

<%@ Register TagPrefix="uc1" TagName="UcTransactionSend" Src="~/Remit/UserControl/UcTransactionSend.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table > tbody > tr > td {
            border: none !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                        <li class="active"><a href="TxnDetail.aspx">Modification Request</a></li>
                    </ol>
                </div>
            </div>
        </div>

        <%--<div class="bredCrom" style="width: 90%"><% =PrintBreadCrum()%></div>--%>
        <div>
            <div id="divMsg" runat="server" style="margin-top: 100px"></div>
            <div id="divTranDetails" runat="server" visible="false">
                <div>
                    <uc1:UcTransactionSend ID="ucTran" runat="server" ShowSettlment="true" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>