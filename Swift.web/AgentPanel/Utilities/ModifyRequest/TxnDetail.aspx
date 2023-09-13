<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TxnDetail.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.ModifyRequest.TxnDetail" %>

<%@ Register TagPrefix="uc1" TagName="UcTransactionSend" Src="~/Remit/UserControl/UcTransactionSend.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />--%>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style>
        .table > tbody > tr > td {
            border: none !important;
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
                            <li class="active"><a href="TxnDetail.aspx">Modification Request</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <%--<div class="bredCrom" style="width: 90%"><% =PrintBreadCrum()%></div>--%>
            <div>
                <div id="divMsg" runat="server" style="margin-top: 100px"></div>
                <div id="divTranDetails" runat="server" visible="false">
                    <div>
                        <uc1:UcTransactionSend ID="ucTran" runat="server" ShowSettlment="true" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>