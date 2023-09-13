<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAStatisticRpt.aspx.cs"
    Inherits="Swift.web.Remit.RiskBaseAnalysis.RBACustomer.RBAStatisticRpt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/highcharts/jquery.min.js" type="text/javascript"></script>
    <style type="text/css">
		    $ {
		        demo .css;
		    }
		</style>
    <script type="text/javascript">
       

   $(function () {

    $(document).ready(function () {
        
        Highcharts.setOptions({
        colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263',      '#6AF9C4']
        });

        // Build the chart
        $('#container').highcharts({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: 'RBA - Overall Customer Evaluation'
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false
                    },
                    showInLegend: true
                }
            },
            series: [{
                type: 'pie',
                name: 'RBA Customer Evaluation',
                point: {
                    events: {
                        click: function(e) {                            
                             if(e.point.url==undefined)
                            {
                                e.preventDefault();
                            }
                            else
                            {
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
        colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263',      '#6AF9C4']
        });

        // Build the chart
        $('#sCountryWise').highcharts({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false
            },
            title: {
                text: 'RBA - Sending Country Wise'
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false
                    },
                    showInLegend: true
                }
            },
            series: [{
                type: 'pie',
                name: 'Sending Country Wise',
                point: {
                    events: {
                        click: function(e) {                            
                            if(e.point.url==undefined)
                            {
                                e.preventDefault();
                            }
                            else
                            {
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
</head>
<body>
    <script src="../../../js/highcharts/highcharts.js"></script>
    <script src="../../../js/highcharts/modules/exporting.js"></script>
    <form id="form1" runat="server">
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">
                Compliance » RBA Statistic Report
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
            <td height="524" align="center" valign="top">
                <div id="container" style="min-width: 310px; height: 400px; max-width: 600px; margin: 0 auto">
                </div>
            </td>
        </tr>
        <tr>
            <td height="524" align="center" valign="top">
                <div id="sCountryWise" runat="server" visible="false" style="min-width: 310px; height: 400px;
                    max-width: 600px; margin: 0 auto">
                </div>
            </td>
        </tr>
    </table>
    <asp:TextBox ID="txtPageLoad" Style="display: none;" runat="server" AutoPostBack="true"></asp:TextBox>
    </form>
</body>
</html>
