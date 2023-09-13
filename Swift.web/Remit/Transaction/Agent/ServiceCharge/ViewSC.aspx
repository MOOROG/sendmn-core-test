<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewSC.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ServiceCharge.ViewSC" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />

    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/menucontrol.js" type="text/javascript"></script>
    <style>
        .headingRate {
            height: 20px;
            width: 700px;
            font-size: 11px;
            padding-bottom: 2px;
            xcolor: #999999;
            color: Black;
            font-weight: bold;
            text-transform: uppercase;
            vertical-align: top;
        }

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

        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="ViewSC.aspx">Agent Locator</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:UpdatePanel ID="upd1" runat="server">
                <ContentTemplate>
                    <div class="row panels">
                        <div class="col-sm-2">
                            <label>Collection Currency: <span class="errormsg">*</span></label></div>
                        <div class="col-sm-4">
                            <asp:DropDownList ID="cCurrency" runat="server" CssClass="form-control" Width="100%"></asp:DropDownList>

                            <asp:RequiredFieldValidator ID="rv1" runat="server"
                                ControlToValidate="cCurrency" Display="Dynamic" ErrorMessage="Required"
                                ForeColor="Red" SetFocusOnError="True" ValidationGroup="SC">
                            </asp:RequiredFieldValidator>
                        </div>
                        <div class="col-sm-2">
                            <label>Payment Country : <span class="errormsg">*</span></label></div>
                        <div class="col-sm-4">
                            <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control" AutoPostBack="True" Width="100%"></asp:DropDownList>

                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                ControlToValidate="pCountry" Display="Dynamic" ErrorMessage="Required"
                                ForeColor="Red" SetFocusOnError="True" ValidationGroup="SC">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row panels">
                        <div class="col-sm-2"></div>

                        <div class="col-sm-4">
                            <asp:Button ID="btnFilter" runat="server" Text=" Search " ValidationGroup="SC"
                                CssClass="btn btn-primary btn-sm" OnClick="btnFilter_Click" />
                        </div>
                    </div>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="pCountry" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="pCountry" EventName="SelectedIndexChanged" />
                    <asp:PostBackTrigger ControlID="btnFilter" />
                </Triggers>
            </asp:UpdatePanel>

            <div id="showRpt" runat="server" visible="false">
                <div class="row">
                    <div class="col-sm-2"><span class="headingRate">SERVICE CHARGE RESULT</span></div>
                </div>
                <div class="col-sm-4">
                    <div id="RPTSC" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
