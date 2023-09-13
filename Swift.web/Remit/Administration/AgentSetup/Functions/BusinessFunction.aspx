<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BusinessFunction.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.BusinessFunction" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <base id="Base1" target="_self" runat="server" />
  <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="../../../../ui/css/style.css" rel="stylesheet" />
  <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
  <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />

  <script src="../../../../js/functions.js" type="text/javascript"> </script>
  <style>
    .table .table {
      background-color: #F5F5F5 !important;
    }
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li>Administration » Agent Function » Business Function </li>
            </ol>
          </div>
        </div>
      </div>
      <div class="listtabs">
        <ul class="nav nav-tabs">
          <div id="divTab" runat="server"></div>
        </ul>
      </div>
      <div class="clearfix">
        <br />
      </div>
      <div class="tab-content">
        <div class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default ">
                <div class="panel-heading">
                  <h4 class="panel-title">Agent Business Function Form </h4>
                  <div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                  </div>
                </div>

                <div class="panel-body left">
                  <table class="table table-responsive">
                    <tr>
                      <td class="welcome"><%=GetAgentPageTab()%></td>
                    </tr>
                    <tr>
                      <td>
                        <table class="table table-responsive">
                          <tr>
                            <td>
                              <div class="panel-body">
                                <fieldset>
                                  <table class="table table-responsive">
                                    <tr>
                                      <td>Invoice Print Mode
                                            <br />
                                        <asp:DropDownList ID="invoicePrintMode" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="M">Multiple</asp:ListItem>
                                          <asp:ListItem Value="S">Single</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Print Invoice After
                                            <br />
                                        <asp:DropDownList ID="invoicePrintMethod" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="ba" Selected="true">TXN Send</asp:ListItem>
                                          <asp:ListItem Value="aa">TXN Approval</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Default Deposit Mode
                                            <br />
                                        <asp:DropDownList ID="defaultDepositMode" runat="server" CssClass="form-control"></asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>Global Transaction Allowed
                                            <br />
                                        <asp:DropDownList ID="globalTRNAllowed" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>

                                      <td>Settlement Type
                                            <br />
                                        <asp:DropDownList ID="settlementType" runat="server" CssClass="form-control"></asp:DropDownList>
                                      </td>
                                      <td>Date Format
                                            <br />
                                        <asp:DropDownList ID="dateFormat" runat="server" CssClass="form-control"></asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>Agent Operation Type
                                            <span class="errormsg">*</span>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                          runat="server" ControlToValidate="agentOperationType" ValidationGroup="admin" Display="Dynamic" ErrorMessage="Required!" ForeColor="Red">
                                        </asp:RequiredFieldValidator>
                                        <br />
                                        <asp:DropDownList ID="agentOperationType" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="">Select</asp:ListItem>
                                          <asp:ListItem Value="B">Both</asp:ListItem>
                                          <asp:ListItem Value="S">Send</asp:ListItem>
                                          <asp:ListItem Value="R">Receive</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Apply Cover Fund
                                            <br />
                                        <asp:DropDownList ID="applyCoverFund" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="">Select</asp:ListItem>
                                          <asp:ListItem Value="N">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td valign="top">Is RT User<br />
                                        <asp:DropDownList ID="isRTUser" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>

                                      <td>Auto Approval Limit<br />
                                        <asp:TextBox runat="server" ID="autoApprovalLimit" CssClass="form-control"></asp:TextBox>
                                      </td>

                                      <td>Routing Enable<br />
                                        <asp:DropDownList ID="routingEnable" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Self Txn Approve<br />
                                        <asp:DropDownList ID="selfTxnApprove" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>Is Enabled Fx Gain<br />
                                        <asp:DropDownList ID="fxGain" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                          <asp:ListItem Value="N">No</asp:ListItem>
                                        </asp:DropDownList></td>

                                      <td>Incoming Principle Account<br />
                                        <asp:DropDownList ID="incomingList" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                      </td>
                                      <td>Outgoing Principle Account<br />
                                        <asp:DropDownList ID="outgoingList" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                  </table>
                                </fieldset>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td>
                              <div class="panel-body">
                                <fieldset>
                                  <table class="table table-responsive">
                                    <tr>
                                      <td>Send Email To Sender
                                                                               <br />
                                        <asp:DropDownList ID="sendEmailToSender" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Send Email To Receiver
                                                                            <br />
                                        <asp:DropDownList ID="sendEmailToReceiver" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Send SMS To Sender
                                                                              <br />
                                        <asp:DropDownList ID="sendSMSToSender" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Send SMS To Receiver
                                                                              <br />
                                        <asp:DropDownList ID="sendSMSToReceiver" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>Enable Birthday and other wishes
                                                                                  <br />
                                        <asp:DropDownList ID="birthdayAndOtherWish" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>Agent Limit Display in Send Txn
                                                                               <br />
                                        <asp:DropDownList ID="agentLimitdispSendTxn" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>
                                        <asp:Label ID="lblHasUSDNostro" runat="server" Text="Has USD Nostro Account" />
                                        <br />
                                        <asp:DropDownList ID="hasUSDNostroAc" runat="server" CssClass="form-control">
                                          <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                          <asp:ListItem Value="Y">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                      </td>
                                      <td>
                                        <asp:Label ID="lblFlcNostroAcCurr" runat="server" Text="FLC Nostro Account Currency" />
                                        <br />
                                        <asp:DropDownList ID="flcNostroAcCurr" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                      </td>
                                    </tr>
                                  </table>
                                </fieldset>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td>
                              <div class="panel-body">
                                <fieldset>
                                  <table class="table table-responsive">
                                    <tr>
                                      <td>
                                        <legend><span class="subLegend">Send Trn Time Allowed</span></legend>
                                        <table class="table table-responsive">
                                          <tr>
                                            <td valign="top">From Time
                                                                                                 <br />
                                              <asp:TextBox ID="fromSendTrnTime" runat="server" CssClass="form-control" Text="00:00:00"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="fromSendTrnTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator2" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="fromSendTrnTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                            <td valign="top">To Time
                                                                                                <br />
                                              <asp:TextBox ID="toSendTrnTime" runat="server" CssClass="form-control" Text="23:59:59"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="toSendTrnTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="toSendTrnTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                          </tr>
                                        </table>
                                      </td>
                                      <td>
                                        <legend><span class="subLegend">Pay Trn Time Allowed </span></legend>
                                        <table class="table table-responsive">
                                          <tr>
                                            <td valign="top">From Time<br />
                                              <asp:TextBox ID="fromPayTrnTime" runat="server" CssClass="form-control" Text="00:00:00"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="fromPayTrnTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator3" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="fromPayTrnTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                            <td valign="top">To Time
                                                                                                 <br />
                                              <asp:TextBox ID="toPayTrnTime" runat="server" CssClass="form-control" Text="23:59:59"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender4" runat="server" TargetControlID="toPayTrnTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator4" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="toPayTrnTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                          </tr>
                                        </table>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>
                                        <legend><span class="subLegend">Report View Time Allowed</span> </legend>
                                        <table class="table table-responsive">
                                          <tr>
                                            <td valign="top">From Time
                                                                                               <br />
                                              <asp:TextBox ID="fromRptViewTime" runat="server" CssClass="form-control" Text="00:00:00"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender5" runat="server" TargetControlID="fromRptViewTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator5" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="fromRptViewTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                            <td valign="top">To Time
                                                                                             <br />
                                              <asp:TextBox ID="toRptViewTime" runat="server" CssClass="form-control" Text="23:59:59"></asp:TextBox>
                                              <br />
                                              <cc1:MaskedEditExtender ID="MaskedEditExtender6" runat="server" TargetControlID="toRptViewTime"
                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                ErrorTooltipEnabled="True" />

                                              <cc1:MaskedEditValidator ID="MaskedEditValidator6" runat="server" ControlExtender="MaskedEditExtender2"
                                                ControlToValidate="toRptViewTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="admin"
                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                              </cc1:MaskedEditValidator>
                                            </td>
                                          </tr>
                                        </table>
                                      </td>
                                      <td></td>
                                    </tr>
                                  </table>
                                </fieldset>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td colspan="3" nowrap="nowrap">&nbsp;   &nbsp;
                                                            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25"
                                                              ValidationGroup="admin" Display="Dynamic" TabIndex="27" OnClick="btnSubmit_Click" />
                              <cc1:ConfirmButtonExtender ID="btnSubmitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSubmit">
                              </cc1:ConfirmButtonExtender>
                              &nbsp;
                                                          <input type="button" id="btnBack" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />&nbsp;&nbsp;
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
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
