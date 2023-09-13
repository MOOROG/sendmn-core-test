<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Summary.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveModification.Summary" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
      <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="Summary.aspx">TRANSACTION MODIFICATION APPROVE SUMMARY</a></li>
                        </ol>
                        <li class="active">
                            <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                        </li>
                    </div>
                </div>
            </div>
            <div id="newsFeeder" runat="server" style="width: 600px;">
                <div id="divSummary" runat="server">
                    The modification request has been approved successfully.
                    <br />
                    <br />
                    <asp:Label ID="controlNoLbl" runat="server"></asp:Label>&nbsp;:
                    <asp:Label ID="controlNo" runat="server" Style="color: red; font-weight: bold;"></asp:Label><br />
                    <div id="DvModification" runat="server" style="width: 600px;">
                    </div>
                    <div id="postPaidAlertMsg" runat="server" style="width: 600px; background: red;" visible="false"></div>
                </div>
                <asp:HiddenField ID="HiddenField1" runat="server" />
            </div>
            <asp:HiddenField ID="hdnEmail" runat="server" />
            <div>
                <asp:Button ID="btnBack" runat="server" Text="Back To Pending List"
                    OnClick="btnBack_Click" CssClass="btn btn-primary" ></asp:Button>
            </div>
        </div>
    </form>
</body>
</html>
