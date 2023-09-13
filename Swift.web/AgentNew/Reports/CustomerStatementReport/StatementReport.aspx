<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="StatementReport.aspx.cs" Inherits="Swift.web.AgentNew.Reports.CustomerStatementReport.StatementReport" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#<%=startDate.ClientID%>", "#<%=endDate.ClientID%>", 1);
            $('#<%=startDate.ClientID%>').mask('0000-00-00');
            $('#<%=endDate.ClientID%>').mask('0000-00-00');
        });

        function CheckFormValidation() {
            var reqField = "<%=startDate.ClientID%>,<%=endDate.ClientID%>,ContentPlaceHolder1_CustomerInfo_aText,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#<%=startDate.ClientID%>").val();
            var endDate = $("#<%=endDate.ClientID%>").val();
            var acInfo = $('#ContentPlaceHolder1_CustomerInfo_aValue').val();

            var url = "TxnStatement.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo;
            //alert(url);
            window.location.href = url;
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
                        <li><a href="#" onclick="return LoadModule('account')">Customer</a></li>
                        <li><a href="#" onclick="return LoadModule('sub_account')">Customer Management </a></li>
                        <li class="active"><a href="StatementReport.aspx">Customer Statement</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-8">
                <div class="panel panel-default recent-activites">
                    <div class="panel-heading">
                        <h4 class="panel-title">Search Customer Statement
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <label class="col-lg-2 col-md-3 control-label" for="">
                                Customer Name/Id Number:<span class="errormsg">*</span></label>
                            <div class="col-lg-10 col-md-9">
                                <uc1:SwiftTextBox ID="CustomerInfo" runat="server" Category="remit-CustomerInfo" CssClass="form-control" Title="Enter Customer Name/Id Number" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-2 col-md-3 control-label" for="">
                                Start Date:<span class="errormsg">*</span></label>
                            <div class="col-lg-10 col-md-9">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="startDate" onchange="return DateValidation('startDate','t','endDate')" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    <%--<asp:TextBox autocomplete="off" ID="startDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" CssClass="form-control form-control-inline input-medium "></asp:TextBox>--%>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="startDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-2 col-md-3 control-label" for="">
                                End Date:<span class="errormsg">*</span></label>
                            <div class="col-lg-10 col-md-9">
                                <div class="input-group m-b">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox autocomplete="off" ID="endDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="endDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-2 col-md-3 control-label">&nbsp;</label>
                            <div class="col-lg-10 col-md-9">
                                <input type="button" value="Search" onclick="CheckFormValidation();" class="btn btn-primary m-t-25" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>