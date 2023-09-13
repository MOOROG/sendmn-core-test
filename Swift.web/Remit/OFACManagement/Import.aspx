<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Import.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.Import" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../js/swift_grid.js" type="text/javascript"></script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <style>
        .td {
            font-size: 10px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
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
                                    <li class="active"><a href="#">Import OFAC List</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Import OFAC List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label>OFAC</label><br />
                                        <asp:Button ID="btnImport" runat="server" Text="Download OFAC Data" CssClass="btn btn-primary" OnClick="btnImport_Click" />
                                        <asp:Button ID="btnLoadOfac" runat="server" Text="Upload OFAC Data" CssClass="btn btn-primary" OnClick="btnLoadOfac_Click" />
                                    </div>
                                    <div class="form-group">
                                        <label>UNSCR</label><br />
                                        <asp:Button ID="BtnImpAQList" runat="server" CssClass="btn btn-primary" OnClick="BtnImpAQList_Click" Text="Download UNSCR Data" />
                                        <asp:Button ID="btnUpload" runat="server" CssClass="btn btn-primary" OnClick="btnUpload_Click" Text="Upload UNSCR Data" />
                                    </div>
                                    <div class="form-group">
                                        <label>OTHERS DATA SOURCE [ FBI, EU, BXA_UN, HMS, BXA_DPL, OSFI ]</label><br />
                                        <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary" Text="Upload Others Data" OnClick="Button1_Click" />
                                    </div>
                                    <div class="form-group">
                                        <div runat="server" id="SourceWiseData" style="width: 400px; float: right; font-size: 10px;">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div runat="server" id="DivMessage" style="text-align: center; color: Red; display: block">
                                        </div>
                                        <p>
                                        </p>
                                        <p>
                                        </p>
                                        <div id="rpt_grid" runat="server" class="gridDiv">
                                        </div>
                                        <div id="rpt_AQgrid" runat="server" class="gridDiv">
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
