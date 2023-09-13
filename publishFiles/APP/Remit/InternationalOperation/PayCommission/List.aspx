<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionAgent.Pay.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <style>
         .table .table {
    background-color: #F5F5F5 !important;
        }
    </style>
    <script language="javascript" type="text/javascript">
        function DeleteRow(id) {
            if (confirm("Sure to delete the selected row?")) {
            }
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">International Operation </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Service Charge/Commission</a></li>
                            <li class="active">Pay Commission Setup - Custom</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a target="_self" href="#" class="selected">Main</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Pay Commission Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td>
                                                <asp:UpdatePanel ID="upd1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td valign="top">
                                                                    <table>
                                                                        <tr>
                                                                            <th></th>
                                                                            <th align="left">Sending</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Country</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sCountry" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Super Agent</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="ssAgent" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="ssAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Agent</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sAgent" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="sAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Branch</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sBranch" CssClass="form-control" runat="server" ></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td align="left">
                                                                                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                                                                                    CssClass="btn btn-primary" OnClick="btnFilter_Click" />
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td></td>
                                                                <td valign="top">
                                                                    <table>
                                                                        <tr>
                                                                            <th></th>
                                                                            <th align="left">Receiving</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Country</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rCountry" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="rCountry_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Super Agent</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rsAgent" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="rsAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Agent</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rAgent" runat="server"  CssClass="form-control"
                                                                                    OnSelectedIndexChanged="rAgent_SelectedIndexChanged" AutoPostBack="True">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Branch</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rBranch" CssClass="form-control" runat="server" ></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td valign="top">
                                                                    <table>
                                                                        <tr>
                                                                            <th></th>
                                                                            <th align="left">Applies To</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>State</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="state" runat="server"  CssClass="form-control">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>ZIP</td>
                                                                            <td>
                                                                                <asp:TextBox ID="zip" runat="server" CssClass="form-control"></asp:TextBox>

                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Group</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="agentGroup" runat="server"  CssClass="form-control">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Transaction Type </td>
                                                                            <td>
                                                                                <asp:DropDownList ID="tranType" runat="server"  CssClass="form-control"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>Has Changed </td>
                                                                            <td>
                                                                                <asp:DropDownList ID="hasChanged" runat="server"  CssClass="form-control">
                                                                                    <asp:ListItem Value="">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                                                </asp:DropDownList>
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
                                                        <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                                                        <asp:PostBackTrigger ControlID="btnFilter" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                        <div class="table table-responsive">
                                            <tr>
                                                <td valign="top" align="left">
                                                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                                </td>
                                            </tr>
                                        </div>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:UpdatePanel ID="upnl1" runat="server">
            <ContentTemplate>
                <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                    <table cellpadding="0" cellspacing="0" style="background: white;">
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
    </form>
</body>
<script language="javascript">
    var oldId = 0;
    var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
    function RemoveDiv() {
        $("#newDiv").slideToggle("fast");
    }
    function ShowSlab(id) {
        var master = "scPayMaster";
        var detail = "scPayDetail";
        $.get(urlRoot + "/Include/ShowSlab.aspx", { master: master, detail: detail, masterId: id }, function (data) {
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
</html>
