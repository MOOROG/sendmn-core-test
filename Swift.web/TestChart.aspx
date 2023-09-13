<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestChart.aspx.cs" Inherits="Swift.web.TestChart" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Example</title>
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.css">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="graph"></div>
        <div id="donut"></div>
    </form>
    <script>
        Morris.Donut({
            element: 'donut',
            data: [
              { value: 70, label: 'Nepal' },
              { value: 4, label: 'India' },
              { value: 5, label: 'Vietnam' },
              { value: 11, label: 'Cambodia' },
              { value: 6, label: 'Pakistan' },
              { value: 4, label: 'Srilanka' }
            ],
            formatter: function (x) { return x + "%" }
        }).on('click', function (i, row) {
            console.log(i, row);
        });

        var day_data = [
              { "elapsed": "Jan", "Txns": 15000 },
              { "elapsed": "Feb", "Txns": 18000 },
              { "elapsed": "Mar", "Txns": 22000 },
              { "elapsed": "Apr", "Txns": 16000 },
              { "elapsed": "May", "Txns": 10000 },
              { "elapsed": "Jun", "Txns": 28000 },
              { "elapsed": "Jul", "Txns": 30000 },
              { "elapsed": "Aug", "Txns": 26000 },
              { "elapsed": "Sep", "Txns": 12000 },
              { "elapsed": "Oct", "Txns": 19000 },
              { "elapsed": "Dec", "Txns": 19400 }
        ];

        new Morris.Line({
            element: 'graph',
            data: day_data,
            xkey: 'elapsed',
            ykeys: ['Txns'],
            labels: ['Txns'],
            parseTime: false
        });
    </script>
</body>
</html>
