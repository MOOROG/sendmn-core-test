<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAReportMex.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.RBAReportMex" %>

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
    <div class="breadCrumb"> Risk Base Analysis » Report</div>
    <asp:HiddenField ID="hdnIsAdvaceSearch" runat="server" Value="N"/>
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <table border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td height="10"> 
                <div class="tabs" > 
                    <ul> 
                        <li> <a href="RBAReport.aspx">Remittance</a></li>
                        <li> <a href="#" class="selected">Money Exchange</a></li>
                    </ul> 
                </div> 
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel ID="updatePanel1" runat="server">
                <ContentTemplate>
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" width="600px">
                    <tr>
                        <th class="frmTitle" colspan="3">Risk Base Analysis Report</th>
                    </tr>
                  
                    <tr>
                        <td class="formLabel"><div align="left" class="formLabel"> Report For:</div></td>
                        <td colspan="2">
                            <asp:RadioButtonList ID="reportFor" runat="server" 
                                RepeatDirection="Horizontal" AutoPostBack="true"
                                onselectedindexchanged="reportFor_SelectedIndexChanged">
                            <asp:ListItem Value="Txn RBA">Txn RBA</asp:ListItem>
                            <asp:ListItem Value="Txn Average RBA">Txn Average RBA</asp:ListItem>
                            <asp:ListItem Value="Periodic RBA">Periodic RBA</asp:ListItem>
                            <asp:ListItem Value="Final RBA" Selected="true">Final RBA</asp:ListItem>
                        </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr id="trSendingBranch" runat="server" Visible="false">
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Transacting Branch:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="sBranch" runat="server" 
                                style="width:200px;"></asp:DropDownList> 
                           
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Customer's Native Country:</div></td>                        
                        <td nowrap="nowrap">
                            <asp:DropDownList ID="sNativeCountry" runat="server" 
                                style="width:200px;"></asp:DropDownList> 
                           
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap"> <div align="left" class="formLabel">Customer's ID Number:</div></td>                        
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
                                <asp:ListItem Value = "Detail Report">Detail Report</asp:ListItem>
                                <asp:ListItem Value = "Summary Report-Monthly">Summary Report-Monthly</asp:ListItem>
                            </asp:DropDownList> 
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="rptType" ForeColor="Red" 
                                                            ValidationGroup="rpt" Display="Dynamic"  ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td><b><u>Additional Filter</u></b></td>
                    </tr>
                    <tr id="trTxnType" runat="server">
                        <td>
                            <div align="left" class="formLabel">TXN Type:</div>
                        </td>
                        <td>
                            <asp:RadioButtonList ID="txnType" runat="server" 
                                RepeatDirection="Horizontal">
                            <asp:ListItem Value="p" Selected="true">Buy</asp:ListItem>
                            <asp:ListItem Value="s">Sell</asp:ListItem>
                        </asp:RadioButtonList>
                        </td>
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
                    <tr id="trTxnCount" runat="server">
                        <td>
                            <div align="left" class="formLabel">TXN Count:</div>
                        </td>
                        <td>
                            <asp:TextBox ID= "txnCountFrom" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID= "txnCountTo" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                    </tr>
                    <tr id="trCurrencyCount" runat="server">
                        <td>
                            <div align="left" class="formLabel">Currency Count:</div>
                        </td>
                        <td>
                            <asp:TextBox ID= "currencyCountFrom" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID= "currencyCountTo" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                    </tr>
                    <tr id="trOutletCount" runat="server">
                        <td>
                            <div align="left" class="formLabel">Outlet Count:</div>
                        </td>
                        <td>
                            <asp:TextBox ID= "outletCountFrom" runat = "server" Width="80px" size="12"></asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID= "outletCountTo" runat = "server" Width="80px" size="12"></asp:TextBox>
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
                    <asp:AsyncPostBackTrigger ControlID="reportFor" EventName="SelectedIndexChanged"/>
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

           var reportFor = getRadioCheckedValue("<%=reportFor.ClientID %>");
           var sBranch = GetValue("<% =sBranch.ClientID%>");
           var sNativeCountry = GetValue("<% =sNativeCountry.ClientID%>");

           var sIdNumber = GetValue("<% =sIdNumber.ClientID%>");
           var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var rbaRangeFrom = GetValue("<% =rbaRangeFrom.ClientID%>");
           var rbaRangeTo = GetValue("<% =rbaRangeTo.ClientID%>");
           var rptType = GetValue("<% =rptType.ClientID%>");

           var txnType = getRadioCheckedValue("<%=txnType.ClientID %>");
           var txnAmountFrom = GetValue("<% =txnAmountFrom.ClientID%>");
           var txnAmountTo = GetValue("<%=txnAmountTo.ClientID %>");
           var txnCountFrom = GetValue("<%=txnCountFrom.ClientID %>");
           var txnCountTo = GetValue("<%=txnCountTo.ClientID %>");
           var currencyCountFrom = GetValue("<%=currencyCountFrom.ClientID %>");
           var currencyCountTo = GetValue("<%=currencyCountTo.ClientID %>");
           var outletCountFrom = GetValue("<%=outletCountFrom.ClientID %>");
           var outletCountTo = GetValue("<%=outletCountTo.ClientID %>");

           var url = "../../ExchangeSystem/ReportDisplay.aspx?reportName=rbareportmex" +
            "&reportFor=" + reportFor +
            "&sBranch=" + sBranch +
            "&sNativeCountry=" + sNativeCountry +
            "&sIdNumber=" + sIdNumber +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&rbaRangeFrom=" + rbaRangeFrom +
            "&rbaRangeTo=" + rbaRangeTo +
            "&rptType=" + rptType +
            "&txnType=" + txnType +
            "&txnAmountFrom=" + txnAmountFrom +
            "&txnAmountTo=" + txnAmountTo +
            "&txnCountFrom=" + txnCountFrom +
            "&txnCountTo=" + txnCountTo +
            "&currencyCountFrom=" + currencyCountFrom +
            "&currencyCountTo=" + currencyCountTo +
            "&outletCountFrom=" + outletCountFrom +
            "&outletCountTo=" + outletCountTo;

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
