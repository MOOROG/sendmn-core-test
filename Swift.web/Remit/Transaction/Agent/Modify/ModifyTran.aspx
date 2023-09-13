<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyTran.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Modify.ModifyTran" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Src="../../../UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/menucontrol.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        <%--$(document).ready(function () {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>");
        });--%>
        function ValidationCheck() {
            var controlNo = $("#<%=controlNo.ClientID%>").val();
            var tranNo = $("#<%=tranId.ClientID%>").val();
            if (tranNo == "" && controlNo == "") {
                alert("JME No Or Tran No Is Required");
                var reqField = "controlNo,tranId,";
                if (ValidRequiredField(reqField) === false) {
                    return false;
                }
            }
        }
    </script>
</head>

<body>

    <form id="form1" runat="server">

        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="/Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="ModifyTran.aspx">Search Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div id="divSearch" class="col-md-12" runat="server">
                    <div class="panel panel-default">
                        <div class="panel-heading">Search Transaction For Modification & View</div>
                        <div class="panel-body">
                            <div class="col-md-8">
                                <%-- <div class="form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Search Name:</label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:TextBox ID="searchByText" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="sender">Sender</asp:ListItem>
                                            <asp:ListItem Value="receiver">Receiver</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>--%>
                                <%--<div class="form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">Send Date:</label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:TextBox runat="server" ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>--%>
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            <span align="right" class="formLabel"><%=GetStatic.GetTranNoName() %>.:</span>
                                        </label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <label class="control-label">
                                            Tran No:
                                        </label>
                                    </div>
                                    <div class="col-md-5">
                                        <asp:TextBox ID="tranId" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-offset-2 col-md-2">
                                        <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary" OnClientClick="return ValidationCheck();" OnClick="btnSearchDetail_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <asp:HiddenField ID="hdnControlNo" runat="server" />
                    <asp:Button ID="btnClick" runat="server" OnClick="btnClick_Click" Style="display: none;" />
                    <asp:HiddenField ID="hdnStatus" runat="server" />
                </div>
            </div>
            <div class="col-md-12">
                <div id="divLoadGrid" runat="server" visible="false"></div>
            </div>
        </div>
        <asp:Button ID="btnReloadDetail" runat="server"
            OnClick="btnReloadDetail_Click" Style="display: none;" />
        <div id="divTranDetails" runat="server" visible="false">
            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
            <input type="button" id="btnBack" class="btn btn-primary" style="margin-left: 20px;" value="Back" onclick="window.location.replace('ModifyTran.aspx');" />
        </div>
    </form>
</body>
<script type="text/javascript">
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

    function OnClickNo(controlNo) {

        var data = controlNo.split(",");
        document.getElementById("<% =hdnStatus.ClientID %>").value = data[1];
        document.getElementById("<% =hdnControlNo.ClientID %>").value = data[0];
        document.getElementById("<% =btnClick.ClientID %>").click();
    }

    function EditPayoutLocation(label, fieldName, oldValue, tranId) {
        var url = "Modify.aspx?label=" + label +
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