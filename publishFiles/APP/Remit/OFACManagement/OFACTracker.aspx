<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OFACTracker.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.OFACTracker" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../js/swift_grid.js" type="text/javascript"></script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../css/swift_component.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
            <ProgressTemplate>
                <div style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black;">
                    <img alt="progress" src="/Images/Loading_small.gif" />
                    Processing...
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:UpdatePanel ID="upd1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <ol class="breadcrumb">
                                    <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li class="active"><a href="#">OFAC Management</a></li>
                                    <li class="active"><a href="#">OFAC Tracker</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">OFAC Tracker</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label>Enter Name:</label>
                                        <asp:TextBox ID="name" runat="server" CssClass="form-control" Width="40%"></asp:TextBox>
                                        
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary" Text="Search"
                                            OnClick="btnSearch_Click" />&nbsp;
                                    </div>
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server"></div>
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
