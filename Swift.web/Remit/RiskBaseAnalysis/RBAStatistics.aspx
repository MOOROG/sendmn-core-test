<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAStatistics.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.RBAStatistics" %>
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
                        <li> <a href="RBATxnRpt.aspx">RBA TXN Report</a></li>
                        <li> <a href="#" class="selected">RBA Statistics</a></li>
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
                        <th class="frmTitle" colspan="3">RBA Statistics</th>
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
                        <td>&nbsp;</td>
                        <td colspan="2">   
                                <asp:Button ID="BtnSave1" runat="server" CssClass="button" 
                                        Text=" Search " ValidationGroup="rpt" 
                                OnClientClick="return showReport();"  /> 
                        </td>
                    </tr>                   
                </table>
                </ContentTemplate>
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
   		var reportFor = "STAT-RBA-V2";
   		var sCountry = $("#sCountry option:selected").text();
   		var sAgent = GetValue("<% =sAgent.ClientID%>");
   		var sBranch = GetValue("<% =sBranch.ClientID%>");
   		var fromDate = GetDateValue("<% =fromDate.ClientID%>");
   		var toDate = GetDateValue("<% =toDate.ClientID%>");
   		var url = "../../SwiftSystem/Reports/Reports.aspx?reportName=rbareport" +
               "&sCountry=" + sCountry +
                "&reportFor=" + reportFor +
                   "&sAgent=" + sAgent +
                       "&sBranch=" + sBranch +
							"&fromDate=" + fromDate +
								"&toDate=" + toDate;

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
