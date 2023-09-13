<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommissionPackage.aspx.cs" Inherits="Swift.web.Remit.DomesticOperation.CommissionGroupMapping.CommissionPackage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>

    <script type="text/javascript" language="javascript">
        function IsDelete(id) {
            if (confirm("Confirm Delete?")) {
                document.getElementById("<% =hdnId.ClientID %>").value = id;
                document.getElementById("<% =btnDeleteRecord.ClientID %>").click();
            }
        }
        function ShowHide(obj, imgId) {
            var img = GetElement(imgId);
            var me = GetElement(obj);
            if (me.style.display == "block") {
                me.style.display = "none";
                img.src = "../../../images/plus.png";
                img.title = "Show";
            }
            else {
                me.style.display = "block";
                img.src = "../../../images/minus.gif";
                img.title = "Hide";
            }
            //            $("#" + obj).slideToggle("fast");
        }
        function CallBack() {
            window.location.reload(1);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnId" runat="server" />
        <asp:Button ID="btnDeleteRecord" runat="server" Text="Delete" OnClick="btnDeleteRecord_Click" Style="display: none;" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('servicecharge_and_commission')">Service Charge and Comission </a></li>
                            <li class="active"><a href="CommissionPackage.aspx">Commission Group Mapping</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a target="_self" href="#" class="selected">Commission Package Setup </a></li>
                    <li><a target="_self" href="CommissionGroup.aspx">Commission Group Setup</a></li>

                </ul>
            </div>
            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Send Commission Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td valign="top">
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td style="width: 130px;">Type:</td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="type" runat="server" CssClass="form-control" Width="350px"
                                                                AutoPostBack="True" OnSelectedIndexChanged="type_SelectedIndexChanged">
                                                                <asp:ListItem Value="">Select</asp:ListItem>
                                                                <asp:ListItem Value="I">International</asp:ListItem>
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="type"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pck" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>

                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 130px;">Package:</td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="package" runat="server" CssClass="form-control" Width="350px">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="package"
                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pck" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>

                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td nowrap="nowrap" valign="bottom">&nbsp;<asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary"
                                                            Text=" Search " ValidationGroup="pck" OnClick="btnSearch_Click" />
                                                        </td>
                                                    </tr>

                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPackage" runat="server" Style="font-size: 12px; font-weight: bold;"></asp:Label>
                                                <span id="spnViewChanges" runat="server"></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="domestic" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">Commission Package Domestic</td>
                                                    </tr>
                                                    <div class="table table-responsive">
                                                        <tr>
                                                            <td>
                                                                <div id="rpt_domestic" runat="server" style="overflow: auto;" enableviewstate="false"></div>
                                                            </td>
                                                        </tr>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="serviceCharge" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">
                                                            <img id="imgSc" src="../../../Images/minus.gif" border="0" title="Hide" class="showHand" onclick="ShowHide('rpt_sc', 'imgSc');" />
                                                            Commission Package International Service Charge
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_sc" runat="server" style="overflow: auto;" enableviewstate="false"></div>
                                                        </td>
                                                    </tr>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="payComm" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">
                                                            <img id="imgCp" src="../../../images/minus.gif" border="0" title="Hide" class="showHand" onclick="ShowHide('rpt_cp', 'imgCp');" />
                                                            Commission Package International Pay Commission
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_cp" runat="server" style="overflow: auto;" enableviewstate="false"></div>
                                                        </td>
                                                    </tr>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="sendComm" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">
                                                            <img id="imgCs" src="../../../images/minus.gif" border="0" title="Hide" class="showHand" onclick="ShowHide('rpt_cs', 'imgCs');" />
                                                            Commission Package International Send Commission
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_cs" runat="server" style="overflow: auto;" enableviewstate="false"></div>
                                                        </td>
                                                    </tr>
                                                </div>
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
