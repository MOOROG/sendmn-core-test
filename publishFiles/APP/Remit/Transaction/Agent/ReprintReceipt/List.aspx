<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ReprintReceipt.List" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">

    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript">
        function GenerateReceipt(url) {
            param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            OpenInNewWindow(url);
        }

        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);

            alert(resultList[1] + "callback");

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
        }
    </script>
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

        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h4 class="panel-title">
                        </h4>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                             <li><a href="#" onclick="return LoadModuleAgentMenu('reports')">Reports</a></li>
                            <li class="active"><a href="List.aspx">Reprint Receipt</a></li>
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
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <i class="fa fa-search"></i>
                            <label>Search Transaction By</label>
                        </div>
                        <div class="panel-body">
                            <div class="row panels">
                                <div class="col-sm-2">
                                    <label><%=GetStatic.GetTranNoName()%> :<span class="errormsg">*</span></label></div>
                                <div class="col-sm-4">
                                    <asp:TextBox ID="controlNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>

                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="controlNo"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay"
                                        SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="row panels">
                                <div class="form-group form-inline">
                                    <div class="col-sm-2">
                                        <label>Receipt Type :<span class="errormsg">*</span></label></div>
                                    <div class="col-sm-4 form-inline">
                                        <asp:DropDownList ID="receiptType" runat="server" Width="100%" CssClass="form-control">
                                            <asp:ListItem Value="SD">Send Domestic</asp:ListItem>
                                            <asp:ListItem Value="PD">Pay Domestic</asp:ListItem>
                                            <asp:ListItem Value="SI">Send International</asp:ListItem>
                                            <asp:ListItem Value="PI">Pay International</asp:ListItem>
                                            <asp:ListItem Value="CD">Cancel Domestic</asp:ListItem>
                                        </asp:DropDownList>

                                        <asp:RequiredFieldValidator ID="rv2" runat="server" ControlToValidate="receiptType"
                                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay"
                                            SetFocusOnError="True">
                                        </asp:RequiredFieldValidator>

                                    </div>
                                </div>
                            </div>
                            <div class="row panels">
                                <div class="col-sm-2"></div>
                                <div class="col-sm-4">
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="pay"
                                        CssClass="btn btn-primary btn-sm" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>


