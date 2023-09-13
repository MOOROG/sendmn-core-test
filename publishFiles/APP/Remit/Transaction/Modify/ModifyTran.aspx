<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyTran.aspx.cs" Inherits="Swift.web.Remit.Transaction.Modify.ModifyTran" %>

<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Src="../../UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/functions.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<%--    <script src="/ui/js/metisMenu.min.js"></script>
    <script type="text/javascript" src="/ui/js/custom.js"></script>--%>
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                           <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="ModifyTran.aspx">Modify  Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Find By <%=GetStatic.GetTranNoName()%></h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div id="divSearch" runat="server">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td valign="top">
                                                        <table>
                                                            <tr>
                                                                <td>
                                                                    <b><%=GetStatic.GetTranNoName()%></b>
                                                                    <span class="errormsg">*</span>
                                                                    <asp:RequiredFieldValidator ID="rfv1" runat="server" ControlToValidate="controlNo"
                                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="approve" ForeColor="Red"
                                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    <br />
                                                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <br />
                                                                    <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary m-t-25" OnClick="btnSearchDetail_Click" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="table table-responsive">
                                        <asp:Button ID="btnReloadDetail" runat="server" OnClick="btnReloadDetail_Click" Style="display: none;" />
                                        <div id="divTranDetails" runat="server" visible="false">
                                            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>

<script language="javascript">
    function PostMessageToParent(controlNo) {
        $("#controlNo").text = controlNo;
        $("#btnSearchDetail").click();
    }
    function EditData(label, fieldName, oldValue, tranId) {
        var url = "ModifyField.aspx?label=" + label +
                                "&fieldName=" + fieldName +
                                "&oldValue=" + oldValue +
                                "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnReloadDetail.ClientID %>").click();
        }
        return false;
    }

    function EditPayoutLocation(label, fieldName, oldValue, tranId) {
        var url = "ModifyLocation.aspx?label=" + label +
                                "&fieldName=" + fieldName +
                                "&oldValue=" + oldValue +
                                "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnReloadDetail.ClientID %>").click();
        }
        return false;
    }
</script>
</html>