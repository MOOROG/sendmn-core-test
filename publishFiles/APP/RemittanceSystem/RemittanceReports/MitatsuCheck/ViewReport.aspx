<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewReport.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.MitatsuCheck.ViewReport" %>

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
                                    <div class="table-responsive" id="main">
                                        <table class="table" border="1">
                                            <thead>
                                                <tr>
                                                    <th>S.NO.</th>
                                                    <th>Date</th>
                                                    <th>Unpaid Remittance<br />(139286032)</th>
                                                    <th>Unreconciled Customer Liab<br />(139265123)</th>
                                                    <th>Untransacted<br />(101139273793)</th>
                                                    <th>Wallet Rem. Balance</th>
                                                    <th>Total</th>
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
