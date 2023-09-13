<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Front.aspx.cs" Inherits="Swift.web.Front" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1">
    <meta charset="utf-8" content="" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Fast Remit-Admin</title>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <link rel="stylesheet" href="ui/font-awesome/css/font-awesome.min.css" />
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.8.3/umd/popper.min.js" integrity="sha512-1MLpoCl/kz5ZBbx0J+lAOFcmH96ixcQeyKcSZBCKc/MY19OvIjBVUloVxHn3BF6+VCWxnn4CurOxm9YG5HlJdg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.1.3/js/bootstrap.min.js" integrity="sha512-OvBgP9A2JBgiRad/mM36mkzXSXaJE9BEIENnVEmeZdITvwT09xnxLtT4twkCa8m/loMbPHsvPl0T8lRGVBwjlQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.sumoselect/3.1.6/sumoselect.min.css">

    <!-- Latest compiled and minified JavaScript -->
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery.sumoselect/3.1.6/jquery.sumoselect.min.js"></script>
    <style>
        * {
            color: white;
        }

        option, li > label, .select-all > label {
            color: black;
        }

        .select-all {
            height: 37px !important;
        }

        .row, .col, .col-1, .col-2, .col-4, .col-8 {
            /*outline: 1px solid black;*/
        }

        .container {
            max-width: 1800px;
            margin-top: 50px
        }

        .center {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        span {
            font-size: 50px;
            color: black;
            text-align: center;
        }

            span.apexcharts-legend-text {
                color: white !important;
            }

        tpsan {
            color: white !important;
        }

        text {
            fill: white !important;
        }

        .fa-gradient {
            background: pink;
            background: -webkit-linear-gradient(0deg, rgba(105,60,205,1) 0%, rgba(34,166,195,1) 100%);
            background: linear-gradient(0deg, rgba(105,60,205,1) 0%, rgba(34,166,195,1) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-align: center;
        }

        h5 {
            text-align: center;
            color: deepskyblue;
        }

        .bg {
            background-color: #09314E;
            border-radius: 10px;
            margin: 5px;
        }

        .bgg {
            background-color: #09314E;
            border-radius: 10px;
            margin: px;
            padding: 0px;
        }

        .SumoSelect > .CaptionCont > span {
            display: block;
            font-size: initial;
        }

        .SumoSelect {
            width: 140px;
        }

            .SumoSelect > .CaptionCont > label, .select-all > span > i, .select-all.partial > span > i {
                display: none
            }

            .SumoSelect .select-all.partial > span i, .SumoSelect .select-all.selected > span i, .SumoSelect > .optWrapper.multiple > .options li.opt.selected span i {
                background-color: #0a58ca;
            }

        #title {
            font-weight: bold;
            text-align: center;
        }
    </style>
</head>
<body>
    <form runat="server">
        <div class="container">
            <div class="row bg" style="min-height: 150px; margin-right: 0;">
                <div class="col-1 center">
                    <img alt="logo" src="ui/images/sendmnlogo.svg" style="width: 70px" />
                </div>
                <div class="col-3">
                    <div class="row">
                        <h1 id="title">Currency Transaction Dashboard</h1>
                    </div>
                    <div class="row flex-grow-1" style="margin: 10px">
                        <div class="col-6 center" style="padding: 0 40px 0 40px;">
                            <asp:Button ID="buttonMNT" runat="server" Text="MNT" CssClass="btn btn-primary btn-lg col-12" OnClick="buttonMNT_Click" />
                        </div>
                        <div class="col-6 center" style="padding: 0 40px 0 40px;">
                            <asp:Button ID="buttonUSD" runat="server" Text="USD" CssClass="btn btn-light btn-lg col-12" OnClick="buttonUSD_Click" />
                        </div>
                    </div>
                </div>
                <div class="col-5">
                    <div class="row" style="margin-top: 30px; padding-left: 12px; padding-right: 14px;">
                        <div class="col" style="margin: 2px">
                            <div class="form-group">
                                <label class="input-label">Year:</label>
                                <asp:ListBox ID="dropdownYear" runat="server" CssClass="form-select" SelectionMode="Multiple">
                                    <asp:ListItem Text="2020" Value="2020" />
                                    <asp:ListItem Text="2021" Value="2021" />
                                    <asp:ListItem Text="2022" Value="2022" />
                                    <asp:ListItem Text="2023" Value="2023" />
                                </asp:ListBox>
                            </div>
                        </div>
                        <div class="col" style="margin: 2px">
                            <div class="form-group">
                                <label class="input-label">Month:</label>
                                <asp:ListBox ID="dropdownMonth" runat="server" CssClass="form-select" SelectionMode="Multiple">
                                    <asp:ListItem Text="January" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="February" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="March" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="April" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="May" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="June" Value="6"></asp:ListItem>
                                    <asp:ListItem Text="July" Value="7"></asp:ListItem>
                                    <asp:ListItem Text="August" Value="8"></asp:ListItem>
                                    <asp:ListItem Text="September" Value="9"></asp:ListItem>
                                    <asp:ListItem Text="October" Value="10"></asp:ListItem>
                                    <asp:ListItem Text="November" Value="11"></asp:ListItem>
                                    <asp:ListItem Text="December" Value="12"></asp:ListItem>
                                </asp:ListBox>
                            </div>
                        </div>
                        <div class="col" style="margin: 2px">
                            <div class="form-group">
                                <label class="input-label">Agent:</label>
                                <asp:ListBox ID="dropdownAgent" runat="server" CssClass="form-select" SelectionMode="Multiple"></asp:ListBox>
                            </div>
                        </div>
                        <div class="col" style="margin: 2px">
                            <div class="form-group">
                                <label class="input-label">Agent:</label>
                                <asp:ListBox ID="dropdownCountry" runat="server" CssClass="form-select" SelectionMode="Multiple"></asp:ListBox>
                            </div>
                        </div>
                    </div>

                    <div class="row" style="margin: 15px 26px 15px 15px;">
                        <asp:Button ID="timelineButton" runat="server" Text="Timeline" class="btn btn-primary" OnClick="timelineButton_Click" OnClientClick="dashboardTimeline();" />
                    </div>
                </div>
                <div class="col">
                    <div class="row" style="height: 100%">
                        <div class="col-6 center">
                            <asp:Button ID="outButton" runat="server" Text="Гарсан" CssClass="btn btn-primary btn-lg col-12" OnClick="OutButton_Click" />
                        </div>
                        <div class="col-6 center">
                            <asp:Button ID="inButton" runat="server" Text="Орсон" CssClass="btn btn-light btn-lg col-12" OnClick="InButton_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="row" style="min-height: 150px">
                <div class="col d-flex flex-column">
                    <div class="row flex-grow-1 align-items-center">
                        <div class="col-4 center">
                            <i class="fa fa-bar-chart fa-5x fa-gradient"></i>
                        </div>
                        <div class="col-8">
                            <div class="row">
                                <h5>Total Amount</h5>
                            </div>
                            <div class="row justify-content-center">
                                <asp:Label ID="totalAmount" runat="server" Text="32.31M"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col d-flex flex-column">
                    <div class="row flex-grow-1 align-items-center">
                        <div class="col-4 center">
                            <i class="fa fa-money fa-5x fa-gradient"></i>
                        </div>
                        <div class="col-8">
                            <div class="row">
                                <h5>Commission amount</h5>
                            </div>
                            <div class="row justify-content-center">
                                <asp:Label ID="commissionAmount" runat="server" Text="32.31M"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col d-flex flex-column">
                    <div class="row flex-grow-1 align-items-center">
                        <div class="col-4 center">
                            <i class="fa fa-line-chart fa-5x fa-gradient"></i>
                        </div>
                        <div class="col-8">
                            <div class="row">
                                <h5>Volume</h5>
                            </div>
                            <div class="row justify-content-center">
                                <asp:Label ID="volumeAmount" runat="server" Text="0.0K"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col d-flex flex-column">
                    <div class="row flex-grow-1 align-items-center">
                        <div class="col-4 center">
                            <i class="fa fa-pie-chart fa-5x fa-gradient"></i>
                        </div>
                        <div class="col-8">
                            <div class="row">
                                <h5>Gross profit margin</h5>
                            </div>
                            <div class="row justify-content-center">
                                <asp:Label ID="profitAmount" runat="server" Text="32.31M"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="dashboardChart" class="row" style="min-height: 200px; display: flex">
                <div class="col" style="padding-right: 0px;">
                    <div id="chart" class="row bg"></div>
                    <div id="chart4" class="row bg"></div>
                </div>
                <div class="col" style="padding-left: 8px;">
                    <div class="row">
                        <div id="chart2" class="col bg" style="padding: 10px"></div>
                        <div id="chart3" style="max-height: 300px; margin-left: 1px;" class="col bg"></div>
                    </div>
                    <div class="row">
                        <div id="chart5" class="row" style="background-color: #09314E; border-radius: 10px; margin-left: 5px; width: 99%;"></div>
                    </div>
                </div>
            </div>
            <div id="dashboardTimeline" class="row" style="min-height: 200px; display: none">
                <div class="col">
                    <div id="chartTimeline" class="row bg">
                        <div id="chart6" class="row"></div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        if (timeline == false) {
            var dashboardTimeline = document.getElementById("dashboardTimeline");
            dashboardChart.style.display = "flex";
            dashboardTimeline.style.display = "none";
            var options2 = {
                chart: {
                    height: '250px',
                    type: 'donut',
                    foreColor: '#ffffff'
                },
                series: options2series,
                labels: options2labels
            };
            var options3 = {
                chart: {
                    height: '300px',
                    type: 'bar',
                    foreColor: '#ffffff'
                },
                plotOptions: {
                    bar: {
                        horizontal: true
                    }
                },
                series: [{
                    data: sChargeList,
                }],
                xaxis: {
                    categories: countryList,
                },
            };

            //var options5 = {
            //    chart: {
            //        height: '250px',
            //        type: "treemap",
            //    },
            //    series: [
            //        {
            //            data: [
            //                {
            //                    x: "New Delhi",
            //                    y: 218,
            //                },
            //                {
            //                    x: "Kolkata",
            //                    y: 149,
            //                },
            //                {
            //                    x: "Mumbai",
            //                    y: 184,
            //                },
            //                {
            //                    x: "Ahmedabad",
            //                    y: 55,
            //                },
            //                {
            //                    x: "Bangaluru",
            //                    y: 84,
            //                },
            //                {
            //                    x: "Pune",
            //                    y: 31,
            //                },
            //                {
            //                    x: "Chennai",
            //                    y: 70,
            //                }
            //            ],
            //        },
            //    ]
            //}
            var chart = new ApexCharts(document.querySelector("#chart"), options1);
            var chart2 = new ApexCharts(document.querySelector("#chart2"), options2);
            var chart3 = new ApexCharts(document.querySelector("#chart3"), options3);
            var chart4 = new ApexCharts(document.querySelector("#chart4"), options4);
            var chart5 = new ApexCharts(document.querySelector("#chart5"), options5);
            //var chart6 = new ApexCharts(document.querySelector("#chart4"), options6);


            chart.render();
            chart2.render();
            chart3.render();
            chart4.render();
            chart5.render();
            //chart6.render();

            $('#submit').value = "You selected: " + $('#mySelect').val();
        } else {
            var dashboardTimeline = document.getElementById("dashboardTimeline");
            dashboardChart.style.display = "none";
            dashboardTimeline.style.display = "flex";
            console.log(options6data)
            console.log(options6data[0])

            var options6 = {
                series: [{
                    data: options6data,
                }],
                chart: {
                    id: 'area-datetime',
                    type: 'area',
                    height: 500,
                    zoom: {
                        autoScaleYaxis: true
                    }
                },
                yaxis: {
                    labels: {
                        formatter: function (val) {
                            return val.toLocaleString();
                        }
                    }
                },
                dataLabels: {
                    enabled: false
                },
                markers: {
                    size: 0,
                    style: 'hollow',
                },
                xaxis: {
                    type: 'datetime',
                    min: new Date('01 Jan 2021').getTime(), //
                    max: new Date('01 Dec 2023').getTime(), //
                    tickAmount: 6,
                },
                tooltip: {
                    x: {
                        format: 'dd MMM yyyy'
                    }
                },
                fill: {
                    type: 'gradient',
                    gradient: {
                        shadeIntensity: 1,
                        opacityFrom: 0.7,
                        opacityTo: 0.9,
                        stops: [0, 100]
                    }
                },
            };
            var chart6 = new ApexCharts(document.querySelector("#chart6"), options6);
            chart6.render();
        }
    </script>
    <script> 
        var yearSelect;
        var monthSelect;
        var agentSelect;
        var countrySelect;

        $(document).ready(function () {
            yearSelect = $('#dropdownYear').SumoSelect({
                placeholder: 'Select',
                csvDispCount: 0,
                selectAll: true,
                selectAllPartialCheck: false,
            });
            monthSelect = $('#dropdownMonth').SumoSelect({
                placeholder: 'Select',
                csvDispCount: 0,
                selectAll: true,
            });
            agentSelect = $('#dropdownAgent').SumoSelect({
                placeholder: 'Select',
                csvDispCount: 0,
                selectAll: true,

            });
            countrySelect = $('#dropdownCountry').SumoSelect({
                placeholder: 'Select',
                csvDispCount: 0,
                selectAll: true,
            });
            //document.querySelector('.SumoSelect.sumo_dropdownYear')[0].sumo.selectAll();
        });
        function dashboardTimeline() {
            yearSelect.sumo.selectAll();
            monthSelect.sumo.selectAll();
            agentSelect.sumo.selectAll();
            countrySelect.sumo.selectAll();
        }
    </script>
</body>
</html>
