<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommissionGroup.aspx.cs" Inherits="Swift.web.Remit.DomesticOperation.CommissionGroupMapping.CommissionGroup" %>

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
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnId" runat="server" />
        <asp:Button ID="btnDeleteRecord" runat="server" Style="display: none" OnClick="btnDeleteRecord_Click" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('servicecharge_and_commission')">Service Charge and Comission </a></li>
                            <li class="active"><a href="CommissionGroup.aspx">Commission Group Mapping</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a target="_self" href="CommissionPackage.aspx">Commission Package Setup </a></li>
                    <li class="active"><a target="_self" href="#" class="selected">Commission Group Setup</a></li>

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
                                                        <td style="width: 130px;">Group</td>
                                                        <td>
                                                            <asp:DropDownList ID="group" runat="server" CssClass="form-control" Width="350px">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="group"
                                                                Display="Dynamic" ErrorMessage="*" ValidationGroup="pck" ForeColor="Red"
                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                          <td style="width: 130px;"></td>
                                                        <td nowrap="nowrap" valign="bottom" colspan="2" >&nbsp;<asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25"
                                                            OnClick="btnSearch_Click" Text="Search" ValidationGroup="pck" />
                                                            <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
                                                        </td>
                                                    </tr>

                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="domestic" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">
                                                            <img id="imgDomestic" src="../../../images/minus.gif" border="0" title="Hide" class="showHand" onclick="ShowHide('rpt_domestic', 'imgDomestic');" />
                                                            Commission Package Domestic
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_domestic" runat="server" style="margin-left: 5px; height: 200px; overflow: auto; display: block;" enableviewstate="false"></div>
                                                        </td>
                                                    </tr>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="international" visible="false" runat="server">
                                                    <tr>
                                                        <td align="left" valign="top" class="welcome">
                                                            <img id="imgIntl" src="../../../images/minus.gif" border="0" title="Hide" class="showHand" onclick="ShowHide('rpt_intl', 'imgIntl');" />
                                                            Commission Package International
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_intl" runat="server" style="margin-left: 5px; height: 200px; overflow: auto; display: block;" enableviewstate="false"></div>
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
