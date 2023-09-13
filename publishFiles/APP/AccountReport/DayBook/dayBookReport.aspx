<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dayBookReport.aspx.cs"
    Inherits="Swift.web.AccountReport.DayBook.dayBookReport" %>

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
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript">
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
    <form id="form1" runat="server" class="col-md-12">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="dayBookReport.aspx?startDate=<%=FromDate() %>&endDate=<%=ToDate() %>&vType=<%=VoucherType() %>&vName=<%=VoucherName() %>">Day Book </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row" id="main">
                <div class="form-group col-md-3">
                    <label>Voucher Filter: </label>
                    <asp:DropDownList ID="ddlShowAll" runat="server" OnSelectedIndexChanged="ddlShowAll_SelectedIndexChanged" CssClass="form-control" AutoPostBack="true">
                        <asp:ListItem Text="Show All" Value="all"  Selected="True"></asp:ListItem>
                        <%--<asp:ListItem Text="Show Manual Entry Only" Value="manual"></asp:ListItem>
                        <asp:ListItem Text="Show System Entries Only" Value="system"></asp:ListItem>--%> 
                        <asp:ListItem Text="Withdraw Money From Wallet" Value="withdraw"></asp:ListItem>
                        <asp:ListItem Text="Deposit Money Into Wallet" Value="deposit"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group col-md-12">
                    <div align="center">
                        <div align="right">
                            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                                onclick="DownloadPDF();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-striped table-bordered TBLReport" cellspacing="0">
                                <tr>
                                    <th nowrap="nowrap">
                                        <strong>SN</strong>
                                    </th>
                                    <th nowrap="nowrap">
                                        <strong>V No</strong>
                                    </th>
                                    <th nowrap="nowrap">
                                        <strong>Voucher</strong>
                                    </th>
                                    <th nowrap="nowrap">
                                        <strong>Acc Number </strong>
                                    </th>
                                    <th nowrap="nowrap">
                                        <strong>Name</strong>
                                    </th>
                                    <th nowrap="nowrap">
                                        <strong>Date</strong>
                                    </th>
                                    <th width="91" nowrap="nowrap">
                                        <strong>Amount</strong>
                                    </th>
                                </tr>
                                <tbody id="dayBook" runat="server">
                                </tbody>
                                <tr>
                                    <td nowrap="nowrap" colspan="6" align="right">
                                        <strong>Total :</strong>
                                    </td>
                                    <td nowrap="nowrap" align="right">
                                        <asp:Label ID="totalBalance" runat="server" Text="00.00" />
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