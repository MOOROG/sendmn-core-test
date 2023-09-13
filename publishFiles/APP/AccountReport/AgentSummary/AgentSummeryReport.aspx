<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentSummeryReport.aspx.cs" Inherits="Swift.web.AccountReport.AgentSummary.AgentSummeryReport" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../ui/js/pickers-init.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!-- <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>

    <script type="text/javascript">
        function CheckRequired() {
            var reqField = "acInfo_aText,asOnDate,";
            if (ValidRequiredField(reqField) == true) {
                var agentGrp = $("#agentGroupDDL").val();
                var agentId = GetItem("acInfo")[0];
                var date = $("#asOnDate").val();
                var tranType = $("#tranType").val();

                var url = "/AccountReport/Reports.aspx?reportName=agentSummaryRpt&agentGrp=" + agentGrp + "&agentId=" + agentId + "&date=" + date + "&tranType=" + tranType;
                OpenInNewWindow(url);
            }
        }
        function GetAgentGroup() {
            return $("#<%=agentGroupId.ClientID%>").val();
        }
        function SetValue() {
            $("#acInfo_aText").val("");
            //alert('called);
            $("#<%=agentGroupId.ClientID%>").val($("#<%=agentGroupDDL.ClientID%>").val());
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="agentGroupId" runat="server" />
        <%--<asp:ScriptManager ID="sp1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>--%>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="AgentSummeryReport.aspx">Agent Summery Balance Weekly</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent Summary Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Agent Group:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="agentGroupDDL" runat="server" CssClass="form-control" AutoPostBack="true">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Agent Name:</label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="acInfo" runat="server" Category="remit-agentByGrp" CssClass="form-control" Param1="@GetAgentGroup()"
                                        Title="Blank for All" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    As On Date:</label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                        <asp:TextBox ID="asOnDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Tran Type:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="DR" Value="dr"></asp:ListItem>
                                        <asp:ListItem Text="CR" Value="cr"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <input type="button" value="Search" onclick="CheckRequired();" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%--</ContentTemplate>
        </asp:UpdatePanel>--%>
    </form>
</body>
</html>