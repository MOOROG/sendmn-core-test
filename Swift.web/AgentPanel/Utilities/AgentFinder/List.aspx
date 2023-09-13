<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.AgentFinder.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />--%>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <%--<script src="../../../js/menucontrol.js" type="text/javascript"></script>--%>
    <script src="../../../ui/js/jquery.min.js"></script>
    <style>
        .table > tbody > tr > td {
            border: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="upd1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <h1></h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('remittance')">Utilities</a></li>
                                    <li><a href="#" onclick="return LoadModule('transaction')">Agent Finder</a></li>
                                    <li class="active"><a href="List.aspx">List</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>

                    <asp:HiddenField ID="hdnCashPayment" runat="server" Value="Cash Payment" />
                    <div class="row col-md-10">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3>Search Agent</h3>
                            </div>
                            <div class="panel-body">
                                <div class=" table-responsive">
                                    <table class="table" border="0">
                                        <tr>
                                            <td>
                                                <div>
                                                    District :<span class="errorMsg">*</span>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap">
                                                <asp:DropDownList ID="district" runat="server" AutoPostBack="True" CssClass="form-control"
                                                    OnSelectedIndexChanged="district_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="district"
                                                    Display="Dynamic" ErrorMessage="Required" ForeColor="Red" SetFocusOnError="True"
                                                    ValidationGroup="SC">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div>
                                                    Location :  <span class="errorMsg">*</span>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap">
                                                <asp:DropDownList ID="location" runat="server" CssClass="form-control">
                                                </asp:DropDownList>
                                                <br />
                                                <asp:Button ID="btnAgentFind" CssClass="btn btn-sm btn-primary" runat="server" Text="Search Agent"
                                                    OnClick="btnAgentFind_Click" ValidationGroup="SC" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="divLoadGrid" runat="server">
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>