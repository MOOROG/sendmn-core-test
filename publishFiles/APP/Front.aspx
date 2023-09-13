<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Front.aspx.cs" Inherits="Swift.web.Font" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Fast Remit-Admin</title>
    <link href="ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="ui/css/style.css" rel="stylesheet" />
    <script src="ui/js/jquery.min.js"></script>
    <script src="ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="js/functions.js"></script>

    <!-- for PI chart -->
    <%--<script src="js/highcharts/picharts.js"></script>--%>
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/modules/series-label.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="js/DashBoardchart.js"></script>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style type="text/css">
        .holder {
            /*background-color: #ccc;*/
            /*width: 300px;*/
            height: 250px;
            overflow: hidden;
            padding: 10px;
            /*font-family: Helvetica;*/
        }

            .holder .mask {
                position: relative;
                left: 0px;
                /*top: 10px;*/
                /*width: 300px;*/
                height: 240px;
                overflow: hidden;
            }

            .holder ul {
                list-style: none;
                margin: 0;
                padding: 0;
                position: relative;
            }

                .holder ul li {
                    padding: 10px 0px;
                }

                    .holder ul li a {
                        /*color: darkred;*/
                        text-decoration: none;
                    }
    </style>
    <style>
        #container1 {
            min-width: 310px;
            max-width: 1200px;
            height: 270px;
            margin-left: -50px !important;
        }

        #container2 {
            min-width: 310px;
            max-width: 1200px;
            height: 270px;
            margin-left: -50px !important;
        }

        #container3 {
            min-width: 310px;
            max-width: 1200px;
            height: 270px;
            margin-left: -50px !important;
        }

        #container4 {
            min-width: 310px;
            max-width: 1200px;
            height: 270px;
            margin-left: -50px !important;
        }

        #container5 {
            min-width: 310px;
            max-width: 1200px;
            height: 270px;
            margin-left: -50px !important;
        }

        .highcharts-menu-item {
            font-family: sans-serif !important;
            font-weight: bold !important;
        }

        hr {
            margin-bottom: 10px !important;
            margin-top: 10px !important;
        }
    </style>
    <script type="text/javascript">
        function OpenInNewWin(urlType) {
            var url;
            if (urlType == 'iSend') {
                url = '../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?reportName=trananalysisintl&fromDate=<%= GetDate() %>&toDate=<%= GetDate() %>&fromTime=00:00:00&toTime=23:59:59&dateType=S&sCountry=&rCountry=&groupBy=detail&searchBy=sender&status=iSend';
            }
            else if (urlType == 'iPaid') {
                url = '../Remit/Transaction/Reports/IntlReports/PayTrnRpt/ShowReport.aspx?reportName=paidtranint&fromDate=<%= GetDate() %>&toDate=<%= GetDate() %>&sCountry=&sZone=All&sDistrict=All&rCountry=&rZone=All&rDistrict=All';
            }
            else if (urlType == 'iCancel') {
                //reportName=40111600&sBranch=393879&orderBy=dot&fromDate=1/20/2019&toDate=1/20/2019&dateField=paidDate&from=2019/01/20&to=2019/01/20&transType=Cancel&rptType=s&displayTranNo=N
                url = '../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20163300&fromDate=<%= GetDate() %>&toDate=<%= GetDate() %>&rCountry=Nepal&ctype=Approved&transType=Cancel&rptType=s&displayTranNo=N';
            }
            else if (urlType == 'isend') {
                url = "";
            }
            OpenInNewWindow(url);
            return false;
        }
        function ShowReport(reportType) {
            var url;
            if (reportType == 'Unpaid Transactions') {
                var TranType = 'i';
                var Country = '';
                var url = "RemittanceSystem/RemittanceReports/Reports.aspx?reportName=20167500&flag=detail1&TranType=" + TranType + "&country=" + Country;
            }
            OpenInNewWindow(url);
            return false;
        }

        jQuery.fn.liScroll = function (settings) {
            settings = jQuery.extend({
                travelocity: 0.03
            }, settings);
            return this.each(function () {
                var $strip = jQuery(this);
                $strip.addClass("newsticker")
                var stripHeight = 1;
                $strip.find("li").each(function (i) {
                    stripHeight += jQuery(this, i).outerHeight(true); // thanks to Michael Haszprunar and Fabien Volpi
                });
                var $mask = $strip.wrap("<div class='mask'></div>");
                var $tickercontainer = $strip.parent().wrap("<div class='tickercontainer'></div>");
                var containerHeight = $strip.parent().parent().height();	//a.k.a. 'mask' width
                $strip.height(stripHeight);
                var totalTravel = stripHeight;
                var defTiming = totalTravel / settings.travelocity;	// thanks to Scott Waye
                function scrollnews(spazio, tempo) {
                    $strip.animate({ top: '-=' + spazio }, tempo, "linear", function () { $strip.css("top", containerHeight); scrollnews(totalTravel, defTiming); });
                }
                scrollnews(totalTravel, defTiming);
                $strip.hover(function () {
                    jQuery(this).stop();
                },
                    function () {
                        var offset = jQuery(this).offset();
                        var residualSpace = offset.top + stripHeight;
                        var residualTime = residualSpace / settings.travelocity;
                        scrollnews(residualSpace, residualTime);
                    });
            });
        };

        $(function () {
            $("ul#messages").liScroll();
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row" id="divPopulateTxnCount" runat="server">
                <div class="col-sm-6 col-md-3 margin-b-30">
                    <div class="tile green">
                        <div class="tile-title clearfix">
                            Today's  Send
                        </div>
                        <div class="tile-body clearfix">
                            <i class="fa fa-credit-card"></i>
                            <h4 class="pull-right">
                                <a onclick=" OpenInNewWin('iSend')" href="#" style="color: white;">
                                    <asp:Label runat="server" ID="iSend"></asp:Label></a>
                            </h4>
                        </div>
                        <div class="tile-footer">
                            <a onclick=" OpenInNewWin('iSend')" href="#">View Details...</a>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-md-3 margin-b-30">
                    <div class="tile blue">
                        <div class="tile-title clearfix">
                            Today's     Pay
                        </div>
                        <div class="tile-body clearfix">
                            <i class="fa fa-credit-card"></i>
                            <h4 class="pull-right">
                                <a style="color: white;" onclick=" return OpenInNewWin('iPaid');" href="#">
                                    <asp:Label runat="server" ID="iPaid"></asp:Label>
                                </a>
                            </h4>
                        </div>
                        <div class="tile-footer">
                            <a onclick="return OpenInNewWin('iPaid');" href="#">View Details...</a>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-md-3 margin-b-30">
                    <div class="tile red">
                        <div class="tile-title clearfix">
                            Today's  Cancel
                        </div>
                        <div class="tile-body clearfix">
                            <i class="fa fa-credit-card"></i>
                            <h4 class="pull-right">
                                <a onclick=" OpenInNewWin('iCancel')" style="color: white;" href="#">
                                    <asp:Label runat="server" ID="iCancel"></asp:Label></a>
                            </h4>
                        </div>
                        <div class="tile-footer">
                            <a onclick=" OpenInNewWin('iCancel')" href="#">View Details...
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" style="display: none">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Status Wise number of Transaction</h4>
                            <div class="panel-actions">
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="col-md-12" id="TxnWiseStatus" runat="server"></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Notification And Messages</h4>
                            <div class="panel-actions">
                            </div>
                        </div>
                        <div class="panel-body pad-0 holder" style="height: 200px !important">
                            <ul class="list-group" id="messages" runat="server">
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function ExportToExcel(type) {
            if (type == 'AccountList') {
                $("#btnExcelAccount").click();
            }
            else {
                $("#type").val(type);
                $("#btnExcel").click();
            }

        };
        function ShowMessage(msgId) {
            $.ajax({
                type: "POST",
                url: "/Front.aspx",
                data: { MethodName: "Messages", MessageId: msgId },
                success: function (result) {
                    PopulateData(result);
                }
            });
        };
        function PopulateData(data) {
            $('#myModal').modal('show');

            var obj = jQuery.parseJSON(data);
            $('#message').html(obj.Message);
            $('#createdBy').html(obj.CreatedBy);
            $('#createdDate').html(obj.CreatedDate);
            //$('#questionDesc').html(obj.Description);
            //$('#forumTitle').html(obj.ForumTitle);
        };
    </script>
</body>
</html>