<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAExceptionRpt.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.RBACustomer.RBAExceptionRpt" %>
<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <script src="../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <base id="Base1" target = "_self" runat = "server" />
</head>
<script type="text/javascript">

    function LoadCalendars() {
        ShowCalDefault("#<% =fromDate.ClientID%>");
        ShowCalDefault("#<% =toDate.ClientID%>");
    }
    LoadCalendars();

    function openReport(rCat, rType,risk,url) {

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=RBAExceptionRpt&rType=" + rType + "&rCat=" + rCat+"&risk="+risk+url;
        OpenInNewWindow(url);
        return false;
    }
    function GetCountryId() {
            return GetItem("<% = country.ClientID %>")[0];
        }
function GetAgentId() {
            return GetItem("<% = agent.ClientID %>")[0];
        }
         function CallBackAutocomplete(id) {
            var d = ["",""];
            if (id == "#<% = country.ClientID%>")
            {
                SetItem("<% =agent.ClientID%>", d);
                <% = agent.InitFunction() %>;  
                
            }
            else if (id == "#<% = agent.ClientID%>")
            {
                SetItem("<% =branch.ClientID%>", d);
                <% = branch.InitFunction() %>;  
                
            }
            }

</script>
<style type="text/css">
.contentlink 
{
    color:blue;
    cursor:pointer;
    text-decoration:underline;
    
}
a
{
    color: Blue;
    text-decoration: underline;
}

.number
{
    text-align: right;
    text-decoration: underline;
}
</style>
<body>
    <form id="form1" runat="server">
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">
                Compliance » Customer Risk Assessment Exception Report
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
        <td>
         <table style="width: 50%;">
                <tr>
                    <td class="frmLableBold">
                        Date From
                    </td>
                    <td>
                        <asp:TextBox ID="fromDate" runat="server" class="dateField" Width="100px"
                                                size="12"></asp:TextBox>
                                            <span class="errormsg">*</span>
                    </td>
                    <td class="frmLableBold">
                        Date To
                    </td>
                    <td>
                        <asp:TextBox ID="toDate" runat="server" class="dateField" Width="100px"
                                                size="12"></asp:TextBox>
                                            <span class="errormsg">*</span>
                    </td>
                </tr>
                <tr>
                   <td class="frmLableBold">
                        Country
                    </td>
                    <td>
                      <uc1:SwiftTextBox ID="country" runat="server" Category="country" Width="200px"></uc1:SwiftTextBox>
                                           <%--  <span class="errormsg">*</span> <span runat="server" id="Span3" visible="false" class="errMsg" style="color: Red;">
                                                            Required!</span>--%>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                      <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="frmLableBold">
                        Agent
                    </td>
                    <td>
                      <uc1:SwiftTextBox ID="agent" runat="server" Category="s-r-agent" Width="200px" Param1="@GetCountryId()" ></uc1:SwiftTextBox>
                                           <%--  <span class="errormsg">*</span> <span runat="server" id="Span1" visible="false" class="errMsg" style="color: Red;">
                                                            Required!</span>--%>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                      <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                   <td class="frmLableBold">
                        Branch
                    </td>
                    <td>
                       <uc1:SwiftTextBox ID="branch" runat="server" Category="pbranchByAgent" Param1="@GetAgentId()" Width="200px"></uc1:SwiftTextBox>
                                            <%-- <span class="errormsg">*</span> <span runat="server" id="Span2" visible="false" class="errMsg" style="color: Red;">
                                                            Required!</span>--%>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                      <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="frmLableBold">
                       RBA Type
                    </td>
                    <td>                        
                        <asp:DropDownList ID="reportType"  Width="100px" runat="server">
                        <asp:ListItem Value="">Select</asp:ListItem>
                        <asp:ListItem Value="customer">Customer</asp:ListItem>
                        <asp:ListItem Value="txn">Txn</asp:ListItem>
                        </asp:DropDownList>

                          <span class="errormsg">*</span> <span runat="server" id="Span3" visible="false" class="errMsg" style="color: Red;">
                                                            Required!</span>

                    </td>
                    <td>
                        &nbsp;
                    </td>
                      <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="frmLableBold">
                        &nbsp;</td>
                    <td>
                        <asp:Button ID="showReport" runat="server" Text="Show Report" 
                            onclick="showReport_Click" />
                    </td>
                    <td>
                        &nbsp;</td>
                      <td>
                          &nbsp;</td>
                </tr>
            </table>
        </td>
        </tr>
        <tr>
           
            <td height="524" align="center" valign="top">
                <div id = "rpt_grid" runat = "server" class = "gridDiv" >                    
                </div>
              
            </td>            
        </tr>
    </table>   
    </form>
</body>
</html>

