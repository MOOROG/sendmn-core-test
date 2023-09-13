<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.PostAcDeposit.PaidTransaction.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../js/functions.js"></script>
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<%=fromDate.ClientID%>", "#<%=toDate.ClientID %>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Pay A/C Deposit </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    From Date:<span class="errormsg">*</span></label>
                                <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="fromTime"
                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                    ErrorTooltipEnabled="True" />

                                <cc1:MaskedEditValidator ID="MaskedEditValidator2" runat="server" ControlExtender="MaskedEditExtender2"
                                    ControlToValidate="fromTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="rpt"
                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                </cc1:MaskedEditValidator>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="fromDate" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                </div>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="fromTime" runat="server" Text="00:00:00" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    To Date:<span class="errormsg">*</span></label>
                                <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="toTime"
                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                    ErrorTooltipEnabled="True" />

                                <cc1:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="MaskedEditExtender2"
                                    ControlToValidate="toTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="rpt"
                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                </cc1:MaskedEditValidator>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="toDate" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                </div>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="toTime" runat="server" Text="23:59:59" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-10 col-md-offset-2">
                                    <asp:Button ID="btnSearch" runat="server" Text=" Search " CssClass="btn btn-primary m-t-25"
                                        OnClick="btnSearch_Click" ValidationGroup="rpt" />&nbsp;&nbsp;
                                    <asp:Button ID="BtnSearchAll" runat="server" Text=" Search All" CssClass="btn btn-primary m-t-25"
                                        OnClick="BtnSearchAll_Click" />
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


<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
        }
    }
</script>
