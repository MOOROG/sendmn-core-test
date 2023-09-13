<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="CustomerSoaReceipt.aspx.cs" Inherits="Swift.web.AgentNew.CustomerSOA.CustomerSoaReceipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
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
            background: #808080;
            color: #000;
            font-size: 11px;
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
                height: 95px;
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

            .page-content .headerClass td span{
                -webkit-print-color-adjust: exact;
                color: white !important;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
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
                                            <img style="float: left;" width="400" src="/Images/jme.png">
                                        </div>
                                    </td>
                                    <td width="30%;">
                                        <h2><span class="info" style="float: left">Remittance History
                                            <br />
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                           利用履歴</span></h2>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table width="100%;">
                            <tbody>
                                <tr>
                                    <td>
                                        <p style="margin-bottom: 10px; margin-top: 10px; font-size: 14px; float: left" class="tleft">
                                            <strong>Period :-
                                            <strong id="txtperiod" runat="server"></strong>
                                            </strong>
                                        </p>
                                    </td>
                                    <td>
                                        <p style="text-align: center; font-size: 14px">
                                            Print Date :-
                                            <label id="txtPrintDate" runat="server"></label>
                                        </p>
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
                                        <label>Name 送金者名</label></td>
                                    <td width="50%" valign="top"><span class="info">: <strong class="info"><strong id="txtName" runat="server"></strong></strong></span></td>
                                    <td width="15%" valign="top">
                                        <label>Customer Id</label></td>
                                    <td width="30%" valign="top"><span class="info">: <strong class="info"><strong id="txtCustomerId" runat="server"></strong></strong></span></td>
                                </tr>
                                <tr>
                                    <td width="15%" valign="top">
                                        <label>Address 住所</label></td>
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
                                <tr class="headerClass" style="background: #1717b2; color: white; text-align: center">
                                    <td>#</td>
                                    <td>
                                        <span style="white-space: nowrap;">Date
                                                <br>
                                            処理日</span>
                                    </td>
                                    <td>
                                        <span style="white-space: nowrap">Receiver<br />
                                            受取人名</span>
                                    </td>
                                    <td>
                                        <span style="white-space: nowrap">Purpose<br />
                                            送金目的</span>
                                    </td>
                                    <td>
                                        <span style="white-space: nowrap">Transfer Amount<br />
                                            送金額</span>
                                    </td>
                                    <td>
                                        <span style="white-space: nowrap">Exc. Rate<br />
                                            適用相場</span>
                                    </td>
                                    <td>
                                        <span style="white-space: nowrap">Receive Amount<br />
                                            現地受取金額</span>
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
                <div style="display: table; width: 100%; vertical-align: middle;">
                    <div style="display: table-cell; z-index: 1; float: left; text-align: left; width: 40%; position: relative">
                        <p>ジャパンマネーエクスプレス株式会社 </p>
                        <p>資金移動業者登録番号「関東財務局００００６号」 </p>
                        <img width="50" src="/css/images/watermarkNew.png" style="position: absolute; height: 78px; width: 73px; right: 100px; z-index: -2; top: 0;" />
                    </div>

                    <div style="display: table-cell; float: left; text-align: right; width: 57%;">
                        <p>〒169-0073　東京都新宿区百人町1丁目10-7大森ビル4ＦＡＢ号室</p>
                        <p>Post Code:169-0073Omori Building 4F(AB), Hyakunincho 1-10-7,Shinjuku-ku, Tokyo</p>
                        <p>Tel: 03-5475-3913, Fax: 03-5475-3914</p>
                        <p>E-mail: info@japanremit.com l URL: www.japanremit.com</p>
                    </div>
                    <div style="display: table-cell; float: left; text-align: right; width: 3%;">
                    </div>
                </div>
            </section>

        </footer>
    </div>

</asp:Content>
