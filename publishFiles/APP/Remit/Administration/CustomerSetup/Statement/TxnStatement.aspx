<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TxnStatement.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.Statement.TxnStatement" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <!--new css and js -->
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href=".../.././../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <!-- end -->

    <base id="Base1" runat="server" target="_self" />

    <%-- <link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("buttonPdf").click();
        }
    </script>
</head>
<body>
    <form id="form" method="post" runat="server">
        <div class="page-wrapper">

            <div class="row">
                <div class="col-md-12">
                    <table style="margin-left: 10px !important; margin-right: 10px !important">
                        <tr>
                            <td>
                                <%-- <table width="30%">--%>
                                <div class="table-responsive">
                                    <table class="table" width="100%" cellspacing="0" class="TBLReport">
                                        <tr>
                                            <td align="left" class="logo">
                                                <img style="float: left; margin-top:2%" width="250" src="/ui/images/jme.png">
                                                <br />
                                                <br />
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="center">TRANSACTION STATEMENT<br />
                                                (From :
                                                <asp:Label ID="startDate" runat="server" Text=""></asp:Label>
                                                To :
                                                <asp:Label ID="endDate" runat="server" Text=""></asp:Label>)
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="5%" nowrap="nowrap" align="left" colspan="2">
                                                <strong>Sender’s Name : </strong>
                                                <asp:Label ID="senderName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap" align="left" colspan="2">
                                                <strong>ID Number :</strong>
                                                <asp:Label ID="idNumber" runat="server"></asp:Label>
                                                <br />
                                                <br />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div id="divStmt" runat="server" style="font-size: 12px !important">
                                    <div class="table-responsive">
                                        <table>
                                            <tr>
                                                <th nowrap="nowrap">Tran Date
                                                </th>
                                                <th nowrap="nowrap">Control No:
                                                </th>
                                                <th nowrap="nowrap">Receiver's Name
                                                </th>
                                                <th nowrap="nowrap">Sending Amount(MNT)
                                                </th>
                                                <th colspan="2" nowrap="nowrap">Payout Amount
                                                </th>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div id="rowSpanDiv" runat="server"></div>
                                ..........................................................<br />
                                Statement printed on(
                                <asp:Label ID="lblToday" runat="server" Text=""></asp:Label>)</td>
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="opacity: 70%">
                                <br />
                                <br />
                                For more details: Write to:<%= Swift.web.Library.GetStatic.ReadWebConfig("headFirst","") %>,Tel:<%= Swift.web.Library.GetStatic.ReadWebConfig("headTel","") %>, Fax:<%= Swift.web.Library.GetStatic.ReadWebConfig("headFax","") %>, email:<%= Swift.web.Library.GetStatic.ReadWebConfig("headEmail","") %>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>