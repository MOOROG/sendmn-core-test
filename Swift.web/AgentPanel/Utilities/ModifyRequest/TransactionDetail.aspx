<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TransactionDetail.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.ModifyRequest.TransactionDetail" %>

<%@ Register TagPrefix="uc1" TagName="UcTransactionSend" Src="~/Remit/UserControl/UcTransactionSend.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />--%>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <%--<link href="../../../js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />--%>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>

    <style>
        .table > tbody > tr > td {
            border: none;
        }

        .errorMsg {
            color: red;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row" id="top">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="TransactionDetail.aspx">Modification Request</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
                <ProgressTemplate>
                    <div style="position: fixed; left: 530px; top: 0px; background-color: white; border: 1px solid black;">
                        <img alt="progress" src="../../../Images/Loading_small.gif" />
                        Processing...
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div id="divControlno" runat="server">

                        <%-->>Transaction View Details --%>
                        <div id="divTranDetails" runat="server" visible="false">
                            <div>
                                <uc1:UcTransactionSend ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="false" />
                            </div>
                        </div>

                        <%-->>Transaction Modification Request Form --%>
                        <div id="modtable" runat="server" visible="false">
                            <div class="panel panel-default">
                                <div class="panel-heading">Transaction Modification Request</div>
                                <div class="panel-body">
                                    <table id="Table1" runat="server" class="table">
                                        <tr>
                                            <td>
                                                <table width="100%" class="table">
                                                    <tr>
                                                        <td nowrap="nowrap">Amendment For :<br />
                                                            <asp:DropDownList ID="txnmodifyField" runat="server"
                                                                AutoPostBack="true"
                                                                OnSelectedIndexChanged="txnmodifyField_SelectedIndexChanged" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <span id="newValueLabel" runat="server" visible="false">New Value
                                                                <br />

                                                                <asp:DropDownList ID="idType" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                                <span id="Span1" class="errorMsg" runat="server">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="idType"
                                                                    ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="add"
                                                                    SetFocusOnError="True">
                                                                </asp:RequiredFieldValidator>
                                                            </span>

                                                            <span id="labelValue" runat="server">New Value
                                                            <span id="Span2" class="errorMsg" runat="server">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="txtValue"
                                                                    ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="add"
                                                                    SetFocusOnError="True">
                                                                </asp:RequiredFieldValidator>
                                                                <br />
                                                                <asp:TextBox ID="txtValue" runat="server" CssClass="form-control"></asp:TextBox>
                                                            </span>

                                                            <div id="nameTable" runat="server" visible="false">
                                                                <table id="Table2" runat="server" class="table">
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <asp:Label ID="firstName" Text="First Name" runat="server"></asp:Label>
                                                                            <span class="ErrMsg">*</span>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="txtFirstName"
                                                                                ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="add"
                                                                                SetFocusOnError="True">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                        </td>
                                                                        <td style="vertical-align: top;" nowrap="nowrap">
                                                                            <asp:Label ID="middleName" Text="Middle Name" runat="server" Width="125px"></asp:Label><br />
                                                                            <asp:TextBox ID="txtMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                        </td>
                                                                        <td nowrap="nowrap">
                                                                            <asp:Label ID="firstLastName" Text="Last Name" runat="server"></asp:Label>
                                                                            <%--<span class="ErrMsg">*</span>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="txtFirstLastName"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="add"
                                        SetFocusOnError="True">
                                        </asp:RequiredFieldValidator>--%>
                                                                            <br />
                                                                            <asp:TextBox ID="txtFirstLastName" runat="server" Width="125px" CssClass="form-control"></asp:TextBox>
                                                                        </td>
                                                                        <td style="vertical-align: top;" nowrap="nowrap">
                                                                            <asp:Label ID="secondLastName" Text="Second Last Name" runat="server" Width="125px"></asp:Label><br />
                                                                            <asp:TextBox ID="txtSecondLastName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <label>&nbsp;</label>
                                                            <asp:Button ID="btnAdd" runat="server" Text="Add" ValidationGroup="add" CssClass="btn btn-primary"
                                                                OnClick="btnAdd_Click" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 100%" colspan="2">
                                                            <div style="width: 100%" id="dispRequest" runat="server" visible="false"></div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap" colspan="2">User Email:<br />
                                                            <asp:TextBox ID="emailAdd" runat="server" Width="47.5%" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                            (Check your authorized email, if you found incorrect email here, please contact  headoffice! )
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="middle">
                                                            <asp:Button ID="btnRequest" runat="server" Text="Request" ValidationGroup="request" OnClick="btnRequest_Click" CssClass="btn btn-primary" />
                                                            <cc1:ConfirmButtonExtender ID="btnCancelcc" runat="server"
                                                                ConfirmText="Confirm To Request ?" Enabled="True"
                                                                TargetControlID="btnRequest">
                                                            </cc1:ConfirmButtonExtender>
                                                            <input type="button" id="btnBack" value="Back" class="btn btn-primary" onclick="window.location.replace('Search.aspx'); " />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>

                            <asp:HiddenField ID="rowid" runat="server" />
                            <asp:Button ID="btnDelete" runat="server" Text="Button" Style="display: none" OnClick="btnDelete_Click" CssClass="btn btn-danger" />
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function Delete(obj) {
        document.getElementById("rowid").value = obj;
        GetElement("<%=btnDelete.ClientID %>").click();
    }
</script>