<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Pay.aspx.cs" Inherits="Swift.web.Remit.Transaction.ThirdPartyTXN.Pay.Pay" %>

<%@ Register Src="../../../../Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">

        $.validator.messages.required = "Required!"; 
        
    </script>
    <style type="text/css">
        label.error, .msg
        {
            color: red;
            float: none;
            font: bold 10px 'Verdana'; /* padding: 2px;
            text-align: left; /*vertical-align: top;*/
        }
        
        form input.error, form input.error:hover, form input.error:focus, form select.error, form textarea.error
        {
            background: #FFD9D9;
            border-style: solid;
            border-width: 1px;
        }
        .grayBg
        {
            background: #D3D3D3;
        }
        
        .HeighlightText
        {
            font-size: 20px;
            font-weight: bold;
            color: #004D20;
            padding: 2px;
        }
        
        legend
        {
            color: #FFFFFF;
            background: #FF0000;
            padding: 5px;
            border-radius: 2px;
        }
        
        fieldset
        {
            border: 1px solid #000000;
        }
        
        td
        {
            color: #000000;
        }
        table
        {
            padding: 5px;
        }
        .watermark
        {
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div id="DivLoad" style="position: absolute; height: 20px; width: 220px; background-color: #333333;
        display: none; left: 185px; top: 135px;">
        <img src="../../../../images/progressBar.gif" border="0" alt="Loading..." />
    </div>
    <form id="form1" runat="server">
    <div id="top" class="breadCrumb">
        Pay Money » Third Party Payment -V2</div>
    <div id="agentNameDiv" class="headers" runat="server">
        <asp:Label ID="lblAgentName" runat="server"></asp:Label></div>
    <div>
        <asp:HiddenField ID="hddCeTxn" runat="server" />
        <asp:HiddenField ID="hddRowId" runat="server" />
        <asp:HiddenField ID="hddControlNo" runat="server" />
        <asp:HiddenField ID="hddTokenId" runat="server" />
        <asp:HiddenField ID="hddSCountry" runat="server" />
        <asp:HiddenField ID="hddPayAmt" runat="server" />
        <asp:HiddenField ID="hddAgentName" runat="server" />
        <asp:HiddenField ID="hddOrderNo" runat="server" />
        <asp:HiddenField ID="hddRCurrency" runat="server" />
        <asp:HiddenField ID="hdnMapCode" runat="server" />
        <table id="tblSearch" style="margin-left: 20px; width: 400px;" runat="server">
            <tr>
                <td>
                    <fieldset>
                        <legend>Search By</legend>
                        <table>
                            <tr>
                                <td>
                                    <b>Agent:</b>
                                </td>
                                <td>
                                    <uc1:SwiftTextBox ID="agentName" runat="server" Width="400px" Category="agent" CssClass="required" />
                                </td>

                            </tr>
                            <tr>
                                <td>
                                    <b>Partner:</b>
                                </td>
                                <td>
                                    <asp:DropDownList runat="server" ID="partner" Width="208px">
                                        <asp:ListItem Text="Global Remit" Value="4734"></asp:ListItem>
                                        <asp:ListItem Text="Cash Express" Value="4670"></asp:ListItem>
                                        <asp:ListItem Text="EZ Remit" Value="4726"></asp:ListItem>
                                        <asp:ListItem Text="RIA Remit" Value="4869"></asp:ListItem>
                                        <asp:ListItem Text="MoneyGram" Value="4854"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    <b>Pin No:</b>
                                </td>
                                <td>
                                    <asp:TextBox MaxLength="16" Width="200px" CssClass="required" ID="controlNo" runat="server" ></asp:TextBox><span
                                        class="ErrMsg">*</span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                                <td>
                                    <asp:Button ID="btnGo" runat="server" Text="GO" 
                                        CssClass="button" OnClientClick="return DoSearch();" OnClick="btnGo_Click" />                                        
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
        </table>
        <div>
            <div id="dvContent" runat="server">
            </div>
        </div>
        <br />
        <div id="dvReceiver" runat="server" visible="false">
           <table id="Table1" style="margin-left: 17px;" runat="server">
                <tr>
                    <td>
                        <fieldset>
                            <legend>Payment Information</legend>
                            <table border="0" cellpadding="0" cellspacing="0" width="812px">
                                <tr>
                                    <td nowrap="nowrap">
                                        Receiver ID Type: <span class="ErrMsg">*</span><br />
                                        <asp:DropDownList ID="rIdType" runat="server" CssClass="required" Width="135px">
                                        </asp:DropDownList>
                                    </td>
                                    <td nowrap="nowrap">
                                        Receiver ID Number: <span class="ErrMsg">*</span>
                                        <br />
                                        <asp:TextBox Width="150px" ID="rIdNumber" CssClass="required" runat="server"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>

                                <tr>
                                    <td nowrap="nowrap">
                                        Place Of Issue (District)<span class="errormsg">*</span>
                                        <br />
                                        <asp:DropDownList ID="rIdPlaceOfIssue" runat="server" CssClass="required" Width="135px">
                                        </asp:DropDownList>
                                    </td>
                                    <td nowrap="nowrap">
                                        Contact No.: <span class="ErrMsg">*</span>
                                        <br />
                                        <asp:TextBox Width="150px" ID="rContactNo" CssClass="required" runat="server"></asp:TextBox>
                                    </td>
                                    <td nowrap="nowrap">
                                        Parent/Spouse:<span class="errormsg">*</span>
                                        <br />
                                        <asp:DropDownList ID="relationType" runat="server" Width="135px" CssClass="required">
                                        </asp:DropDownList>
                                    </td>
                                    <td nowrap="nowrap">
                                        Parent/Spouse Name: <span class="ErrMsg">*</span>
                                        <br />
                                        <asp:TextBox Width="150px" ID="relativeName" runat="server" CssClass="required"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr><td>&nbsp;</td></tr>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                   
                                    <td colspan="3">
                                        <asp:Button ID="btnPay" runat="server" CssClass="button" OnClientClick="return ConfirmPay();"
                                            Text="Pay transaction" OnClick="btnPay_Click" />
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    </form>
</body>
</html>

<script language="javascript" type="text/javascript">
    function ConfirmPay() {
        if (!confirm("Are you sure to pay this Transaction?"))
            return false;
        $("#form1").validate();
        return true;

    }

    function DoSearch() {
        $("#form1").validate().cancelSubmit = true;
        if ($("#<% = controlNo.ClientID %>").val() == "")
            return false;
        var agentId = GetItem("<% = agentName.ClientID %>")[0]
        if (agentId == '' || agentId == undefined) {
            alert('Please choose Agent');
            return false;
        }
        $("#DivLoad").show();
        return true;
    }
</script>
