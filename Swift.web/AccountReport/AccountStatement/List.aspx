<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.AccountStatement.List" %>

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
    <script src="/ui/js/bootstrap-datepicker.js" type="text/javascript"></script>
    <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <!--page plugins-->
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/Reports/AccountStatement.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#startDate", "#endDate");
            ShowCalFromToUpToToday("#startDate2", "#endDate2");
            ShowCalFromToUpToToday("#startDateAfterSearch", "#endDateAfterSearch");
        });

        function CheckFormValidation(type) {
            var reqField = "startDate,endDate,acInfo_aText,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#startDate").val();
            var endDate = $("#endDate").val();
            var acInfo = GetItem("acInfo")[0];
            var acInfotxt = GetItem("acInfo")[1];
            var curr = $("#ddlCurrency").val();

            var url;
            //alert(url);
            if (type == 'download') {
                url = "StatementDetails.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&acName=" + acInfotxt + "&curr=" + curr + "&type=a&isDownload=y";
                OpenInNewWindow(url);
            }
            else {
                url = "StatementDetails.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&acName=" + acInfotxt + "&curr=" + curr + "&type=" + type;
                window.location.href = url;
            }
        }

        function CheckFormValidation2() {
            var reqField = "startDate2,endDate2,acInfo1_aText,havingValue,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = $("#startDate2").val();
            var endDate = $("#endDate2").val();
            var acInfo = GetItem("acInfo1")[0];
            var condition = $("#filterContion").val();
            var having = $("#havingValue").val();

            var url = "FilterStatementResult.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&filterContion=" + condition + "&having=" + having;
            window.location.href = url;


        }
        function ViewStatement() {
            ViewStatementReport();
        }
    </script>
</head>
<body>
    <form id="Form1" name="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="List.aspx">Account Statement</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row" id="searchDiv">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Account Statement
                            </h4>
                            <%-- <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>--%>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Ledger Name:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-8">
                                    <uc1:SwiftTextBox ID="acInfo" runat="server" Category="acInfo" CssClass="form-control" Title="Blank for All" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Currency:</label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Start Date:</label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    End Date:</label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDate" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-10 col-md-offset-4">
                                    <input type="button" value="Search" id="Search" onclick="ViewStatementReport()" class="btn btn-primary m-t-25" />
                                    &nbsp;
                                    <input type="button" style="display:none;" value="Date wise Search" onclick="CheckFormValidation('d');" class="btn btn-primary m-t-25" />
                                    &nbsp;
                                    <input type="button" value="Export To Excel" onclick="CheckFormValidation('download');" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6" style="display:none">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Conditional Statement
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    AC information:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-8">
                                    <uc1:SwiftTextBox ID="acInfo1" runat="server" Category="acInfo" CssClass="form-control"
                                        Title="Blank for All" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Start Date:</label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate2" onchange="return DateValidation('startDate2','t','endDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    End Date:</label>
                                <div class="col-lg-8 col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDate2" onchange="return DateValidation('startDate2','t','endDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    <label>
                                        Condition:</label>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="filterContion" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="AC Number" Value="ACC_NUM"></asp:ListItem>
                                        <asp:ListItem Text="Cheque No" Value="CHEQUE_NO"></asp:ListItem>
                                        <asp:ListItem Text="Narrations" Value="tran_particular"></asp:ListItem>
                                        <asp:ListItem Text="Amount" Value="tran_amt"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Having:<span class="errormsg">*</span></label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="havingValue" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-4">
                                    <input type="button" value="    Search    " onclick="CheckFormValidation2();" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="statementResult" style="display: none;">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Statement Search Result
                            </h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12 col-lg-12 form-group">
                                    <label id="accDetails"></label>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-lg-1 col-md-1 control-label form-group" for="">
                                    Start Date:</label>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDateAfterSearch" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-lg-1 col-md-1 control-label form-group" for="">
                                    End Date:</label>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDateAfterSearch" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-md-offset-1 form-group">
                                    <input type="button" id="SearchAgain" value="Search" class="btn btn-primary" onclick="ViewStatementReport('re')" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="table table-responsive" id="main">
                                            <table id="statementReportTbl" class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>S. No.</th>
                                                        <th>Tran Date</th>
                                                        <th>Particulars</th>
                                                        <th>FCY</th>
                                                        <th>FCY Amount</th>
                                                        <th>FCY Closing</th>
                                                        <th>DR/CR</th>
                                                        <th><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyMN","") %> Amount</th>
                                                        <th><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyMN","") %> Closing</th>
                                                        <th>DR/CR</th>
                                                        <%--<th>Reversal</th>--%>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="col-md-8 form-group">
                                        </div>
                                        <div class="col-md-4 form-group">
                                            <div class="table-responsive">
                                                <table class="table table-striped dt-responsive nowrap">
                                                    <tr>
                                                        <td><b>Opening Balance:</b></td>
                                                        <td><b>
                                                            <label id="openingBalance"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Total DR:(<label id="totalDrCount"></label>)</b></td>
                                                        <td><b>
                                                            <label id="totalDR"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Total CR:(<label id="totalCrCount"></label>)</b></td>
                                                        <td><b>
                                                            <label id="totalCR"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Closing Balance:(<label id="DrOrCr"></label>)</b></td>
                                                        <td><b>
                                                            <label id="closingBalance"></label>
                                                        </b></td>
                                                    </tr>
                                                </table>
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
