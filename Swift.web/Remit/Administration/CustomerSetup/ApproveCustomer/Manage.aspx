<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />

    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../js/functions.js"></script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../../../js/swift_calendar.js"></script>

    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script language="javascript" type="text/javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
        function ViewDetails(id) {
            var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
            var url = "" + urlRoot + "/Remit/Administration/CustomerSetup/Manage.aspx?customerId=" + id + "&mode=1";
            var ret = OpenDialog(url, 800, 1000, 50, 50);
            if (ret) {
                GetElement("<% =btnSearch.ClientID %>").click();
            }
        }
        function ClearFields() {
            $('#tblForm').find('input:text').val('');
            $('#tblForm').find('input:hidden').val('');
            $('#tblForm').find('select').val('');
            GetElement("<% =btnSearch.ClientID %>").click();
        }

        function GetTxnZone() {
            return GetItem("<% = sZone.ClientID %>")[0];
        }
        function GetTxnZoneName() {
            return GetItem("<% = sZone.ClientID %>")[1];
        }

        function GetTxnDistrict() {
            return GetItem("<% = district.ClientID %>")[1];
        }
        function CallBackAutocomplete(id) {
            var d = ["", ""];
            if (id == "#<% = sZone.ClientID%>") {
                  SetItem("<% =district.ClientID%>", d);
                  <% = district.InitFunction() %>;

                  SetItem("<% =agent.ClientID%>", d);
                  <% = agent.InitFunction() %>;
              }
              if (id == "#<% = district.ClientID%>") {
                  SetItem("<% =agent.ClientID%>", d);
                <% = agent.InitFunction() %>;
            }
          }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="Manage.aspx">Approve Customer </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="DashBoard.aspx">DashBoard</a></li>
                    <li class="active"><a href="Manage.aspx" class="selected">Search Customer</a></li>
                    <li><a href="Report.aspx">Search Customer Report</a></li>
                </ul>
            </div>
            <div class="clearfix"></div>
            </br>
            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Search Customer Criteria </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class=" table-responsive">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <b>From Date</b><br />
                                                    <asp:TextBox ID="fromDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </td>
                                                <td nowrap="nowrap">
                                                    <b>To Date</b><br />
                                                    <asp:TextBox ID="toDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <b>Zone:</b>
                                                    <br />
                                                    <uc1:SwiftTextBox ID="sZone" runat="server" Category="remit-sZone" />
                                                </td>
                                                <td>
                                                    <b>District:</b><br />
                                                    <uc1:SwiftTextBox ID="district" runat="server" Category="remit-districtRpt" Param1="@GetTxnZone()" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <b>Agent</b><br />
                                                    <uc1:SwiftTextBox ID="agent" Category="remit-zoneagendistrictRpt" runat="server" Param1="@GetTxnZoneName()" Param2="@GetTxnDistrict()" />
                                                </td>
                                                <td nowrap="nowrap">
                                                    <b>Status</b><br />
                                                    <asp:DropDownList ID="status" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="Pending">Pending</asp:ListItem>
                                                        <asp:ListItem Value="Complain">Complain</asp:ListItem>
                                                        <asp:ListItem Value="Updated">Updated</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <b>Agent Group:</b>
                                                    <br />
                                                    <asp:DropDownList runat="server" ID="agentGrp" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </td>
                                                <td nowrap="nowrap">
                                                    <b>Is Doc. Uploaded</b><br />
                                                    <asp:DropDownList ID="isDocUploaded" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="">All</asp:ListItem>
                                                        <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                                        <asp:ListItem Value="No">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" colspan="2">
                                                    <b>Membership Id</b><br />
                                                    <asp:TextBox ID="memId" runat="server" CssClass="form-control" size="8" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" nowrap="nowrap">
                                                    <asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="btn btn-primary m-t-25"
                                                        OnClick="btnSearch_Click" ValidationGroup="rpt" />&nbsp;&nbsp;
                                                                 <input type="button" value="Clear Field" id="btnSclearField" class="btn btn-primary m-t-25" onclick=" ClearFields(); " />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div id="rptGrid" runat="server" enableviewstate="false">
        </div>
    </form>
</body>
</html>