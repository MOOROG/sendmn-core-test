<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer.Report" %>

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
    <script language="javascript" type="text/javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();

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
                            <li class="active"><a href="Report.aspx">Approve Customer </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="DashBoard.aspx">DashBoard</a></li>
                    <li><a href="Manage.aspx">Search Customer</a></li>
                    <li class="active"><a href="#" class="selected">Search Customer Report</a></li>
                </ul>
            </div>

            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Search Customer Criteria  </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
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
                                                <b>Zone:</b>
                                                <br />
                                                <uc1:SwiftTextBox ID="sZone" runat="server" Width="385px" Category="remit-sZone" />
                                            </td>
                                            <td>
                                                <b>District:</b><br />
                                                <uc1:SwiftTextBox ID="district" runat="server" Width="385px" Category="remit-districtRpt"
                                                    Param1="@GetTxnZone()" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap" colspan="2">
                                                <b>Agent</b><br />
                                                <uc1:SwiftTextBox ID="agent" Category="remit-zoneagendistrictRpt" runat="server" Width="385px" Param1="@GetTxnZoneName()" Param2="@GetTxnDistrict()" />
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
                                            <td nowrap="nowrap">
                                                <b>Membership Id</b><br />
                                                <asp:TextBox ID="memId" runat="server" CssClass="form-control" size="8" />
                                            </td>
                                            <td nowrap="nowrap">
                                                <b>Report By</b><br />
                                                <asp:DropDownList ID="rptType" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="summary">SUMMARY</asp:ListItem>
                                                    <asp:ListItem Value="detail">DETAILS</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="2"></td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <input type="button" id="searchCustRpt" value=" Search " class="btn btn-primary m-t-25" onclick="ShowReport();"></input>
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
    </form>
</body>
</html>
<script type="text/javascript">
    function ShowReport() {
        var fromDate = GetDateValue("<%=fromDate.ClientID%>");
        var toDate = GetDateValue("<%=toDate.ClientID%>");
        var status = GetValue("<%=status.ClientID%>");
        var sZone = GetItem("<% = sZone.ClientID %>")[1];
        var district = GetItem("<% = district.ClientID %>")[1];
        var agentGrp = GetValue("<%=agentGrp.ClientID%>");
        var agent = GetItem("<%=agent.ClientID%>")[0];
        var membershipId = GetValue("<%=memId.ClientID%>");
        var isDocUploaded = GetValue("<%=isDocUploaded.ClientID%>");
        var rptType = GetValue("<%=rptType.ClientID%>");

        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20822000_sc" +
            "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&status=" + status +
                "&sZone=" + sZone +
                "&district=" + district +
                "&agentGrp=" + agentGrp +
                "&sAgent=" + agent +
                "&membershipId=" + membershipId +
                 "&isDocUploaded=" + isDocUploaded +
                "&rptType=" + rptType;

        OpenInNewWindow(url);
        return false;
    }
</script>