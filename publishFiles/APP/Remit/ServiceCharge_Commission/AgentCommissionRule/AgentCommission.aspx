<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentCommission.aspx.cs" Inherits="Swift.web.Remit.Commission.AgentCommissionRule.AgentCommission" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
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
        function CallBack() {
            window.location.reload(1);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnId" runat="server" />
        <asp:HiddenField ID="hdnAgentId" runat="server" />
        <asp:Button ID="btnDeleteRecord" runat="server" Text="Delete" OnClick="btnDeleteRecord_Click" Style="display: none;" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Service Charge & Commission </li>
                            <li><a href="List.aspx">Agent Commission Rule </a></li>
                            <li class="active">Agent Commission and Service Charge Attach</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent Commission and Service Charge Attach</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group">
                                    <div class="shadowBG"><span id="spnCname" runat="server"></span></div>
                                </div>
                            </div>
                            <table class="table table-responsive">
                                <tr>
                                    <td>
                                        <asp:Label ID="lblAgent" runat="server" Style="font-size: 12px; font-weight: bold;"></asp:Label>
                                        <span id="spnViewChanges" runat="server"></span>
                                    </td>
                                </tr>
                                <div class="table table-responsive">
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
                                                        <div id="rpt_sc" runat="server" style="overflow: auto;"></div>
                                                    </td>
                                                </tr>
                                            </div>
                                        </td>
                                    </tr>
                                </div>
                                <div class="table table-responsive">
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
                                                        <div id="rpt_cp" runat="server" style="overflow: auto; display: block;"></div>
                                                    </td>
                                                </tr>
                                            </div>
                                        </td>
                                    </tr>
                                </div>
                                <div class="table table-responsive">
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
                                                        <div id="rpt_cs" runat="server" style="overflow: auto; display: block;"></div>
                                                    </td>
                                                </tr>
                                            </div>
                                        </td>
                                    </tr>
                                </div>
                                <tr>
                                    <td>
                                        <asp:Button ID="btnBack" runat="server" Text="Back" OnClick="btnBack_Click" CssClass="btn btn-primary" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
