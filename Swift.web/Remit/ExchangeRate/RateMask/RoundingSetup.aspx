<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoundingSetup.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.RateMask.RoundingSetup" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../../js/functions.js" type="text/javascript"> </script>
     <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <style>
            .page-title 
            {
               
                border-bottom: 2px solid #f5f5f5;
                margin-bottom: 15px;
                padding-bottom: 10px;
                text-transform: capitalize;
            }
              .page-title h1{
            color: #656565;
            font-size: 20px;
            text-transform: uppercase;
            font-weight: 400;
        }
            .page-title .breadcrumb 
            {
                 
                background-color: transparent;
                margin: 0;
                padding: 0;
            }
            .breadcrumb > li {
                display: inline-block;
            }
            .breadcrumb > li a
            {
                color:#0E96EC;
            }
            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }
            .tabs > li > a 
            {
                padding: 10px 15px;
                background-color: #444d58;
                border-radius: 5px 5px 0 0;
                color: #fff;
            }
        </style>
        <script type="text/javascript">
            var gridName = "<% =GridName%>";

            function GridCallBack() {
                var id = GetRowId(gridName);

                if (id != "") {
                    GetElement("<% =btnEdit.ClientID%>").click();
                    GetElement("<% =btnSave.ClientID%>").disabled = false;
                } else {
                    GetElement("<% =btnSave.ClientID%>").disabled = true;
                    ResetForm();
                    ClearAll(gridName);
                }
            }

            function ResetForm() {
                SetValueById("<% =tranType.ClientID%>", "");
                SetValueById("<% =place.ClientID%>", "");
                SetValueById("<% =cDecimal.ClientID%>", "");
            }

            function NewRecord() {
                ResetForm();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
                SetValueById("<% =countryCurrencyId.ClientID%>", "0");
                ClearAll(gridName);
            }
        </script>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0 " style="padding: 50px;"">
        <tr>
            <td>
                 <div class="page-title">
            <h1>Rate Setup<small></small></h1>
            <ol class="breadcrumb">
                <li><a href="#"><i class="fa fa-home"></i></a></li>
                <li><a href="#">Remittance</a></li>
                    <li><a href="#">Exchange Rate</a></li>
                    <li class="active"><a href="#">Agent Exchange Rate Menu >> View Rounding Setup</a></li>
                  
            </ol>
        </div>
            </td>
            
        </tr>
        <tr>
            <td valign="top">
                <asp:UpdatePanel ID="upnl1" runat="server">
                    <ContentTemplate>
                        <table border="0" cellspacing="0" cellpadding="0" width="100%" style="padding: 50px; background-color:#F2F2F2;" >
                            <tr>
                                <th colspan="2" class="frmTitle">Currency Rounding Setup</th>
                            </tr>
                            <tr>
                                <td align="left" nowrap="nowrap"><label>Currency Code :</label></td>
                                <td><%=GetCurrencyCode() %></td>
                            </tr>
                            <tr>
                                <td align="left" nowrap="nowrap" ><label>Tran Type :</label></td>
                                <td><asp:DropDownList ID="tranType" runat="server" Width="130px" CssClass="form-control"></asp:DropDownList></td>
                            </tr>
                            <tr>
                                <td align="left" nowrap="nowrap"><label>Placing :</label></td>
                                <td>                                    
                                    <asp:DropDownList ID="place" runat="server" AutoPostBack="True" CssClass="form-control"
                                        onselectedindexchanged="place_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" nowrap="nowrap"><label>Decimal :</label></td>
                                <td>
                                    <asp:TextBox ID="cDecimal" runat="server" Text="0" Width="100px" MaxLength="4" CssClass="form-control"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td nowrap="nowrap">
                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="button" ValidationGroup="currency"
                                                onclick="btnSave_Click" />&nbsp;
                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="button" style="display: none;"
                                                onclick="btnEdit_Click"  />&nbsp;
                                    <input type = "button" value = "New" onclick = " NewRecord(); " class = "button" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <div id="rpt_grid" runat="server"></div>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td nowrap="nowrap"> 
                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                               ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                    </cc1:ConfirmButtonExtender> 
                                    <asp:HiddenField ID="countryCurrencyId" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
