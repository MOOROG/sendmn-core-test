<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AutoDebitTransaction.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.AutoDebitTransaction" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js"></script>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/metisMenu.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>



    <script type="text/javascript">
       <%-- function LoadCalendars() {
            ShowCalFromTo("#<% =startDate.ClientID %>", "#<% =toDate.ClientID %>", 1);
            ShowCalFromTo("#<% =startDate2.ClientID %>", "#<% =toDate2.ClientID %>", 1);
        }
        LoadCalendars();--%>

        function CheckFormValidation() {
            var reqField = "startDate,toDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var startDate = $("#startDate").val();
            var endDate = $("#toDate").val();
            var SType = $("#StatusType").val();
           
            var url = "";
            //if (vName == "All") {
            //    url = "dayBookReportAll.aspx?startDate=" + startDate + "&endDate=" + endDate + "&vType=" + vType + "&vName=" + vName;

            //}
            //else
            url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?startDate=" + startDate + "&endDate=" + endDate + "&StatusType=" + SType + "&reportName=AutoDebit";
           
            OpenInNewWindow(url);
        }
       
    </script>
</head>
<body>
    <form id="Form1" name="repform" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="AutoDebitTransaction.aspx">Auto Debit Transaction Processing Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Auto Debit Transaction Processing Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    From Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>

                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    To Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                    <!-- End .row -->
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    <label>
                                        Status Type:</label>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="StatusType" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="All" Value="" />
                                        <asp:ListItem Text="Success" Value="0" />
                                        <asp:ListItem Text="Failed" Value="1" />
                                       
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-3">
                                    <input type="button" value="Search" class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                </div>
                            </div>
                            <!-- End .form-group  -->

                        </div>
                    </div>
                </div>
               
            </div>
        </div>
    </form>
    <!--script--->
   
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <script src="../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <!-- Flot -->
    <script src="../../../ui/js/flot/jquery.flot.js"></script>
    <script src="../../../ui/js/flot/jquery.flot.tooltip.min.js"></script>
    <script src="../../../ui/js/flot/jquery.flot.resize.js"></script>
    <script src="../../../ui/js/flot/jquery.flot.pie.js"></script>
    <script src="../../../ui/js/chartjs/Chart.min.js"></script>
    <script src="../../../ui/js/pace.min.js"></script>
    <script src="../../../ui/js/waves.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>
</body>
</html>
