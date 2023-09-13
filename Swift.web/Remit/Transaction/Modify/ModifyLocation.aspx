<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyLocation.aspx.cs" Inherits="Swift.web.Remit.Transaction.Modify.ModifyLocation" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target = "_self" runat = "server" />
     <script src="../../../js/functions.js" type="text/javascript"> </script>
     <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
     <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
     <script type="text/javascript">
         function CallBack(result) {
            var jsonRes = JSON.parse(result);
            alert(jsonRes.Msg);
            if (jsonRes.ErrorCode != 0) {
                return;
            }
            window.returnValue = jsonRes.ErrorCode;
            window.opener.PostMessageToParent(jsonRes.Extra);
            //window.onunload = window.opener.location.reload();
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
       <asp:ScriptManager runat="server" id="sc"></asp:ScriptManager>
    <div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td height="26" class="bredCrom"> <div >Modify Transaction // Modify Payout Location</div> </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG"></td>
        </tr>
      
        <tr>
            <td>
                    <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                    <asp:HiddenField ID = "hddField" runat = "server" />
                    <asp:HiddenField ID = "hddOldValue" runat = "server" />
                    <asp:HiddenField ID = "hdnValueType" runat="server" />
                        <tr>
                            <td colspan="2"  nowrap="nowrap"><asp:Label ID="lblMsg" runat="server"></asp:Label> </td>
                        </tr>
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right">Field Name : </div>
                            </td>
                            <td  nowrap="nowrap">
                                <asp:Label ID="lblFieldName" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td  nowrap="nowrap"> 
                                <div align="right">Old Value : </div>
                            </td>
                            <td>
                                <asp:Label ID="lblOldValue" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <div id="rptShowOther" runat="server">
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right">New Value : </div>
                            </td>
                            <td  nowrap="nowrap">
                                <asp:DropDownList ID="ddlNewValue" runat="server" CssClass="input"></asp:DropDownList>
                            </td>
                        </tr>
                        </div>
                        <div id="showBranch" runat="server" visible="false">
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right"> Bank : </div>
                            </td>
                            <td  nowrap="nowrap">
                                <asp:DropDownList ID="ddlBank" runat="server" CssClass="input" 
                                    AutoPostBack="True" onselectedindexchanged="ddlBank_SelectedIndexChanged"></asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right"> Branch : </div>
                            </td>
                            <td  nowrap="nowrap">
                                <asp:DropDownList ID="ddlBranch" runat="server" CssClass="input"></asp:DropDownList>
                            </td>
                        </tr>
                        </div>
                        <div id="rptAccountNo" runat="server" visible="false">
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right">New Value : </div>
                            </td>
                            <td  nowrap="nowrap">
                                <asp:TextBox ID="txtNewValue" runat="server" CssClass="input"></asp:TextBox>
                            </td>
                        </tr>
                        </div>
                        <div id="rptBranch" runat="server" visible="false">
                        <tr>
                            <td  nowrap="nowrap">
                                <div align="right">New Value : </div>
                            </td>
                            <td nowrap="nowrap">
                                <input type="text" readonly="readonly" id="sendBy" style="width: 320px"/>
                                <input type="button" value="Pick" onclick="PickAgent();" class="button"/>
                                 <asp:HiddenField ID="hdnBranchName" runat="server"/>
                                <asp:HiddenField ID="hdnBranchId" runat="server" />                                 
                               
                            </td>
                        </tr>
                        </div>
                        <tr>
                            <td>&nbsp;</td>
                            <td>
                            <asp:Button ID="btnUpdate" runat="server" Text=" Update " CssClass="button" 
                                        onclick="btnUpdate_Click" />
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
