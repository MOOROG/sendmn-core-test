<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelRequest.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.CancelRequest.CancelRequest" %>

<%--<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>--%>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <%--<link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />--%>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/menucontrol.js" type="text/javascript"></script>

    <script type="text/javascript">
        function ClearField() {
            SetValueById("<% =controlNo.ClientID%>", "", false);
        }

        function CallBack(mes, url) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
            window.location.replace(url);
        }
    </script>

    <%-- <style>
        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }
    </style>--%>

    <style>
        .infotext {
            color: #000;
            font-size: 14px;
            font-weight: 600;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="CancelRequest.aspx">Cancel Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
                <ProgressTemplate>
                    <div style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black;">
                        <img alt="progress" src="../../../../Images/Loading_small.gif" />
                        Processing...
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div>
                        <div id="tblSearch" runat="server">
                            <div class="panel panel-default">
                                <div class="panel-heading"><i class="fa fa-search"></i>Search By</div>
                                <div class=" panel-body">
                                    <div class="col-sm-12  form-inline">
                                        <div class="col-md-1">
                                            <b><%=GetStatic.GetTranNoName() %></b>
                                            <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="controlNo"
                                                ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="search"
                                                SetFocusOnError="True">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                        <div class="col-md-3">
                                            <asp:TextBox ID="controlNo" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                                        </div>
                                        <div class="col-sm-2 ">
                                            <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary btn-sm"
                                                OnClick="btnSearch_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div style="clear: both;">
                            </div>
                        </div>
                        <div id="divTranDetails" runat="server" visible="false">
                            <div class="panel panel-default">
                                <div class="panel-heading">
                                    <div id="div1" style="clear: both;" class="panels">
                                        <div style="text-align: center;">

                                            <span style="font-size: 2em; font-weight: bold;">
                                                <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                                                <span style="color: red;">
                                                    <asp:Label ID="lblControlNo" runat="server"></asp:Label></span>
                                            </span>

                                            <span style="width: 100px;"></span>

                                            <span style="font-size: 2em; font-weight: bold;">Transaction Status: 
                                                 <span style="color: red;">
                                                     <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                                 </span>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table">
                                        <tr>
                                            <td class="tableForm" colspan="2">
                                                <table class="table table-bordered ">
                                                    <tr>
                                                        <td>
                                                            <table id="tblCreatedLog" class="table table-bordered">
                                                                <tr>
                                                                    <td>Created By:</td>
                                                                    <td>
                                                                        <asp:Label ID="createdBy" runat="server" CssClass="infotext"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Created Date:</td>
                                                                    <td>
                                                                        <asp:Label ID="createdDate" runat="server" CssClass="infotext"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td>
                                                            <table id="tblApprovedLog" class="table table-bordered">
                                                                <tr>
                                                                    <td>
                                                                        <label>Approved By:</label></td>
                                                                    <td>
                                                                        <asp:Label ID="approvedBy" runat="server" CssClass="infotext"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Approved Date:</td>
                                                                    <td>
                                                                        <asp:Label ID="approvedDate" runat="server" CssClass="infotext"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="50%" valign="top" class="tableForm">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Sender</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered">
                                                            <tr style="background-color: #0e96ec">
                                                                <td style="color: #000; font-size: 14px;">Name:</td>
                                                                <td>
                                                                    <asp:Label ID="sName" runat="server" CssClass="infotext"></asp:Label></td>
                                                            </tr>
                                                            <tr>
                                                                <td>Address: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAddress" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Country: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sCountry" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Contact No: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sContactNo" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Id Type: </td>
                                                                <td>
                                                                    <asp:Label ID="sIdType" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Id Number: </td>
                                                                <td>
                                                                    <asp:Label ID="sIdNo" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Email: </td>
                                                                <td>
                                                                    <asp:Label ID="sEmail" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                            <td width="50%" valign="top" class="tableForm">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Receiver</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered">
                                                            <tr style="background-color: #0e96ec">
                                                                <td style="color: #000; font-size: 14px;">Name:</td>
                                                                <td>
                                                                    <asp:Label ID="rName" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Address: </td>
                                                                <td>
                                                                    <asp:Label ID="rAddress" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Country: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="rCountry" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Contact No: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="rContactNo" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Id Type: </td>
                                                                <td>
                                                                    <asp:Label ID="rIdType" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Id Number: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="rIdNo" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Relationship with sender: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="relationship" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" class="tableForm">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Sending Agent Detail</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered">
                                                            <tr>
                                                                <td>Agent: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAgentName" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Branch: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sBranchName" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>S. Agent Location: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAgentLocation" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>District:</td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAgentDistrict" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>City: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAgentCity" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Country: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="sAgentCountry" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                            <td valign="top" class="tableForm">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Payout Agent Detail</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered">
                                                            <tr>
                                                                <td>Agent: </td>
                                                                <td>
                                                                    <asp:Label ID="pAgentName" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Branch: </td>
                                                                <td>
                                                                    <asp:Label ID="pBranchName" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Payout Location: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="pAgentLocation" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>District:</td>
                                                                <td class="text">
                                                                    <asp:Label ID="pAgentDistrict" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>City: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="pAgentCity" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Country: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="pAgentCountry" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="tableForm" valign="top">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Transaction Amount Detail</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered" style="width: 100%" cellspacing="0" cellpadding="0">
                                                            <tr>
                                                                <td>Collection Amount: </td>

                                                                <td class="text-amount">
                                                                    <asp:Label ID="total" runat="server" CssClass="infotext"></asp:Label>
                                                                    <asp:Label ID="totalCurr" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>

                                                            </tr>
                                                            <tr>
                                                                <td>Service Charge: </td>
                                                                <td>
                                                                    <asp:Label ID="serviceCharge" runat="server" CssClass="infotext"></asp:Label>
                                                                    <asp:Label ID="scCurr" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Sent Amount: </td>

                                                                <td class="text-amount">
                                                                    <asp:Label ID="transferAmount" runat="server" CssClass="infotext"></asp:Label>
                                                                    <asp:Label ID="tAmtCurr" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Payout Amount: </td>
                                                                <td class="text-amount DisFond">
                                                                    <asp:Label ID="payoutAmt" runat="server" CssClass="infotext"></asp:Label>
                                                                    <asp:Label ID="pAmtCurr" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                            <td valign="top" class="tableForm">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">Other Detail</div>
                                                    <div class="panel-body">
                                                        <table class="table table-bordered">
                                                            <tr>
                                                                <td>Mode of Payment: </td>
                                                                <td class="text">
                                                                    <asp:Label ID="modeOfPayment" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="DisFond">Trn Status:</td>
                                                                <td class="DisFond">
                                                                    <asp:Label ID="tranStatus" runat="server" CssClass="infotext"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="panel panel-default">
                                                    <table class="table">
                                                        <tr>
                                                            <td>
                                                                <b>Payout Message</b>
                                                                <br />
                                                                <asp:Label ID="payoutMsg" runat="server" CssClass="infotext"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:HiddenField ID="hddTranId" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>


                            </div>

                            <div class="panel panel-default">
                                <table class="table">
                                    <tr>
                                        <td>
                                            <b>Cancel Reason</b>
                                            <span class="ErrMsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="controlNo"
                                                ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cancel"
                                                SetFocusOnError="True">
                                            </asp:RequiredFieldValidator>
                                            <br />
                                            <asp:TextBox ID="cancelReason" runat="server" TextMode="MultiLine" Width="350px" Height="40px"></asp:TextBox>
                                            <%--<asp:RangeValidator ID="RangeValidator1" runat="server" Type="String" ControlToValidate="cancelReason" MaximumValue="199" 
                                            ErrorMessage="Cannot exceed more than 199 charactor" ForeColor="Red" ValidationGroup="cancel"></asp:RangeValidator>--%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnCancel" runat="server" Text="Request for Cancel" ValidationGroup="cancel" CssClass="btn btn-danger" OnClick="btnCancel_Click" />&nbsp;&nbsp;&nbsp;&nbsp;
                                    <cc1:ConfirmButtonExtender ID="btnCancelcc" runat="server"
                                        ConfirmText="Confirm To Request for cancel?" Enabled="True" TargetControlID="btnCancel">
                                    </cc1:ConfirmButtonExtender>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>




    </form>
</body>
</html>


