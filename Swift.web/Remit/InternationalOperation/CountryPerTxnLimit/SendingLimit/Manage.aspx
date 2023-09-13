<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.SendingLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Credit Risk Management </li>
                            <li>Transaction Limit  </li>
                            <li>Country Wise</li>
                            <li>Sending Limit</li>
                            <li class="active">Manage  </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-7">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Sending Limit Details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <fieldset>
                                <legend>Sending Limit(Country Wise)</legend>
                                <div class="form-group">
                                     <label class="col-lg-4 col-md-4 control-label" for="">
                                        <span id="spnCname" runat="server"><%=GetCountryName()%></span>
                                     </label>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Receiving Country : <span class="ErrMsg">*</span>
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:DropDownList ID="receivingCountry" runat="server" AutoPostBack="true"
                                            CssClass="form-control" OnSelectedIndexChanged="receivingCountry_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="receivingCountry" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Collection Mode : 
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:DropDownList ID="collMode" runat="server" CssClass="form-control"></asp:DropDownList>

                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Receiving Mode : 
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:DropDownList ID="receivingMode" runat="server" CssClass="form-control"></asp:DropDownList>

                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Min Per Trn. Limit: <span class="ErrMsg">*</span>
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:TextBox ID="minLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="minLimitAmt" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Max Per Trn. Limit : <span class="ErrMsg">*</span>
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Currency: <span class="ErrMsg">*</span>
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                        Customer Type : <span class="ErrMsg">*</span>
                                    </label>
                                    <div class="col-lg-8 col-md-8">
                                        <asp:DropDownList ID="customerType" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-10 col-md-offset-4">
                                        <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                            CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                        </cc1:ConfirmButtonExtender>
                                        <asp:Button ID="btnApplyForAllCountry" runat="server"
                                            Text="Apply For All Country" ValidationGroup="country" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnApplyForAllCountry_Click" />
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnDelete_Click" />
                                        <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                            ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                        </cc1:ConfirmButtonExtender>
                                        <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>


<%--  <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Credit Risk Management » Transaction Limit » Country Wise » Sending Limit » Manage </div> </td>
                        </tr>
                        <tr>
                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetCountryName()%></span></td>
                        </tr>--%>
<%--<tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul> 
                                        <li> <a href="../List.aspx">Country Wise </a></li>
                                        <li> <a href="List.aspx" >Collection Limit</a></li>
                                        <li> <a href="../ReceivingLimit/List.aspx?countryId=<%=GetCountryId()%>">Payment Limit</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Manage</a></li>
                                    </ul> 
                                </div>		
                            </td>
                        </tr>--%>
<%--      </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top" >       
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                    <tr>
                        <th colspan="2" class="frmTitle">Sending Limit Details</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <fieldset>
                                <legend>Sending Limit(Country Wise)</legend>
                                <table>
                                  
                                    <tr>
                                        <td class="frmLable">
                                            Receiving Country
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="receivingCountry" runat="server" Width="153px" AutoPostBack="true"
                                                CssClass="input" onselectedindexchanged="receivingCountry_SelectedIndexChanged"></asp:DropDownList> 
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="receivingCountry" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>--%>
<%--<td class="frmLable">Collection Mode</td>
                                        <td>
                                            <asp:DropDownList ID="collMode" runat="server" Width="153px" CssClass="input"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">
                                            Receiving Mode
                                        </td>
                                        <td>--%>
<%--     <asp:DropDownList ID="receivingMode" runat="server" Width="153px" CssClass="input"></asp:DropDownList> 
                                        </td>
                                    </tr>
                                    <tr>--%>
<%-- <td class="frmLable">
                                            Min Per Trn. Limit
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td nowrap="nowrap">
                                             <asp:TextBox ID="minLimitAmt" runat="server"></asp:TextBox>  
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="minLimitAmt" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>

                                     <tr>--%>
<%--   <td class="frmLable">
                                            Max Per Trn. Limit
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td nowrap="nowrap">
                                        <asp:TextBox ID="maxLimitAmt" runat="server"></asp:TextBox>  
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                           
                                        </td>
                                    </tr>
                                    <tr>--%>
<%--<td class="frmLable">
                                            Currency
                                            <span class="ErrMsg">*</span>
                                        </td>
                                        <td nowrap="nowrap">
                                            <asp:DropDownList ID="currency" runat="server" Width="153px"></asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red" 
                                                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>--%>
<%--  <td class="frmLable">Customer Type</td>
                                        <td>
                                            <asp:DropDownList ID="customerType" runat="server" Width="153px"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>--%>
<%--                  <td>
                                            <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country" 
                                                        CssClass="button" onclick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>&nbsp;
                                            <asp:Button ID="btnApplyForAllCountry" runat="server" 
                                                Text="Apply For All Country" ValidationGroup="country" CssClass="button" 
                                                onclick="btnApplyForAllCountry_Click" />
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" 
                                                        onclick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                       ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender> &nbsp; 
                                            <input id="btnBack" type="button" value="Back" class="button" onClick=" Javascript:history.back(); " />
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
   