<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Summary.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.ModifyRequest.Summary" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="Summary.aspx">Modification Request</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="newsFeeder" runat="server" style="width: 600px;">
                <div id="divSummary" runat="server">
                    The modification request has been processed. BRN Help Desk will get back to you shortly.<br />
                    <br />
                    <asp:Label ID="controlNoLbl" runat="server"></asp:Label>&nbsp;:
                    <asp:Label ID="controlNo" runat="server" Style="color: red; font-weight: bold;"></asp:Label><br />

                    <div id="DvModification" runat="server" style="width: 600px;">
                    </div>

                    <p>
                        Please email to support@jme.com.np for any queries.
                    </p>
                </div>
                <asp:HiddenField ID="hdnEmail" runat="server" />
            </div>
        </div>
    </form>
</body>
</html>