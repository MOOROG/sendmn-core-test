<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Restore.Manage" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../js/functions.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Transaction </a></li>
                            <li class="active"><a href="Manage.aspx">Restore Details</a></li>
                            <li class="active"><a href="Manage.aspx">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx">List </a></li>
                        <li class="active" role="presentation"><a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab">Manage</a></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="Manage">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Transaction Detail
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body" id="Printreceiptdetail" runat="server">
                                        <table class="table table-responsive" width="600px">
                                            <tr>
                                                <td valign="top" width="200px">
                                                    <span style="float: left">
                                                        <img src="/ui/images/fastmoneypro.png"/>
                                                    </span>
                                                    <div id="headMsg" runat="server" style="text-align: right; margin-top: 5px; font-size: 11px; text-align: left;"></div>
                                                </td>
                                                <td valign="top">
                                                    <table class="innerTableHeader" width="400px">
                                                        <tr>
                                                            <td class="label">
                                                                <asp:Label ID="agentName" runat="server" Style="font-weight: 700"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="label">
                                                                <asp:Label ID="branchName" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="label">Address:
                            <asp:Label ID="agentLocation" runat="server"></asp:Label>, 
                                <asp:Label ID="agentCountry" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="label">Contact No: 
                                <asp:Label ID="agentContact" runat="server"></asp:Label>

                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">Select Agent : 
                                <uc1:swifttextbox id="agentId" runat="server" category="remit-agent" width="300px" limittolist="true" />
                                                                <asp:Button ID="btnLoad" runat="server" OnClick="btnLoad_Click" Style="display: none" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        <div id="divDetails" style="clear: both;" class="panels">
                                            <span style="background: red; font-size: 1.5em; font-weight: bold; color: White;">Control No:
                        <asp:Label ID="lblControlNo" runat="server"></asp:Label>
                                                <asp:HiddenField ID="hddRowId" runat="server" />
                                            </span>
                                            <table width="100%" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td valign="top" class="tableForm" style="width: 50%">
                                                        <fieldset>
                                                            <table style="width: 100%">
                                                                <tr style="background-color: #FDF79D;">
                                                                    <td class="label">Sender's Name: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="sName" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Address: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">City: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="sCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Country: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Id Type: </td>
                                                                    <td class="text" style="width: 150px">
                                                                        <asp:Label ID="sIdType" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 60px;">Id No: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Contact No: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                    <td valign="top" class="tableForm">
                                                        <fieldset>
                                                            <table style="width: 100%">
                                                                <tr style="background-color: #F9CCCC;">
                                                                    <td class="label">Receiver's Name: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="rName" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Address: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">City: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="rCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Country: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Id Type: </td>
                                                                    <td class="text" style="width: 150px">
                                                                        <asp:Label ID="recIdType" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 60px;">Id No: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="recIdNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Contact No: </td>
                                                                    <td class="text" colspan="3">
                                                                        <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" class="tableForm">
                                                        <fieldset>
                                                            <table style="width: 100%">
                                                                <tr>
                                                                    <td class="label">Sending Country: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sAgentCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Sending Agent: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sendAgent" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                    <td class="tableForm" valign="top">
                                                        <fieldset>
                                                            <table style="width: 100%">
                                                                <tr>
                                                                    <td class="label">Payout Amount: </td>
                                                                    <td class="text-amount" style="text-align: left;">
                                                                        <asp:Label ID="payoutAmount" runat="server" CssClass="amount"></asp:Label>
                                                                        <asp:Label ID="payoutCurr" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Payment Type: </td>
                                                                    <td>
                                                                        <asp:Label ID="paymentType" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <fieldset>
                                                            <table class="tableForm">
                                                                <tr>
                                                                    <td class="label" style="width: 700px">Payout Amount in figure</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="text">
                                                                        <asp:Label ID="pAmtFigure" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div class="headers">Receiver Identification Details</div>
                                        <div class="panels">
                                            <table width="800px">
                                                <tr>
                                                    <td valign="top" nowrap="nowrap">
                                                        <b>Receiver ID Type : </b>
                                                        <asp:Label ID="rIdType" runat="server"></asp:Label>
                                                    </td>
                                                    <td valign="top" nowrap="nowrap">
                                                        <b>Receiver ID No: </b>
                                                        <asp:Label ID="rIdNumber" runat="server"></asp:Label>

                                                    </td>

                                                    <td nowrap="nowrap">
                                                        <b>Place Of Issue (District) :</b>
                                                        <asp:Label ID="placeOfIssue" runat="server"></asp:Label>

                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" nowrap="nowrap">
                                                        <b>Contact No:</b>
                                                        <asp:Label ID="mobileNo" runat="server"></asp:Label>

                                                    </td>
                                                    <td nowrap="nowrap">Receiver <b>Parent/Spouse:</b>
                                                        <asp:Label ID="relationType" runat="server"></asp:Label>
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <b>Parent/Spouse Name:</b>
                                                        <asp:Label ID="relativeName" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                    <asp:Button OnClientClick="return confirm('Are you sure to cofirm pay?');" ID="btnPay" CssClass="btn btn-primary" Style="margin-top: 15px" runat="server" Text="Pay Transaction" OnClick="Pay_Click" />
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

