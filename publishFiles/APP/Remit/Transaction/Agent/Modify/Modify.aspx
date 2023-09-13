<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Modify.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Modify.Modify" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[2];
            window.close();
        }
        function PickAgent() {
            var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
             var url = urlRoot + "/Remit/Administration/AgentSetup/PickBranch.aspx";
             var param = "dialogHeight:400px;dialogWidth:940px;dialogLeft:200;dialogTop:100;center:yes";
             var res = PopUpWindow(url, param);
             if (res == "undefined" || res == null || res == "") {

             }
             else {
                 var result = res.split('|');
                 SetValueById("<%=hdnBranchName.ClientID %>", result[0], "");
                 SetValueById("<%=hdnBranchId.ClientID %>", result[1], "");
                 SetValueById("sendBy", result[0] + "|" + result[1], "");

             }
         }
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sc"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="Modify.aspx">Search Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table class="table">
                <tr>
                    <td height="10" class="shadowBG"></td>
                </tr>

                <tr>
                    <td>
                        <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                            <asp:HiddenField ID="hddField" runat="server" />
                            <asp:HiddenField ID="hddOldValue" runat="server" />
                            <asp:HiddenField ID="hdnValueType" runat="server" />
                            <tr>
                                <td colspan="2" nowrap="nowrap">
                                    <asp:Label ID="lblMsg" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">Field Name : </div>
                                </td>
                                <td nowrap="nowrap">
                                    <asp:Label ID="lblFieldName" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <div align="right">Old Value : </div>
                                </td>
                                <td>
                                    <asp:Label ID="lblOldValue" runat="server"></asp:Label>
                                </td>
                            </tr>
                            <div id="rptShowOther" runat="server">
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="right">New Value : </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList ID="ddlNewValue" runat="server" CssClass="input"></asp:DropDownList>
                                    </td>
                                </tr>
                            </div>
                            <div id="showBranch" runat="server" visible="false">
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="right">Bank : </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList ID="ddlBank" runat="server" CssClass="input"
                                            AutoPostBack="True" OnSelectedIndexChanged="ddlBank_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="right">Branch : </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:DropDownList ID="ddlBranch" runat="server" CssClass="input"></asp:DropDownList>
                                    </td>
                                </tr>
                            </div>
                            <div id="rptAccountNo" runat="server" visible="false">
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="right">New Value : </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <asp:TextBox ID="txtNewValue" runat="server" CssClass="input"></asp:TextBox>
                                    </td>
                                </tr>
                            </div>
                            <div id="rptBranch" runat="server" visible="false">
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="right">New Value : </div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <input type="text" readonly="readonly" id="sendBy" style="width: 320px" />
                                        <input type="button" value="Pick" onclick="PickAgent();" class="button" />
                                        <asp:HiddenField ID="hdnBranchName" runat="server" />
                                        <asp:HiddenField ID="hdnBranchId" runat="server" />

                                    </td>
                                </tr>
                            </div>
                            <tr>
                                <td>&nbsp;</td>
                                <td>
                                    <asp:Button ID="btnUpdate" runat="server" Text=" Update " CssClass="button"
                                        OnClick="btnUpdate_Click" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>


</html>
