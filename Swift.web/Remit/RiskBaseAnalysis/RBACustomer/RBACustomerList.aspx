<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBACustomerList.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.RBACustomer.RBACustomerList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/highcharts/jquery.min.js" type="text/javascript"></script>  
    <script src="../../../js/highcharts/highcharts.js" type="text/javascript"></script>
    <script src="../../../js/highcharts/highcharts-3d.js" type="text/javascript"></script>
    <base id="Base1" target = "_self" runat = "server" />
</head>
<script type="text/javascript">
    function showReport(rType, rdd, assessement) {

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=RBACustomer&rType=" + rType + "&rdd=" + rdd + "&as=" + assessement;
        OpenInNewWindow(url);
        return false;
    }
    function pageLoadonDemand() {
        try {
            var ctrl = document.getElementById("txtPageLoad");
            ctrl.value = "reload";
            __doPostBack('txtPageLoad', '');
        }
        catch (e)
            { }
        }


         $(function () {

    $(document).ready(function () {
        
        Highcharts.setOptions({
        colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263',      '#6AF9C4']
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
                    depth:40,
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
                    depth:40,
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
<style type="text/css">
.contentlink 
{
    color:blue;
    cursor:pointer;
    text-decoration:underline;
    
}
</style>
<body>
<script src="../../../js/highcharts/highcharts.js"></script>
    <script src="../../../js/highcharts/modules/exporting.js"></script>
    <form id="form1" runat="server">
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">
                Compliance » Customer Risk Assessment Summary
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
            <td  align="center" valign="top">
                <div id = "rpt_grid" runat = "server" class = "gridDiv" >                    
                </div>
              
            </td>            
        </tr>

        <tr>
            <td  align="left" valign="top">
                <div id="container" style="min-width: 310px; height: 400px; max-width: 600px; margin-top: 50px">
                </div>
            </td>
        </tr>
        <tr>
            <td align="left" valign="top">
                <div id="sCountryWise" runat="server" visible="false" style=" margin-top: 20px; min-width: 310px; height: 400px;
                    max-width: 600px;">
                </div>
            </td>
        </tr>
    </table>
    <asp:TextBox ID="txtPageLoad" Style="display: none;" runat="server" AutoPostBack="true"></asp:TextBox>   
    </form>
</body>
</html>
