<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentPanel.Administration.CustomerSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/functions.js"></script>
    <script>
        function LoadCalendars() {
            ShowCalDefault("#<% =dob.ClientID%>");
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>CUSTOMER SETUP
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Customer Setup</a></li>
                            <li class="active"><a href="#">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="#" class="selected">Search Customer </a></li>
                    <li><a href="Manage.aspx">Customer Detail </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Customer Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-condensed">
                                        <tr>
                                            <td valign="top">
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table  table-condensed">

                                                            <tr>
                                                                <td>
                                                                    <div class="panel panel-default">
                                                                        <div class="panel-heading panel-title">Basic Information</div>
                                                                        <div class="panel-body">
                                                                            <table class="table  table-condensed">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:CheckBox runat="server" ID="isMemberIssued" Text="Issue Membership Id"
                                                                                            AutoPostBack="True" OnCheckedChanged="isMemberIssued_CheckedChanged" /></td>
                                                                                    <td colspan="3">
                                                                                        <div id="midBox" runat="server" visible="false">
                                                                                            Membership ID
                                                    <br />
                                                                                            <asp:TextBox ID="membershipId" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>First Name
                                                    <span class="ErrMsg">*</span>
                                                                                        <asp:RequiredFieldValidator
                                                                                            ID="RequiredFieldValidator1" runat="server" ControlToValidate="firstName" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="firstName" runat="server" CssClass="required form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td>Middle Name<br />
                                                                                        <asp:TextBox ID="middleName" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td>Last Name<span class="ErrMsg">*</span>
                                                                                        <asp:RequiredFieldValidator
                                                                                            ID="RequiredFieldValidator3" runat="server" ControlToValidate="lastName1" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="lastName1" runat="server" CssClass="required form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td>Second Last Name<br />
                                                                                        <asp:TextBox ID="lastName2" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td valign="top" nowrap="nowrap">Date of Birth<br />
                                                                                        <asp:TextBox ID="dob" runat="server" CssClass="form-control hasDatepicker"></asp:TextBox>
                                                                                        <br />
                                                                                        <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                                                            ControlToValidate="dob"
                                                                                            MaximumValue="12/31/2100"
                                                                                            MinimumValue="01/01/1900"
                                                                                            Type="Date"
                                                                                            ErrorMessage="* Invalid date"
                                                                                            ValidationGroup="customer"
                                                                                            CssClass="errormsg"
                                                                                            SetFocusOnError="true"
                                                                                            Display="Dynamic"> </asp:RangeValidator>
                                                                                        <asp:Label ID="lblDobChk" runat="server" ForeColor="Red"></asp:Label>
                                                                                    </td>
                                                                                    <td valign="top">Gender<span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                                                                            ControlToValidate="gender" Display="Dynamic" ErrorMessage="Required!"
                                                                                            ForeColor="Red" SetFocusOnError="True" ValidationGroup="customer">
                                                                                        </asp:RequiredFieldValidator><br />
                                                                                        <asp:DropDownList ID="gender" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                                    </td>
                                                                                    <td valign="top" nowrap="nowrap">Customer Type<span class="errormsg">*</span><asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
                                                                                        ControlToValidate="customerType" Display="Dynamic" ErrorMessage="Required"
                                                                                        ForeColor="Red" SetFocusOnError="True" ValidationGroup="customer">
                                                                                    </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:DropDownList ID="customerType" runat="server" CssClass="required form-control">
                                                                                        </asp:DropDownList>
                                                                                    </td>

                                                                                    <td valign="top">Occupation <span class="errormsg">*</span>
                                                                                        <br />
                                                                                        <asp:DropDownList ID="occupation" runat="server" CssClass="required form-control">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>Id Type <span class="errormsg">*</span><br />
                                                                                        <asp:DropDownList runat="server" ID="idType" CssClass="required form-control" />
                                                                                    </td>
                                                                                    <td>Id Number <span class="errormsg">*</span><br />
                                                                                        <asp:TextBox runat="server" ID="idNumber" CssClass="required form-control" />
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
                                                                        <div class="panel-heading panel-title">Address</div>
                                                                        <div class="panel-body">
                                                                            <table class="table  table-condensed">
                                                                                <tr>
                                                                                    <td>Country
                                                    <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ControlToValidate="country" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:DropDownList ID="country" runat="server" CssClass="required form-control"
                                                                                            AutoPostBack="true" OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblRegionType" runat="server" Text="State"></asp:Label>
                                                                                        <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator
                                                                                            ID="RequiredFieldValidator4" runat="server" ControlToValidate="state" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:DropDownList ID="state" runat="server" CssClass="required form-control" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="state_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Panel ID="pnlZip" runat="server">
                                                                                            Zip Code<br />
                                                                                            <asp:TextBox ID="zipCode" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                        </asp:Panel>
                                                                                        <asp:Panel ID="pnlDistrict" runat="server">
                                                                                            District<br />
                                                                                            <asp:DropDownList ID="district" runat="server" CssClass="input form-control"></asp:DropDownList>
                                                                                        </asp:Panel>
                                                                                    </td>
                                                                                    <td>Company Name

                                                    <br />
                                                                                        <asp:TextBox ID="companyName" runat="server" CssClass="required form-control"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>City
                                                    <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="city" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="city" runat="server" ValidationGroup="customer" CssClass="required form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td colspan="2">Address
                                                    <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator
                                                                                            ID="RequiredFieldValidator9" runat="server" ControlToValidate="address" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="address" ValidationGroup="customer" runat="server" TextMode="MultiLine" Height="30px" CssClass="required form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td>Native Country<br />
                                                                                        <asp:DropDownList ID="nativeCountry" runat="server" CssClass="selected form-control"></asp:DropDownList>
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
                                                                        <div class="panel-heading panel-title">Contact</div>
                                                                        <div class="panel-body">
                                                                            <table class="table  table-condensed">
                                                                                <tr>
                                                                                    <td>Home Phone
                                                    <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator17" runat="server" ControlToValidate="homePhone" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="homePhone" ValidationGroup="homePhone" runat="server" CssClass="required form-control"></asp:TextBox>
                                                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender3"
                                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="homePhone">
                                                                                        </cc1:FilteredTextBoxExtender>
                                                                                    </td>
                                                                                    <td>Work Phone
                                                    <br />
                                                                                        <asp:TextBox ID="workPhone" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                        <cc1:FilteredTextBoxExtender ID="txtphonres_FilteredTextBoxExtender"
                                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="workPhone">
                                                                                        </cc1:FilteredTextBoxExtender>
                                                                                    </td>
                                                                                    <td>Mobile
                                                    <span class="errormsg">*</span>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="mobile" ForeColor="Red"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="customer" SetFocusOnError="True">
                                                                                        </asp:RequiredFieldValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="mobile" ValidationGroup="customer" runat="server" CssClass="required form-control"></asp:TextBox>
                                                                                        <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2"
                                                                                            runat="server" Enabled="True" FilterType="Numbers" TargetControlID="mobile">
                                                                                        </cc1:FilteredTextBoxExtender>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="2">Email
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ForeColor="Red"
                                                        ControlToValidate="email" ErrorMessage="Invalid Email!"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">
                                                    </asp:RegularExpressionValidator>
                                                                                        <br />
                                                                                        <asp:TextBox ID="email" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>Relation<br />
                                                                                        <asp:DropDownList ID="ddlRelation" runat="server" CssClass="selected form-control"></asp:DropDownList></td>
                                                                                    <td colspan="2">Full Name
                                                                                    <br />

                                                                                        <asp:TextBox ID="relationFullName" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table class="table">
                                                                        <tr>
                                                                            <td class="">Is BlackListed:<br>
                                                                                <asp:DropDownList ID="isBlackListed" CssClass="form-control"
                                                                                    runat="server" Width="39%">
                                                                                    <asp:ListItem Selected="True" Value="N">No</asp:ListItem>
                                                                                    <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>

                                                                        <tr>
                                                                            <td>
                                                                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                                                                    OnClick="btnSave_Click" Text="Submit" ValidationGroup="customer" />
                                                                                <cc1:ConfirmButtonExtender ID="btnSave_ConfirmButtonExtender" runat="server"
                                                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="BtnSave">
                                                                                </cc1:ConfirmButtonExtender>
                                                                                &nbsp;
                                                <asp:Button ID="btnBack" runat="server" CssClass="btn btn-primary btn-sm"
                                                    OnClick="btnBack_Click" Text="Back" />
                                                                            </td>
                                                                            <td></td>
                                                                            <td></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                    </table>
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