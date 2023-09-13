<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="ManageTemplate.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.Transaction.ManageTemplate" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
      
    <link href="../../../../Css/style.css" rel="Stylesheet" type="text/css" />

    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css"/>

    <script src="../../../../js/listBoxMovement.js" type="text/javascript"></script>

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
    </script>
    <style type="text/css">
        .style1
        {
            width: 73px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="breadCrumb">Reports » Transaction Report » Manage Template</div>
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <table border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0" class="formTable">
                    <tr>
                        <th class="frmTitle" colspan="2">Manage Template</th>
                    </tr>
                    <tr>
                        <td colspan="2" valign="top">            
                            <table>
                            <tr>
                                <td>Template Name:</td>
                                <td colspan="4"><asp:TextBox ID="templateName"  runat="server" Width="200px"></asp:TextBox><span class="ErrMsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="templateName" ForeColor="Red" 
                                                                    ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator></td>
                            </tr>
                                <tr>
                                    <td>   
                                        Transaction Information <br />
                                        <asp:DropDownList ID="ddlTranInfo" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder">
                                            <div class="arrow_down" onclick=" return  listbox_moveacross('<%=ddlTranInfo.ClientID %>', '<%=ddlTranInfoSelected.ClientID %>');"></div>
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlTranInfo.ClientID %>', true)" style="width:60px;">Select All </div>
                                            <div class="arrow_up" onclick="return listbox_moveacross('<%=ddlTranInfoSelected.ClientID %>', '<%=ddlTranInfo.ClientID %>');"></div>	
                                        </div>
                                    </td>
                                    <td>   
                                        Sending Agent Information <br />
                                        <asp:DropDownList ID="ddlSendingAgent" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder">
                                            <div class="arrow_down" onclick=" return  listbox_moveacross('<%=ddlSendingAgent.ClientID %>', '<%=ddlTranInfoSelected.ClientID %>');"></div>
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlSendingAgent.ClientID %>', true)" style="width:60px;">Select All </div>
                                            <div class="arrow_up" onclick="return listbox_moveacross('<%=ddlTranInfoSelected.ClientID %>', '<%=ddlSendingAgent.ClientID %>');"></div>	
                                        </div>
                                    </td>
                                    <td>   
                                        Sender Information <br />
                                        <asp:DropDownList ID="ddlSenderInfo" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder">
                                            <div class="arrow_down" onclick=" return  listbox_moveacross('<%=ddlSenderInfo.ClientID %>', '<%=ddlTranInfoSelected.ClientID %>');"></div>
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlSenderInfo.ClientID %>', true)" style="width:60px;">Select All </div>
                                            <div class="arrow_up" onclick="return listbox_moveacross('<%=ddlTranInfoSelected.ClientID %>', '<%=ddlSenderInfo.ClientID %>');"></div>	
                                        </div>
                                    </td>
                                    <td>   
                                        Receiving Agent Information <br />
                                        <asp:DropDownList ID="ddlRecAgent" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder">
                                            <div class="arrow_down" onclick=" return  listbox_moveacross('<%=ddlRecAgent.ClientID %>', '<%=ddlTranInfoSelected.ClientID %>');"></div>
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlRecAgent.ClientID %>', true)" style="width:60px;">Select All </div>
                                            <div class="arrow_up" onclick="return listbox_moveacross('<%=ddlTranInfoSelected.ClientID %>', '<%=ddlRecAgent.ClientID %>');"></div>	
                                        </div>
                                    </td>
                                    <td>   
                                        Receiver Information <br />
                                        <asp:DropDownList ID="ddlRecInfo" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder">
                                            <div align="center" class="arrow_down" onclick=" return  listbox_moveacross('<%=ddlRecInfo.ClientID %>', '<%=ddlTranInfoSelected.ClientID %>');"></div>
                                            <div align="center" class="select_all" onclick="listbox_selectall('<%=ddlRecInfo.ClientID %>', true)" style="width:60px;">Select All </div>
                                            <div align="center" class="arrow_up" onclick="return listbox_moveacross('<%=ddlTranInfoSelected.ClientID %>', '<%=ddlRecInfo.ClientID %>');"></div>	
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:DropDownList ID="ddlTranInfoSelected" runat="server" CssClass="CMBDesign" style="height:250px !important; width:250px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <%--<div class="button_placeholder" style="width:100px">
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlTranInfoSelected.ClientID %>', true)" style="width:60px;">Select All </div>
                                        </div>--%>
                                    </td>
                                    <%-- <td>
                                        <asp:DropDownList ID="ddlSendingAgentSelected" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder" style="width:100px">
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlSendingAgentSelected.ClientID %>', true)" style="width:60px;">Select All </div>
                                        </div>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlSenderInfoSelected" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder" style="width:100px">
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlSenderInfoSelected.ClientID %>', true)" style="width:60px;">Select All </div>
                                        </div>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlRecAgentSelected" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder" style="width:100px">
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlRecAgentSelected.ClientID %>', true)" style="width:60px;">Select All </div>
                                        </div>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlRecInfoSelected" runat="server" CssClass="CMBDesign" style="height:150px !important; width:200px;" multiple="multiple">
                                        </asp:DropDownList>
                                        <div class="button_placeholder" style="width:100px">
                                            <div class="select_all" onclick="listbox_selectall('<%=ddlRecInfoSelected.ClientID %>', true)" style="width:60px;">Select All </div>
                                        </div>
                                    </td>--%>
                                </tr>
                                <tr>
                                <td colspan="4">
                                <asp:Button ID="btnSave" runat="server" CssClass="button"  Text="Save Template" ValidationGroup="rpt" onclick="btnSave_Click" Height="30px"/>
                                </td>
                                    
                                </tr>
                                </table>
                        </td>
                    
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
