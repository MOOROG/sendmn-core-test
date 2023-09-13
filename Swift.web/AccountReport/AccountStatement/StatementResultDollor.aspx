<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatementResultDollor.aspx.cs"
    Inherits="Swift.web.AccountReport.AccountStatement.StatementResultDollor" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../css/style.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =startDate.ClientID %>", "#<% =endDate.ClientID %>", 1);
        }
        LoadCalendars();
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("pdf").click();
        }
    </script>
</head>
<body>
    <form id="form" method="post" runat="server">
        <div class="breadCrumb">
            &nbsp;&nbsp;Account Statement FCY
        </div>
        <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
        <asp:HiddenField ID="hidden" runat="server" />
        <div id="main">
            <table width="90%">
                <tr>
                    <td>
                        <table width="30%">
                            <tr>
                                <td width="30%" nowrap="nowrap">
                                    <div align="left">
                                        <strong>AC number:</strong>
                                    </div>
                                </td>
                                <td width="70%" nowrap="nowrap">
                                    <div align="left">
                                        <asp:Label ID="acNumber" runat="server"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <strong>AC Name:</strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <asp:Label ID="acName" runat="server"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <strong>Start Date: </strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <asp:TextBox ID="startDate" runat="server" Width="100"></asp:TextBox>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <strong>End Date: </strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <asp:TextBox ID="endDate" runat="server" Width="100"></asp:TextBox>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">&nbsp;
                                </td>
                                <td nowrap="nowrap">
                                    <div align="left">
                                        <asp:Button ID="goBtn" runat="server" CssClass="noPrint" Text="     Go     " OnClick="goBtn_Click" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <img alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                            onclick="DownloadPDF();" src="../../images/pdf.png" border="0" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div align="center">
                            <%--<asp:Label runat="server" ID="letterHead"></asp:Label><br />--%>
                            <strong>Account Statement FCY Report</strong>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="tableBody" runat="server">
                            <table width="100%" class="TBLReport">
                                <tr>
                                    <th nowrap="nowrap">Transaction Date
                                    </th>
                                    <th nowrap="nowrap">Description
                                    </th>
                                    <th nowrap="nowrap">Dr Amount
                                    </th>
                                    <th nowrap="nowrap">Cr Amount
                                    </th>
                                    <th colspan="2" nowrap="nowrap">Balance
                                    </th>
                                </tr>
                                <tr>
                                    <td align="right">a
                                    </td>
                                    <td align="right">a
                                    </td>
                                    <td align="right">a
                                    </td>
                                    <td align="right">a
                                    </td>
                                    <td align="right">a
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="6">
                        <table width="35%" border="0" align="right" cellpadding="2" cellspacing="1">
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">
                                        <strong>Opening Balance: </strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap" style="text-align: right;">
                                    <div align="right">
                                        <strong>
                                            <asp:Label ID="openingBalance" runat="server"></asp:Label>
                                        </strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">
                                        <strong>DR:(<asp:Label ID="drCount" runat="server"></asp:Label>) </strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap" style="text-align: right;">
                                    <div align="right">
                                        <strong>
                                            <asp:Label ID="drAmt" runat="server"></asp:Label>
                                        </strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">
                                        <strong>CR:(
                                        <asp:Label ID="crCount" runat="server"></asp:Label>)</strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap" style="text-align: right;">
                                    <div align="right">
                                        <strong>
                                            <asp:Label ID="crAmt" runat="server"></asp:Label>
                                        </strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">
                                        <strong>Closing Balance:(
                                        <asp:Label runat="server" ID="drOrCr"></asp:Label>)</strong>
                                    </div>
                                </td>
                                <td nowrap="nowrap" style="text-align: right;">
                                    <div align="right">
                                        <a href="#" id="closingBalance" title="Bill by Bill Outstanding"><strong>
                                            <asp:Label ID="closingBalanceAmt" runat="server">0.00</asp:Label>
                                        </strong></a>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>