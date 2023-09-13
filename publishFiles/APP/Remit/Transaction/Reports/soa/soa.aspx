<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="soa.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.soa.soa" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <% }%>
    <script type="text/javascript">
        function DownloadExcel(url) {
            OpenInNewWindow(url);
        }
    </script>

</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h2 class="panel-title">Statement Of Account 
                        <asp:Label runat="server" ID="rptDetail" Style="font-size: medium"></asp:Label>
                        </h2>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <div id="exportDiv" runat="server" class="noprint">
                                Filters Applied :<br />
                                Agent=<asp:Label runat="server" ID="lblAgentName"></asp:Label>|
                                From Date=<asp:Label runat="server" ID="lblFrmDate"></asp:Label>
                                &nbsp;To Date=<asp:Label runat="server" ID="lbltoDate"></asp:Label>&nbsp;|
                                Generated On=
                                <asp:Label runat="server" ID="lblGeneratedDate"></asp:Label>
                            </div>
                        </div>
                        <div class="form-group">
                            <div id="Div1" runat="server" class="noprint">
                                <img alt="Print" title="Print" style="cursor: pointer;" onclick=" javascript:ReportPrint(); " src="../../../../images/printer.png" border="0" />
                                <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../../../images/excel.gif" border="0" />
                            </div>
                        </div>
                        <div style="clear: both"></div>
                        <div class="form-group" style="overflow: auto;">
                            <div id="rptDiv" runat="server"></div>
                        </div>
                        <div class="form-group table table-responsive" style="width:40%">
                            <table class="table table-responsive table-bordered table-striped" width="40%">
                                <tr>
                                    <th>
                                        <div align="left">Opening Balance:</div>
                                    </th>
                                    <td>
                                        <asp:Label runat="server" ID="lblOpSing"></asp:Label></td>
                                    <td>
                                        <div align="right">
                                            <asp:Label runat="server" ID="lblOpAmt"></asp:Label></div>
                                    </td>
                                </tr>
                                <tr>
                                    <th width="125">
                                        <div align="left">DR Total:</div>
                                    </th>
                                    <td width="33">&nbsp;</td>
                                    <td width="226">
                                        <div align="right">
                                            <asp:Label runat="server" ID="lblDrTotal"></asp:Label></div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        <div align="left">CR Total:</div>
                                    </th>
                                    <td>&nbsp;</td>
                                    <td>
                                        <div align="right">
                                            <asp:Label runat="server" ID="lblCrTotal"></asp:Label></div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        <div align="left">Closing Balance:</div>
                                    </th>
                                    <td>
                                        <asp:Label runat="server" ID="lblCloSign"></asp:Label>
                                    </td>
                                    <td>
                                        <div align="right">
                                            <asp:Label runat="server" ID="lblCloAmt"></asp:Label></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <div align="right">
                                            <asp:Label runat="server" ID="lblAmtMsg" Style="font-weight: 700; color: Red;"></asp:Label>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

