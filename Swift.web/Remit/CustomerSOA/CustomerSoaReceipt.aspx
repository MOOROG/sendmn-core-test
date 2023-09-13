<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerSoaReceipt.aspx.cs" Inherits="Swift.web.Remit.CustomerSOA.CustomerSoaReceipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <style>
        header {
            top: 0;
            height: 80px;
            width: 100%;
        }

        footer {
            width: 100%;
            height: 100px;
            bottom: 0;
        }

        .header-space {
            height: 15px;
        }

        tr.total td {
            background: white;
            color: black;
            font-size: 14px;
            font-weight: 600;
        }

        .tright {
            white-space: nowrap;
            text-align: right;
        }

        label {
            # font-weight: 400;
        }

        .info {
            text-transform: uppercase;
            font-weight: 600;
            padding: 0px;
            margin: 3px 0;
            font-size: 16px;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        td {
            border: 0;
            white-space: nowrap;
        }

        thead {
            display: table-header-group;
        }

        tfoot {
            display: table-footer-group;
        }

        .page-content td {
            padding: 5px;
            font-size: 13px;
            line-height: 15px;
            border: 1px solid #cccccc !important;
        }

        .page-content tr:nth-child(even) {
            background-color: #87ceeb;
        }

        p {
            margin-bottom: 3px;
        }

        body {
            margin: 0;
        }

        @media print {

            tr.total td {
                -webkit-print-color-adjust: exact;
                background: #808080 !important;
                color: #000 !important;
                font-size: 11px !important;
                font-weight: 600 !important;
            }

            .page-content tr:nth-child(even) {
                -webkit-print-color-adjust: exact;
                background-color: #87ceeb !important;
            }

            body {
                margin: 0;
                padding: 0;
            }

            table thead {
                background: #1717b2;
                color: white;
                font:13px;
            }

            table tr:nth-child(even) {
                background-color: #87ceeb;
            }

            td {
                white-space: nowrap;
                line-height: normal;
            }

            header {
                top: 0;
                height: 200px;
                position: fixed;
                width: 100%;
                min-height: 100px;
            }

            footer {
                width: 100%;
                height: 100px;
                bottom: 0;
                position: fixed;
            }

            .header-space {
                height: 110px;
            }

            .footer-space {
                height: 100px;
            }

            .footer {
                display: none;
            }

            p {
                margin-bottom: 3px;
                font-size: 10px;
            }

            body {
                margin: 0;
            }

            .headerClass {
                -webkit-print-color-adjust: exact;
                background: #1717b2 !important;
                color: #fff !important;
                text-align: center;
            }

            .page-content .headerClass td span {
                -webkit-print-color-adjust: exact;
                color: white !important;
            }
        }
    </style>
    <style type="text/css">
        .holderDiv {
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="holderDiv">
            <header>
                <table>
                    <tr>
                        <td>
                            <table width="100%;" border="0">
                                <tbody>
                                    <tr>
                                        <td width="70%;">
                                            <div class="logo">
                                                <img style="float: left; margin-top:2%" width="250" src="/Images/jme.png">
                                            </div>
                                        </td>
                                        <td width="30%;">
                                            <h2><span class="info" style="float: left">Remittance History
                                            </h2>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </table>
            </header>
            <table>
                <thead>
                    <tr>
                        <td>
                            <div class="header-space">&nbsp;</div>
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <table width="100%;">
                                <tbody>
                                    <tr>
                                        <td width="15%" valign="top">
                                            <label>Period </label></td>
                                        <td width="50%" valign="top"><span class="info">: <strong class="info"><strong id="txtperiod" runat="server"></strong></strong></span></td>
                                        <td width="15%" valign="top">
                                            <label>Print Date</label></td>
                                        <td width="30%" valign="top"><span class="info">: <strong class="info"><strong id="txtPrintDate" runat="server"></strong></strong></span></td>
                                    </tr>
                                    <tr>
                                        <td width="15%" valign="top">
                                            <label>Name</label></td>
                                        <td width="50%" valign="top"><span class="info">: <strong class="info"><strong id="txtName" runat="server"></strong></strong></span></td>
                                        <td width="15%" valign="top">
                                            <label>Customer Id</label></td>
                                        <td width="30%" valign="top"><span class="info">: <strong class="info"><strong id="txtCustomerId" runat="server"></strong></strong></span></td>
                                    </tr>
                                    <tr>
                                        <td width="15%" valign="top">
                                            <label>Address</label></td>
                                        <td width="50%" valign="top"><span class="info">:<strong class="info"><strong id="txtAddress" runat="server"></strong> </strong></span></td>
                                        <td width="15%" valign="top">
                                            <label>Dob</label></td>
                                        <td width="30%" valign="top"><span class="info">: <strong class="info"><strong id="txtDob" runat="server"></strong></strong></span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table class="page-content" cellspacing='0' cellpadding='0' border-spacing='0' style="width: 100%, border:0;">
                                <thead>
                                    <tr class="headerClass" style="font-size:14px; background: red; color: white; text-align: center">
                                        <td>#</td>
                                        <td>
                                            <span style="white-space: nowrap;">Date
                                                </span>
                                        </td>
                                        <td>
                                            <span style="white-space: nowrap">Receiver</span>
                                        </td>
                                        <td>
                                            <span style="white-space: nowrap">Purpose</span>
                                        </td>
                                        <td>
                                            <span style="white-space: nowrap">Transfer Amount</span>
                                        </td>
                                        <td>
                                            <span style="white-space: nowrap">Exc. Rate</span>
                                        </td>
                                        <td>
                                            <span style="white-space: nowrap">Receive Amount</span>
                                        </td>
                                    </tr>
                                </thead>
                                <tbody>
                                    <div id="rpt_grid" runat="server" class="no-margin"></div>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td>
                            <div class="footer-space">&nbsp;</div>
                        </td>
                    </tr>
                </tfoot>
            </table>
            <footer>
                <section>
                        <div style="float:right">
                            <p><%= Swift.web.Library.GetStatic.ReadWebConfig("headName","") %> <%= Swift.web.Library.GetStatic.ReadWebConfig("headFirst","") %></p>
                            <p><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseName","") %> || Number:<span><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseNo","") %></p>
                            <p>Tel : <%= Swift.web.Library.GetStatic.ReadWebConfig("headTel","") %> || Fax : <%= Swift.web.Library.GetStatic.ReadWebConfig("headFax","") %></p>
                            <p>E-mail: <%= Swift.web.Library.GetStatic.ReadWebConfig("headEmail","") %></p>
                        </div>
                </section>

            </footer>
        </div>
    </form>
</body>
</html>
