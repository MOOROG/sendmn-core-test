<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBATxnRpt.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.RBATxnRpt" %>
<%@ Import Namespace="Swift.web.Library" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../Css/style.css" rel="Stylesheet" type="text/css" />
    <link href="../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/functions.js"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../css/formStyle.css" rel="stylesheet" type="text/css" />

    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script src="../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>


    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalDefault("#<% =fromDate.ClientID%>");
            ShowCalDefault("#<% =toDate.ClientID%>");
        }
        LoadCalendars();
    </script> 
</head>
<body>
    <form id="form1" runat="server">
    <div class="breadCrumb"> Reports » Risk Base Analysis TXN </div>
    <asp:HiddenField ID="hdnIsAdvaceSearch" runat="server" Value="N"/>
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <table border="0" align="left" cellpadding="0" cellspacing="0">
		<tr>
            <td height="10"> 
                <div class="tabs" > 
                    <ul> 
                        <li> <a href="#" class="selected">RBA TXN Report</a></li>
                        <li> <a href="RBAStatistics.aspx">RBA Statistics</a></li>
                    </ul> 
                </div> 
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel ID="updatePanel1" runat="server">
                <ContentTemplate>
                <table border="0" cellspacing="5" cellpadding="5" class="formTable">
                    <tr>
                        <th class="frmTitle" colspan="3">RBA TXN Report</th>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" width="100px"><div align="left" class="formLabel">Sending Country:</div></td>                        
                        <td nowrap="nowrap" colspan="2">
                            <asp:DropDownList ID="sCountry" runat="server" 
                                style="width:200px;" AutoPostBack="True" 
                                onselectedindexchanged="sCountry_SelectedIndexChanged"></asp:DropDownList>
                            <span class="errormsg">*</span>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="sCountry" ForeColor="Red" 
                                                        ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"><div align="left" class="formLabel">Sending Agent:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="sAgent" runat="server" 
                                style="width:200px;" AutoPostBack="True" 
                                onselectedindexchanged="sAgent_SelectedIndexChanged"></asp:DropDownList> 
                                    
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Sending Branch:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="sBranch" runat="server" 
                                style="width:200px;"></asp:DropDownList> 
                           
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Sender's Native Country:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="sNativeCountry" runat="server" 
                                style="width:200px;"></asp:DropDownList> 
                           
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Sender's ID Number:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:TextBox ID="sIdNumber" runat="server" 
                                style="width:200px;"></asp:TextBox> 
                           
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"  width="100px"> <div align="left" class="formLabel"> Date:</div></td> 
                        <td nowrap="nowrap"> From <br />
                            <asp:TextBox ID= "fromDate" runat = "server" class="dateField" Width="80px" size="12"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>

                        </td>
                        <td nowrap="nowrap"> To <br />
                            <asp:TextBox ID= "toDate" runat = "server" class="dateField"  Width="80px" size="12"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                        </td>                       
                    </tr>
                    <tr>
                        <td nowrap="nowrap"  width="100px"> <div align="left" class="formLabel"> RBA Range:</div></td> 
                        <td nowrap="nowrap">
                            <asp:TextBox ID= "rbaRangeFrom" runat = "server" Text="" Width="80px" size="12"></asp:TextBox>
                        </td>
                        <td nowrap="nowrap">
                            <asp:TextBox ID= "rbaRangeTo" runat = "server" Text="" Width="80px" size="12"></asp:TextBox>
                        </td>                       
                    </tr>  
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel"> Report Type:</div></td> 
                        <td colspan="2">
                            <asp:DropDownList ID="rptType" runat="server" Width="200px">
                                <asp:ListItem Value = "">Select</asp:ListItem>  
                                <asp:ListItem Value = "Summary Report-Monthly">Summary Report-Monthly</asp:ListItem>
                                <asp:ListItem Value = "Summary Report-Agent">Summary Report-Agent</asp:ListItem>
                                <asp:ListItem Value = "Summary Report-Branch">Summary Report-Branch</asp:ListItem>
                            </asp:DropDownList> 
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="rptType" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                        </td>
                    </tr>     
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel"> Receiver&#39;s Country:</div></td> 
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="rCountry" runat="server" 
                                style="width:200px;"></asp:DropDownList> 
                                   
                        </td>
                    </tr>
                    <tr>
                        <td><div align="left" class="formLabel">Txn to Non Native Country:</div></td>
                        <td>
                            <asp:DropDownList ID="txnToNonNativeCountry" runat="server">
                                <asp:ListItem Value="">All</asp:ListItem>
                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                <asp:ListItem Value="N">No</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td><b><u>Additional Filter</u></b></td>
                    </tr>
                    <tr>
                        <td>
                            <div align="left" class="formLabel">TXN Amount:</div>
                        </td>
                        <td>
                            <asp:TextBox ID= "txnAmountFrom" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID= "txnAmountTo" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td colspan="2">   
                                <asp:Button ID="BtnSave1" runat="server" CssClass="button" 
                                        Text=" Search " ValidationGroup="rpt" 
                                OnClientClick="return showReport();"  /> 
                        </td>
                    </tr>                     
                </table>
                </ContentTemplate>
                <Triggers> 
                    <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" /> 
                </Triggers> 
                </asp:UpdatePanel>
            </td>
        </tr>        
    </table>
    </form>
</body>
</html>
   <script language = "javascript" type = "text/javascript">
       function getRadioCheckedValue(radioName) {
           var oRadio = document.forms[0].elements[radioName];

           for (var i = 0; i < oRadio.length; i++) {
               if (oRadio[i].checked) {
                   return oRadio[i].value;
               }
           }
           return '';
       }

       function showReport() {
           if (!Page_ClientValidate('rpt'))
               return false;
           var reportFor = "TXN RBA-V2";
           var sCountry = $("#sCountry option:selected").text();
           var sAgent = GetValue("<% =sAgent.ClientID%>");
           var sBranch = GetValue("<% =sBranch.ClientID%>");
           var sNativeCountry = GetValue("<% =sNativeCountry.ClientID%>");
           var rCountry = GetValue("<% =rCountry.ClientID%>");

           var sIdNumber = GetValue("<% =sIdNumber.ClientID%>");
           var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var rbaRangeFrom = GetValue("<% =rbaRangeFrom.ClientID%>");
           var rbaRangeTo = GetValue("<% =rbaRangeTo.ClientID%>");
           var txnToNonNativeCountry = GetValue("<% =txnToNonNativeCountry.ClientID%>");
           var rptType = GetValue("<% =rptType.ClientID%>");
           var txnAmountFrom = GetValue("<% =txnAmountFrom.ClientID%>");
           var txnAmountTo = GetValue("<%=txnAmountTo.ClientID %>");
           var url = "../../SwiftSystem/Reports/Reports.aspx?reportName=rbareport" +
               "&sCountry=" + sCountry +
                "&reportFor=" + reportFor +
                   "&sAgent=" + sAgent +
                       "&sBranch=" + sBranch +
                           "&sNativeCountry=" + sNativeCountry +
                               "&rCountry=" + rCountry +
                                   "&sIdNumber=" + sIdNumber +
                                       "&fromDate=" + fromDate +
                                           "&toDate=" + toDate +
                                               "&rbaRangeFrom=" + rbaRangeFrom +
                                                   "&rbaRangeTo=" + rbaRangeTo +
                                                       "&txnToNonNativeCountry=" + txnToNonNativeCountry +
                                                           "&rptType=" + rptType +
                                                               "&txnAmountFrom=" + txnAmountFrom +
                                                                   "&txnAmountTo=" + txnAmountTo;

           OpenInNewWindow(url);
           return false;
       }
   </script>
    <script type='text/javascript' language='javascript'>
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
        function EndRequest(sender, args) {
            if (args.get_error() == undefined) {
                LoadCalendars();
            }
        }   
</script>
