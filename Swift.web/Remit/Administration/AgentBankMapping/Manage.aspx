<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentBankMapping.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <title></title>
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
                            <li><a href="#" onclick="return LoadModule('account')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Application Setting</a></li>
                            <li class="active"><a href="List.aspx">Agent's Bank Mapping Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent's Bank Mapping Manage
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-2 control-label">Bank Partner's Name:</label>
                                <div class="col-md-10">
                                    <asp:DropDownList ID="ddlApiBank" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-3 col-md-offset-2">
                                    <asp:Button Text="Search" ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                            <div id="showData" runat="server" visible="false">
                                <div class="form-group">
                                    <table class="table table-responsive table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>Sno.</th>
                                                <th>Partner Name</th>
                                                <th>Bank Name</th>
                                            </tr>
                                        </thead>
                                        <tbody id="rpt" runat="server">
                                        </tbody>
                                    </table>
                                </div>
                                <div class="form-group">
                                    <asp:Button Text="Save" ID="btnSave" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
                                    <asp:Button Text="Cancel" ID="btnCancel" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnCancel_Click" />
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