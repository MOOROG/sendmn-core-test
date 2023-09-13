<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreditSecurityRPT.aspx.cs"
    Inherits="Swift.web.Remit.CreditRiskManagement.Reports.CreditSecurityRPT" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js"></script>
    <script src="../../../ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script type="text/javascript" language="javascript">
        function Zone() {
            return GetItem("<% = zone.ClientID %>")[0];
        }

        function District() {
            return GetItem("<% = district.ClientID %>")[0];
        }

        function Location() {
            return GetItem("<% = location.ClientID %>")[0];
        }

        function Agent() {
            return GetItem("<% = agent.ClientID %>")[0];
       }

       function CallBackAutocomplete(id) {
           var d = ["", ""];

           if (id == "#<% = zone.ClientID%>") {
                SetItem("<% =district.ClientID%>", d);
                <% = district.InitFunction() %>;

            } else if (id == "#<% = district.ClientID%>") {
                SetItem("<% =location.ClientID%>", d);
                <% = location.InitFunction() %>;

            } else if (id == "#<% = location.ClientID%>") {
                SetItem("<% =agent.ClientID%>", d);
                <% = agent.InitFunction() %>;
            }
        }

        function LoadCalendars() {
            ShowCalDefault("#<% =txtDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="CreditSecurityRPT.aspx">Credit Security Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="TopupHistoryRpt.aspx" target="_self">Balance Topup History Report </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Agent Credit Security Report</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Agent Credit Security Report </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="col-md-3">Zone :  </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="zone" runat="server" Category="remit-sZone" CssClass="form-control" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">District : </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="district" runat="server" Category="remit-districtRpt"
                                                CssClass="form-control" Param1="@Zone()" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Location : </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="location" runat="server" Category="remit-locationRpt"
                                                CssClass="form-control" Param1="@District()" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Agent :</label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="agent" runat="server" Category="remit-sAgent" CssClass="form-control"
                                                Param1="@Location()" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Security Type : </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="securitytype" runat="server" CssClass="form-control" AutoPostBack="True"
                                                OnSelectedIndexChanged="securitytype_SelectedIndexChanged">
                                                <asp:ListItem Value="">All</asp:ListItem>
                                                <asp:ListItem Value="bg">Bank Guarantee</asp:ListItem>
                                                <asp:ListItem Value="cs">Cash Security</asp:ListItem>
                                                <asp:ListItem Value="fd">Fixed Deposit</asp:ListItem>
                                                <asp:ListItem Value="mo">Mortgage</asp:ListItem>
                                                <asp:ListItem Value="na">Not Available</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3"></label>
                                        <div class="col-md-8">
                                            <asp:CheckBox ID="isexpiry" CssClass="form-control" Text="Is Going to Expiry" runat="server" Visible="false" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Group by :  </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList runat="server" ID="groupby" CssClass=" form-control">
                                                <asp:ListItem Value="aw">Agent Wise</asp:ListItem>
                                                <asp:ListItem Value="summary">Summary</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Date : </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="txtDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3"></label>
                                        <div class="col-md-8">
                                            <asp:Button ID="btn" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " OnClientClick="showReport();"></asp:Button>
                                        </div>
                                    </div>
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
<script language="javascript" type="text/javascript">
    function showReport() {

        var zone = GetItem("<% = zone.ClientID %>")[1];
        var district = GetItem("<% =district.ClientID%>")[1];
        var location = GetItem("<% =location.ClientID%>")[0];
        var agent = GetItem("<% = agent.ClientID %>")[0];
        var securitytype = GetValue("<% = securitytype.ClientID %>");
        var groupby = GetValue("<% = groupby.ClientID %>");
        var isexpiry = GetValue('<%= isexpiry.ClientID %>');
        var date = GetValue('<%= txtDate.ClientID %>');
        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20181800" +
            "&zone=" + zone +
            "&district=" + district +
            "&location=" + location +
            "&agent=" + agent +
            "&securitytype=" + securitytype +
            "&groupby=" + groupby +
            "&isexpiry=" + isexpiry +
            "&date=" + date;
        OpenInNewWindow(url);
        return false;
    }
</script>