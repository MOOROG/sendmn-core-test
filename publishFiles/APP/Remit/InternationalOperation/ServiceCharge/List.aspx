<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Commission.ServiceCharge.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style type="text/css">
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            background-color: #f5f5f5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">International Operation </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Service Charge/Commission</a></li>
                            <li class="active"><a href="List.aspx">Service Charge Setup - Special</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#" class="selected" target="_self">Main </a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upd1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td valign="top">
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <th></th>
                                                                    <th align="left">Sending</th>
                                                                </tr>
                                                                <tr>
                                                                    <td>Country</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control"
                                                                            OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Super Agent</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="ssAgent" runat="server" CssClass="form-control"
                                                                            OnSelectedIndexChanged="ssAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Agent</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr height="10px">
                                                                    <td>Has Changed</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="hasChanged" runat="server" CssClass="form-control">
                                                                            <asp:ListItem Value="">All</asp:ListItem>
                                                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                            <asp:ListItem Value="N">No</asp:ListItem>
                                                                        </asp:DropDownList></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="left">Transaction Type </td>
                                                                    <td>
                                                                        <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"></asp:DropDownList>


                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td></td>
                                                                    <td>
                                                                        <asp:Button ID="btnFilter" runat="server" Text="Filter"
                                                                            CssClass="btn btn-primary" OnClick="btnFilter_Click" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td></td>
                                                        <td valign="top">
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <th></th>
                                                                    <th align="left">Receiving</th>
                                                                </tr>
                                                                <tr>
                                                                    <td>Country</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control"
                                                                            OnSelectedIndexChanged="rCountry_SelectedIndexChanged" AutoPostBack="True">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Super Agent</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="rsAgent" runat="server" CssClass="form-control"
                                                                            OnSelectedIndexChanged="rsAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Agent</td>
                                                                    <td>
                                                                        <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control"></asp:DropDownList>


                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="ssAgent" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                                                <asp:PostBackTrigger ControlID="btnFilter" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </div>
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;" enableviewstate="false"></div>
                                    </div>
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">Amount Slab</td>
                                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                                                                <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick="RemoveDiv();"><b>x</b></span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <div id="showSlab" runat="server">N/A</div>
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
            </div>
        </div>
    </form>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>
<script language="javascript">
    var oldId = 0;
    var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
    function RemoveDiv() {
        $("#newDiv").slideToggle("fast");
    }
    function ShowSlab(id) {
        var master = "sscMaster";
        var detail = "sscDetail";
        $.get(urlRoot + "/Include/ShowSlab.aspx", { master: master, detail: detail, masterId: id }, function (data) {
            GetElement("showSlab").innerHTML = data;
            ShowHideServiceCharge(id);
        });
    }
    function ShowHideServiceCharge(id) {
        var pos = FindPos(GetElement("showSlab_" + id));
        var left = pos[0] + 35;
        var top = pos[1] - 220;
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
