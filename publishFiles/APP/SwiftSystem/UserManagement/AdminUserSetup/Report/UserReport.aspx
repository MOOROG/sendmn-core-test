<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserReport.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.Report.UserReport" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function GetAgentId() {
            return GetItem("<% = agent.ClientID %>")[0];
        }
         function LoadCalendars() {
            ShowCalDefault("#<% =txtRequestedDate.ClientID%>");
           }
        LoadCalendars();

        function GetBranchId() {
            return GetItem("<% = branch.ClientID %>")[0];
        }
        function CallBackAutocomplete(id) {
            var d = ["",""];
            if (id == "#<% = agent.ClientID%>") {
                SetItem("<% =branch.ClientID%>", d);
                SetItem("<% =user.ClientID%>", d);
                <% = branch.InitFunction() %>;  
                <% = user.InitFunction() %>;  
            } else if (id == "#<% = branch.ClientID%>") {
                SetItem("<% =user.ClientID%>", d);
                <% = user.InitFunction() %>;  
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table>
            <tr>
                <td height="26" class="bredCrom">
                    <div>
                        Report » User Report
                    </div>
                </td>
            </tr>
            <tr>
                <td height="10" class="shadowBG">
                </td>
            </tr>
            <tr>
                <td>
                    <table class="formTable">
                        <tr>
                            <td class="frmTitle" colspan="3">
                                User Report
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            Agent :
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="agent" runat="server" Category="agent"></uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            Branch :
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="branch" runat="server" Category="branch" Param1="@GetAgentId()">
                                            </uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            User :
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="user" runat="server" Category="user" Param2="@GetAgentId()"
                                                Param1="@GetBranchId()"></uc1:SwiftTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            <%--<input type = "button" value = "Add To List" onclick = "AddToList();" />--%>
                                            <asp:Button ID="btnAddToList" runat="server" Text="Add to list" OnClick="btnAddToList_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td>
                                <div>
                                    <asp:DropDownList ID="addList" runat="server" Style="height: 143px !important; width: 200px;"
                                        multiple="multiple">
                                    </asp:DropDownList>
                                    &nbsp<span class="ErrMsg">*</span><span id="err" runat="server" style="color: Red;"
                                        visible="false">!Required</span><br />
                                </div>
                                <br />
                                <asp:Button ID="bttnRemoveSelected" runat="server" Text="Remove Item" OnClick="bttnRemoveSelected_Click" />
                            </td>
                            <td>
                                <table>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            Requested By:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtRequestedBy"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            Email:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtReqEmail"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">
                                            Requested Date:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtRequestedDate" Width="100px" CssClass="required"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td colspan="2" >
                                            <asp:Button ID="btnSearch" runat="server" Text="Generate" OnClick="btnSearch_Click" />
                                        </td>
                                    </tr>
                                </table>
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
