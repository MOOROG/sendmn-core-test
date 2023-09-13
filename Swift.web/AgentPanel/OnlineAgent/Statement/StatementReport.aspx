<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatementReport.aspx.cs" Inherits="Swift.web.AgentPanel.Statement.StatementReport" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="/ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <!-- <script src="js/jquery.nanoscroller.min.js"></script>-->
    <!--page plugins-->
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function (){
			ShowCalFromToUpToToday("#startDate", "#endDate", 1);
			$('#startDate').mask('0000-00-00');
			$('#endDate').mask('0000-00-00');
        });

        function CheckFormValidation() {
            var reqField = "startDate,endDate,CustomerInfo_aText,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#startDate").val();
            var endDate = $("#endDate").val();
            var acInfo = GetItem("CustomerInfo")[0];

            var url = "TxnStatement.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo;
            //alert(url);
            window.location.href = url;
        }
    </script>
</head>
<body>
    <form id="Form1" name="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Customer Management </a></li>
                            <li class="active"><a href="StatementReport.aspx">Customer Statement</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Customer Statement
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-4 control-label" for="">
                                    Customer Name/Id Number:<span class="errormsg">*</span></label>
                                <div class="col-lg-10 col-md-8">
                                    <uc1:SwiftTextBox ID="CustomerInfo" runat="server" Category="remit-CustomerInfo" CssClass="form-control" Title="Enter Customer Name/Id Number" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-4 control-label" for="">
                                    Start Date:</label>
                                <div class="col-lg-10 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox autocomplete="off" ID="startDate" runat="server" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-4 control-label" for="">
                                    End Date:</label>
                                <div class="col-lg-10 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox autocomplete="off" ID="endDate" runat="server" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-4">
                                    <input type="button" value="Search" onclick="CheckFormValidation();" class="btn btn-primary m-t-25" />
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