<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.CustomerModifyLog.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <!-- <script src="js/jquery.nanoscroller.min.js"></script>-->
    <!--page plugins-->
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style type="text/css">
        .errormsg1 {
            color: red;
        }
    </style>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $('.errormsg1').hide();
            $("#searchFroVal").val(0);
            $("#ddlSearchType").change(function () {
                var d = ["", ""];
                SetItem("<% =CustomerInfo.ClientID%>", d);
                <% = CustomerInfo.InitFunction() %>;
            });
            ShowCalFromToUpToToday("#fromDate", "#toDate", 1);
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');

            $("#searchFor").on('change', function () {
                var a = $("#searchFor").children("option:selected").val();
                $("#searchFroVal").val(a);
                if (a == 'individual') {
                    $('.errormsg1').show();
                    //$('#CustomerInfo_aText').prop("disabled",false);
                } else {
                    $('.errormsg1').hide();
                    $('#CustomerInfo_aText').val('');
                    $('#CustomerInfo_aValue').val('');
                    //$('#CustomerInfo_aText').prop("disabled", true); 
                }
            });

        });
        function GetCustomerSearchType() {
            return $('#ddlSearchType').val();
        }
        function CheckFormValidation() {
            var reqField = "";
            if ($("#searchFroVal").val().toString() == 'individual') {
                 reqField = "ddlSearchType,fromDate,toDate,CustomerInfo_aText,";
            } else {
                 reqField = "fromDate,toDate,";
            }
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#fromDate").val();
            var endDate = $("#toDate").val();
            var customerId = $("#CustomerInfo_aValue").val();
             var searchFor = $("#searchFroVal").val();
            var url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerModifyLog&flag=s&fromDate=" + startDate + "&toDate=" + endDate + "&customerId=" + customerId + "&searchFor=" + searchFor;
            //alert(url);
            OpenInNewWindow(url);
        }
    </script>
</head>
<body>
    <form id="Form1" name="form1" runat="server">
        <asp:HiddenField ID="searchFroVal" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Customer Management </a></li>
                            <li class="active"><a href="List.aspx">Customer Modify Log</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Customer Modify Log
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-6 control-label text-right" for="">
                                    Search For:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-6">
                                    <asp:DropDownList ID="searchFor" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="0">All</asp:ListItem>
                                        <asp:ListItem Value="individual">Individual</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-6 control-label text-right" for="">
                                    Search By:<span class="errormsg1">*</span></label>
                                <div class="col-lg-8 col-md-6">
                                    <asp:DropDownList ID="ddlSearchType" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-6 control-label text-right" for="">
                                    Search Value:<span class="errormsg1">*</span></label>
                                <div class="col-lg-8 col-md-6">
                                    <uc1:SwiftTextBox ID="CustomerInfo" runat="server" Category="remit-searchCustomerForLog" Param1="@GetCustomerSearchType()" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-6 control-label text-right" for="">
                                    From Date:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox autocomplete="off" ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-6 control-label text-right" for="">
                                    To Date:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox autocomplete="off" ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-offset-2">
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
