<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="VaultTransferList.aspx.cs" Inherits="Swift.web.AgentNew.VaultTransfer.VaultTransferList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        function test() {
            var result = "<%=CheckIfAnyUnapprovedTransaction()%>";
            if (result == "True") {
                alert("Unapproved transaction found. Cannot perform vault transfer");
            } else {
                window.location.replace('/AgentNew/VaultTransfer/TransferToVaultManage.aspx');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Cash Management</a></li>
                        <li class="active"><a href="VaultTransferList.aspx">Transfer To Vault</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Vault Transfer Details</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div id="rpt_grid" runat="server"></div>
                    </div>
                </div>
                <div class="col-sm-12" runat="server">
                    <div class="form-group">
                        <input type="button" id="btnProceed" value="Proceed Transfer" class="btn btn-primary" onclick="test()" />
                        <%--  <button id="btnProceed" onclick="test()" class="btn btn-primary" >Proceed Transfer</button>--%>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>