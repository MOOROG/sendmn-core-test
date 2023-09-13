<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TxnDocument.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Send.Domestic.TxnDocument" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        $.validator.messages.required = "Required";

        $(document).ready(function () {
            $("#btnDocUpload").click(function () {
                $("#form1").validate();
            });

        });

        function ViewImage(img, style) {
            if (style == 2) {
                document.getElementById("imgHisplay").style.display = "none";
                document.getElementById("<%=dvUpload.ClientID %>").style.display = "block";
            }
            else {
                document.getElementById("imgHisplay").style.display = "block";
                document.getElementById("<%=dvUpload.ClientID %>").style.display = "none";
                document.getElementById("imgHisplay").innerHTML = "<img class='linkText' width='610' height='490' src='" + img + "' onclick='ViewImage(1,2);'>";
            }

        }

        function DeleteImage(fileName) {
            if (confirm("Are you sure to delete this image?")) {
                SetValueById("<%=hddFileId.ClientID %>", fileName);
                GetElement("<%=btnDocDelete.ClientID %>").click();
            }
        }

        function openScanWindow(user, batchId) {
            var url = "../../../../../ScanDocument/Scan.aspx?t=txntmp&txnbatchId=" + batchId + "&u=" + user;
            OpenInNewWindow(url);
        }
        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }
        function RedirectToIframe(url) {
            window.open(url, "_self");
        }
        function getQuerystring(key, default_) {
            if (default_ == null) default_ = "";
            key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
            var regex = new RegExp("[\\?&]" + key + "=([^&#]*)");
            var qs = regex.exec(window.location.href);
            if (qs == null)
                return default_;
            else
                return qs[1];
        }
        function openImageWindow(path) {
            OpenInNewWindow(path);
        }
        function closeDialog() {
            try {
                window.opener.pageLoadonDemand();
            }
            catch (e)
                { }

            top.window.close();
            return false;
        }
        function pageLoadonDemand() {
            var ctrl = document.getElementById("txtPageLoad");
            ctrl.value = "reload";
            __doPostBack('txtPageLoad', '');
        }
        function updateDocStatus(myvalue) {
            try {
                //alert(myvalue);
                var oMyObj = dialogArguments;
                oMyObj.pageLoadonDemand(myvalue);
            }
            catch (e)
                { }
        }
    </script>
    <style type="text/css">
        body {
            padding: 0;
            margin: 0;
            font-family: Arial;
            font-size: 12px;
        }

        div.container {
            padding: 5px;
            /*max-width: 650px;*/
            overflow: hidden;
        }

        div#custId {
            border: 1px solid #CACACA;
            padding-bottom: 5px;
            margin-bottom: 5px;
            overflow: hidden;
        }

            div#custId img {
                max-width: 630px;
                margin: 0 auto;
                display: block;
            }

        fieldset {
            border-radius: 7px;
        }

        legend.legendCss {
            font: 17px/21px Calibri, Arial, Helvetica, sans-serif;
            padding: 2px;
            font-weight: bold;
            font-family: Verdana, Arial;
            font-size: 12px;
            padding: 1px;
            margin-left: 2em;
        }

        td.frmLable {
            width: 70px;
            font-weight: 600;
        }

        input.error {
            background-color: #FFD9D9;
        }

        label.error {
            color: #E00024;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField runat="server" ID="hddFileId" />

        <div class="page-wrapper container">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>UPLOAD TRANSACTION DOCUMENT
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="/#">Transaction</a></li>
                            <li class="active"><a href="/#">Transaction Documents</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div id="dvUpload" runat="server">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">Transaction Documents</h4>
                            </div>
                            <div class="panel-body">
                                <table class="table table-condensed">
                                    <tr>
                                        <td class="frmLable">Document:
                                        </td>
                                        <td>
                                            <input id="fileUpload" runat="server" name="docUpload" type="file" />
                                        </td>
                                        <td>
                                            <input id="btnScanDoc" onclick="openScanWindow()" runat="server" type="button" value="Scan Document" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" nowrap="nowrap">Type:
                                        </td>
                                        <td colspan="2">
                                            <asp:DropDownList Width="68.5%" runat="server" CssClass="required form-control" ID="docType">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Description:
                                            <label style="color: Red; font-weight: bold;">
                                                *
                                            </label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="docDesc" Width="68.5%" runat="server" MaxLength="100" CssClass="required form-control"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td colspan="2">
                                            <asp:Button ID="btnDocUpload" runat="server" Text="Upload" OnClick="btnDocUpload_Click" />
                                            <input type="button" value="Close" onclick="closeDialog();" />
                                            <asp:Button ID="btnDocDelete" runat="server" Text="Delete" Style="display: none"
                                                OnClick="btnDocDelete_Click" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td class="style2" colspan="2">
                                            <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-10 col-md-offset-1">
                            <label class="alert alert-danger" style="width: 76%">
                                * File size should be less than 2 MB. File types other than image(JPG/JPEG,GIF,PNG)
                                are not acceptable.</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-9 col-md-offset-1">
                            <div runat="server" id="txnId" style="padding: 5px; width: 85%;"></div>
                        </div>
                    </div>
                    <asp:TextBox ID="txtPageLoad" Style="display: none;" runat="server" AutoPostBack="true"></asp:TextBox>
                    <div id="imgHisplay" style="display: none"></div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>