<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PasswordFormat.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.PasswordFormat.PasswordFormat" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <base id="Base1" target="_self" runat="server" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <style type="text/css">
        legend {
            font-size: 1.2em;
            padding: 5px;
            margin-left: 1em;
            color: #3A4F63;
            background: #CCCCCC;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="PasswordFormat.aspx">Password and Security Policy</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Password Format
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Fields are mandatory   <span class="ErrMsg">*</span>
                                </label>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Wrong login attempts Limit:   <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="loginAttemptCount" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="loginAttemptCount"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Minimum Password Length:   <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="minPwdLength" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="minPwdLength"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red" SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Password Record History Number:  <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="pwdHistoryNum" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="pwdHistoryNum"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red" SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Special Charactor :  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="specialCharNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Numeric :  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="numericNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Capital Alphabet :  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="capNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Lock User (Within Days if not logged in) :  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="lockUserDays" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Invalid Control No.attempt(For a Day) :   
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="invalidControlNoForDay" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Invalid Control No.attempt(For Continous) :   
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="invalidControlNoContinous" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Operation Time From : 
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="operationTimeFrom" runat="server" CssClass="form-control"></asp:TextBox>
                                    <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="operationTimeFrom"
                                        Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                        ErrorTooltipEnabled="True" />

                                    <cc1:MaskedEditValidator ID="MaskedEditValidator3" runat="server" ControlExtender="MaskedEditExtender3"
                                        ControlToValidate="operationTimeFrom" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                        MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                        MinimumValueMessage="Time must be grater than 00:00:00"
                                        SetFocusOnError="true" ForeColor="Red" ValidationGroup="user"
                                        ToolTip="Enter time between 00:00:00 to 23:59:59" Display="Dynamic"></cc1:MaskedEditValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Operation Time To :   
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:TextBox ID="operationTimeTo" runat="server" CssClass="form-control"></asp:TextBox>
                                    <cc1:MaskedEditExtender ID="MaskedEditExtender4" runat="server" TargetControlID="operationTimeTo"
                                        Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                        ErrorTooltipEnabled="True" />
                                    <cc1:MaskedEditValidator ID="MaskedEditValidator4" runat="server" ControlExtender="MaskedEditExtender3"
                                        ControlToValidate="operationTimeTo" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                        MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                        MinimumValueMessage="Time must be grater than 00:00:00"
                                        SetFocusOnError="true" ValidationGroup="user" ForeColor="Red"
                                        ToolTip="Enter time between 00:00:00 to 23:59:59" Display="Dynamic"></cc1:MaskedEditValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Enable Global Operation Time:  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:DropDownList ID="globalOperationTimeEnable" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        <asp:ListItem Value="N">No</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-7 col-md-7 control-label" for="">
                                    Is Active :  
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        <asp:ListItem Value="N">No</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-7">
                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="pwd" CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
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

<%--                    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top: 110px">
                        <tr>
                            <td>
                                <table style="width: 100%">
                                    <tr>
                                        <td height="26" class="bredCrom">
                                            <div>General Settings » Password Format</div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="10" class="shadowBG"></td>
                                    </tr>

                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>--%>
<%--           <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable" style="width: 400px;">
                                    <tr>
                                        <th colspan="4" class="frmTitle">Password Format</th>
                                    </tr>
                                    <tr>
                                        <td colspan="6" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" valign="top" align="left">
                                            <fieldset>
                                                <table>
                                                    <tr>
                                                        <td valign="top">Wrong login attempts Limit
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="loginAttemptCount" runat="server" Width="50px"></asp:TextBox>
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="loginAttemptCount"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>--%>
<%--     <td valign="top">Minimum Password Length
        </td>
        <td>
            <asp:TextBox ID="minPwdLength" runat="server" Width="50px"></asp:TextBox>
            <span class="errormsg">*</span>
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="minPwdLength"
                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red"
                SetFocusOnError="True"></asp:RequiredFieldValidator>
        </td>
        </tr>
--%>
<%--       <tr>
                                                        <td>Password Record History Number
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="pwdHistoryNum" runat="server" Width="50px"></asp:TextBox>
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="pwdHistoryNum"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pwd" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>--%>
<%--    <tr>
            <td>Special Charactor
            </td>
            <td valign="top">
                <asp:TextBox ID="specialCharNo" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>--%>
<%-- <tr>
            <td>Numeric</td>
            <td>
                <asp:TextBox ID="numericNo" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td>Capital Alphabet</td>
            <td>
                <asp:TextBox ID="capNo" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td>Lock User (Within Days if not logged in)</td>
            <td>
                <asp:TextBox ID="lockUserDays" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>

        <tr>
            <td>Invalid Control No.attempt(For a Day)</td>
            <td>
                <asp:TextBox ID="invalidControlNoForDay" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>

        <tr>
            <td>Invalid Control No.attempt(For Continous)</td>
            <td>
                <asp:TextBox ID="invalidControlNoContinous" runat="server" Width="50px"></asp:TextBox>
            </td>
        </tr>
        <tr>--%>
<%--    <td>Operation Time From
            </td>
            <td>
                <asp:TextBox ID="operationTimeFrom" runat="server" Width="100px"></asp:TextBox>
                <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="operationTimeFrom"
                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                    ErrorTooltipEnabled="True" />

                <cc1:MaskedEditValidator ID="MaskedEditValidator3" runat="server" ControlExtender="MaskedEditExtender3"
                    ControlToValidate="operationTimeFrom" MaximumValue="23:59:59" MinimumValue="00:00:00"
                    MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                    MinimumValueMessage="Time must be grater than 00:00:00"
                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="user"
                    ToolTip="Enter time between 00:00:00 to 23:59:59" Display="Dynamic"></cc1:MaskedEditValidator>
            </td>
        </tr>
        <tr>--%>
<%--   <td>Operation Time To
        </td>
        <td>
            <asp:TextBox ID="operationTimeTo" runat="server" Width="100px"></asp:TextBox>
            <cc1:MaskedEditExtender ID="MaskedEditExtender4" runat="server" TargetControlID="operationTimeTo"
                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                ErrorTooltipEnabled="True" />
            <cc1:MaskedEditValidator ID="MaskedEditValidator4" runat="server" ControlExtender="MaskedEditExtender3"
                ControlToValidate="operationTimeTo" MaximumValue="23:59:59" MinimumValue="00:00:00"
                MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                MinimumValueMessage="Time must be grater than 00:00:00"
                SetFocusOnError="true" ValidationGroup="user" ForeColor="Red"
                ToolTip="Enter time between 00:00:00 to 23:59:59" Display="Dynamic"></cc1:MaskedEditValidator>
        </td>
        </tr>
        <tr>--%>
<%--   <td>Enable Global Operation Time
        </td>
        <td>
            <asp:DropDownList ID="globalOperationTimeEnable" runat="server">
                <asp:ListItem Value="Y">Yes</asp:ListItem>
                <asp:ListItem Value="N">No</asp:ListItem>
            </asp:DropDownList>
        </td>
        </tr>
        <tr>--%>
<%-- <td>Is Active
        </td>
        <td>
            <asp:DropDownList ID="isActive" runat="server">
                <asp:ListItem Value="Y">Yes</asp:ListItem>
                <asp:ListItem Value="N">No</asp:ListItem>
            </asp:DropDownList>
        </td>
        </tr>
        </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="pwd" CssClass="button"
                                                OnClick="btnSave_Click" />
                                        </td>
                                    </tr>
        </table>
                            </td>
                        </tr>
                    </table>--%>
   