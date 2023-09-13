<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Calculator.aspx.cs" Inherits="Swift.web.AgentPanel.International.Calculator.Calculator" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="/js/functions.js"></script>

    <script type="text/javascript">
		function ClearTxnData() {
			ClearAllAmountFields();
			$("#txtpBranch_aValue").val("");
			$("#txtpBranch_aText").val("");
			$("#<%=txtCollAmt.ClientID%>").attr("readonly", false);
			$("#<%=txtPayAmt.ClientID%>").attr("readonly", false);
			$("#<%=lblServiceChargeAmt.ClientID%>").val('');
			SetValueById("<%=pCountry.ClientID %>", "", "");
		}
		function ClearAllAmountFields() {
			$("#<%=txtCollAmt.ClientID%>").val('');
			$("#<%=txtPayAmt.ClientID%>").val('');
			$("#<%=lblSendAmt.ClientID%>").val('');
			$("#<%=lblServiceChargeAmt.ClientID%>").val('');
			$("#<%=lblExRate.ClientID%>").val('');
			$("#<%=pAgent.ClientID %>").empty();
			$("#<%=pMode.ClientID %>").empty();
			$("#<%=lblExCurr.ClientID%>").text('');
			$("#<%=lblPayCurr.ClientID%>").text('');
			$("#<%=lblExCurr.ClientID%>").val('');
			$("#<%=lblPayCurr.ClientID%>").val('');
		}
		function CheckValidaion() {
			var reqField = "<%=pCountry.ClientID%>,<%=pMode.ClientID%>,";
			if (ValidRequiredField(reqField) === false) {
				return false;
			}
			return true;
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
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>
                                                Country:   <span class="errormsg" id='pCountry_err'>*</span>
                                            </label>
                                        </div>
                                        <div class="col-sm-4">
                                            <asp:DropDownList CssClass="form-control" ID="pCountry" runat="server" AutoPostBack="true" OnSelectedIndexChanged="pCountry_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Pay Mode:   <span class="ErrMsg" id='pMode_err'>*</span></label>
                                        </div>
                                        <div class="col-sm-4">
                                            <asp:DropDownList ID="pMode" runat="server" AutoPostBack="true" OnSelectedIndexChanged="pMode_SelectedIndexChanged" CssClass="form-control"></asp:DropDownList>
                                            <span id="hdnreqAgent" style="display: none"></span>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>
                                                Agent / Bank:    <span class="ErrMsg" id="pAgent_err" style="display: none">*</span>
                                            </label>
                                        </div>
                                        <div class="col-sm-4">
                                            <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                            <span id="hdnreqAgent" style="display: none"></span>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>
                                                Calculate By: <span class="errormsg">*</span>
                                            </label>
                                        </div>
                                        <div class="col-sm-2">
                                            <asp:RadioButton ID="bySendAmt" runat="server" GroupName="Mode" AutoPostBack="true" Text="Sending Amount" OnCheckedChanged="bySendAmt_CheckedChanged" />&nbsp;&nbsp;
                                        </div>
                                        <div class="col-sm-2">
                                            <asp:RadioButton ID="byPayOutAmt" runat="server" GroupName="Mode" AutoPostBack="true" Text="Receiving Amount" OnCheckedChanged="byPayOutAmt_CheckedChanged" />
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Collection Amount:  <%--<span class="ErrMsg" id='cAmt_err'>*</span>--%></label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="input-group">
                                                <asp:TextBox ID="txtCollAmt" runat="server" Enabled="false" CssClass="form-control" ErrorMessage="Required!"></asp:TextBox>
                                                <div class="input-group-addon">
                                                    <asp:Label ID="lblCollCurr" runat="server" Text="MYR"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Sending Amount:</label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="input-group">
                                                <asp:TextBox ID="lblSendAmt" runat="server" CssClass="form-control amountLabel" Enabled="false"></asp:TextBox>
                                                <div class="input-group-addon">
                                                    <asp:Label ID="lblSendCurr" runat="server" Text="JPY" CssClass="amountLabel"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Service Charge:</label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="input-group">
                                                <asp:TextBox ID="lblServiceChargeAmt" runat="server" CssClass="form-control amountLabel" Enabled="false"></asp:TextBox>
                                                <div class="input-group-addon">
                                                    <asp:Label ID="lblServiceChargeCurr" runat="server" Text="MYR" CssClass="amountLabel"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Customer Rate:</label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="input-group">
                                                <asp:TextBox ID="lblExRate" runat="server" CssClass="form-control amountLabel" Enabled="false"></asp:TextBox>
                                                <div class="input-group-addon">
                                                    <asp:Label ID="lblExCurr" runat="server" Text="" CssClass="amountLabel"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>Payout Amount:  <%--<span class="ErrMsg" id='Span1'>*</span>--%></label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="input-group">
                                                <asp:TextBox ID="txtPayAmt" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>

                                                <div class="input-group-addon">
                                                    <asp:Label ID="lblPayCurr" runat="server" Text="" CssClass="amountLabel"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-sm-2">
                                            <label>&nbsp;</label>
                                        </div>
                                        <div class="col-sm-4">
                                            <asp:Button runat="server" ID="btnCalculate" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckValidaion();" Text="Calculate" OnClick="btnCalculate_Click" ValidationGroup="cal" />
                                            <input type="button" id="btnCalcClean" class="btn btn-clear m-t-25" onclick="ClearTxnData()" value="Clear" />&nbsp;
											<span id="finalSenderId" style="display: none"></span>
                                            <span id="finalBenId" style="display: none"></span>
                                            <input type="hidden" id="finalAgentId" />
                                            <input type="hidden" id="txtCustomerLimit" value="0" />
                                            <input type="hidden" id="hdnInvoicePrintMethod" />
                                            <asp:Label ID="lblErr" runat="server" Text="" CssClass="amountLabel"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row form-group" style="display: none;">
                                        <div class="col-sm-2">
                                            <label>&nbsp;</label>
                                        </div>
                                        <div class="col-sm-4">
                                            <div align="center">
                                                <span id="span_txnInfo" align="center" runat="server" style="font-size: 13px; color: #FFFF00; line-height: 22px; vertical-align: middle; text-align: center; font-weight: bold;">NOTE : This calculation is assumption of CASH PAYMENT only, whereas BANK A/C
															  DEPOSIT might vary depending upon the payout bank, please check the detail charges
															  in transaction detail windows
                                                </span>
                                            </div>
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