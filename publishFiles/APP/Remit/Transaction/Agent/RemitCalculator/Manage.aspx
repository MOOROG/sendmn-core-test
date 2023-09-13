<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.RemitCalculator.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />

    <script src="../../../../js/functions.js"></script>
    <script src="../../../../js/Swift_grid.js"></script>
    <script src="../../../../js/menucontrol.js"></script>
    <style>
        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Other Services</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Remittance Calculator</a></li>
                            <li class="active"><a href="Manage.aspx">Calculate</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row panels">
                <div class="col-sm-8 form-inline">
                    <label><span class="errormsg">*</span> Fields are mandatory</label>
                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                </div>

            </div>


            <div class="row panels">
                <div class="col-sm-2">
                    <label>Collection Currency: <span class="errormsg">*</span></label>
                </div>
                <div class="col-sm-4">
                    <asp:DropDownList ID="collCurrency" runat="server" CssClass="input form-control"
                        AutoPostBack="True" OnSelectedIndexChanged="sendCurrency_SelectedIndexChanged">
                    </asp:DropDownList>

                    <asp:RequiredFieldValidator ID="rv1" runat="server"
                        ControlToValidate="collCurrency" Display="Dynamic" ErrorMessage="Required"
                        ForeColor="Red" SetFocusOnError="True" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>

                </div>
                <div class="col-sm-2">
                    <label>Tran Type: <span class="errormsg">*</span></label></div>
                <div class="col-sm-4">
                    <asp:DropDownList ID="txnType" runat="server" CssClass="input form-control">
                    </asp:DropDownList>

                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                        ControlToValidate="txnType" Display="Dynamic" ErrorMessage="Required!"
                        ForeColor="Red" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="row panels">
                <div class="col-sm-2">
                    <label>Payment Country:  <span class="errormsg">*</span></label></div>
                <div class="col-sm-4">
                    <asp:DropDownList ID="payCountry" runat="server" CssClass="input form-control"
                        AutoPostBack="True" OnSelectedIndexChanged="payCountry_SelectedIndexChanged">
                    </asp:DropDownList>

                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                        ControlToValidate="payCountry" Display="Dynamic" ErrorMessage="Required!"
                        ForeColor="Red" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>
                </div>
                <div class="col-sm-2">
                    <label>Payment Currency: <span class="errormsg">*</span></label></div>
                <div class="col-sm-4">
                    <asp:DropDownList ID="payCurrency" runat="server" CssClass="input form-control">
                    </asp:DropDownList>

                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                        ControlToValidate="payCurrency" Display="Dynamic" ErrorMessage="Required!"
                        ForeColor="Red" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="row panels">
                <div class="col-sm-2">
                    <label>Amount To Send: <span class="errormsg">*</span></label></div>
                <div class="col-sm-4">
                    <asp:TextBox ID="amount" runat="server" CssClass="input form-control" AutoPostBack="True"
                        OnTextChanged="amount_TextChanged"></asp:TextBox>

                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
                        ControlToValidate="amount" Display="Dynamic" ErrorMessage="Required!"
                        ForeColor="Red" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>
                </div>
                <div class="col-sm-2">
                    <label>Amount To Receive: <span class="errormsg">*</span></label></div>
                <div class="col-sm-4">
                    <asp:TextBox ID="amountRec" runat="server" CssClass="input form-control" AutoPostBack="True"
                        OnTextChanged="amountRec_TextChanged"></asp:TextBox>

                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
                        ControlToValidate="amountRec" Display="Dynamic" ErrorMessage="Required!"
                        ForeColor="Red" ValidationGroup="cal">
                    </asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="row panels">
                <div class="col-sm-2"></div>

                <div class="col-sm-4">
                    <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary"
                        OnClick="btnSave_Click" Text="Calculate" ValidationGroup="cal" />
                </div>
            </div>


            <div id="result" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <label>Result</label>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-sm-2">
                                <label>Collection Currency :</label></div>
                            <div class="col-sm-4">
                                <asp:Label ID="cCurrency" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Payment Country :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="pCountry" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Payment Currency :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="pCurrency" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Tran Type :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="tranType" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Rate :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="rate" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-2">Amount To Send :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="amountToSend" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Amount To Receive :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="amountToReceive" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-2">Fee :</div>
                            <div class="col-sm-4">
                                <asp:Label ID="fee" runat="server"></asp:Label>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>
