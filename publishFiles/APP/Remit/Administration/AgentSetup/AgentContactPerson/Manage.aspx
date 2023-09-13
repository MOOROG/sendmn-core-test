<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.AgentContactPerson.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../../../css/swift_component.css" rel="stylesheet" type="text/css" />--%>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <style>
        .formTable {
            background-color: #f5f5f5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sc" runat="server"></asp:ScriptManager>
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
                                    <li class="active"><a href="#">Contact Person</a></li>
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
                                <div id="divTab" runat="server"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel panel-default">
                                    <div class="panel-heading">
                                        <h4>Contact Person Details</h4>
                                    </div>
                                    <div class="panel-body">
                                        <table class="formTable table table-condensed">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Name
                                    <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="name"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    <br />
                                                    <asp:TextBox ID="name" runat="server" CssClass="input form-control" Width="50%"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Button ID="btnCopyDetails" runat="server" Text="Copy Details From Agent" CssClass="btn btn-primary"
                                                        OnClick="btnCopyDetails_Click" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Address</div>
                                                        <div class="panel-body">
                                                            <table class="formTable table table-condensed">
                                                                <tr>
                                                                    <td>Country
                                                    <span class="errormsg">*</span><asp:RequiredFieldValidator ID="Rfd3" runat="server" ControlToValidate="country"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:DropDownList ID="country" runat="server" CssClass="input form-control"
                                                                            OnSelectedIndexChanged="country_SelectedIndexChanged" AutoPostBack="true">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>State
                                                    <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd10" runat="server" ControlToValidate="state"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:DropDownList ID="state" runat="server" CssClass="input form-control"></asp:DropDownList>
                                                                    </td>
                                                                    <td>City
                                                    <span class="errormsg">*</span><asp:RequiredFieldValidator ID="rfd7" runat="server" ControlToValidate="city"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="city" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Zip
                                                    <br />
                                                                        <asp:TextBox ID="zip" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">Address
                                                    <br />
                                                                        <asp:TextBox ID="address" runat="server" TextMode="MultiLine" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Contact</div>
                                                        <div class="panel-body">
                                                            <table class="formTable table table-condensed">
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
                                                                    <td>Fax
                                                    <br />
                                                                        <asp:TextBox ID="fax" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
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
                                                <td>
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading"></div>
                                                        <div class="panel-body">
                                                            <table class="formTable table">
                                                                <tr>
                                                                    <td>Post
                                                    <br />
                                                                        <asp:TextBox ID="post" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Contact Person Type
                                                    <br />
                                                                        <asp:DropDownList ID="contactPersonType" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                    </td>
                                                                    <td>Is Primary
                                                    <br />
                                                                        <asp:DropDownList ID="isPrimary" runat="server" CssClass="form-control">
                                                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                            <asp:ListItem Value="N">No</asp:ListItem>
                                                                        </asp:DropDownList>
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