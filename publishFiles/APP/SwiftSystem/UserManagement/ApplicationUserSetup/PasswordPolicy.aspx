<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PasswordPolicy.aspx.cs"
    Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.PasswordPolicy" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../Bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- MetisMenu CSS -->
    <link href="../../../Bootstrap/css/metisMenu.min.css" rel="stylesheet" type="text/css" />
    <!-- timeline CSS -->
    <link href="../../../Bootstrap/css/timeline.css" rel="stylesheet" type="text/css" />
    <!-- Custom CSS -->
    <link href="../../../Bootstrap/css/style.css" rel="stylesheet" type="text/css" />
    <!-- Custom Fonts -->
    <link href="../../../Bootstrap/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../css/style1.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function CheckRequired() {
            var RequiredField = "wrongLogin,pwdMinLen,pwdRecHistory,specialChar,Numeric,capAlpha,lockInDay,cdd,edd,txnApprove,morethenTOindBranch,";
            if (ValidRequiredField(RequiredField) == false) {
                return false;
            }
            else {
                if (confirm("Are you sure to save a transaction?")) {
                    return true;
                }
                return false;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" onsubmit="return CheckRequired();">
    <div id="main-page-wrapper">
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Transaction Policy
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>
                                    Customer Due Diligence Required on:<span class="errormsg">*</span></label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:TextBox ID="cdd" runat="server" MaxLength="10" Width="100%"  CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>
                                    Enhance Due Diligence Required on:<span class="errormsg">*</span></label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:TextBox ID="edd" runat="server" MaxLength="10" Width="100%"  CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>
                                    Hold Accumulated or individual Txn on:<span class="errormsg">*</span></label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:TextBox ID="txnApprove" runat="server" MaxLength="10" Width="100%"  CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>
                                    Hold Individual Customer >2 branches Txn on:<span class="errormsg">*</span></label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:TextBox ID="morethenTOindBranch" runat="server" Width="100%"  MaxLength="10" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>
                                    Is Active:</label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:CheckBox ID="isActive" runat="server" CssClass="checkbox" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <asp:Button ID="btnSave" runat="server" Text="  Save  " OnClick="btnSave_Click" CssClass="btn btn-primary m-t-25" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
        <%--<div class="breadCrumb">
        USER MANAGEMENT » TRANSACTION POLICY</div>
    <div>
        <table>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>
                                <tr>
                                    <td>
                                        <tr>
                                            <td>
                                                <table class="formTable">
                                                    <tbody>
                                                        <tr>
                                                            <th class="frmTitle">
                                                                SEARCH ACCOUNT STATEMENT
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td class="container_content">
                                                                <!--################ END FORM STYLE-->
                                                                <table>
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <div align="left" class="text_form">
                                                                                Customer Due Diligence Required on
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="cdd" runat="server" MaxLength="10" Width="100px"></asp:TextBox>
                                                                            <span class="errormsg">*</span>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <div align="left" class="text_form">
                                                                                Enhance Due Diligence Required on
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="edd" runat="server" MaxLength="10" Width="100px"></asp:TextBox>
                                                                            <span class="errormsg">*</span>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <div align="left" class="text_form">
                                                                                Hold Accumulated or individual Txn on
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="txnApprove" runat="server" MaxLength="10" Width="100px"></asp:TextBox>
                                                                            <span class="errormsg">*</span>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <div align="left" class="text_form">
                                                                                Hold Individual Customer >2 branches Txn on
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="morethenTOindBranch" runat="server" MaxLength="10" Width="100px"></asp:TextBox>
                                                                            <span class="errormsg">*</span>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td nowrap="nowrap">
                                                                            <div align="left" class="text_form">
                                                                                Is Active
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="isActive" runat="server" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                        </td>
                                                                        <td>
                                                                            <asp:Button ID="btnSave" runat="server" Text="  Save  " OnClick="btnSave_Click" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                    </td>
                                </tr>
                            </td>
                        </tr>
                </td>
            </tr>
        </table>
    </div>--%>
    </form>
</body>
</html>
