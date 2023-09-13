<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ComplianceDetail.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.ComplianceDetail" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <script src="../../js/swift_grid.js" type="text/javascript"></script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <style>
        legend {
            background-color: rgb(3, 169, 244);
            color: white;
            margin-bottom: 0 !important;
        }

        fieldset {
            padding: 10px !important;
            margin: 5px !important;
            border: 1px solid rgba(158, 158, 158, 0.21) !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">OFAC Management</a></li>
                            <li class="active"><a href="#">OFAC Compliance Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">OFAC Compliance Details</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group" id="detail1" runat="server" visible="false">
                                <asp:UpdatePanel ID="upnl1" runat="server">
                                    <ContentTemplate>
                                        <div id="rpt_grid" runat="server" style="overflow: scroll;" enableviewstate="false"></div>
                                    </ContentTemplate>
                                    <Triggers>
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="form-group" id="detail2" runat="server" visible="false">
                                <div class="row">
                                    <div class="col-md-6 form-group">
                                        <fieldset>
                                            <legend>Sender Information</legend>
                                            <table class="table table-responsive table-bordered table-striped">
                                                <tr>
                                                    <td>Sender's Name: </td>
                                                    <td>
                                                        <asp:Label ID="sName" runat="server" ForeColor="red"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="sIdType" runat="server"></asp:Label>
                                                        : </td>
                                                    <td>
                                                        <asp:Label ID="sIdNo" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Country: </td>
                                                    <td>
                                                        <asp:Label ID="sCountry" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Contact No: </td>
                                                    <td>
                                                        <asp:Label ID="sContactNo" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <fieldset>
                                            <legend>Receiver Information</legend>
                                            <table class="table table-responsive table-bordered table-striped">
                                                <tr>
                                                    <td>Receiver's Name: </td>
                                                    <td>
                                                        <asp:Label ID="rName" runat="server" ForeColor="red"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Country: </td>
                                                    <td>
                                                        <asp:Label ID="rCountry" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12 form-group">
                                        <fieldset>
                                            <legend>Compliance Detail</legend>
                                            <table class="table table-responsive table-bordered table-striped">
                                                <tr>
                                                    <td>Compliance Reason: </td>
                                                    <td>
                                                        <asp:Label ID="compReason" runat="server" ForeColor="red"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Max Allowed Amount: </td>
                                                    <td>
                                                        <asp:Label ID="maxAmt" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Sent Amount: </td>
                                                    <td>
                                                        <asp:Label ID="sAmt" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Detail Message: </td>
                                                    <td>
                                                        <asp:Label ID="msg" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
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
