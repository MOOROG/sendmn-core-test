<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatementReport.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.Statement.StatementReport" %>

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
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <!-- <script src="js/jquery.nanoscroller.min.js"></script>-->
    <!--page plugins-->
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#startDate", "#endDate");
            $("#CustomerInfo_aText").val("");
			$("#CustomerInfo_aSearch").val("");
			$('#startDate').mask('0000-00-00');
			$('#endDate').mask('0000-00-00');
        });
        function CheckFormValidation(type) {
            var customer = GetValue("CustomerInfo_aSearch");
            if (customer == "") {
                alert("Please choose customer first");
                return false;
            }
            var reqField = "startDate,endDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#startDate").val();
            var endDate = $("#endDate").val();
            var acInfo = GetItem("CustomerInfo")[0];
            var acName = GetItem("CustomerInfo")[1];


            var url = "TxnStatement.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&type=" + type + "&acName=" + acName;
            //alert(url);
           //window.location.href = url;
            OpenInNewWindow(url);
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
                <div class="col-md-6">
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
                                <label class="col-md-3 control-label" for="">
                                    Customer Name/Id Number:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="CustomerInfo" runat="server" Category="remit-CustomerInfo" CssClass="form-control" Title="Enter Customer Name/Id Number" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Start Date:</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" runat="server" CssClass="form-control form-control-inline input-medium" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" autocomplete="off"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    End Date:</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDate" runat="server" CssClass="form-control form-control-inline input-medium" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" autocomplete="off"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-10 col-md-offset-3">
                                    <input type="button" value="Transaction Statement" onclick="return CheckFormValidation('T');" class="btn btn-primary m-t-25" />
                                    <input type="button" value="Account Statement" onclick="return CheckFormValidation('A');" class="btn btn-primary m-t-25" />
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