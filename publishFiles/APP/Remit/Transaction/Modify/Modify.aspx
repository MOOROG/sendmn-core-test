<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Modify.aspx.cs" Inherits="Swift.web.Remit.Transaction.Modify.Modify" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <%--<link href="../../../css/TranStyle.css" rel="stylesheet" type="text/css" />--%>

    <script type="text/javascript">
        document.onkeypress = function (e) {
            var e = window.event || e;

            if (e.keyCode == 27)
                window.close();
        };

        function checkAll(me) {
            var checkBoxes = document.forms[0].chkTran;
            var boolChecked = me.checked;

            for (i = 0; i < checkBoxes.length; i++) {
                checkBoxes[i].checked = boolChecked;
            }
        }

        function ClearField() {
            SetValueById("<% =controlNo.ClientID%>", "", false);

            SetValueById("<% =sFirstName.ClientID%>", "", false);
            SetValueById("<% =sMiddleName.ClientID%>", "", false);
            SetValueById("<% =sLastName1.ClientID%>", "", false);
            SetValueById("<% =sLastName2.ClientID%>", "", false);
            SetValueById("<% =sMemId.ClientID%>", "", false);

            SetValueById("<% =rFirstName.ClientID%>", "", false);
            SetValueById("<% =rMiddleName.ClientID%>", "", false);
            SetValueById("<% =rLastName1.ClientID%>", "", false);
            SetValueById("<% =rLastName2.ClientID%>", "", false);
            SetValueById("<% =rMemId.ClientID%>", "", false);
        }

        function GridCallBack() {
            GetElement("<% =btnTranSelect.ClientID%>").click();
        }

        function ShowSender() {
            var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
            var customerId = GetElement("<% =hddSCustomerId.ClientID%>").value;
            var tranId = GetElement("<% =hddTran.ClientID%>").value;
            var url = urlRoot + "/Remit/Transaction/Modify/ModifyCustomer.aspx?customerId=" + customerId + "&tranId=" + tranId + "&srFlag=S";
            param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
            var Id = PopUpWindow(url, param);
            LoadTranDetail();
        }

        function ShowReceiver() {
            var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
            var customerId = GetElement("<% =hddRCustomerId.ClientID%>").value;
            var tranId = GetElement("<% =hddTran.ClientID%>").value;
            var url = urlRoot + "/Remit/Transaction/Modify/ModifyCustomer.aspx?customerId=" + customerId + "&tranId=" + tranId + "&srFlag=R";
            param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
            var Id = PopUpWindow(url, param);
            LoadTranDetail();
        }

        function ModifyPayoutLocation() {
            var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
            var tranId = GetElement("<% =hddTran.ClientID%>").value;
            var url = urlRoot + "/Remit/Transaction/Modify/PickAgent.aspx?tranId=" + tranId;
            param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
            var Id = PopUpWindow(url, param);
            LoadTranDetail();
        }

        function LoadTranDetail() {
            GetElement("<% =btnSearch.ClientID%>").click();
        }

        function PickSender() {
            var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
            var customerId = GetElement("<% =hddSCustomerId.ClientID%>").value;
            var tranId = GetElement("<% =hddTran.ClientID%>").value;
            var url = urlRoot + "/Remit/Transaction/Modify/PickCustomer.aspx?oldCustomerId=" + customerId + "&tranId=" + tranId + "&srFlag=S";
            param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
            var Id = PopUpWindow(url, param);
            LoadTranDetail();
        }

        function PickReceiver() {
            var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
            var customerId = GetElement("<% =hddRCustomerId.ClientID%>").value;
            var tranId = GetElement("<% =hddTran.ClientID%>").value;
            var url = urlRoot + "/Remit/Transaction/Modify/PickCustomer.aspx?oldCustomerId=" + customerId + "&tranId=" + tranId + "&srFlag=R";
            param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
            var Id = PopUpWindow(url, param);
            LoadTranDetail();
        }

        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div style="min-height: 720px">
            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="page-wrapper">
                        <div class="row">
                            <div class="col-sm-12">
                                <div class="page-title">
                                    <h1></h1>
                                    <ol class="breadcrumb">
                                        <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                        <li><a href="#" onclick="return LoadModule('remittance')">Other Services</a></li>
                                        <li class="active"><a href="Modify.aspx">Search Transaction </a></li>
                                    </ol>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div id="div_pay_search" class="panels">
                                <table class="table">
                                    <tr>
                                        <td valign="top" style="width: 400px;">
                                            <div class="panel panel-body">
                                                <div class="panel-heading">Search By</div>
                                                <div class="panel-body">
                                                    <table class="table">
                                                        <tr>
                                                            <td>
                                                                <b><%=GetStatic.GetTranNoName() %></b>
                                                                <span class="ErrMsg">*</span>
                                                                <br />
                                                                <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="controlNo"
                                                                    ForeColor="Red" Display="Dynamic" ErrorMessage="*" ValidationGroup="search"
                                                                    SetFocusOnError="True">
                                                                </asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </td>
                                        <td valign="top" style="width: 400px;">
                                            <div class="panel panel-default" style="display: none;">
                                                <div class="panel-heading">Sender</div>
                                                <div class="panel-body">
                                                    <table id="tbl_sender" align="center" class="table">
                                                        <tr>
                                                            <td>
                                                                <b>First Name</b><br />
                                                                <asp:TextBox ID="sFirstName" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <b>Middle Name</b><br />
                                                                <asp:TextBox ID="sMiddleName" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <b>First Last Name</b><br />
                                                                <asp:TextBox ID="sLastName1" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <b>Second Last Name</b><br />
                                                                <asp:TextBox ID="sLastName2" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <b>Membership Id</b><br />
                                                                <asp:TextBox ID="sMemId" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </td>
                                        <td valign="top" style="width: 400px;">
                                            <div class="panel panel-body" style="display: none;">
                                                <div class="panel-heading">Receiver</div>
                                                <div class="panel-body">
                                                    <table id="tbl_receiver" align="center" class="table">
                                                        <tr>
                                                            <td>
                                                                <b>First Name</b><br />
                                                                <asp:TextBox ID="rFirstName" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <b>Middle Name</b><br />
                                                                <asp:TextBox ID="rMiddleName" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <b>First Last Name</b><br />
                                                                <asp:TextBox ID="rLastName1" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <b>Second Last Name</b><br />
                                                                <asp:TextBox ID="rLastName2" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <b>Membership Id</b><br />
                                                                <asp:TextBox ID="rMemId" runat="server" Width="100px" CssClass="form-control"></asp:TextBox>
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="panels2">
                                <div id="div_search_button" class="buttons">
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search"
                                        OnClick="btnSearch_Click" CssClass="btn btn-primary">
                                    <input type="button" value="Clear Field" class="btn btn-primary" id="btnSclearField" onclick=" ClearField('s'); " />
                                </div>
                            </div>
                            <div style="clear: both;">
                                <div id="grd_tran" runat="server" class="grid-div" style="display: none;"></div>
                                <asp:HiddenField ID="hddTran" runat="server" />
                                <asp:HiddenField ID="hddSCustomerId" runat="server" />
                                <asp:HiddenField ID="hddRCustomerId" runat="server" />
                            </div>
                            <asp:Button ID="btnTranSelect" runat="server" Text="Select" Style="display: none;" OnClick="btnTranSelect_Click" />
                            <div id="divTranDetails" runat="server" visible="false">
                                <div class="panel panel-default">
                                    <div class="panel-heading">Transaction Details</div>
                                    <div id="divDetails" style="clear: both;" class="panel-body">
                                        <table width="100%" cellspacing="0" cellpadding="0" class="table">
                                            <tr>
                                                <td width="400px" valign="top" class="tableForm">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">
                                                            SENDER
                                                        </div>
                                                        <div class="panel-body">
                                                            <table style="width: 100%" class="table">
                                                                <tr>
                                                                    <td class="label">Sender's Name: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sName" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Address: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">City: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">State: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sState" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Country: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Contact No: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">
                                                                        <input type="button" id="btnModifySender" value="Modify Sender" onclick=" ShowSender(); " />
                                                                        <input type="button" id="btnChangeSender" value="Change Sender" onclick=" PickSender(); " />
                                                                    </td>
                                                                </tr>
                                                            </table>

                                                        </div>
                                                    </div>
                                                </td>
                                                <td valign="top" class="tableForm">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">
                                                            RECEIVER
                                                        </div>
                                                        <div class="panel-body">
                                                            <table style="width: 100%" class="table">
                                                                <tr>
                                                                    <td class="label">Receiver's Name: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rName" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Address: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rAddress" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">City: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rCity" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">State: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rState" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Country: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Contact No: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="rContactNo" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">
                                                                        <input type="button" id="btnModifyReceiver" value="Modify Receiver" onclick=" ShowReceiver(); " />
                                                                        <input type="button" id="btnChangeReceiver" value="Change Receiver" onclick=" PickReceiver(); " />
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
                                                        <div class="panel-heading">
                                                            AGENT INFORMATION
                                                        </div>
                                                        <div class="panel-body">
                                                            <table style="width: 100%" class="table">
                                                                <tr>
                                                                    <td class="label">Payout Agent: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="pName" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Super Agent:</td>
                                                                    <td class="text">
                                                                        <asp:Label ID="pSuperAgent" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Country: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="pCountry" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">State: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="pState" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">District:</td>
                                                                    <td class="text">
                                                                        <asp:Label ID="pDistrict" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>

                                                                <tr>
                                                                    <td class="label">Mode of Payment: </td>
                                                                    <td class="text">
                                                                        <asp:Label ID="modeOfPayment" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Transaction Status:</td>
                                                                    <td class="text">
                                                                        <asp:Label ID="tranStatus" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">
                                                                        <input type="button" id="btnModifyAgent" class="btn btn-primary" value="Modify Agent Location" onclick=" ModifyPayoutLocation(); " />
                                                                    </td>
                                                                </tr>
                                                            </table>

                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="tableForm" valign="top">
                                                    <div class="panel panel-default">
                                                        <div class="panel-body">
                                                            <table class="table" style="width: 100%" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td class="label">Transfer Amount: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="transferAmount" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Service Charge: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="serviceCharge" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Handling: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="aHandling" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Total: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="total" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Exchange Rate: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="exchangeRate" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="label">Payout Amount: </td>
                                                                    <td class="text-amount">
                                                                        <asp:Label ID="payoutAmt" runat="server"></asp:Label>
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
                                                        <div class="panel-body">
                                                            <table class="table">
                                                                <tr>
                                                                    <td style="width: 150px;">
                                                                        <b>Purpose Of Remittance</b>
                                                                        <br />
                                                                        <asp:Label ID="purpose" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 150px;">
                                                                        <b>Relationship</b>
                                                                        <br />
                                                                        <asp:Label ID="relationship" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 150px;">
                                                                        <b>Source of Fund</b>
                                                                        <br />
                                                                        <asp:Label ID="sourceOfFund" runat="server"></asp:Label>
                                                                    </td>
                                                                    <td>
                                                                        <b>Payout Message</b>
                                                                        <br />
                                                                        <asp:Label ID="payoutMsg" runat="server"></asp:Label>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div id="rptLog" runat="server" style="margin-left: 20px"></div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
