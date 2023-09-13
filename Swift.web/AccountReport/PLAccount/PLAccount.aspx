<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PLAccount.aspx.cs" Inherits="Swift.web.AccountReport.PLAccount.PLAccount" %>

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
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <%--<link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            //alert(copy);
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("pdf").click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <%-- <h1>
                                Day Book <small></small>
                            </h1>--%>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="PLAccount.aspx?toDate=<%=ToDate() %>&fromDate=<%=FromDate() %>">Profit and Loss</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <%--  <div id="main" align="center">--%>
            <div class="row">
                <div id="main" align="center">
                    <div class="form-group col-md-8 ">
                        <div class="table-responsive">
                            <table class="table" style="width: 750px">
                                <tr>
                                    <td>
                                        <div align="center">
                                            <asp:Label runat="server" ID="letterHead"></asp:Label><br />
                                            <strong>Profit and Loss Account </strong>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;&nbsp;&nbsp; Report Date: <strong>
                                        <asp:Label ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server"></asp:Label></strong> To <strong>
                                            <asp:Label ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server"></asp:Label>
                                        </strong>
                                    </td>
                                    <td>
                                        <div align="center">
                                            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                                                onclick="DownloadPDF();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <div id="plReport" runat="server">
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