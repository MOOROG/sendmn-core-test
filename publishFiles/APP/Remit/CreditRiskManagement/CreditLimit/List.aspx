<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditLimit.List" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript">
        function TopUp(id) {
            if (id == "undefined" || id == null)
                return;
            SetValueById("<%=hdnAmount.ClientID %>", GetValue("topUp_" + id), "");
            SetValueById("<%=hdnAgentId.ClientID %>", id, "");
            GetElement("<%=btnTopUp.ClientID %>").click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="List.aspx">Credit Limit</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Credit Limit List</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title"></h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                        <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                                        <asp:HiddenField ID="hdnAgentId" runat="server" />
                                        <asp:HiddenField ID="hdnAmount" runat="server" />
                                        <asp:Button ID="btnCallBack" runat="server" OnClick="btnCallBack_Click" Style="display: none;" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="26" class="bredCrom">
                    <div>Credit Risk Management » Credit Limit » List </div>
                </td>
            </tr>
            <tr>
                <td height="20" class="welcome"></td>
            </tr>
            <tr>
                <td width="100%" colspan="2">

                    <table width="100%">

                        <tr>
                            <td></td>
                        </tr>

                        <tr>
                            <td height="10" width="100%">
                                <div class="tabs">
                                    <ul>
                                        <li><a href="Javascript:void(0)" class="selected">Credit Limit List</a></li>--%>
        <%--<li> <a href="NewList.aspx">Credit Limit List - New Grid</a></li>--%>
        <%-- </ul>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top" colspan="2">
                    <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                    <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                    <asp:HiddenField ID="hdnAgentId" runat="server" />
                    <asp:HiddenField ID="hdnAmount" runat="server" />
                    <asp:Button ID="btnCallBack" runat="server" OnClick="btnCallBack_Click" Style="display: none;" />
                </td>
            </tr>
        </table>--%>
    </form>
</body>
<script language="javascript">
    function OpenLink(URL) {
        var id = PopUpWindowWithCallBack(URL, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnCallBack.ClientID %>").click();
        }
        return false;
    }
</script>
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../../Autocomplete.asmx/GetAgentNameList";
        $("#grdCrLimits_agentName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urla,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdCrLimits_agentName", result[0], "");
            }

        });
    }
    Autocomplete();
</script>
</html>