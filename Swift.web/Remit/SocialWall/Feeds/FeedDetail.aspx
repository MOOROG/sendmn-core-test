<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FeedDetail.aspx.cs" Inherits="Swift.web.Remit.SocialWall.Feeds.FeedDetail" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBoxCustom" Src="~/Component/AutoComplete/SwiftTextBoxCustom.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <%--<script type="text/javascript" src="../../ui/js/jquery-1.8.3.js"></script>--%>
    
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>
        <script type="text/javascript" src="../../../ui/js/custom.js"></script>-->
    
    <!--page plugins-->
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_autocomplete_custom.js" type="text/javascript"></script>
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
      
            if(!$.isFunction($.fn.curCSS))
            if(!$.isFunction($.curCSS))
            $.curCSS = $.css;
        
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
                            <li><a href="Feeddetail.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="Feeddetail.aspx">Feeds List</a></li>

                        </ol>
                    </div>
                </div>
            </div>
            <div class="rba-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active">
                            <a href="Feeddetail.aspx" >Feeds List </a></li>
                        
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">

                        <div class="row">
                            <div class="panel-body">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        User ID:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    
                                    <uc1:SwiftTextBoxCustom ID="userAc" runat="server" Category="remit-UserInfo"   />
                                    <%--agentNameAC--%>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <!-- End .form-group  -->
                            <%--<div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Country:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <input type="text" id="country" />
                                    <asp:DropDownList ID="branchDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>--%>
                            
                            <div class="form-group">
                                <div class="col-md-12 col-md-offset-2">
                                    
                                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25" Text="Feeds Report" OnClick="btnSearch_Click" />
                                </div>
                                
                            </div>
                            <!-- End .form-group  -->
                        </div>
                            <div class="col-md-12">
                                <div class="panel panel-default recent-activites">
                                    <!-- Start .panel -->
                                    <div class="panel-heading" style="width:1900px;">
                                        <h4 class="panel-title">Feeds List
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body" style="width:1900px;">
                                        <div>
                                            
                                        </div>
                                    </div>

                                    <div class="panel-body" style="width:1900px;">
                                        <div>
                                            <div  class="trans-list">
                                    
                                    <div class="table-responsive">
                                        <!-- table  -->
                                         
                                        <asp:DataGrid ID="grdList" CssClass="gridDiv table table-bordered table-striped table-condensed table-scroll" runat="server" AllowPaging="True" PageSize="100" >
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

