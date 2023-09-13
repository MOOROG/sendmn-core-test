<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DynamicPopupList.aspx.cs"
    Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.DynamicPopupList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="DynamicPopupList.aspx">Message Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="ListHeadMsg.aspx" target="_self">Head </a></li>
                    <li><a href="ListMessage1.aspx" target="_self">Common</a></li>
                    <li><a href="ListMessage2.aspx" target="_self">Country</a></li>
                    <li><a href="ListNewsFeeder.aspx" target="_self">News Feeder </a></li>
                    <li><a href="ListEmailTemplate.aspx" target="_self">Email Template</a></li>
                    <li><a href="ListMessageBroadCast.aspx" target="_self">Broadcast</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Dynamic Popup</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Dynamic Pop-Up Message
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>


<%--    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top:110px">
        <tr>
            <td height="26" class="bredCrom">
                <div>
                    Application Setting » Message Setting » Dynamic Pop up Message » List</div>
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
            <td height="10">
                <div class="tabs">
                    <ul>
                        <li><a href="ListHeadMsg.aspx">Head </a></li>
                        <li><a href="ListMessage1.aspx">Common</a></li>
                        <li><a href="ListMessage2.aspx">Country</a></li>
                        <li><a href="ListNewsFeeder.aspx">News Feeder </a></li>
                        <li><a href="ListEmailTemplate.aspx">Email Template</a></li>
                        <li><a href="ListMessageBroadCast.aspx">Broadcast</a></li>
                        <li><a href="Javascript:void(0)" class="selected">Dynamic Popup</a></li>
                    </ul>
                </div>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">--%>
<%--   <div id="rpt_grid" runat="server" class="gridDiv">
                </div>
            </td>
        </tr>
    </table>--%>
    </form>
</body>
</html>
