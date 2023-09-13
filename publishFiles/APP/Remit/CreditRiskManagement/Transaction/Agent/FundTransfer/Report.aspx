<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.FundTransfer.Report" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <script src="../../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script src="../../../../../js/swift_autocomplete.js"></script>
    <script src="../../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function ShowReport(url) {
            var fromDate = GetDateValue("<% =fromDate.ClientID %>");
            var toDate = GetDateValue("<% =toDate.ClientID %>");
            var agent = GetValue("<% =ddlAgent.ClientID %>");
            var bank = GetValue("<% =ddlBank.ClientID %>");
            var url = "../../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20181930" +
                        "&fromDate=" + fromDate +
                        "&toDate=" + toDate +
                        "&agent=" + agent +
                        "&bank=" + bank;
            OpenInNewWindow(url);
            return false;
        }
        function LoadCalendars() {
            ShowCalFromTo("#<%= fromDate.ClientID %>", "#<%=toDate.ClientID %>", 1);
        }
        LoadCalendars();
    </script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Fund Transfer  </li>
                            <li class="active">List</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx" target="_self">Transfer List</a></li>
                    <li><a href="VerifyList.aspx" target="_self">Verify List </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Report </a></li>
                </ul>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Voucher Deposit History Report</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="col-md-3">From  Date : </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">To Date : </label>
                                        <div class="col-md-8">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Agent : </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlAgent" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3">Bank : </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlBank" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3"></label>
                                        <div class="col-md-8">
                                            <input id="btnRpt" type='button' class="btn btn-primary m-t-25" value="Show Report" onclick='return ShowReport();' /></td>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">
                Fund Transfer » List
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
            <td height="10">
                <div class="tabs">
                    <ul>
                        <li><a href="List.aspx">Transfer List</a></li>
                        <li><a href="VerifyList.aspx">Verify List</a></li>
                        <li><a href="Report.aspx" class="selected">Report</a></li>
                    </ul>
                </div>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <table class="formTable">
                    <tr>
                        <th colspan="4" class="frmTitle">Voucher Deposit History Report</th>
                    </tr>
                    <tr>
                        <td>From Date:</td>
                        <td><asp:TextBox ID="fromDate" runat="server"></asp:TextBox></td>
                        <td>To Date:</td>
                        <td><asp:TextBox ID="toDate" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>--%>
        <%-- <td>Agent:</td>
                        <td colspan="3">
                            <asp:DropDownList ID="ddlAgent" runat="server" Width="200">
                            </asp:DropDownList>
                        </td>
                    </tr>
                     <tr>--%>
        <%--            <td>Bank:</td>
                        <td colspan="3">
                            <asp:DropDownList ID="ddlBank" runat="server" Width="200">
                            </asp:DropDownList>
                        </td>
                    </tr>
                     <tr>--%>
        <%--               <td></td>
                        <td><input id="btnRpt" type='button' value="Show Report" onclick='return ShowReport();' /></td>
                        <td></td>
                        <td></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
    </form>
</body>
</html>