<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LiquidityStatementResult.aspx.cs" Inherits="Swift.web.AccountReport.LiquidityReport.LiquidityStatementResult" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/functions.js"></script>
    <script src="../../js/swift_calendar.js"></script>
    <script language="JavaScript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =startDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Liquidity Report</li>
                            <li class="active">Statement Report</li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <table class="table table-striped table-bordered" cellspacing="0">
                    <tr>
                        <td nowrap="nowarp">
                            <div align="right"><strong>AC number:</strong></div>
                        </td>
                        <td nowrap="nowarp">
                            <asp:Label ID="accNum" runat="server" /></td>
                    </tr>
                    <tr>
                        <td nowrap="nowarp">
                            <div align="right"><strong>AC Name:</strong></div>
                        </td>
                        <td nowrap="nowarp">
                            <asp:Label ID="acct_name" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td nowrap>
                            <div align="right"><strong>Start Date: </strong></div>
                        </td>
                        <td nowrap>
                            <asp:TextBox ID="startDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap>
                            <div align="right">
                                <strong>End Date: </strong>
                            </div>
                        </td>
                        <td nowrap>
                            <asp:TextBox ID="toDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap>&nbsp;</td>
                        <td nowrap>
                            <div align="left">
                                <input type="submit" name="Submit" value="GO" class="button">
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="row">

                <div class="form-group col-md-8 ">
                    <div align="center">
                        <div class="form-group">
                            <hr style="width: 100%" runat="server" id="hr1" />
                            <hr style="width: 100%" runat="server" id="hr3" />
                            <hr style="width: 100%" runat="server" id="hr2" />
                            <div runat="server" id="exportDiv" class="noprint">
                                <div style="float: left; margin-left: 10px; vertical-align: top">
                                    <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../images/printer.png" border="0" />
                                </div>
                                <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                    <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive" id="tblRpt" runat="server">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>