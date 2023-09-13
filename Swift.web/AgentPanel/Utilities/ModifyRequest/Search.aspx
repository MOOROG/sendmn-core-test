<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.ModifyRequest.Search" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register TagPrefix="uc1" TagName="UcTransactionSend" Src="~/Remit/UserControl/UcTransactionSend.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <style>
        .table > tbody > tr > td {
            border: none !important;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }

        .ErrMsg {
            color: red;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="Search.aspx">Modification Request</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
                <ProgressTemplate>
                    <div style="position: fixed; left: 530px; top: 0px; background-color: white; border: 1px solid black;">
                        <img alt="progress" src="../../../Images/Loading_small.gif" />
                        Processing...
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div id="divControlno" class="col-md-12" runat="server">
                        <div class="panel panel-default">
                            <div class="panel-heading">Search By</div>
                            <div class="panel-body">
                                <div class="form-group">
                                    <div class="row">
                                        <center><span class="ErrMsg" id="err" style="font-size: 15px;" runat="server" visible="false">One of field is required!</span></center>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="row">
                                            <label class="col-md-3 form-group">
                                                <%=GetStatic.GetTranNoName()%> <span class="ErrMsg" id="spancontrolNo" runat="server" visible="false">*</span>
                                            </label>
                                            <div class="col-md-9 form-group">
                                                <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <label class="col-md-3 form-group">Tran No <span class="ErrMsg" id="spantranId" runat="server" visible="false">*</span></label>
                                            <div class="col-md-9 form-group">
                                                <asp:TextBox ID="tranId" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-3 col-md-offset-3 form-group">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary"
                                                    OnClick="btnSearch_Click" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%-->>Grid (List) Pending Modification Request--%>
                    <div id="pendList" runat="server">
                        <br />
                        <div>
                            <div id="grd_tran" runat="server"></div>
                        </div>
                    </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>