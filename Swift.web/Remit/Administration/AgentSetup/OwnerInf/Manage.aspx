<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.OwnerInf.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/swift_calendar.js"></script>

    <script>
        LoadCalendars();
        function LoadCalendars() {

            ShowCalDefault("#<% =expiryDate.ClientID%>");

        }
    </script>

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
        <asp:UpdatePanel ID="up" runat="server">
            <ContentTemplate>
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="page-title">
                                <h1>Administration<small></small>
                                </h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#">Agent Setup</a></li>
                                    <li class="active"><a href="#">Owner</a></li>
                                    <li class="active"><a href="#">Manage</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Panel ID="pnl2" runat="server">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Panel ID="pnl1" runat="server">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td height="10">
                                                <div class="tabs">
                                                    <ul>
                                                        <li><a href="../Functions/ListAgent.aspx">Agent List </a></li>
                                                        <li><a href="#" class="selected">Edit Agent </a></li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                <table class="table table-condensed">
                                    <tr>
                                        <td height="10">
                                            <div class="listtabs row">
                                                <ul class="nav nav-tabs" role="tablist">
                                                    <li><a href="../../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                                    <li><a href="../AgentCurrency.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Allowed Currency </a></li>
                                                    <li><a href="../AgentBusinessHistory.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Business History </a></li>
                                                    <li><a href="List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                                    <li><a href="../Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                                    <li><a href="../AgentContactPerson/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Contact Person</a></li>
                                                    <li><a href="../AgentBankAccount/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                                    <li class="active"><a href="#" class="selected">Manage</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel panel-default">
                                    <div class="panel-heading">Owner Setup</div>
                                    <div class="panel-body">

                                        <table class="formTable">

                                            <tr>
                                                <td colspan="3">
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Owner Information</div>
                                                        <div class="panel-body">
                                                            <table class="table table-condensed">
                                                                <tr>
                                                                    <td colspan="2">Name
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="ownerName"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="ownerName" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>SSN
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd2" runat="server" ControlToValidate="ssn"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="ssn" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Position/Title
                                                                <br />
                                                                        <asp:TextBox ID="position" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Share Holding
                                                                <br />
                                                                        <asp:TextBox ID="shareHolding" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>ID Type
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd3" runat="server" ControlToValidate="idType"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:DropDownList ID="idType" runat="server" CssClass="input form-control"></asp:DropDownList>
                                                                    </td>
                                                                    <td>ID Number
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd4" runat="server" ControlToValidate="idNumber"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="idNumber" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Issuing Country
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd9" runat="server" ControlToValidate="issuingCountry"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:DropDownList ID="issuingCountry" runat="server"
                                                                            BackColor="#F8FAFA" CssClass="form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>Expiry Date
                                                                <%--<span class="errormsg">*</span><asp:RequiredFieldValidator  ID="rfd6" runat="server" ControlToValidate="expiryDate"
                                                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                                                                        <br />
                                                                        <asp:TextBox ID="expiryDate" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                        <%--<cc1:CalendarExtender ID="ce1" runat="server" TargetControlID="expiryDate" CssClass="cal_Theme1"></cc1:CalendarExtender>--%>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Address</div>
                                                        <div class="panel-body">
                                                            <table class="table table-condensed">
                                                                <tr>
                                                                    <td>Country<br />
                                                                        <asp:DropDownList ID="country" runat="server" CssClass="input form-control"
                                                                            AutoPostBack="true" OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>State
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd10" runat="server" ControlToValidate="state"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:DropDownList ID="state" runat="server" CssClass="input form-control"></asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>City
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd7" runat="server" ControlToValidate="city"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="city" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Zip<br />
                                                                        <asp:TextBox ID="zip" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">Permanent Address<br />
                                                                        <asp:TextBox ID="permanentAddress" runat="server" TextMode="MultiLine" Height="30px" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td valign="top">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Contact Information</div>
                                                        <div class="panel-heading">
                                                            <table class="table table-condensed">
                                                                <tr>
                                                                    <td>Telephone
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd12" runat="server" ControlToValidate="phone"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="phone" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2"
                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="phone">
                                                                        </cc1:FilteredTextBoxExtender>
                                                                    </td>
                                                                    <td>Fax<br />
                                                                        <asp:TextBox ID="fax" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Mobile1
                                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd5" runat="server" ControlToValidate="mobile1"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="mobile1" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                        <cc1:FilteredTextBoxExtender ID="AGENT_PHONE1_FilteredTextBoxExtender"
                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="mobile1">
                                                                        </cc1:FilteredTextBoxExtender>
                                                                    </td>
                                                                    <td>Mobile2
                                                                <br />
                                                                        <asp:TextBox ID="mobile2" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1"
                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="mobile2">
                                                                        </cc1:FilteredTextBoxExtender>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">Email
                                                                <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ValidationGroup="agent" ForeColor="Red"
                                                                    ControlToValidate="email" ErrorMessage="Invalid Email!" SetFocusOnError="True"
                                                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">
                                                                </asp:RegularExpressionValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="email" runat="server"
                                                                            CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5">
                                                    <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="btn btn-primary" ValidationGroup="agent"
                                                        OnClick="bntSubmit_Click" />
                                                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                                    </cc1:ConfirmButtonExtender>
                                                    &nbsp;<input id="btnBack" type="button" value="Back" class="btn btn-primary" onclick=" Javascript: history.back(); ">
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>