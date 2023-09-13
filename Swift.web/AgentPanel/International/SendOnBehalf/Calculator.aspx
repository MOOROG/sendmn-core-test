<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Calculator.aspx.cs" Inherits="Swift.web.AgentPanel.International.SendOnBehalf.Calculator" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>

    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../js/functions.js"></script>

    <script type="text/javascript">
        function ClearTxnData() {
            $("#<%=pAgent.ClientID %>").empty();
            $("#<%=pMode.ClientID %>").empty();

            $("#txtpBranch_aValue").val("");
            $("#txtpBranch_aText").val("");
            $("#txtCollAmt").val(0);
            $('#txtCollAmt').attr("readonly", false);
            $("#txtPayAmt").val(0);
            $('#txtPayAmt').attr("readonly", false);
            $("#lblSendAmt").text('0.00');
            $("#lblServiceChargeAmt").text('0.00');
            $("#lblExRate").text('0.00');

            $("#lblPayCurr").text('');
            SetValueById("<%=pCountry.ClientID %>", "", "");
        }

        function CallBack() {
            var collAmt = $("#txtCollAmt").val();
            if (collAmt == "" || collAmt == undefined || collAmt == null) {
                alert("Collection amount cannot be empty to proceed for send");
                return;
            }
            window.returnValue = collAmt;
            window.opener.PostMessageToParentNewFromCalculator(window.returnValue);
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="Container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Agent Panel</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Transaction </a></li>
                            <li class="active"><a href="Calculator.aspx">International Send</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Calculator
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upnl1" runat="server">
                                <ContentTemplate>
                                    <div>
                                        <div class="rowConatainer">
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td>Payout Country:</td>
                                                    <td>
                                                        <asp:DropDownList CssClass="form-control" ID="pCountry" runat="server" AutoPostBack="true" OnSelectedIndexChanged="pCountry_SelectedIndexChanged"></asp:DropDownList>
                                                        <span class="errormsg" id='pCountry_err'>*</span>
                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="pCountry" ValidationGroup="cal" ErrorMessage="Required!" ForeColor="Red"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Pay Mode:</td>
                                                    <td>
                                                        <asp:DropDownList ID="pMode" runat="server" AutoPostBack="true" OnSelectedIndexChanged="pMode_SelectedIndexChanged" CssClass="form-control"></asp:DropDownList>
                                                        <span class="ErrMsg" id='pMode_err'>*</span>
                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator2" ControlToValidate="pMode"
                                                            ValidationGroup="cal" ErrorMessage="Required!" ForeColor="Red">
                                                        </asp:RequiredFieldValidator>
                                                        <span id="hdnreqAgent" style="display: none"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Agent / Bank:</td>
                                                    <td>
                                                        <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        <span class="ErrMsg" id="pAgent_err" style="display: none">*</span>
                                                        <span id="hdnreqAgent" style="display: none"></span>
                                                    </td>
                                                </tr>
                                                <tr align="center">
                                                    <td colspan="4" class="frmTitle">
                                                        <asp:RadioButton ID="bySendAmt" runat="server" GroupName="Mode" AutoPostBack="true" Text="Calculate By Sending Amount" OnCheckedChanged="bySendAmt_CheckedChanged" />
                                                        <asp:RadioButton ID="byPayOutAmt" runat="server" GroupName="Mode" AutoPostBack="true" Text="Calculate By Receiving Amount" OnCheckedChanged="byPayOutAmt_CheckedChanged" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Collection Amount:</td>
                                                    <td>
                                                        <asp:TextBox ID="txtCollAmt" runat="server" Width="150px" Enabled="false" CssClass="form-control"></asp:TextBox>
                                                        <span class="ErrMsg" id='cAmt_err'>*</span>
                                                        <asp:Label ID="lblCollCurr" runat="server" Text="MYR"></asp:Label>
                                                    </td>
                                                    <td>Sending Amount:</td>
                                                    <td>
                                                        <asp:Label ID="lblSendAmt" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                                        <asp:Label ID="lblSendCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                                    </td>
                                                </tr>

                                                <tr>
                                                    <td>Service Charge:</td>
                                                    <td>
                                                        <asp:Label ID="lblServiceChargeAmt" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                                        <asp:Label ID="lblServiceChargeCurr" runat="server" Text="MYR" class="amountLabel"></asp:Label>
                                                    </td>
                                                    <td>&nbsp;</td>
                                                    <td>&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td>Customer Rate:</td>
                                                    <td>
                                                        <asp:Label ID="lblExRate" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                                        <asp:Label ID="lblExCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                                    </td>
                                                </tr>

                                                <tr>
                                                    <td>Payout Amount:</td>
                                                    <td>
                                                        <asp:TextBox ID="txtPayAmt" Width="150px" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                                                        <span class="ErrMsg" id='Span1'>*</span>
                                                        <asp:Label ID="lblPayCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>&nbsp;</td>
                                                    <td>
                                                        <asp:Button runat="server" ID="btnCalculate" CssClass="btn btn-primary m-t-25" Text="Calculate" OnClick="btnCalculate_Click" ValidationGroup="cal" />
                                                        <input type="button" id="btnCalcClean" class="btn btn-primary m-t-25" onclick="ClearTxnData()" value="Clear" />&nbsp;
                                                        <input type="button" style="display: none" id="btnProceed" onclick="CallBack()" class="btn btn-primary m-t-25" value="Proceed Send" />
                                                        <span id="finalSenderId" style="display: none"></span>
                                                        <span id="finalBenId" style="display: none"></span>
                                                        <input type="hidden" id="finalAgentId" />
                                                        <input type="hidden" id="txtCustomerLimit" value="0" />
                                                        <input type="hidden" id="hdnInvoicePrintMethod" />
                                                        <asp:Label ID="lblErr" runat="server" Text="" CssClass="amountLabel"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr style="display: none;">
                                                    <td colspan="4" style="background-color: #666666;">
                                                        <div align="center">
                                                            <span id="span_txnInfo" align="center" runat="server" style="font-size: 13px; color: #FFFF00; line-height: 22px; vertical-align: middle; text-align: center; font-weight: bold;">NOTE : This calculation is assumption of CASH PAYMENT only, whereas BANK A/C
                                                              DEPOSIT might vary depending upon the payout bank, please check the detail charges
                                                              in transaction detail windows
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td>&nbsp;</td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </ContentTemplate>
                                <Triggers>
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>