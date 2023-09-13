<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionAgent.Send.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
       <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
   
    <script type="text/javascript">
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
        <asp:UpdatePanel ID="upd1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <ol class="breadcrumb">
                                    <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('adminstration')">International Operation </a></li>
                                    <li><a href="#" onclick="return LoadModule('sub_administration')">Service Charge/Commission</a></li>
                                    <li class="active">Send Commission Setup - Custom</li>
                                </ol>
                            </div>
                        </div>
                    </div>
                      <div class="listtabs">
                        <ul class="nav nav-tabs">
                            <li class="active"><a  target="_self" href="#" class="selected" >Main </a></li>
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
                                            <div class="row">

                                                <!-- send div -->
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <div class="col-md-4 col-md-4 col-md-offset-4">Sending  </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Country : </label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Super Agent :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="ssAgent" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="ssAgent_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Agent :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="sAgent_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Branch : </label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <div class="col-md-4 col-md-offset-4">
                                                            <asp:Button ID="btnFilter" runat="server" CssClass="btn btn-primary m-t-25"
                                                                OnClick="btnFilter_Click" Text="Filter" />
                                                        </div>
                                                    </div>
                                                </div>

                                                <!--  Receiving -->
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <div class="col-md-4 col-md-offset-4">Receiving</div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Country :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="rCountry_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Super Agent :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="rsAgent" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="rsAgent_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Agent : </label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control"
                                                                OnSelectedIndexChanged="rAgent_SelectedIndexChanged" AutoPostBack="True">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Branch : </label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="rBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Applies To -->
                                                <div class="col-md-4">
                                                    <div class="form-group">
                                                        <div class="col-md-4 col-md-offset-4">Applies To</div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">State :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="state" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">ZIP :</label>
                                                        <div class="col-md-8">
                                                            <asp:TextBox ID="zip" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Agent Group  :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="agentGroup" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Transaction Type  :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-md-4 control-label">Has Changed :</label>
                                                        <div class="col-md-8">
                                                            <asp:DropDownList ID="hasChanged" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="">All</asp:ListItem>
                                                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                <asp:ListItem Value="N">No</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div class="table-responsive">
                                                <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                            </div>
                                            <div class="form-group">
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <div id="newDiv" style="position: absolute; display: none;">
                                                            <table class="table table-bordered table-striped table-responsive">
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
                <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                <asp:PostBackTrigger ControlID="btnFilter" />
            </Triggers>
        </asp:UpdatePanel>
        <%--  <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin: 100px 150px;">
                <tr>
                    <td align="left" valign="top" class="bredCrom">Send Commission Setup - Custom</td>
                </tr>
                <tr>
                    <td height="10" class="shadowBG"></td>
                </tr>
                <tr>
                    <td height="10">
                        <div class="tabs">
                            <ul>
                                <li><a href="#" class="selected">Main</a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:UpdatePanel ID="upd1" runat="server">
                            <ContentTemplate>
                                <table class="fieldsetcss" style="margin-left: 0px; width: 1000px;">
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <th></th>--%>
        <%--      <th align="left">Sending</th>
                                                </tr>
                                                <tr>
                                                    <td>Country</td>
                                                    <td>
                                                        <asp:DropDownList ID="sCountry" runat="server" Width="180px"
                                                            OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="True">
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
                                                        <asp:DropDownList ID="sAgent" runat="server" Width="180px"
                                                            OnSelectedIndexChanged="sAgent_SelectedIndexChanged" AutoPostBack="True">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Branch</td>
                                                    <td>
                                                        <asp:DropDownList ID="sBranch" runat="server" Width="180px"></asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td align="left">
                                                        <asp:Button ID="btnFilter" runat="server" CssClass="button"
                                                            OnClick="btnFilter_Click" Text="Filter" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td></td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <th></th>--%>
        <%-- <th align="left">Receiving</th>
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
                    <asp:DropDownList ID="rAgent" runat="server" Width="180px"
                        OnSelectedIndexChanged="rAgent_SelectedIndexChanged" AutoPostBack="True">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>Branch</td>
                <td>
                    <asp:DropDownList ID="rBranch" runat="server" Width="180px"></asp:DropDownList>
                </td>
            </tr>
            </table>
                                        </td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <th></th>--%>
        <%--                                                    <th align="left">Applies To</th>
                                                </tr>
                                                <tr>
                                                    <td>State</td>
                                                    <td>
                                                        <asp:DropDownList ID="state" runat="server" Width="180px">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>ZIP</td>
                                                    <td>
                                                        <asp:TextBox ID="zip" runat="server" Width="175px"></asp:TextBox>

                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Group</td>
                                                    <td>
                                                        <asp:DropDownList ID="agentGroup" runat="server" Width="180px">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Transaction Type </td>
                                                    <td>
                                                        <asp:DropDownList ID="tranType" runat="server" Width="180px"></asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Has Changed </td>
                                                    <td>
                                                        <asp:DropDownList ID="hasChanged" runat="server" Width="180px">
                                                            <asp:ListItem Value="">All</asp:ListItem>
                                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                            <asp:ListItem Value="N">No</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
            </tr>
                                </table>--%>
        <%-- </ContentTemplate>
                            <triggers>
                                <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="ssAgent" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                                <asp:PostBackTrigger ControlID="btnFilter" />
                            </triggers>
            </asp:UpdatePanel>
                    </td>
                </tr>
                <tr>--%>
        <%--     <td height="524" valign="top" align="left">
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
<script language="javascript">
    var oldId = 0;
    var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
    function RemoveDiv() {
        $("#newDiv").slideToggle("fast");
    }
    function ShowSlab(id) {
        var master = "scSendMaster";
        var detail = "scSendDetail";
        $.get(urlRoot + "/Include/ShowSlab.aspx", { master: master, detail: detail, masterId: id }, function (data) {
            GetElement("showSlab").innerHTML = data;
            ShowHideServiceCharge(id);
        });
    }
    function ShowHideServiceCharge(id) {
        var pos = FindPos(GetElement("showSlab_" + id));
        var left = pos[0] + 39;
        var top = pos[1] -200;
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
