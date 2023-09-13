<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.InternationalOperation.BalanceTopUp.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js"></script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>

    <script type="text/javascript">
        function TopUp(id) {
            if (id == "undefined" || id == null)
                return;
            if (GetValue("topUp_" + id) == null || GetValue("topUp_" + id) == '' || GetValue("topUp_" + id) == '0') {
                alert('Topup amount can not be blank or 0!');
                return false;
            }
            SetValueById("<%=hdnAmount.ClientID %>", GetValue("topUp_" + id), "");
            SetValueById("<%=hdnAgentId.ClientID %>", id, "");
            GetElement("<%=btnTopUp.ClientID %>").click();
        }
    </script>
    <style>
        .ui-autocomplete
        {
        background:#fff;
        border:1px solid #ccc;
        width:400px;
    }
    </style>
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
                            <li><a href="#" onclick="return LoadModule('international_operation')">Intl Operation</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk')">Credit Risk Management </a></li>
                            <li class="active"><a href="List.aspx">Balance TopUP</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Credit Limit List
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="table table-responsive">
                                <div class="form-group">
                                    <table id="limitIntl" style="font-size: 14px; font-weight: bold; float: left;">
                                        <tr>
                                            <td>Credit Limit Authority :
                                            </td>
                                            <td><span style="color: Red;">[<asp:Label ID="ilimit" runat="server">0.00</asp:Label>]</span>
                                                <asp:Label ID="iclaCurr" runat="server"><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyUSA","") %></asp:Label>
                                            </td>
                                            <td>| Per Top Up Limit :
                                            </td>
                                            <td><span style="color: Red;">[<asp:Label ID="iperTopUpLimit" runat="server">0.00</asp:Label>]</span>
                                                <asp:Label ID="iptulCurr" runat="server"><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyUSA","") %></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="form-group">
                                <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                                <asp:Button ID="btnTopUp" runat="server" OnClick="btnTopUp_Click" Style="display: none;" />
                                <asp:HiddenField ID="hdnAgentId" runat="server" />
                                <asp:HiddenField ID="hdnAmount" runat="server" />
                            </div>
                            <div class="form-group">
                                <asp:UpdatePanel ID="upnl1" runat="server">
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
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    var oldId = 0;
    var urlRoot = "<%=Swift.web.Library.GetStatic.GetUrlRoot() %>";
    function RemoveDiv() {
        $("#newDiv").slideToggle("fast");
    }
    function ShowSlab(id) {
        //        alert('test');
        //        return;
        $.get(urlRoot + "/Remit/InternationalOperation/BalanceTopUp/LimitDetail.aspx", { agentId: id }, function (data) {
            GetElement("showSlab").innerHTML = data;
            ShowHideServiceCharge(id);
        });
    }
    function ShowHideServiceCharge(id) {
        var pos = FindPos(GetElement("showSlab_" + id));
        var left = pos[0] + 40;
        var top = pos[1] - 170;
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
