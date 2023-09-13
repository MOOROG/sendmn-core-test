<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="NewBenificiarList.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.Benificiar.NewBenificiarList" %>

<%--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        function checkCount() {
            isChecked = false;
            $('input[type=checkbox]').each(function () {
                if ($(this).is(":checked")) {
                    isChecked = true;
                }
            });
            if (!isChecked) {
                alert("At least one record must be selected");
                return false;
            }
            return true;
        }
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#newBenificiar_grid_fromDate').mask('0000-00-00');
            $('#newBenificiar_grid_toDate').mask('0000-00-00');
            ShowCalFromToUpToToday("#newBenificiar_grid_fromDate", "#newBenificiar_grid_toDate");
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <asp:HiddenField ID="hideCustomerId" runat="server" />
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                        <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                        <li class="active"><a href="NewBenificiarList.aspx?customerId=<%=hideCustomerId.Value %>">New Beneficiary List </a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Beneficiary List:
                                <%--<label runat="server" id="customerName"></label>
                                (<label runat="server" id="txtMembershipId"></label>
                                )--%></h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row" id="rpt_grid" runat="server"></div>
                        <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass=" btn btn-primary m-t-25 fa fa-print" OnClientClick="return checkCount()" OnClick="btnPrint_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
