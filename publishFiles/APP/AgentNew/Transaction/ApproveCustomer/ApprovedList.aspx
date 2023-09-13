<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="ApprovedList.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.ApproveCustomer.ApprovedList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
      <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grid_al_fromDate", "#grid_al_toDate");
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
     <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Other Services</a></li>
                            <li class="active"><a href="ApprovedList.aspx">Approved List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx">Approve Pending </a></li>
                    <li role="presentation" class="active"><a href="ApprovedList.aspx" aria-controls="home" role="tab" data-toggle="tab">Approved List </a></li>
                    <%--<li><a href="VerifyPendingList.aspx">Verify Pending</a></li>--%>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
