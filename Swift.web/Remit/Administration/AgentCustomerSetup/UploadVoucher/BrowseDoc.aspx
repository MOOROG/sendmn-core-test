<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BrowseDoc.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentCustomerSetup.UploadVoucher.BrowseDoc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        function ShowBtn(id) {
            document.getElementById(id).style.display = 'block';
        }

        function hideBtn(id) {
            document.getElementById(id).style.display = 'none';
        }

        function DeleteDocument(id) {
            document.getElementById("docId").value = id;
            document.getElementById("btnDelete").click();
        }
    </script>
    <style type="text/css">
        div.show-image {
            position: relative;
            float: left;
            margin: 5px;
        }

            div.show-image:hover img {
                opacity: 0.5;
            }

            div.show-image:hover input {
                display: block;
            }

            div.show-image input {
                position: absolute;
                display: none;
            }

                div.show-image input.delete {
                    top: 140px;
                    left: 70%;
                }
    </style>
</head>
<body>
    <div class="row">
        <div class="col-sm-12">
            <div class="page-title">
                <h4>BROWSE DOC
                </h4>
                <ol class="breadcrumb">
                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                    <li class="active"><a href="#">Transaction</a></li>
                    <li class="active"><a href="#">Upload Docs</a></li>
                </ol>
            </div>
        </div>
    </div>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdntnxType" runat="server" />
        <asp:HiddenField ID="hdnAgentId" runat="server" />
        <asp:HiddenField ID="docId" runat="server" />
        <asp:HiddenField ID="hdnTranId" runat="server" />
        <asp:HiddenField ID="txnType" runat="server" />
        <asp:HiddenField ID="hdnIcn" runat="server" />
        <%--<asp:Button ID="btnDelete" runat="server" Text="Delete" OnClick="btnDelete_Click"
        Style="display: none;" />--%>
        <div class="panel panel-default" runat="server" id="uploadPanel">
            <div class="panel-heading">Upload Document</div>
            <div class="panel-body">
                <input id="fileUpload" runat="server" name="fileUpload" type="file" /><br />
                <br />
                Upload As:
            <asp:Button ID="voucher" runat="server" Text="Voucher" Style="width: 100px !important; height: 40px !important;"
                OnClick="voucher_Click" />
                <asp:Button ID="id" runat="server" Text="Id" Style="width: 100px !important; height: 40px !important;"
                    OnClick="id_Click" />
                <asp:Button ID="Both" runat="server" Text="Both" Style="width: 100px !important; height: 40px !important;"
                    OnClick="Both_Click" />
            </div>
        </div>
        <div id="ingDisplay" runat="server">
        </div>
    </form>
</body>
</html>