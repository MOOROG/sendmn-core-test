<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.ReceivingLimit.Manage" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
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
        <asp:ScriptManager ID="ScriptManager2" runat="server">
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
                            <li>Receiving Limit</li>
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
                            <h4 class="panel-title">Receiving Limit Details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Sending Country:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="sendingCountry" runat="server" CssClass="form-control"></asp:DropDownList> 
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Receiving Mode:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="receivingMode" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Max Limit:<span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red" 
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>  
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Max Limit for all Agent:<span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="agMaxLimitAmt" ForeColor="Red" 
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="agMaxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Currency:<span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red" 
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Customer Type:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="customerType" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Branch Selection:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="branchSelection" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Not Required">Not Required</asp:ListItem>
                                        <asp:ListItem Value="Manual Type">Manual Type</asp:ListItem>
                                        <asp:ListItem Value="Select">Select</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Beneficiary Id Required:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="benificiaryIdreq" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="H">Hide</asp:ListItem>
                                        <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                        <asp:ListItem Value="O">Optional</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Relationship Required:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:DropDownList ID="relationshipReq" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="H">Hide</asp:ListItem>
                                        <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                        <asp:ListItem Value="O">Optional</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Beneficiary Contact Required:
                                </label>
                                <div class="col-lg-8 col-md-8">
                                     <asp:DropDownList ID="benificiaryContactReq" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="H">Hide</asp:ListItem>
                                        <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                        <asp:ListItem Value="O">Optional</asp:ListItem>
                                    </asp:DropDownList>  
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-12 col-md-12">
                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country" 
                                                        CssClass="btn btn-primary" onclick="btnSave_Click" />
                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                    </cc1:ConfirmButtonExtender>&nbsp;
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger" 
                                                onclick="btnDelete_Click" />
                                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                    </cc1:ConfirmButtonExtender> &nbsp; 
                                    <input id="btnBack" type="button" value="Back" class="btn btn-primary" onClick=" Javascript: history.back(); " /> 
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
