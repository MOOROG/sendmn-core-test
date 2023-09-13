<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AgentUserSetup.Manage" %>

<%@ Register Src="../../../Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base target="_self">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../Css/swift_compnent.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../js/functions.js"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>

    <script type="text/javascript">
        function PickAgent() {
            var ; = "<%=Swift.web.Library.GetStatic.GetUrlRoot() %>";
            var url = urlRoot + "/Remit/Administration/AgentSetup/PickAgent.aspx";
            var param = "dialogHeight:400px;dialogWidth:940px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);
            if (res == "undefined" || res == null || res == "") {

            }
            else {
                var result = res.split('|');
                SetValueById("<%=branchName.ClientID %>", "", "");
                SetValueById("<%=branchName.ClientID %>", result[0] + "|" + result[1], "");
                SetValueById("<%=hdnBranchName.ClientID %>", result[0] + "|" + result[1], "");
                SetValueById("<%=hdnAgentType.ClientID %>", result[2], "");
            }
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sc">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>
                <div id="container" class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <h1></h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('adminstration')"> Administration</a></li>
                                    <li class="active"><a href="Manage.aspx"> Agent User Setup</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="listtabs" style="margin-left:8px;">
                        <ul class="nav nav-tabs" role="tablist">
                            <li><a href="list.aspx?agentId">User List </a></li>
                            <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Manage User </a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="panel panel-default">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">User Information</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Salutation:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList ID="salutation" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Gender:</label>
                                                        <asp:DropDownList ID="gender" CssClass="form-control" runat="server">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                            </div>
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            First Name:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="firstName" runat="server" Width="100%" CssClass="form-control" onblur="CheckAlfabetOnly(this,'First Name')"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            Middle Name:</label>
                                                        <asp:TextBox ID="middleName" runat="server" Width="100%" CssClass="form-control" onblur="CheckAlfabetOnly(this,'Middle Name')"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            Last Name:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="lastName" runat="server" Width="100%" CssClass="form-control" onblur="CheckAlfabetOnly(this,'Last Name')"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-10">
                                                    <div class="form-group">
                                                        <label>
                                                            Agent/Branch:<span class="errormsg">*</span></label>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="branchName" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        <br />
                                                        <asp:TextBox ID="branchName" runat="server" ReadOnly="true" CssClass="form-control" Style="display: none"></asp:TextBox>
                                                        <uc1:SwiftTextBox ID="branchNameAuto" Category="remit-agentList" runat="server" CssClass="form-control" />
                                                    </div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="form-group">
                                                        <br />
                                                        <span id="spnPickAgent" runat="server"></span>
                                                        <asp:HiddenField ID="hdnBranchId" runat="server" />
                                                        <asp:HiddenField ID="hdnBranchName" runat="server" />
                                                        <asp:HiddenField ID="hdnAgentType" runat="server" />
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
                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1" runat="server" Enabled="True"
                                                            FilterType="Numbers" TargetControlID="pwdChangeDays">
                                                        </cc1:FilteredTextBoxExtender>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            Pwd Change Warning Days:</label>
                                                        <asp:TextBox ID="pwdChangeWarningDays" runat="server" Width="100%" Text="12" CssClass="form-control" />
                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender3" runat="server" Enabled="True"
                                                            FilterType="Numbers" TargetControlID="pwdChangeWarningDays">
                                                        </cc1:FilteredTextBoxExtender>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            Session Time-out (In Minutes):</label>
                                                        <asp:TextBox ID="sessionTimeOutPeriod" runat="server" Width="100%" CssClass="form-control"
                                                            Text="300" />
                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender5" runat="server" Enabled="True"
                                                            FilterType="Numbers" TargetControlID="sessionTimeOutPeriod">
                                                        </cc1:FilteredTextBoxExtender>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            Max Report View Days:</label>
                                                        <asp:TextBox ID="maxReportViewDays" runat="server" Width="100%" Text="60" CssClass="form-control"></asp:TextBox>
                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender4" runat="server" Enabled="True"
                                                            FilterType="Numbers" TargetControlID="maxReportViewDays">
                                                        </cc1:FilteredTextBoxExtender>
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
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Send Transaction From:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="sendTrnFrom" runat="server" Text="00:00:00" Width="100%" CssClass="form-control"></asp:TextBox>
                                                        <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="sendTrnFrom"
                                                            Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                            ErrorTooltipEnabled="True" />
                                                        <cc1:MaskedEditValidator ID="MaskedEditValidator3" runat="server" ControlExtender="MaskedEditExtender2"
                                                            ControlToValidate="sendTrnFrom" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                            EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                            MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                            SetFocusOnError="true" ForeColor="Red" ValidationGroup="user" ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                        </cc1:MaskedEditValidator>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Send Transaction To:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="sendTrnTo" runat="server" Text="00:00:00" Width="100%" CssClass="form-control"></asp:TextBox>
                                                        <cc1:MaskedEditExtender ID="MaskedEditExtender4" runat="server" TargetControlID="sendTrnTo"
                                                            Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                            ErrorTooltipEnabled="True" />
                                                        <cc1:MaskedEditValidator ID="MaskedEditValidator4" runat="server" ControlExtender="MaskedEditExtender2"
                                                            ControlToValidate="sendTrnTo" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                            EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                            MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                            SetFocusOnError="true" ValidationGroup="user" ForeColor="Red" ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                        </cc1:MaskedEditValidator>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Pay Transaction From:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="payTrnFrom" runat="server" Text="00:00:00" Width="100%" CssClass="form-control"></asp:TextBox>
                                                        <cc1:MaskedEditExtender ID="MaskedEditExtender5" runat="server" TargetControlID="payTrnFrom"
                                                            Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                            ErrorTooltipEnabled="True" />
                                                        <cc1:MaskedEditValidator ID="MaskedEditValidator5" runat="server" ControlExtender="MaskedEditExtender2"
                                                            ControlToValidate="payTrnFrom" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                            EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                            MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                            SetFocusOnError="true" ForeColor="Red" ValidationGroup="user" ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                        </cc1:MaskedEditValidator>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>
                                                            Pay Transaction To:<span class="errormsg">*</span></label>
                                                        <asp:TextBox ID="payTrnTo" runat="server" Text="00:00:00" Width="100%" CssClass="form-control"></asp:TextBox>
                                                        <cc1:MaskedEditExtender ID="MaskedEditExtender6" runat="server" TargetControlID="payTrnTo"
                                                            Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                            ErrorTooltipEnabled="True" />
                                                        <cc1:MaskedEditValidator ID="MaskedEditValidator6" runat="server" ControlExtender="MaskedEditExtender2"
                                                            ControlToValidate="payTrnTo" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
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
                                                        <asp:DropDownList ID="country" runat="server" Width="100%" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <label>
                                                            <asp:Label ID="lblRegionType" runat="server" Text="State"></asp:Label>:<span class="errormsg">*</span></label>
                                                        <asp:DropDownList ID="state" runat="server" Width="100%" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="state_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <asp:Panel ID="pnlZip" runat="server">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>
                                                                Zip:</label>
                                                            <asp:TextBox ID="zip" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </asp:Panel>
                                                <asp:Panel ID="pnlDistrict" runat="server" hidden>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>
                                                                District:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="district" runat="server" Width="100%" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </asp:Panel>
                                                <%--<div class="col-md-4">
                                                <div class="form-group">
                                                    <label>
                                                        City:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="city" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>--%>
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
                                                        <input class="btn btn-primary m-t-25" onclick="CheckRequired()" type="button" value="Save" />
                                                        <asp:Button ID="btnSumit" Text="Save" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnSumit_Click" style="display: none;" />
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
            </ContentTemplate>
        </asp:UpdatePanel>

    </form>
    <script language="javascript" type="text/javascript">
        function goBack() {
            window.history.back();
        }
        function CheckRequired() {
            var RequiredField = "salutation,firstName,lastName,userName,userAccessLevel,loginTime,logoutTime,country,address,email,pwdChangeDays,";
            if (ValidRequiredField(RequiredField) == false) {
                return false;
            }
            if (confirm("Are you sure to save a transaction?")) {
                document.getElementById('btnSumit').click();
            }

        }
    </script>
    <!--<script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
            <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</body>
</html>
