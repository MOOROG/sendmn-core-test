<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.ThirdPartyTXN.Reconcile.Manage" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>

    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>

    </head>

    <body>
        <form id="form1" runat="server">
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <ol class="breadcrumb">
                                <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="#" onclick="return LoadModule('other_services')">Other Services</a></li>
                                <li class="active"><a href="Manage.aspx">Reconcile</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Reconcile Report </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group">
                                    <label class="control-label col-md-4">Partner :  </label>
                                    <div class="col-md-8">
                                        <asp:DropDownList ID="thirdPartyAgent" runat="server" CssClass="form-control" AutoPostBack="true"
                                            OnSelectedIndexChanged="thirdPartyAgent_SelectedIndexChanged">
                                            <asp:ListItem Value="1069">Global Remit</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Label ID="lblFromDate" runat="server" Text="From Date:" class="control-label col-md-4"></asp:Label>
                                    <div class="col-md-8">
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div id="tDate" runat="server">
                                        <label class="control-label col-md-4">To Date :  </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div id="rptType" runat="server" visible="false">
                                        <label class="control-label col-md-4">Report Type :  </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="reportType" runat="server" CssClass="form-control">
                                                <asp:ListItem Text="All" Value="A"></asp:ListItem>
                                                <%--<asp:ListItem Text="Send" Value="S"></asp:ListItem>--%>
                                                <asp:ListItem Text="Paid" Value="P"></asp:ListItem>
                                               <%-- <asp:ListItem Text="Cancel" Value="C"></asp:ListItem>
                                                <asp:ListItem Text="Un-Paid" Value="U"></asp:ListItem>--%>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div id="tAgent" runat="server">
                                        <label class="control-label col-md-4">Agent :  </label>
                                        <div class="col-md-8">
                                            <uc1:SwiftTextBox ID="agentName" runat="server" CssClass="form-control" Category="agent" />
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="control-label col-md-4"></label>
                                    <div class="col-md-8">
                                        <asp:Button ID="BtnSave1" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search "
                                         OnClientClick="return showReport();" />
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
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var thirdPartyAgent = GetValue("<% =thirdPartyAgent.ClientID%>");
        var rptType = GetValue("<% =reportType.ClientID%>");
        var agentId = GetItem("<% = agentName.ClientID %>")[0];
        var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20171000" +
           "&fromDate=" + fromDate +
           "&toDate=" + toDate +
           "&agentId=" + agentId +
           "&provider=" + thirdPartyAgent +
           "&rptType=" + rptType;
        OpenInNewWindow(url);
        return false;
    }
</script>

