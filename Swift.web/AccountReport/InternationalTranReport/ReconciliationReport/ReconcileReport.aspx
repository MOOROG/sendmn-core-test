<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReconcileReport.aspx.cs" Inherits="Swift.web.AccountReport.InternationalTranReport.ReconciliationReport.ReconcileReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="ReconcileReport.aspx">Txn Reconsile View</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Reconcile Report View
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <table class="table table-responsive table-bordered table-striped">
                         <%--       <tr>
                                    <td colspan="13" style="align-content: center">
                                        <strong>
                                            <span style="font-size: 14px">Best Remit Pvt.Ltd.</span><br />
                                            Transaction Reconciliation Report 
                                            <br />
                                            Date : <%=GetStartDate("start_date")	%>					
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowspan="2"><strong>SN</strong></td>
                                    <td rowspan="2"><strong>Country</strong></td>
                                    <td rowspan="2"><strong>Agent</strong></td>
                                    <td colspan="2">
                                        <div align="center"><strong>Unpaid Opening </strong></div>
                                    </td>
                                    <td colspan="2">
                                        <div align="center"><strong>Send Transaction </strong></div>
                                    </td>
                                    <td colspan="2">
                                        <div align="center"><strong>Paid Transacton </strong></div>
                                    </td>
                                    <td colspan="2">
                                        <div align="center"><strong>Cancel Transacton </strong></div>
                                    </td>
                                    <td colspan="2">
                                        <div align="center"><strong>Closing Un-paid </strong></div>
                                    </td>
                                </tr>

                                <tr>
                                    <td align="right">
                                        <div align="center"><strong>TRN </strong></div>
                                    </td>
                                    <td align="right">
                                        <div align="center"><strong>NPR AMT</strong></div>
                                    </td>

                                    <td align="right">
                                        <div align="center"><strong>TRN </strong></div>
                                    </td>
                                    <td align="right">
                                        <div align="center"><strong>NPR AMT</strong></div>
                                    </td>

                                    <td align="right">
                                        <div align="center"><strong>TRN </strong></div>
                                    </td>
                                    <td align="right">
                                        <div align="center"><strong>NPR AMT</strong></div>
                                    </td>

                                    <td align="right">
                                        <div align="center"><strong>TRN </strong></div>
                                    </td>
                                    <td align="right">
                                        <div align="center"><strong>NPR AMT</strong></div>
                                    </td>

                                    <td align="right">
                                        <div align="center"><strong>TRN </strong></div>
                                    </td>
                                    <td align="right">
                                        <div align="center"><strong>NPR AMT</strong></div>
                                    </td>
                                </tr>--%>
                                <div id="rpt" runat="server"></div>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
