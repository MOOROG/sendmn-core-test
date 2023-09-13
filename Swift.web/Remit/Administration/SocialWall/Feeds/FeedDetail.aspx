<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FeedDetail.aspx.cs" Inherits="Swift.web.Remit.SocialWall.Feeds.FeedDetail" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBoxCustom" Src="~/Component/AutoComplete/SwiftTextBoxCustom.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/menu.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/sweetalert.css" rel="stylesheet" />

    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/Swift_grid.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="../../../../css/datatables/datatables.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js"></script>
    <script src="../../../../js/swift_autocomplete_custom.js"></script>

     <style type="text/css">
        .form-control-sm
        {
            height: 26px;
            padding: 2px 6px;
        }
        .feedpagination
        {
            margin:5px 0;
        }
        .btnfeed
        {
            margin-left: 10px;
        }
    </style>

    <script type="text/javascript">
        function GetReportedFeed(feedId) {
            var param = "dialogHeight:550px;dialogWidth:800px;dialogLeft:150;dialogTop:80;center:yes;";
            var res = PopUpWindow("ReportedFeedDetail.aspx?methodName=" + "ReportedFeed" + "&feedId=" + feedId, param);
        }
    </script>

    <script type="text/javascript">
        function ViewFeedDetail(feedId) {
            var param = "dialogHeight:550px;dialogWidth:800px;dialogLeft:150;dialogTop:80;center:yes;";
            var res = PopUpWindow("ViewFeedDetail.aspx?methodName=" + "GetReport" + "&feedId=" + feedId, param);
        }
    </script>
</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper">

            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Feeds List</a></li>
                            <li class="active"><a href="FeedDetail.aspx">Feed Details </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Feeds List</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title" style="margin-top: 20px">Search Feed Details</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <input type="hidden" id="hddPrevious" />
                                    <input type="hidden" id="hddiTotalRecords" />
                                    <input type="hidden" id="hddNext" runat="server" />
                                    <%--<div class="form-group">
                                        <label class="col-lg-2 col-md-3 control-label" for="">
                                            User Id:
                                        </label>
                                        <div class="col-lg-10 col-md-9">
                                            <uc1:SwiftTextBoxCustom ID="userAc" runat="server" Category="remit-UserInfo" />
                                        </div>
                                    </div>--%>
                                    <div class="form-group">
                                        <label for="" class="col-sm-2 col-form-label">Operative Country:</label>
                                        <div class="col-lg-10 col-md-9">
                                            <asp:DropDownList ID="ddlOperativeCountry" CssClass="form-control" runat="server"></asp:DropDownList>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="" class="col-sm-2 col-form-label">Reported:</label>
                                        <div class="col-lg-10 col-md-9">
                                            <input type="checkbox" id="chkReported" />
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <div class="col-md-2 col-md-offset-2">
                                            <input type="button" id="btnSearch" class="btn btn-primary m-t-25 btnfeed" value="Search" onclick="GenerateFeeds();" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-body">
                                    <div style="margin-top: 10px;">
                                        <div id="divfeeddetail">
                                            <div class="row">
                                                <div class="col-md-1">
                                                    Show
                                                </div>
                                                <div class="col-md-1">
                                                    <select class="form-control form-control-sm" id="ddlPageSize">
                                                        <option value="2">2</option>
                                                        <option value="5">5</option>
                                                        <option value="10" selected="selected">10</option>
                                                        <option value="25">25</option>
                                                        <option value="75">75</option>
                                                        <option value="100">100</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-1">
                                                    entries
                                                </div>
                                            </div>
                                            <div class="data-table-scroll">
                                            <table id="feed-report" cellspacing="0" class="table table-striped">
                                                <thead>
                                                    <tr>
                                                        <th colspan="0" style="display: none;" rowspan="0">Feed Id</th>
                                                        <th>UserId</th>
                                                        <th style="display:none;">CreatedDate</th>
                                                        <th style="width: 400px;">FeedText</th>
                                                        <th>FeedImage</th>
                                                        <th>Action1</th>
                                                        <th>Action2</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="rpt" runat="server">
                                                </tbody>
                                            </table>
                                                </div>
                                      <div class="feedpagination">
                                            <button type="button" onclick="return GenerateFeeds(this.id);" id="btnPrevious" class="btn btn-primary m-t-25">&laquo; Previous</button>
                                            <button type="button" onclick="return GenerateFeeds(this.id);" id="btnNext" class="btn btn-primary m-t-25">Next &raquo;</button>
                                           </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="../../../../js/datatables/datatables.min.js"></script>
        <script src="../../../../ui/js/sweet-alert/sweetalert.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function()
            {
                $("#btnPrevious").hide();
                $("#btnNext").hide();
            });
                
        </script>
        <script type="text/javascript">
            function feedReport() {
                var table = $('#feed-report').DataTable({
                    "order": [[ 2, "desc" ]],
                    "bserverSide": true,
                    "bPaginate": false,
                    "lengthMenu": [[10, 25, 50, 100, 200, -1], [10, 25, 50, 100, 200, "All"]],
                    "recordsTotal": parseInt($("hddiTotalRecords").val()),
                    "recordsDisplay": parseInt($("hddiTotalRecords").val())
                });

                $(".table.table-striped.dataTable").wrap(function () {
                    return "<div class='data-table-scroll" + "'></div>";
                });
            }
        </script>
        <script type="text/javascript">
            function GenerateFeeds(id) {
                if (id != undefined) {
                    var previous = "";
                    var next = "";
                    if (document.getElementById('btnPrevious').id == id) {
                        previous = $("#hddPrevious").val();
                    }
                    else {
                        previous = null;
                    }
                    if (document.getElementById('btnNext').id == id) {
                        next = $("#hddNext").val();
                    }
                    else {
                        next = null;
                    }
                }
                else
                {
                        $("#btnPrevious").attr("disabled", true);
                }

                //var userId = $("#userAc_aText").val();
                //var user = userId.split('|');
                //var res = null;
                //if (user[1] != null || user[1] != undefined) {
                //    userId = user[1].trim();
                //}

                //var ddlCountry = document.getElementById("userAc_aCustom");
                //var country = ddlCountry.options[ddlCountry.selectedIndex].text;
                var country = $("#ddlOperativeCountry").val();
                var dataToSend = {
                    methodName: "SearchFeeds",
                    userId: "",
                    country: country,
                    before: previous,
                    after: next,
                    onlyReported: chkReported.checked == true ? "true" : "false",
                    limit: $('#ddlPageSize').val()
                };
                var xhr = $.ajax({
                    type: "POST",
                    url: '',
                    dataType: "JSON",
                    data: dataToSend,
                    success: function (result) {
                        $("#btnPrevious").show();
                        $("#btnNext").show();
                        $('#hddPrevious').val(result.pageInformation.before);
                        $('#hddNext').val(result.pageInformation.after);
                        if (result.pageInformation.remaining == "0" && next != null) {
                            $("#btnNext").attr("disabled", true);
                        }
                        else {
                            $("#btnNext").removeAttr("disabled");

                        }

                        if ((result.pageInformation.remaining == "0" && previous != null)) {
                            $("#btnPrevious").attr("disabled", true);
                        }
                        else {
                            $("#btnPrevious").removeAttr("disabled");

                        }
                        if ((previous == null && next == null))
                        {
                            $("#btnPrevious").attr("disabled", true);
                        }
                        PopulateData(result.objects);
                       
                    },
                    error: function () {
                        swal("Error!", "Oops!!! something went wrong, please try again.", "error");
                    }
                });

            };

            function PopulateData(dt) {
                var table = '';
                if (dt.length == 0) {
                    debugger
                    table += "<tr>"
                    table += "<td colspan='6' align='center'>No Data to Display!</td>"
                    table += "</tr>"
                    $("#rpt").html(table);
                    $("#btnPrevious").hide();
                    $("#btnNext").hide();
                    return;
                }
                debugger;
                console.log(dt);
                for (var i = 0; i < dt.length; i++) {
                    table += "<tr>"
                    table += "<td scope='row' style='display:none;'>" + dt[i]["id"] + "</td>"
                    table += "<td>" + dt[i]["userId"] + "</td>"
                    table += "<td style='display:none;'>" + dt[i]["createdDate"] + "</td>"
                    var imgUrl = dt[i]["feedImage"];
                    table += "<td>" + dt[i]["feedText"] + "</td>"
                    table += "<td>" + ((dt[i]["feedImage"] != null) ? "<div class='show-image'><a href='javascript:void(0)' onclick=OpenInNewWindow('" + imgUrl + "');><img src='" + imgUrl + "' style='width:20px;height:20px;'></a></div>" : "No Image") + "</td>"
                    table += "<td><a onclick=ViewFeedDetail('" + dt[i]["id"] + "')><i class='fa fa-eye' aria-hidden='true'></i></a></td>"
                    table += "<td><input id='btn1' type='button' value='Reported Feed' onclick=GetReportedFeed('" + dt[i]["id"] + "') class='btn btn-primary'></td>"
                    table += "</tr>"
                }
                if ($.fn.DataTable.isDataTable('#feed-report')) {
                    $('#feed-report').DataTable().destroy();
                }
                $("#rpt").html(table);
                feedReport();
            };
        </script>
    </form>
</body>
</html>

