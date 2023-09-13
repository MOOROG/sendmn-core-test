<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AmendmentReportPage.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.AmendmentReport.AmendmentReportPage" %>

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
    <script src="/js/swift_calendar.js"></script>


</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel">
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="table-responsive1" id="main">
                                        <table class="table" border="1">
                                            <tr>
                                                <td colspan="4" style="text-align: center">
                                                    <img src="/ui/images/jme.png" /></td>
                                            </tr>
                                        </table>
                                        <div id="customerHeadingDiv" runat="server">
                                            <table class="table" border="1">
                                                <thead>
                                                    <tr>
                                                        <td colspan="4" style="font-weight: bold; text-align: center; font-style: italic;">Customer Information Update Form</td>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                        <div id="receiverHeadingDiv" runat="server"  >
                                            <table class="table" border="1">
                                                <thead>
                                                    <tr>
                                                        <td colspan="4" style="font-weight: bold; text-align: center; font-style: italic;">Beneficiary Update Form</td>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                        <div id="TransactionHeadingDiv" runat="server" >
                                            <table class="table" border="1">
                                                <thead>
                                                    <tr>
                                                        <td colspan="4" style="font-weight: bold; text-align: center; font-style: italic;">Transaction Amendment Request Form</td>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                        <table class="table" border="1">
                                            <tr>
                                                <td style="font-weight: bold; text-align: left; font-style: italic;">Customer's Name :</td>
                                                <td id="customerName" runat="server" colspan="3"></td>
                                            </tr>
                                            <tr>
                                                <td style="font-weight: bold; text-align: left; font-style: italic;">Customer's Id</td>
                                                <td id="customerId" runat="server"></td>
                                                <td style="font-weight: bold; text-align: left; font-style: italic;">Date:</td>
                                                <td id="date" runat="server"></td>
                                            </tr>
                                            <tr>
                                                <td style="font-weight: bold; text-align: left; font-style: italic;">MTCN / PIN NO</td>
                                                <td id="controlNo" runat="server" colspan="3"></td>
                                            </tr>
                                        </table>
                                        <div id="customerDiv" runat="server">
                                            <table class="table" border="1">
                                                <thead>
                                                    <tr>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">Customer's Information</td>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">Existing Information</td>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">New Information</td>
                                                    </tr>
                                                </thead>
                                                <tbody id="custInfo" runat="server">
                                                </tbody>
                                            </table>
                                        </div>
                                        <div id="receiverDiv" runat="server">
                                            <table class="table" border="1">
                                                <thead>
                                                    <tr>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">Beneficiary's Information</td>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">Existing Information</td>
                                                        <td style="font-weight: bold; text-align: left; font-style: italic;">New Information</td>
                                                    </tr>
                                                </thead>
                                                <tbody id="receiverInfo" runat="server">
                                                </tbody>
                                            </table>
                                        </div>

                                        <table class="table" border="1">
                                            <tr>
                                                <td style="text-align: left; font-style: italic;">.......................................<br />
                                                    Customer's Signature
                                                   
                                                </td>
                                                <td style="text-align: left; font-style: italic;">...........................................................<br />
                                                    Submitted By:<br />
                                                </td>
                                                <td style="text-align: left; font-style: italic;">.............................<br />
                                                    Updated by<br />
                                                </td>
                                            </tr>
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
