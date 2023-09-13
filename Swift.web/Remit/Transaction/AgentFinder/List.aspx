<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.AgentFinder.List" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    

     <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="upd1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                    <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                                    <li class="active"><a href="List.aspx">Agent Finder </a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Search Agent</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:HiddenField ID="hdnCashPayment" runat="server" Value="Cash Payment" />
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="col-md-3 control-label">Agent/Branch : </label>
                                                <div class="col-md-7">
                                                <span id="spnSendBy" runat="server" class="welcome" style="margin-left: 0px;"></span>
                                                <uc1:SwiftTextBox ID="agent" CssClass="form-control"  runat="server" Category="sendingAgent" onfocus="Clear();" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label class="col-md-3 control-label">District : </label>
                                                <div class="col-md-7">
                                                    <asp:DropDownList ID="district" runat="server" CssClass="form-control" AutoPostBack="True"
                                                        OnSelectedIndexChanged="district_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                                <div class="col-md-2">
                                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="district"
                                                        Display="Dynamic" ErrorMessage="Required" ForeColor="Red" SetFocusOnError="True"
                                                        ValidationGroup="SC">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-md-3 control-label">Location : </label>
                                                <div class="col-md-7">
                                                    <asp:DropDownList ID="location" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-md-3 col-md-offset-3">
                                                    <asp:Button ID="btnAgentFind" CssClass="btn btn-primary m-t-25" runat="server" Text="Search Agent" OnClick="btnAgentFind_Click" ValidationGroup="SC" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="table table-responsive">
                                            <div id="divLoadGrid" runat="server">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
