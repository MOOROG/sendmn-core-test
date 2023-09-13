<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FilterStatementResult.aspx.cs"
    Inherits="Swift.web.AccountReport.AccountStatement.FilterStatementResult" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
     <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!-- <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("button").click();
        }
    </script>
</head>
<body>
    <form id="form" method="post" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <%-- <h1>
                                Day Book <small></small>
                            </h1>--%>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Account Reports</li>
                            <li><a href="../../AccountReport/AccountStatement/List.aspx" target="mainFrame"> Account Statement</a></li>
                            <li class="active">Account Statement Report Filtered</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div align="right">
            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint" onclick="DownloadPDF();">
                <i class="fa fa-file-pdf-o" aria-hidden="true"></i>
            </span>
           </div>
                 <asp:Button ID="button" runat="server" style="display:none;" onclick="button_Click" />
                <asp:HiddenField ID="hidden" runat="server" />
            <div class="table-responsive">
              <table class="table " width="100%"">
                    <tr>
                <td>

                     <div class="table-responsive" id="tableBody" runat="server">
                       <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                            <tr>
                                <th nowrap="nowrap">
                                    Tran Date
                                </th>
                                <th nowrap="nowrap">
                                    Description
                                </th>
                                <th nowrap="nowrap">
                                    Dr Amount
                                </th>
                                <th nowrap="nowrap">
                                    Cr Amount
                                </th>
                                <th colspan="2" nowrap="nowrap">
                                    Balance
                                </th>
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
                                        <asp:Label ID="crCount" runat="server"></asp:Label>)</strong></div>
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
                                        <asp:Label runat="server" ID="drOrCr"></asp:Label>)</strong></div>
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

   <%-- <div class="breadCrumb">
        Account Report » Account Statement » Account Statement Report Filtered</div>
    <div align="right" style="margin-right: 150px;">
        <img alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
            onclick="DownloadPDF();" src="../../images/pdf.png" border="0" />
    </div>
    <asp:Button ID="button" runat="server" style="display:none;" onclick="button_Click" />
    <asp:HiddenField ID="hidden" runat="server" />
    <div id="main">
        <table width="90%">
            <tr>
                <td>
                    <div id="tableBody" runat="server">
                        <table width="100%" class="TBLReport">
                            <tr>
                                <th nowrap="nowrap">
                                    Tran Date
                                </th>
                                <th nowrap="nowrap">
                                    Description
                                </th>
                                <th nowrap="nowrap">
                                    Dr Amount
                                </th>
                                <th nowrap="nowrap">
                                    Cr Amount
                                </th>
                                <th colspan="2" nowrap="nowrap">
                                    Balance
                                </th>
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
                                        <asp:Label ID="crCount" runat="server"></asp:Label>)</strong></div>
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
                                        <asp:Label runat="server" ID="drOrCr"></asp:Label>)</strong></div>
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
    </div>--%>
      </div>
    </form>
</body>
</html>