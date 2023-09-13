<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.Manage"
    EnableEventValidation="false" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function goBack() {
            history.back();
        }
        function CheckRequired() {
            var RequiredField = "firstName,lastName,userName,pwdChangeDays,userAccessLevel,loginTime,logoutTime,country,state,city,address,email,";
            if (ValidRequiredField(RequiredField) == false) {

                return false;
            }
            else {
                alert("abd");
                if (confirm("Are you sure to save a transaction?")) {
                    return true;
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" onsubmit="return CheckRequired();">
        <asp:ScriptManager runat="server" ID="sc">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="Manage.aspx">Admin User Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx" target="_self">User List</a></li>
                    <li class="active"><a href="#" target="_self">Manage User </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Admin Users List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    First Name:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="firstName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Middle Name:</label>
                                                <asp:TextBox ID="middleName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Last Name:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="lastName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    User Name:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="userName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Login Type:<span class="errormsg">*</span></label>
                                                <asp:DropDownList ID="userAccessLevel" Width="100%" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="S">Single</asp:ListItem>
                                                    <asp:ListItem Value="M">Multiple</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Pwd Change Days:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="pwdChangeDays" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Pwd Change Warning Days:</label>
                                                <asp:TextBox ID="pwdChangeWarningDays" runat="server" Width="100%" Text="12" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Session Time-out (In Second):</label>
                                                <asp:TextBox ID="sessionTimeOutPeriod" runat="server" Width="100%" CssClass="form-control"
                                                    Text="300" />
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Max Report View Days:</label>
                                                <asp:TextBox ID="maxReportViewDays" runat="server" Width="100%" Text="60" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Login Time To:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="loginTime" runat="server" Text="00:00:00" Width="100%" CssClass="form-control"></asp:TextBox>
                                                <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="loginTime"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />
                                                <cc1:MaskedEditValidator ID="MaskedEditValidator2" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="loginTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="user" ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Logout Time To:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="logoutTime" runat="server" Text="23:59:59" Width="100%" CssClass="form-control"></asp:TextBox>
                                                <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="logoutTime"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />
                                                <cc1:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="logoutTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ValidationGroup="user" ForeColor="Red" ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    Country:<span class="errormsg">*</span></label>
                                                <asp:DropDownList ID="country" runat="server" Width="100%" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    State:<span class="errormsg">*</span></label>
                                                <asp:DropDownList ID="state" runat="server" Width="100%" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label>
                                                    City:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="city" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Address:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="address" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Email:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="email" runat="server" Width="100%" CssClass="form-control" />
                                                <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                    ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="user"
                                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ControlToValidate="email"></asp:RegularExpressionValidator>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Phone:</label>
                                                <asp:TextBox ID="telephoneNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                                <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender" runat="server" Enabled="True"
                                                    FilterType="Numbers" TargetControlID="telephoneNo">
                                                </cc1:FilteredTextBoxExtender>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>
                                                    Mobile:</label>
                                                <asp:TextBox ID="mobileNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                                <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2" runat="server" Enabled="True"
                                                    FilterType="Numbers" TargetControlID="mobileNo">
                                                </cc1:FilteredTextBoxExtender>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <asp:Button ID="btnSumit" runat="server" Text="Save" CssClass="btn btn-primary m-t-25"
                                                    OnClick="btnSumit_Click" />
                                                <button class="btn btn-primary m-t-25" onclick="goBack()" type="submit">
                                                    Back</button>
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
