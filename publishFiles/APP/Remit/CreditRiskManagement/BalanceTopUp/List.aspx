<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.BalanceTopUp.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html>
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
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="List.aspx">Balance Top Up</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="panel panel-default recent-activities">
                    <div class="panel-heading">
                        <h4 class="panel-title">Balance Top-Up List</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>

                    <div class="panel-body">
                        <div class="col-md-6">
                            <fieldset>
                                <legend>Limit International</legend>
                                <div class="form-group">
                                    <label class="col-md-4">
                                        Credit Limit Authority :
                                    </label>
                                    <div class="col-md-4">
                                        <span style="color: Red;">[<asp:Label ID="ilimit" runat="server">0.00</asp:Label>]</span>
                                        <asp:Label ID="iclaCurr" runat="server">USD</asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4">
                                        Per Top Up Limit :
                                    </label>
                                    <div class="col-md-4">
                                        <span style="color: Red;">[<asp:Label ID="iperTopUpLimit" runat="server">0.00</asp:Label>]</span>
                                        <asp:Label ID="iptulCurr" runat="server">USD</asp:Label>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                        <div class="col-md-6">
                            <fieldset>
                                <legend>Limit Domestic
                                </legend>
                                <div class="form-group">
                                    <label class="col-md-4">
                                        Credit Limit Authority :
                                    </label>
                                    <div class="col-md-4">
                                        <span style="color: Red;">[<asp:Label ID="dlimit" runat="server">0.00</asp:Label>]</span>
                                        <asp:Label ID="dclaCurr" runat="server">NPR</asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4">
                                        Per Top Up Limit  :
                                    </label>
                                    <div class="col-md-4">
                                        <span style="color: Red;">[<asp:Label ID="dperTopUpLimit" runat="server">0.00</asp:Label>]</span>
                                        <asp:Label ID="dptulCurr" runat="server">NPR</asp:Label>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <span style="color: Red">*Note : Todays Send and Todays Paid For Reference Only</span>
                        </div>
                        <div class="table-responsive">
                            <div id="rpt_grid" runat="server" class="gridDiv"></div>
                            <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                            <asp:HiddenField ID="hdnAgentId" runat="server" />
                            <asp:HiddenField ID="hdnAmount" runat="server" />
                        </div>
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                                    <table cellpadding="0" cellspacing="0" style="background: white;">
                                        <tr>
                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">Other Detail</td>
                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                                                <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick="RemoveDiv();"><b>x</b></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div id="showSlab" style="width: 350px;">N/A</div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
            <%--  <div class="bredCrom">Credit Risk Management » Balance Top Up » List</div>
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <table id="limitIntl" style="font-size: 14px; font-weight: bold; float: left;">
                        <tr>
                            <td colspan="2"><u>Limit International</u></td>
                        </tr>
                        <tr>
                            <td>Credit Limit Authority :
                            </td>
                            <td><span style="color: Red;">[<asp:Label ID="ilimit" runat="server">0.00</asp:Label>]</span>
                                <asp:Label ID="iclaCurr" runat="server">USD</asp:Label>
                            </td>
                        </tr>
                        <tr>--%>
            <%--         <td>Per Top Up Limit :
                            </td>
                            <td><span style="color: Red;">[<asp:Label ID="iperTopUpLimit" runat="server">0.00</asp:Label>]</span>
                                <asp:Label ID="iptulCurr" runat="server">USD</asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
                <td>--%>
            <%-- <table id="limitDomestic" style="font-size: 14px; font-weight: bold;">
                        <tr>
                            <td colspan="2"><u>Limit Domestic</u></td>
                        </tr>
                        <tr>
                            <td>Credit Limit Authority :</td>
                            <td><span style="color: Red;">[<asp:Label ID="dlimit" runat="server">0.00</asp:Label>]</span>
                                <asp:Label ID="dclaCurr" runat="server">NPR</asp:Label>
                            </td>
                        </tr>
                        <tr>--%>
            <%-- <td>Per Top Up Limit :</td>
                            <td><span style="color: Red;">[<asp:Label ID="dperTopUpLimit" runat="server">0.00</asp:Label>]</span>
                                <asp:Label ID="dptulCurr" runat="server">NPR</asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>--%>
            <%--  <td>
            <span style="font-style: italic; color: Red">*Note : Todays Send and Todays Paid For Reference Only</span>
        </td>
        </tr>
            <tr>
                <td height="524" valign="top" colspan="2">
                    <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                    <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                    <asp:HiddenField ID="hdnAgentId" runat="server" />
                    <asp:HiddenField ID="hdnAmount" runat="server" />
                </td>
            </tr>
        </table>--%>
            <%--    <asp:UpdatePanel ID="upnl1" runat="server">
            <ContentTemplate>
                <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                    <table cellpadding="0" cellspacing="0" style="background: white;">
                        <tr>
                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">Other Detail</td>
                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                                <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick="RemoveDiv();"><b>x</b></span>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div id="showSlab" style="width: 350px;">N/A</div>
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>--%>
    </form>
</body>
<script language="javascript">
    var oldId = 0;
    var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
    function RemoveDiv() {
        $("#newDiv").slideToggle("fast");
    }
    function ShowSlab(id) {
        //        alert('test');
        //        return;
        $.get(urlRoot + "/Remit/CreditRiskManagement/BalanceTopUp/LimitDetail.aspx", { agentId: id }, function (data) {
            GetElement("showSlab").innerHTML = data;
            ShowHideServiceCharge(id);
        });
    }
    function ShowHideServiceCharge(id) {
        var pos = FindPos(GetElement("showSlab_" + id));
        var left = pos[0] + 18;
        var top = pos[1];
        GetElement("newDiv").style.left = left + "px";
        GetElement("newDiv").style.top = top + "px";
        GetElement("newDiv").style.border = "1px solid black";
        if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "") {
            $("#newDiv").slideToggle("fast");
        }
        else {
            if (id == oldId) {
                $("#newDiv").slideToggle("fast");
            }
            else {
                GetElement("newDiv").style.display = "none";
                $("#newDiv").slideToggle("fast");
            }
        }
        oldId = id;
    }

    function HideDiv() {
        document.getElementById("showSlab").style.display = "none";
        document.getElementById("delImg").style.display = "none";
    }
</script>
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../../Autocomplete.asmx/GetAgentNameList";
        $("#gridBalTopUp_agentName").autocomplete({

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
                SetValueById("gridBalTopUp_agentName", result[0], "");
            }

        });
    }
    Autocomplete();
</script>
</html>