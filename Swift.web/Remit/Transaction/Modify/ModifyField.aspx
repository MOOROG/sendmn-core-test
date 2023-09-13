<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyField.aspx.cs" Inherits="Swift.web.Remit.Transaction.Modify.ModifyField" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function CallBack(result) {
            var jsonRes = JSON.parse(result);
            alert(jsonRes.Msg);
            if (jsonRes.ErrorCode != 0) {
                return;
            }
            window.returnValue = jsonRes.ErrorCode;
            window.opener.PostMessageToParent(jsonRes.Extra);
            //window.onunload = window.opener.location.reload();
            window.close();
        }
    </script>

    <style type="text/css">
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sc"></asp:ScriptManager>
        <div class="page-wrapper" style="margin-top: -100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Modify Transaction </a></li>
                            <li class="active"><a href="ModifyField.aspx">Modify Field</a></li>
                        </ol>
                        <li class="active">
                            <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                        </li>
                    </div>
                </div>
            </div>
            <div class="panlel panel-default col-md-6">
                <div class="panel-heading">Modify Field</div>
                <div class="panel-body">
                    <table class="table">
                        <tr>
                            <td height="10" class="shadowBG"></td>
                        </tr>

                        <tr>
                            <td>
                                <table class="table">
                                    <asp:HiddenField ID="hddField" runat="server" />
                                    <asp:HiddenField ID="hddOldValue" runat="server" />
                                    <asp:HiddenField ID="hdnValueType" runat="server" />
                                    <tr>
                                        <td>
                                            <div align="right">Field Name : </div>
                                        </td>
                                        <td>
                                            <asp:Label ID="lblFieldName" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">Old Value : </div>
                                        </td>
                                        <td>
                                            <asp:Label ID="lblOldValue" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <div id="rptShowOther" runat="server">
                                        <tr>
                                            <td>
                                                <div align="right">New Value : </div>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtNewValue" runat="server" CssClass="form-control" MaxLength="200"></asp:TextBox>
                                                <asp:TextBox ID="txtContactNo" runat="server" CssClass="form-control" MaxLength="200"></asp:TextBox>
                                                <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender"
                                                    runat="server" Enabled="True" FilterType="Numbers" TargetControlID="txtContactNo">
                                                </cc1:FilteredTextBoxExtender>
                                                <asp:DropDownList ID="ddlNewValue" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                    </div>
                                    <div id="rptName" runat="server">
                                        <tr>
                                            <td>
                                                <div align="right">First Name : </div>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div align="right">Middle Name : </div>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtMiddleName" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div align="right">First Last Name : </div>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtLastName1" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox></td>
                                        </tr>
                                        <tr style="display: none">
                                            <td>
                                                <div align="right">Second Last Name : </div>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtLastName2" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox></td>
                                        </tr>
                                    </div>
                                    <tr>
                                        <td>&nbsp;</td>
                                        <td>
                                            <asp:Button ID="btnUpdate" runat="server" Text=" Update " CssClass="btn btn-primary"
                                                OnClick="btnUpdate_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>

                </div>
            </div>
        </div>
    </form>
</body>
</html>
