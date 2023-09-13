<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBACustomerList.aspx.cs" Inherits="Swift.web.Remit.RiskBasedAssesement.RBAEvaluatedCustomers.RBACustomerList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>

    <script src="../../../js/highcharts/jquery.min.js"></script>
    <script src="../../../js/highcharts/highcharts-3d.js"></script>
    <script src="../../../js/highcharts/highcharts.js"></script>
    <script src="../../../js/highcharts/modules/exporting.js"></script>
    <base id="Base1" target="_self" runat="server" />



    <style type="text/css">
        .contentlink {
            color: blue;
            cursor: pointer;
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Risk Based Assessement</a></li>
                            <li class="active"><a href="RBACustomerList.aspx">RBA Evaluated Customer</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">CUSTOMER RISK ASSESSMENT SUMMARY</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive">
                                <tr>
                                    <td>
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                        </div>

                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <div id="container" style="height:350px;">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="sCountryWise" runat="server" visible="false" >
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <asp:TextBox ID="txtPageLoad" Style="display: none;" runat="server" AutoPostBack="true"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </form>
</body>
<script>
    function showReport(rType, rdd, assessement) {

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=RBACustomer&rType=" + rType + "&rdd=" + rdd + "&as=" + assessement;
        OpenInNewWindow(url);
        return false;
    }
    function pageLoadonDemand() {
        try {
            var ctrl = document.getElementById("txtPageLoad");
            ctrl.value = "reload";
            __doPo
            stBack('txtPageLoad', '');
        }
        catch (e)
        { }
    }


    $(function () {
        $(document).ready(function () {
            Highcharts.setOptions({
                colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
            });

            // Build the chart
            $('#container').highcharts({
                chart: {
                    type: 'pie',
                    plotBackgroundColor: null,
                    plotBorderWidth: null,
                    plotShadow: false,
                    options3d: {
                        enabled: true,
                        alpha: 45,
                        beta: 0
                    }
                },
                title: {
                    text: "<%=legend %>"
                    },
                    tooltip: {
                        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                    },
                    plotOptions: {
                        pie: {
                            allowPointSelect: true,
                            cursor: 'pointer',
                            depth: 40,
                            dataLabels: {
                                enabled: true,
                                format: '{point.name}: {point.y:.1f}%'
                            },
                            showInLegend: true
                        }
                    },
                    series: [{
                        type: 'pie',
                        name: "<%=hoverText %>",
                        point: {
                            events: {
                                click: function (e) {
                                    if (e.point.url == undefined) {
                                        e.preventDefault();
                                    }
                                    else {
                                        location.href = e.point.url;
                                        e.preventDefault();
                                    }
                                }
                            }
                        },
                        data: [
                            <%= pieValue %>
                        ]
                    }]
                });
            });

        });

 $(function () {
        $(document).ready(function () {
            Highcharts.setOptions({
                colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
            });

            // Build the chart
            $('#sCountryWise').highcharts({
                chart: {
                    type: 'pie',
                    plotBackgroundColor: null,
                    plotBorderWidth: null,
                    plotShadow: false,
                    options3d: {
                        enabled: true,
                        alpha: 45,
                        beta: 0
                    }
                },
                title: {
                    text: "<%=level %> "
                    },
                    tooltip: {
                        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                    },
                    plotOptions: {
                        pie: {
                            allowPointSelect: true,
                            cursor: 'pointer',
                            depth: 40,
                            dataLabels: {
                                enabled: true,
                                format: '{point.name}: {point.y:.1f}%'
                            },
                            showInLegend: true
                        }
                    },
                    series: [{
                        type: 'pie',
                        name: 'RBA - SENDING IVE COUNTRY WISE',
                        point: {
                            events: {
                                click: function (e) {
                                    if (e.point.url == undefined) {
                                        e.preventDefault();
                                    }
                                    else {
                                        location.href = e.point.url;
                                        e.preventDefault();
                                    }
                                }
                            }
                        },
                        data: [
                            <%= pieValueSc %>
                        ]
                    }]
                });
            });

        });
</script>
</html>
