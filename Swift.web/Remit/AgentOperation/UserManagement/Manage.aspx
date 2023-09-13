<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.AgentOperation.UserManagement.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript">
        function PickAgent() {
            var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
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
    <style type="text/css">
        .subLegend {
            padding: 5px;
            margin-left: 1em;
            color: black;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sc"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="Manage.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table class="table table-condensed">
                <tr>
                    <td height="20" class="welcome"><span id="spnCname" runat="server"></span></td>
                </tr>
                <tr>
                    <td height="10">
                        <div class="tabs">
                            <ul>
                                <li><a href="ListAgent.aspx">Branch List</a></li>
                                <li><a href="List.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">User List </a></li>
                                <li><a href="#" class="selected">Manage User </a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional" RenderMode="InLine" ChildrenAsTriggers="false">
                            <ContentTemplate>
                                <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                                    <tr>
                                        <th class="frmTitle">User Information</th>
                                    </tr>
                                    <tr>
                                        <td class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="left">
                                            <fieldset>
                                                <legend>Personal Details</legend>
                                                <table style="width: 100%">
                                                    <tr>
                                                        <td>Title
                                                            <br />
                                                            <asp:DropDownList ID="salutation" runat="server" CssClass="input" />
                                                        </td>
                                                        <td valign="top" style="width: 170px;">First Name
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="firstName"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <asp:TextBox ID="firstName" runat="server" Width="130px" CssClass="input"></asp:TextBox>
                                                        </td>
                                                        <td valign="top" style="width: 170px;">Middle Name<br />
                                                            <asp:TextBox ID="middleName" runat="server" Width="130px" CssClass="input"></asp:TextBox>
                                                        </td>
                                                        <td valign="top" style="width: 170px;">Last Name
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="lastName"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <asp:TextBox ID="lastName" runat="server" Width="130px" CssClass="input"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">Gender
                                                            <br />
                                                            <asp:DropDownList ID="gender" runat="server" Width="153px" CssClass="input" />
                                                        </td>
                                                        <td colspan="3" valign="top">Agent/Branch
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="branchName"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <asp:TextBox ID="branchName" runat="server" ReadOnly="true" Width="325px"></asp:TextBox>
                                                            <asp:HiddenField ID="hdnBranchId" runat="server" />
                                                            <asp:HiddenField ID="hdnBranchName" runat="server" />
                                                            <asp:HiddenField ID="hdnAgentType" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <fieldset>
                                                <legend>Credential</legend>
                                                <table>
                                                    <tr>
                                                        <td valign="top">User Name
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="rfd2" runat="server" ControlToValidate="userName"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <asp:TextBox ID="userName" runat="server" Width="130px"></asp:TextBox>
                                                        </td>
                                                        <td valign="top">Password
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="pwd"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <asp:TextBox ID="pwd" runat="server" Width="130px"
                                                                TextMode="Password"></asp:TextBox>
                                                        </td>
                                                        <td valign="top">Confirm Password
                                                            <span class="errormsg">*</span>
                                                            <br />
                                                            <asp:TextBox ID="confirmPassword" runat="server" Width="130px"
                                                                TextMode="Password"></asp:TextBox>
                                                            <br />
                                                            <asp:CompareValidator ID="CompareValidator1" runat="server"
                                                                ErrorMessage="Password Doesn't Match" ControlToCompare="pwd" ValidationGroup="user"
                                                                ControlToValidate="confirmPassword" ForeColor="Red"></asp:CompareValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <fieldset>
                                                <legend>Contact Details</legend>
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <table>
                                                            <tr>
                                                                <td valign="top" style="width: 170px;">Country
                                                            <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="rfd14" runat="server" ControlToValidate="country"
                                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:DropDownList ID="country" runat="server" Width="130px" CssClass="input" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                                <td valign="top">
                                                                    <asp:Label ID="lblRegionType" runat="server" Text="State"></asp:Label><br />
                                                                    <asp:DropDownList ID="state" runat="server" Width="130px" CssClass="input" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="state_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                                <td valign="top">
                                                                    <asp:Panel ID="pnlZip" runat="server">
                                                                        Zip<br />
                                                                        <asp:TextBox ID="zip" runat="server" Width="130px"></asp:TextBox>
                                                                    </asp:Panel>
                                                                    <asp:Panel ID="pnlDistrict" runat="server">
                                                                        District<br />
                                                                        <asp:DropDownList ID="district" runat="server" Width="130px"></asp:DropDownList>
                                                                    </asp:Panel>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td valign="top">City
                                                            <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="city"
                                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:TextBox ID="city" runat="server" Width="130px"></asp:TextBox>
                                                                </td>
                                                                <td valign="top" colspan="2">Address
                                                            <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="address"
                                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:TextBox ID="address" runat="server" Width="315px" TextMode="MultiLine" Height="30px" CssClass="input"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td valign="top">Phone
                                                            <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="rfd7" runat="server" ControlToValidate="telephoneNo"
                                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:TextBox ID="telephoneNo" runat="server" Width="130px"></asp:TextBox>
                                                                    <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender"
                                                                        runat="server" Enabled="True" FilterType="Numbers" TargetControlID="telephoneNo">
                                                                    </cc1:FilteredTextBoxExtender>
                                                                </td>
                                                                <td valign="top" colspan="2">Mobile
                                                            <%--<span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator  ID="rfd10" runat="server" ControlToValidate="mobileNo"
                                                                                         Display="Dynamic" ErrorMessage="Required!" ValidationGroup="user" ForeColor="Red"
                                                                                         SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                                                                    <br />
                                                                    <asp:TextBox ID="mobileNo" runat="server" Width="130px"></asp:TextBox>
                                                                    <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2"
                                                                        runat="server" Enabled="True" FilterType="Numbers" TargetControlID="mobileNo">
                                                                    </cc1:FilteredTextBoxExtender>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3" valign="top">Email
                                                            <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator
                                                                        ID="RequiredFieldValidator6" runat="server" ErrorMessage="Required"
                                                                        ControlToValidate="email" ForeColor="Red" SetFocusOnError="True"
                                                                        ValidationGroup="user"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:TextBox ID="email" runat="server" Width="280px" CssClass="input" />
                                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="user"
                                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                                        ControlToValidate="email"></asp:RegularExpressionValidator>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="country" EventName="SelectedIndexChanged" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnSumit" runat="server" Text="Save" CssClass="button" ValidationGroup="user"
                                                OnClick="btnSumit_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button"
                                        OnClick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnDeletecc" runat="server" ConfirmText="Confirm To Delete ?" Enabled="true" TargetControlID="btnDelete"></cc1:ConfirmButtonExtender>
                                            &nbsp;<asp:Button ID="btnBack" runat="server" Text="Back" CssClass="button"
                                                OnClick="btnBack_Click" />&nbsp;&nbsp;&nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
<script type="text/javascript">
    function CallBack(mes) {
        var resultList = ParseMessageToArray(mes);
        alert(resultList[1]);

        if (resultList[0] != 0) {
            return;
        }

        window.returnValue = resultList[0];
    }
</script>
</html>