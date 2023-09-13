<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAExceptionRpt.aspx.cs" Inherits="Swift.web.Remit.RiskBasedAssesement.RBAExceptionReport.RBAExceptionRpt" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>

 <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <script>
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
    <style type="text/css">
        .contentlink {
            color: blue;
            cursor: pointer;
            text-decoration: underline;
        }



        .number {
            text-align: right;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Risk Based Assessement</a></li>
                            <li class="active"><a href="RBAExceptionRpt.aspx">RBA Exception Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Risk Assessment Exception Report </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <table class="table table-responsive">
                                    <tr>
                                        <td class="frmLableBold" style="width: 15%">Date From  <span class="errormsg">*</span>
                                        </td>
                                        <td>
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline"></asp:TextBox>
                                            </div>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">Date To <span class="errormsg">*</span>
                                        </td>
                                        <td>
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline"></asp:TextBox>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">Country
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="country" runat="server" Category="remit-country" CssClass="form-control"></uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">Agent
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="agent" runat="server" Category="remit-agent" Param1="@GetCountryId()" CssClass="form-control"></uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">Branch
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="branch" runat="server" Category="remit-pbranchByAgent" Param1="@GetAgentId()" CssClass="form-control"></uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">RBA Type
                                            <span class="errormsg">*</span>

                                        </td>
                                        <td>
                                            <asp:DropDownList ID="reportType" CssClass="form-control" runat="server">
                                                <asp:ListItem Value="">Select</asp:ListItem>
                                                <asp:ListItem Value="customer">Customer</asp:ListItem>
                                                <asp:ListItem Value="txn">Txn</asp:ListItem>
                                            </asp:DropDownList>
                                            <span runat="server" id="Span3" visible="false" class="errMsg" style="color: Red;">Required!</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLableBold">&nbsp;</td>
                                        <td>
                                            <asp:Button ID="showReport" runat="server" Text="Show Report" OnClick="showReport_Click" CssClass="btn btn-primary m-t-25" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="form-group">
                                <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
<script type="text/javascript">

  

    function openReport(rCat, rType, risk, url) {

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=RBAExceptionRpt&rType=" + rType + "&rCat=" + rCat + "&risk=" + risk + url;
        OpenInNewWindow(url);
        return false;
    }
    function GetCountryId() {
        return GetItem("<% = country.ClientID %>")[0];
    }
    function GetAgentId() {
        return GetItem("<% = agent.ClientID %>")[0];
    }
    function CallBackAutocomplete(id) {
        var d = ["", ""];
        if (id == "#<% = country.ClientID%>") {
            SetItem("<% =agent.ClientID%>", d);
            <% = agent.InitFunction() %>;

        }
        else if (id == "#<% = agent.ClientID%>") {
            SetItem("<% =branch.ClientID%>", d);
            <% = branch.InitFunction() %>;

        }
    }

</script>

</html>
