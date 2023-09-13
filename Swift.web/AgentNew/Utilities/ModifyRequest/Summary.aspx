<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Summary.aspx.cs" Inherits="Swift.web.AgentNew.Utilities.ModifyRequest.Summary" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
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
                        <li class="active"><a href="Summary.aspx">Modification Request</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div id="newsFeeder" runat="server" style="width: 600px;">
            <div id="divSummary" runat="server">
                The modification request has been processed. BRN Help Desk will get back to you shortly.<br />
                <br />
                <asp:Label ID="controlNoLbl" runat="server"></asp:Label>&nbsp;:
                    <asp:Label ID="controlNo" runat="server" Style="color: red; font-weight: bold;"></asp:Label><br />

                <div id="DvModification" runat="server" style="width: 600px;">
                </div>

                <p>
                    Please email to support@jme.com.np for any queries.
                </p>
            </div>
            <asp:HiddenField ID="hdnEmail" runat="server" />
        </div>
    </div>
</asp:Content>