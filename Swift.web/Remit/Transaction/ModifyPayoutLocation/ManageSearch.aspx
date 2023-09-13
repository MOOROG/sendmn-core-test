<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageSearch.aspx.cs" Inherits="Swift.web.Remit.Transaction.ModifyPayoutLocation.ManageSearch" %>

<%@ Register Src="../../UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance </a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="ManageSearch.aspx">Modify Payout Location</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <!--end .row-->
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">Find By Control No</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                </div>
                            </div>
                            <div class="panel-body">
                                <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div id="divSearch" runat="server">
                                            <div class="form-group">
                                                <label>
                                                    Control No:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rfv1" runat="server" ControlToValidate="controlNo"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="approve" ForeColor="Red"
                                                        SetFocusOnError="True">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:TextBox ID="controlNo" runat="server" CssClass="form-control" Width="40%"></asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearchDetail_Click" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div id="divTranDetails" runat="server" visible="false">
                                                <asp:Button ID="btnCallBack" runat="server" OnClick="btnCallBack_Click" Style="display: none;" />
                                                <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" />
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
<script language="javascript">
    function EditPayoutLocation(label, fieldName, oldValue, tranId) {
        var url = "Modify.aspx?label=" + label +
                                "&fieldName=" + fieldName +
                                "&oldValue=" + oldValue +
                                "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnCallBack.ClientID %>").click();
        }
        return false;
    }
</script>
</html>
