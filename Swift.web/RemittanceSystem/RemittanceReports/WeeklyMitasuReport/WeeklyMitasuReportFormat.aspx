<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WeeklyMitasuReportFormat.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.WeeklyMitasuReport.WeeklyMitasuReportFormat" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>


    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" language="javascript"></script>

    <style type="text/css">
        /*.tg {
            border-collapse: collapse;
            border-spacing: 0;
        }

            .tg td {
                font-family: Arial, sans-serif;
                font-size: 14px;
                padding: 10px 5px;
                border-style: solid;
                border-width: 1px;
                overflow: hidden;
                word-break: normal;
                border-color: transparent;
            }

            .tg th {
                font-family: Arial, sans-serif;
                font-size: 14px;
                font-weight: normal;
                padding: 10px 5px;
                border-style: solid;
                border-width: 1px;
                overflow: hidden;
                word-break: normal;
                border-color: black;
            }

            .tg .tg-46ru {
                background-color: #96fffb;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-e6ut {
                background-color: #9aff99;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-fgpf {
                font-weight: bold;
                background-color: #96fffb;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-8cwo {
                font-weight: bold;
                background-color: #9698ed;
                border-color: inherit;
                text-align: right;
                vertical-align: top
            }

            .tg .tg-j4xs {
                background-color: #cbcefb;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-7od5 {
                background-color: #9aff99;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-dehw {
                background-color: #96fffb;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-py60 {
                font-weight: bold;
                background-color: #ffffc7;
                border-color: inherit;
                text-align: center;
                vertical-align: top
            }

            .tg .tg-jqxo {
                font-weight: bold;
                background-color: #9aff99;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-6we9 {
                font-weight: bold;
                background-color: #dae8fc;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-esup {
                font-weight: bold;
                background-color: #cbcefb;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-x6qq {
                background-color: #dae8fc;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-61xu {
                background-color: #cbcefb;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-xkfo {
                background-color: #9698ed;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }*/

        .company_logo {
            width: 300px;
        }

            .company_logo img {
                width: 100%;
            }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $("#ExportToExcel").click(function () {
                ExportToExcel();
            });
        });
        function ExportToExcel() {
            var html = document.getElementById("main").innerHTML;
            //alert(html);
            if (html == null || html == "" || html == undefined) {
                return false;
            }
            window.open('data:application/vnd.ms-excel,' + encodeURIComponent(
                $('div[id$=main]').html()));
            e.preventDefault();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel">
                        <%--<div class="panel-heading">
                            <h4 class="panel-title"></h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>--%>
                        <div class="panel-body">
                            <button class="btn btn-primary" id="ExportToExcel">Export To Excel</button>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="table-responsive1" id="main">
                                        <table class="table tg" border="0">
                                            <tr>
                                                <td colspan="18">
                                                    <center>
                                                        <h1>Weekly Mitasu Report</h1>
                                                    </center>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">&nbsp;
                                                </td>
                                                <td colspan="5" style="vertical-align: middle;">
                                                    <table class="table" border="1" style="width:175px;margin:auto;">
                                                        <tr>
                                                            <td>Authorize
                                                            </td>
                                                            <td>Check
                                                            </td>
                                                            <td>Prepare
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="height: 100px;"></td>
                                                            <td></td>
                                                            <td></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td colspan="2">&nbsp;
                                                </td>
                                                <td colspan="7">
                                                    <div class="company_logo">
                                                        <img src="<%=Swift.web.Library.GetStatic.GetUrlRoot() %>/ui/images/jme-excel.png" />
                                                    </div>
                                                </td>
                                                <td colspan="2">
                                                    <b>From Date:&nbsp;<%=GetFromDate() %>&nbsp;&nbsp;To Date:&nbsp;<%=GetToDate() %></b>
                                                </td>
                                            </tr>
                                        </table>
                                        <table class="table" border="1">
                                            <thead>
                                                <tr>
                                                    <th colspan="18" style="vertical-align:middle;text-align:center;font-weight:bold;">Calculation of Mitatsusaimu</th>
                                                </tr>
                                                <tr>
                                                    <td rowspan="3" style="vertical-align:middle;text-align:center;font-weight:bold;">日</td>
                                                    <td rowspan="3" style="vertical-align:middle;text-align:center;font-weight:bold;">Date</td>
                                                    <td colspan="5" style="vertical-align:middle;text-align:center;font-weight:bold;">Source of fund</td>
                                                    <td colspan="5" rowspan="2" style="vertical-align:middle;text-align:center;font-weight:bold;">Retrun (F)</td>
                                                    <td rowspan="3" style="vertical-align:middle;text-align:center;font-weight:bold;">Daily payout<br>
                                                        (G)</td>
                                                    <td rowspan="3" style="vertical-align:middle;text-align:center;font-weight:bold;">Service<br>
                                                        Charge<br>
                                                        (H)</td>
                                                    <td colspan="4" rowspan="2" style="vertical-align:middle;text-align:center;font-weight:bold;">Mitatsusaimu</td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3" style="vertical-align:middle;text-align:center;font-weight:bold;">Nepal</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">Indonesia</td>
                                                    <td rowspan="2" style="vertical-align:middle;text-align:center;font-weight:bold;">Total<br>
                                                        (E)</td>
                                                </tr>
                                                <tr>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">JP Post<br>
                                                        (A)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">MUFJ<br>
                                                        (B)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">Cash<br>
                                                        (C)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">JP Post<br>
                                                        (D)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">JP Post_<br>
                                                        Nepal</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">Mufj</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">JP Post_<br>
                                                        Indonesia</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;">Cash</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;"><span style="font-weight: 700">Total</span><br>
                                                        <span style="font-weight: 700">Return</span><br>
                                                        <span style="font-weight: 700">(F)</span></td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;"><span style="font-weight: bold">Total Incoming</span><br>
                                                        <span style="font-weight: bold">(X)</span>= (E-H)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;"><span style="font-weight: bold">Total Payout</span><br>
                                                        <span style="font-weight: bold">(Y)</span>=(F+G)</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;"><span style="font-weight: bold">Mitatsusaimu</span><br>
                                                        <span style="font-weight: bold">(Z) </span>= {Yesterday's<br>
                                                        Balance of (Z)<br>
                                                        + X - Y }</td>
                                                    <td style="vertical-align:middle;text-align:center;font-weight:bold;"><span style="font-weight: bold">要履行保証額</span><br>
                                                        <span style="font-weight: bold"></span>= (Z*1.05)</td>
                                                </tr>
                                            </thead>
                                            <tbody id="rpt" runat="server">
                                                <tr>
                                                    <td colspan="18" align="center">No records found</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
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
