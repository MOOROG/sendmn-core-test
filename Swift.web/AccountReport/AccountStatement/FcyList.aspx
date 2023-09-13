<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FcyList.aspx.cs" Inherits="Swift.web.AccountReport.AccountStatement.FcyList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../Bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- MetisMenu CSS -->
    <link href="../../../Bootstrap/css/metisMenu.min.css" rel="stylesheet" type="text/css" />
    <!-- timeline CSS -->
    <link href="../../../Bootstrap/css/timeline.css" rel="stylesheet" type="text/css" />
    <!-- Custom CSS -->
    <link href="../../../Bootstrap/css/style.css" rel="stylesheet" type="text/css" />
    <!-- Custom Fonts -->
    <link href="../../../Bootstrap/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="../../css/style1.css" rel="stylesheet" type="text/css" />
    <link href="../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =startDate.ClientID %>", "#<% =endDate.ClientID %>", 1);
        }
        LoadCalendars();

        function CheckFormValidation() {
            var reqField = "startDate,endDate";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var startDate = GetValue("startDate");
            var endDate = GetValue("endDate");
            var acInfo = GetItem("acInfo")[1];
            var acInfotxt = GetItem("acInfo")[0];
            window.location.href = "StatementResultDollor.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfotxt + "&acName=" + acInfo;

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="main-page-wrapper">
            <div class="breadCrumb">
                Account Report » AC Statement for Foreign Currency
            </div>
            <div class="col-lg-12">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        Search AC Statement For Foreign Currency
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>
                                        AC Information:</label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <uc1:SwiftTextBox ID="acInfo" runat="server" Category="acInfo" CssClass="form-control"
                                        Title="Blank for All" Width="100%" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>
                                        Start Date:</label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group form-inline">
                                    <asp:TextBox ID="startDate" runat="server" Width="95%" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    End Date:</label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group form-inline">
                                    <asp:TextBox ID="endDate" runat="server" Width="95%" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <input type="button" id="btn" value="Search" class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
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