<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageInternational.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.PaidTrnReport.ManageInternational" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
       
    <link href="../../../../Css/style.css" rel="Stylesheet" type="text/css" />
    <link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../js/functions.js"></script>

         <script type="text/javascript" language="javascript">
             $(function () {
                 $(".calendar2").datepicker({
                     changeMonth: true,
                     changeYear: true,
                     buttonImage: "/images/calendar.gif",
                     buttonImageOnly: true
                 });
             });


             $(function () {
                 $(".calendar1").datepicker({
                     changeMonth: true,
                     changeYear: true,
                     showOn: "button",
                     buttonImage: "/images/calendar.gif",
                     buttonImageOnly: true
                 });
             });

             $(function () {
                 $(".fromDatePicker").datepicker({
                     defaultDate: "+1w",
                     changeMonth: true,
                     changeYear: true,
                     numberOfMonths: 1,
                     showOn: "button",
                     buttonImage: "/images/calendar.gif",
                     buttonImageOnly: true,
                     onSelect: function (selectedDate) {
                         $(".toDatePicker").datepicker("option", "minDate", selectedDate);
                     }
                 });

                 $(".toDatePicker").datepicker({
                     defaultDate: "+1w",
                     changeMonth: true,
                     changeYear: true,
                     numberOfMonths: 1,
                     showOn: "button",
                     buttonImage: "/images/calendar.gif",
                     buttonImageOnly: true,
                     onSelect: function (selectedDate) {
                         $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                     }
                 });
             });
            
            </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <table border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%"> 
                <table width="100%">
                    <tr>
                        <td height="26" class="bredCrom"> <div > Reports » PAID Transaction Report (International) </div> </td>
                    </tr>
                    <tr>
                        <td height="10" class="welcome"></td>
                    </tr>
                </table>	
            </td>
        </tr>
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" style="margin-left: 50px;">
                    <tr>
                        <th class="frmTitle" colspan="4">PAID INTERNATIONAL TRANSACTION REPORT </th>
                    </tr>
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> From Date:</div></td>
                                    <td nowrap="nowrap">  
                                        <asp:TextBox ID= "fromDate" runat = "server" class="fromDatePicker" ReadOnly="true" Width="80px" size="12"></asp:TextBox>
                                            <span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red" 
                                                                        ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                    </td>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> To Date:</div></td>
                                    <td nowrap="nowrap" colspan="3">  
                                        <asp:TextBox ID= "toDate" runat = "server" class="toDatePicker" ReadOnly="true" Width="80px" size="12"></asp:TextBox>
                                            <span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red" 
                                                                        ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel ID = "upd1" runat = "server">
                            <ContentTemplate>
                            <table>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><span class="subHeading"> SENDING INFORMATION</span></td>
                                    <td>&nbsp;</td>
                                    <td><span class="subHeading">RECEIVING INFORMATION</span></td>
                                </tr>
                                <tr>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> Country:</div></td>
                                    <td><asp:DropDownList ID= "sendCountry" runat = "server" CssClass="input" 
                                            onselectedindexchanged="sendCountry_SelectedIndexChanged" 
                                            AutoPostBack="True"></asp:DropDownList></td>
                        
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel"> Country:</div></td>
                                    <td><asp:DropDownList ID= "recCountry" runat = "server" CssClass="input" 
                                            AutoPostBack="True" onselectedindexchanged="recCountry_SelectedIndexChanged"></asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">State:</div></td>
                                    <td><asp:DropDownList ID= "sendZone"  Width="200px" runat = "server" 
                                            CssClass="input"></asp:DropDownList></td>
                        
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">Zone:</div> </td>
                                    <td><asp:DropDownList ID= "recZone"  Width="200px" runat = "server" 
                                            CssClass="input" AutoPostBack="True" 
                                            onselectedindexchanged="recZone_SelectedIndexChanged"></asp:DropDownList></td>
                                </tr>                     
                                <tr>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  Agent:</div></td>
                                    <td><asp:DropDownList ID= "sendAgent" runat = "server" CssClass="input" 
                                            AutoPostBack="True" onselectedindexchanged="sendAgent_SelectedIndexChanged" Width="200px"></asp:DropDownList></td>
                        
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  District:</div></td>
                                    <td><asp:DropDownList ID= "recDistrict"  Width="200px" runat = "server" 
                                            CssClass="input" AutoPostBack="True" 
                                            onselectedindexchanged="recDistrict_SelectedIndexChanged"></asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  Branch:</div></td>
                                    <td><asp:DropDownList ID= "sendBranch" runat = "server" CssClass="input"   Width="200px">                            
                                    </asp:DropDownList></td>
                        
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  Location:</div></td>
                                    <td><asp:DropDownList ID= "recLocation"  Width="200px" runat = "server" 
                                            CssClass="input" onselectedindexchanged="recLocation_SelectedIndexChanged" 
                                            AutoPostBack="True"></asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>

                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  Agent:</div></td>
                                    <td><asp:DropDownList ID= "recAgent" runat = "server" CssClass="input" 
                                            AutoPostBack="True" onselectedindexchanged="recAgent_SelectedIndexChanged"  Width="200px"></asp:DropDownList></td>

                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>  
                       
                                    <td  nowrap="nowrap" valign="top"> <div align="right" class="formLabel">  Branch:</div></td>
                                    <td><asp:DropDownList ID= "recBranch" runat = "server" CssClass="input"   Width="200px"></asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="2">
                                            <asp:Button ID="btnSearch" runat="server" CssClass="button" 
                                                    Text=" Detail " ValidationGroup="rpt" 
                                            OnClientClick="return showReport();" /> 
                                            &nbsp;&nbsp;
                                             <asp:Button ID="btnSearch1" runat="server" CssClass="button" 
                                                    Text=" Summary " ValidationGroup="rpt" 
                                            OnClientClick="return showReportSummary();" Height="20px" /> 
                                               &nbsp;&nbsp;
                                            <asp:Button ID="Button1" runat="server" CssClass="button" 
                                                    Text=" Summary With Commission " ValidationGroup="rpt" 
                                            OnClientClick="return showReportSummary1();" /> 
                                    </td>
                                </tr>
                            </table>
                            </ContentTemplate>
                            <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="sendAgent" EventName="SelectedIndexChanged" /> 
                                    <asp:AsyncPostBackTrigger ControlID="recZone" EventName="SelectedIndexChanged" /> 
                                    <asp:AsyncPostBackTrigger ControlID="recDistrict" EventName="SelectedIndexChanged" />         
                                    <asp:AsyncPostBackTrigger ControlID="recLocation" EventName="SelectedIndexChanged" /> 
                                    <asp:AsyncPostBackTrigger ControlID="recAgent" EventName="SelectedIndexChanged" /> 
                            </Triggers>
                            </asp:UpdatePanel> 
                        </td>
                    </tr>                
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>

   <script language = "javascript" type = "text/javascript">
       function showReport() {
               if (!Page_ClientValidate('rpt'))
                   return false;

               var fromDate = GetDateValue("<% =fromDate.ClientID%>");
               var toDate = GetDateValue("<% =toDate.ClientID%>");
               var sCountry = GetValue("<% = sendCountry.ClientID %>");

               var sendZone = GetElement("<%=sendZone.ClientID %>");
               var sZone = sendZone.options[sendZone.selectedIndex].text;

               var sAgent = GetValue("<% = sendAgent.ClientID %>");
               var sBranch = GetValue("<% = sendBranch.ClientID %>");
               var rCountry = GetValue("<% = recCountry.ClientID %>");

               var recZone = GetElement("<%=recZone.ClientID %>");
               var rZone = recZone.options[recZone.selectedIndex].text;

               var recDistrict = GetElement("<%=recDistrict.ClientID %>");
               var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

               var rLocation = GetValue("<% = recLocation.ClientID %>");
               var rAgent = GetValue("<% = recAgent.ClientID %>");
               var rBranch = GetValue("<% = recBranch.ClientID %>");

               var url = "ShowReport.aspx?reportName=paidtranint" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation;
                "&rAgent=" + rAgent +
                "&rBranch=" + rBranch +
                
               OpenInNewWindow(url);
               return false;
           }
           function showReportSummary() {
               if (!Page_ClientValidate('rpt'))
                   return false;

               var fromDate = GetDateValue("<% =fromDate.ClientID%>");
               var toDate = GetDateValue("<% =toDate.ClientID%>");
               var sCountry = GetValue("<% = sendCountry.ClientID %>");

               var sendZone = GetElement("<%=sendZone.ClientID %>");
               var sZone = sendZone.options[sendZone.selectedIndex].text;
               
               var sAgent = GetValue("<% = sendAgent.ClientID %>");
               var sBranch = GetValue("<% = sendBranch.ClientID %>");
               var rCountry = GetValue("<% = recCountry.ClientID %>");

               var recZone = GetElement("<%=recZone.ClientID %>");
               var rZone = recZone.options[recZone.selectedIndex].text;

               var recDistrict = GetElement("<%=recDistrict.ClientID %>");
               var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

               var rLocation = GetValue("<% = recLocation.ClientID %>");
               var rAgent = GetValue("<% = recAgent.ClientID %>");
               var rBranch = GetValue("<% = recBranch.ClientID %>");

               var url = "ShowReport.aspx?reportName=paidtransummaryint" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation;
               "&rAgent=" + rAgent +
                "&rBranch=" + rBranch +

               OpenInNewWindow(url);
               return false;
           }
           function showReportSummary1() {
               if (!Page_ClientValidate('rpt'))
                   return false;

               var fromDate = GetDateValue("<% =fromDate.ClientID%>");
               var toDate = GetDateValue("<% =toDate.ClientID%>");
               var sCountry = GetValue("<% = sendCountry.ClientID %>");

               var sendZone = GetElement("<%=sendZone.ClientID %>");
               var sZone = sendZone.options[sendZone.selectedIndex].text;

               var sAgent = GetValue("<% = sendAgent.ClientID %>");
               var sBranch = GetValue("<% = sendBranch.ClientID %>");
               var rCountry = GetValue("<% = recCountry.ClientID %>");

               var recZone = GetElement("<%=recZone.ClientID %>");
               var rZone = recZone.options[recZone.selectedIndex].text;

               var recDistrict = GetElement("<%=recDistrict.ClientID %>");
               var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

               var rLocation = GetValue("<% = recLocation.ClientID %>");
               var rAgent = GetValue("<% = recAgent.ClientID %>");
               var rBranch = GetValue("<% = recBranch.ClientID %>");

               var url = "ShowReport.aspx?reportName=paidtransummary1int" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation;
               "&rAgent=" + rAgent +
                "&rBranch=" + rBranch +

               OpenInNewWindow(url);

               return false;

           }
    </script>