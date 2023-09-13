<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewChanges.aspx.cs" Inherits="Swift.web.ViewChanges" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="js/functions.js" type="text/javascript"></script>
    <script src="js/Swift_grid.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        document.onkeypress = function (e) {
            var e = window.event || e;

            if (e.keyCode == 27)
                window.close();
        }
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }
            window.returnValue = resultList[0];
            if (isChrome) {
                window.opener.ShowMessageToParent(window.returnValue);
            }
            window.close();
        }

        function ViewChangesUD() {
            document.getElementById("viewUD").className = "selected";
            document.getElementById("viewUR").className = "none";
            document.getElementById("viewUF").className = "none";

            document.getElementById("rpt_grid").style.display = "block";
            document.getElementById("rpt_gridUR").style.display = "none";
            document.getElementById("rpt_gridUF").style.display = "none";

            document.getElementById("spanUD").style.display = "block";
            document.getElementById("spanUR").style.display = "none";
            document.getElementById("spanUF").style.display = "none";

            document.getElementById("approveButtonUD").style.display = "block";
            document.getElementById("approveButtonUR").style.display = "none";
            document.getElementById("approveButtonUF").style.display = "none";

            document.getElementById("divUD").style.display = "block";
            document.getElementById("divUR").style.display = "none";
            document.getElementById("divUF").style.display = "none";
        }
        function ViewChangesUR() {
            document.getElementById("viewUD").className = "none";
            document.getElementById("viewUR").className = "selected";
            document.getElementById("viewUF").className = "none";

            document.getElementById("rpt_grid").style.display = "none";
            document.getElementById("rpt_gridUR").style.display = "block";
            document.getElementById("rpt_gridUF").style.display = "none";

            document.getElementById("spanUD").style.display = "none";
            document.getElementById("spanUR").style.display = "block";
            document.getElementById("spanUF").style.display = "none";

            document.getElementById("approveButtonUD").style.display = "none";
            document.getElementById("approveButtonUR").style.display = "block";
            document.getElementById("approveButtonUF").style.display = "none";

            document.getElementById("divUD").style.display = "none";
            document.getElementById("divUR").style.display = "block";
            document.getElementById("divUF").style.display = "none";
        }
        function ViewChangesUF() {
            document.getElementById("viewUD").className = "none";
            document.getElementById("viewUR").className = "none";
            document.getElementById("viewUF").className = "selected";

            document.getElementById("rpt_grid").style.display = "none";
            document.getElementById("rpt_gridUR").style.display = "none";
            document.getElementById("rpt_gridUF").style.display = "block";

            document.getElementById("spanUD").style.display = "none";
            document.getElementById("spanUR").style.display = "none";
            document.getElementById("spanUF").style.display = "block";

            document.getElementById("approveButtonUD").style.display = "none";
            document.getElementById("approveButtonUR").style.display = "none";
            document.getElementById("approveButtonUF").style.display = "block";

            document.getElementById("divUD").style.display = "none";
            document.getElementById("divUR").style.display = "none";
            document.getElementById("divUF").style.display = "block";
        }
        function ViewChangesMaster() {
            document.getElementById("rpt_grid").style.display = "block";
            document.getElementById("rpt_gridDetail").style.display = "none";

            document.getElementById("viewMaster").className = "selected";
            document.getElementById("viewDetail").className = "none";

        }
        function ViewChangesDetail() {
            document.getElementById("rpt_grid").style.display = "none";
            document.getElementById("rpt_gridDetail").style.display = "block";

            document.getElementById("viewMaster").className = "none";
            document.getElementById("viewDetail").className = "selected";

        }
        function ShowApproveButton() {
            document.getElementById("approveButton").style.display = "block";
        }
        function HideApproveButton() {
            document.getElementById("approveButton").style.display = "none";
        }
    </script>
    <style type="text/css">
        .show-yellow {
            background-color: yellow;
            color: black;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row" id="tabPanel1" runat="server" visible="false">
                <div class="col-sm-12">
                    <div class="page-title">
                        <div class="listtabs">
                            <ul class="nav nav-tabs" role="tablist">
                                <li><a role="presentation" id="viewUD" onclick="ViewChangesUD()" href="#" class="selected">User Details</a></li>
                                <li><a role="presentation" id="viewUR" onclick="ViewChangesUR()" href="#">User Roles</a></li>
                                <li><a role="presentation" id="viewUF" onclick="ViewChangesUF()" href="#">User Functions</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="dscPanel" runat="server" visible="false">
                <div class="col-sm-12">
                    <div class="page-title">
                        <div class="listtabs">
                            <ul class="nav nav-tabs" role="tablist">
                                <li><a id="viewMaster" onclick="ViewChangesMaster()" href="#" class="selected">Master</a></li>
                                <li><a id="viewDetail" onclick="ViewChangesDetail()" href="#">Detail</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <asp:UpdatePanel runat="server" ID="upd12">
                <ContentTemplate>
                    <div class="table-responsive">
                        <table border="0" cellspacing="5" cellpadding="5" class="table table-striped table-bordered">
                            <tr>
                                <td>
                                    <div id="divUD">
                                        <table id="tableUD" border="0" width="100%" runat="server" class="table table-striped table-bordered">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblmsg" runat="server" CssClass="Label"></asp:Label><br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Date :
                                   <asp:Label ID="createdDate" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Menu : 
                                <asp:Label ID="tableName" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Data Id : 
                                <asp:Label ID="dataId" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Changed By : 
                                <asp:Label ID="createdBy" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Type : 
                                    <asp:Label ID="logType" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="divUR" style="display: none">
                                        <table id="tableUR" border="0" width="100%" runat="server" class="table table-striped table-bordered">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblmsgUR" runat="server" CssClass="Label"></asp:Label><br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Date :
                                <asp:Label ID="createdDateUR" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Menu : 
                                <asp:Label ID="tableNameUR" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Data Id : 
                                <asp:Label ID="dataIdUR" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Changed By : 
                                <asp:Label ID="createdByUR" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Type : 
                                    <asp:Label ID="logTypeUR" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="divUF" style="display: none">
                                        <table id="tableUF" border="0" width="100%" runat="server" class="table table-striped table-bordered">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblmsgUF" runat="server" CssClass="Label"></asp:Label><br />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Date :
                                <asp:Label ID="createdDateUF" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Menu : 
                                <asp:Label ID="tableNameUF" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Data Id : 
                                <asp:Label ID="dataIdUF" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Changed By : 
                                <asp:Label ID="createdByUF" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">
                                                    <div align="left" class="formLabel">
                                                        Change Type : 
                                    <asp:Label ID="logTypeUF" runat="server" CssClass="formLabel"></asp:Label>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="rpt_grid" runat="server" style="display: block"></div>
                                    <div id="rpt_gridUR" runat="server" style="display: none"></div>
                                    <div id="rpt_gridUF" runat="server" style="display: none"></div>
                                    <div id="rpt_gridDetail" runat="server" style="display: none"></div>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <span id="approveButtonUD">
                                        <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnApprove_Click" Style="float: left" />
                                        <cc1:ConfirmButtonExtender ID="btnApprovecc" runat="server"
                                            ConfirmText="Confirm To Approve?" Enabled="True" TargetControlID="btnApprove">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                    <span id="approveButtonUR" style="display: none">&nbsp;
                        <asp:Button ID="btnApproveUR" runat="server" Text="Approve All" CssClass="btn btn-primary m-t-25"
                            OnClick="btnApproveUR_Click" Style="float: left" />
                                        <cc1:ConfirmButtonExtender ID="btnApproveURcc" runat="server"
                                            ConfirmText="Confirm To Approve?" Enabled="True" TargetControlID="btnApproveUR">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                    <span id="approveButtonUF" style="display: none">&nbsp;
                        <asp:Button ID="btnApproveUF" runat="server" Text="Approve All" CssClass="btn btn-primary m-t-25"
                            OnClick="btnApproveUF_Click" Style="float: left" />
                                        <cc1:ConfirmButtonExtender ID="btnApproveUFcc" runat="server"
                                            ConfirmText="Confirm To Approve?" Enabled="True" TargetControlID="btnApproveUF">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                    <span id="spanUD" style="display: block">&nbsp;
                        <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn btn-primary m-t-25"
                            OnClick="btnReject_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnRejectcc" runat="server"
                                            ConfirmText="Confirm To Reject?" Enabled="True" TargetControlID="btnReject">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                    <span id="spanUR" style="display: none">&nbsp;
                        <asp:Button ID="btnRejectUR" runat="server" Text="Reject" CssClass="btn btn-primary m-t-25"
                            OnClick="btnRejectUR_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnRejectURcc" runat="server"
                                            ConfirmText="Confirm To Reject?" Enabled="True" TargetControlID="btnRejectUR">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                    <span id="spanUF" style="display: none">&nbsp;
                        <asp:Button ID="btnRejectUF" runat="server" Text="Reject" CssClass="btn btn-primary m-t-25"
                            OnClick="btnRejectUF_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnRejectUFcc" runat="server"
                                            ConfirmText="Confirm To Reject?" Enabled="True" TargetControlID="btnRejectUF">
                                        </cc1:ConfirmButtonExtender>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>