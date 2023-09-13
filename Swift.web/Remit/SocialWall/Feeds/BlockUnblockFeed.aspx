<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BlockUnblockFeed.aspx.cs" Inherits="Swift.web.Remit.SocialWall.Feeds.BlockUnblockFeed" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
<%--    <script src="../../../js/jQuery/jquery-1.4.1.min.js"></script>--%>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    
    <script src="../../../js/jQuery/jquery.tablesorter.pager.js"></script>
    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/jQueryPagination/style.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style type="text/css">
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            background-color: #f5f5f5 !important;
        }
    </style>

    <script>
        //$(document).ready(function () {
        //    $("#myTable").tablesorter();
        //    //$("#myTable")
        //    //    .tablesorter({ widthFixed: true, widgets: ['zebra'] })
        //    //    .tablesorterPager({ container: $("#pager") });
        //});
        function Edit(criteriaId) {
            
            window.location = "IndividualRiskAssessment.aspx?criteriaId=" + criteriaId;
            
        }
        function DelRow(criteriaId) {
           
            if (confirm("Are you sure to delete selected row?")) {

                window.location = "IndividualRiskAssessment.aspx?criteriaId=" + criteriaId + "&del=Y";
            }
        }
        

    </script>
</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="List.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="BlockUnblockFeed.aspx">BlockUnblock Feeds List</a></li>

                        </ol>
                    </div>
                </div>
            </div>
            <div class="rba-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active">
                            <a href="BlockUnblockFeed.aspx" >BlockUnblock Feeds List </a></li>
                        
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">

                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default recent-activites">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">BlockUnblock Feeds List
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div>
                                            
                                        </div>
                                    </div>

                                    <div class="panel-body">
                                        <div>
                                            <div  class="trans-list">
                                    
                                    <div class="table-responsive">
                                        <!-- table  -->

                                        <asp:DataGrid ID="grdBlockUnblockFeed" CssClass="gridDiv table table-bordered table-striped table-condensed table-scroll" runat="server" AllowPaging="True" PageSize="100" >
       <PagerStyle Mode="NumericPages" />
    </asp:DataGrid>
                                        <!-- ./table -->
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
        </div>

        
    </form>

    
</body>
</html>

   