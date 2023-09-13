<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="TxnStatement.aspx.cs" Inherits="Swift.web.AgentNew.Reports.CustomerStatementReport.TxnStatement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("buttonPdf").click();
        }
    </script>
    <style>
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 0px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">

        <div class="row">
            <div class="col-md-12">
                <table>
                    <tr>
                        <td>
                            <%-- <table width="30%">--%>
                            <div class="table-responsive">
                                <table class="table" width="100%" cellspacing="0" class="TBLReport">
                                    <tr>
                                        <td align="left">
                                            <div class="brand_logo">
                                                <img src="../../../Images/jme.png" />
                                            </div>
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
                                            <strong>Alien ID Number :</strong>
                                            <asp:Label ID="idNumber" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div id="divStmt" runat="server">
                                <div class="table-responsive">
                                    <table>
                                        <tr>
                                            <th nowrap="nowrap">Tran Date
                                            </th>
                                            <th nowrap="nowrap">JME Number
                                            </th>
                                            <th nowrap="nowrap">Receiver's Name
                                            </th>
                                            <th nowrap="nowrap">Sending Amount(<%=Swift.web.Library.GetStatic.ReadWebConfig("currencyJP","") %>)
                                            </th>
                                            <th colspan="2" nowrap="nowrap">Paying Amount(NPR)
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
                            For more details: Write to: <%=Swift.web.Library.GetStatic.ReadWebConfig("jmeName","") %> Remittance, Omori Building 4F(AB), Hyakunincho 1-10-7, Shinjuku-ku, Tokyo, Japan. Post Code: 169-0073
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</asp:Content>