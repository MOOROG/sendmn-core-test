<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.AddCutomer_sReceiver.Manage" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <link href="../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <script src="../../js/swift_autocomplete.js"></script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../js/jQuery/jquery-ui.min.js"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfdReceiverId" Value=" " runat="server" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li class="active"><a href="List.aspx">Add New Customer's Receiver</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Add New Customer's Receiver 
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group ">
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Choose Customer:<span class="errormsg">*</span></label>
                                    <div class="col-md-6 ">
                                        <uc1:SwiftTextBox ID="customerId" runat="server" Category="remit-customer" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Full Name:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="rFirstName" runat="server" name="rFirstName" CssClass="form-control" CausesValidation="True"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ForeColor="Red" ErrorMessage="Required!" ControlToValidate="rFirstName" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6  ">
                                    <label class="col-md-4 control-label">Country:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">

                                        <asp:DropDownList ID="receiveCountry" runat="server" AutoPostBack="true"
                                            CssClass="form-control" OnSelectedIndexChanged="receiveCountry_SelectedIndexChanged" CausesValidation="True">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator6" runat="server" ErrorMessage="Required!" ControlToValidate="receiveCountry" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">State:<span class="errormsg">*</span></label>
                                    <asp:UpdatePanel ID="Update_State" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <div class="col-md-6">
                                                <asp:DropDownList runat="server" ID="rState" CssClass="form-control" CausesValidation="True">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-2">
                                                <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator8" runat="server" ErrorMessage="Required!" ControlToValidate="rState" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                            </div>
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="receiveCountry" EventName="SelectedIndexChanged" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                    <span class="mandatory"></span>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">City:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="rCity" runat="server" name="rCity" CssClass="form-control" CausesValidation="True"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator3" runat="server" ErrorMessage="Required!" ControlToValidate="rCity" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Address:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="RAddress" runat="server" name="RAddress" CssClass="form-control" CausesValidation="True"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator7" runat="server" ErrorMessage="Required!" ControlToValidate="RAddress" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Relation:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:DropDownList ID="receiverrelation" runat="server" name="receiverrelation" CssClass="form-control" CausesValidation="True">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator4" runat="server" ErrorMessage="Required!" ControlToValidate="receiverrelation" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Telephone No:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="rTelephone" runat="server" name="rTelephone" CssClass="form-control" CausesValidation="True"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">Mobile No:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="receiverMobile" runat="server" name="receiverMobile"
                                            CssClass="form-control" ControlToValidate="receiverMobile" ValidationGroup="Receiver" CausesValidation="True"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <asp:RequiredFieldValidator ForeColor="Red" ID="RequiredFieldValidator5" runat="server" ErrorMessage="Required!" ControlToValidate="receiverMobile" ValidationGroup="Receiver"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="col-md-4 control-label">E-Mail:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox ID="receiverEmail" runat="server" CssClass="email form-control" name="receiverEmail" CausesValidation="True"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-10" style="margin-left: 30px">
                                        <p style="font-size: 14px; color: #666">
                                            <strong class="errormsg">Note: </strong><b>Mobile No. should match International Telephone Format. eg for nepal : 9779851012345,where</b>
                                            <strong>977</strong> is country code and <strong>9851012345</strong> <b>is mobileno.
                                            Avoid "0" or "+" before county code in receiver mobile no.</b>
                                        </p>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label"></label>
                                <div class="col-md-6">
                                    <asp:Button ID="back" runat="server" Text="Back" CssClass="btn btn-primary m-t-25" OnClick="back_Click" />
                                    <asp:Button ID="save" runat="server" ValidationGroup="Receiver" Text="Save" CssClass="btn btn-primary m-t-25" OnClick="save_Click" />
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
