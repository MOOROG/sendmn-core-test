<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Commission.ServiceCharge.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>



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
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                    <li><a href="#" onclick="return LoadModule('servicecharge_and_commission')">Service Charge and Comission </a></li>
                                    <li class="active"><a href="List.aspx">Service Charge</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="listtabs">
                        <ul class="nav nav-tabs">
                            <li class="active"><a href="#" class="selected" target="_self">Main </a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Agent List</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <div class="col-md-3 col-md-offset-4"><b>Sending</b> </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-4 control-label">Country : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-4 control-label">Super Agent : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="ssAgent" runat="server" CssClass="form-control" OnSelectedIndexChanged="ssAgent_SelectedIndexChanged" AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-4 control-label">Agent :</label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-4 control-label">Has Changed : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="hasChanged" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="">All</asp:ListItem>
                                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                            <asp:ListItem Value="N">No</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-4 control-label">Transaction Type : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <div class="col-md-3 col-md-offset-4">
                                                        <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn btn-primary m-t-25" OnClick="btnFilter_Click" />
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- receiving -->
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <div class="col-md-3 col-md-offset-3"><b>Receiving</b></div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-3 control-label">Country : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control" OnSelectedIndexChanged="rCountry_SelectedIndexChanged" AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-3 control-label">Super Agent : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="rsAgent" runat="server" CssClass="form-control"
                                                            OnSelectedIndexChanged="rsAgent_SelectedIndexChanged" AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-md-3 control-label">Agent : </label>
                                                    <div class="col-md-7">
                                                        <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="col-md-12">
                                                <div class="table-responsive">
                                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
                                                        <div id="newDiv" style="position: absolute; display: none;">
                                                            <table class="table table-responsive table-bordered table-striped ">
                                                                <tr>
                                                                    <td>Amount Slab</td>
                                                                    <td>
                                                                        <span title="Close" style="cursor: pointer; float: right;" onclick="RemoveDiv();"><b>x</b></span>
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
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="ssAgent" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                <asp:PostBackTrigger ControlID="btnFilter" />
            </Triggers>
        </asp:UpdatePanel>
        <%--    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0"  style="margin:100px 150px;">
        <tr>
            <td align="left" valign="top" class="bredCrom">Service Charge Setup - Special</td>
        </tr>
        <tr>
            <td height="10" class="shadowBG"></td>
        </tr>
        <tr>
            <td height="10"> 
                <div class="tabs"> 
                    <ul>
                        <li> <a href="#" class="selected"> Main </a></li>
                    </ul> 
                </div> 
            </td>
        </tr>
        <tr>
            <td>--%>
        <%--      <asp:UpdatePanel ID="upd1" runat="server">
            <ContentTemplate>

                <table class="fieldsetcss" style="margin-left: 0px; width: 1000px;">
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
                                        <asp:DropDownList ID="sCountry" runat="server" Width="180px" OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Super Agent</td>
                                    <td>
                                        <asp:DropDownList ID="ssAgent" runat="server" Width="180px"
                                            OnSelectedIndexChanged="ssAgent_SelectedIndexChanged" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Agent</td>
                                    <td>
                                        <asp:DropDownList ID="sAgent" runat="server" Width="180px"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr height="10px">
                                    <td>Has Changed</td>
                                    <td>
                                        <asp:DropDownList ID="hasChanged" runat="server" Width="180px">
                                            <asp:ListItem Value="">All</asp:ListItem>
                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                            <asp:ListItem Value="N">No</asp:ListItem>
                                        </asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td align="left">Transaction Type </td>
                                    <td>
                                        <asp:DropDownList ID="tranType" runat="server" Width="180px"></asp:DropDownList>
                                        <asp:Button ID="btnFilter" runat="server" Text="Filter"
                                            CssClass="button" OnClick="btnFilter_Click" />

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
                                        <asp:DropDownList ID="rCountry" runat="server" Width="180px"
                                            OnSelectedIndexChanged="rCountry_SelectedIndexChanged" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Super Agent</td>
                                    <td>
                                        <asp:DropDownList ID="rsAgent" runat="server" Width="180px"
                                            OnSelectedIndexChanged="rsAgent_SelectedIndexChanged" AutoPostBack="True">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Agent</td>
                                    <td>
                                        <asp:DropDownList ID="rAgent" runat="server" Width="180px"></asp:DropDownList>


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
        </td>
        </tr>
        <tr>--%>
        <%--      <td height="524" valign="top" align="left">
                <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
            </td>
        </tr>
        </table>
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
    </asp:UpdatePanel>--%>
    </form>
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
        var top = pos[1] - 195;
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
