<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.AgentExRateMenu.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript">
        var gridName = "<% =GridName%>";

        function GridCallBack() {
            var id = GetRowId(gridName);
            if (id == "0") {
                alert("You can not modify this record. This is not agent specific record.");
                return;
            }
            if (id != "") {
                GetElement("<% =btnEdit.ClientID%>").click();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
            } else {

                GetElement("<% =btnSave.ClientID%>").disabled = true;
                ResetForm();
                ClearAll(gridName);
            }
        }

        function ResetForm() {
            SetValueById("<% =country.ClientID%>", "");
            SetValueById("<% =agent.ClientID%>", "");
            SetValueById("<% =exRateMenu.ClientID%>", "");
        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID%>").disabled = false;
            SetValueById("<% =hdnId.ClientID%>", "0");
            ClearAll(gridName);
        }
    </script>
    <style>
        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
        }

            .page-title h1 {
                color: #656565;
                font-size: 20px;
                text-transform: uppercase;
                font-weight: 400;
            }

            .page-title .breadcrumb {
                background-color: transparent;
                margin: 0;
                padding: 0;
            }

        .breadcrumb > li {
            display: inline-block;
        }

            .breadcrumb > li a {
                color: #0E96EC;
            }

            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }

        .tabs > li > a {
            padding: 10px 15px;
            background-color: #444d58;
            border-radius: 5px 5px 0 0;
            color: #fff;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top: 100px;">
            <tr>
                <td>
                    <div class="page-title">
                        <h1>Rate Setup<small></small></h1>
                        <ol class="breadcrumb">
                            <li><a href="#"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Remittance</a></li>
                            <li><a href="#">Exchange Rate</a></li>
                            <li class="active"><a href="#">Agent Exchange Rate Menu</a></li>
                        </ol>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:HiddenField ID="hdnId" runat="server" />
                    <asp:Button ID="btnEdit" runat="server" OnClick="btnEdit_Click" Style="display: none;" />
                    <table style="margin-left: 10px; width: 100%;" class="sendCss">
                        <tr>
                            <td>
                                <label>
                                    Country
                            <span class="ErrMsg">*</span></label>
                                <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="country"
                                    ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="receivingmode"
                                    SetFocusOnError="True">
                                </asp:RequiredFieldValidator>

                                <asp:DropDownList ID="country" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                    OnSelectedIndexChanged="country_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <label>Agent</label>

                                <asp:DropDownList ID="agent" runat="server" CssClass="form-control" Width="250px"></asp:DropDownList>
                            </td>
                            <td>
                                <label>
                                    Menu
                            <span class="ErrMsg">*</span></label>
                                <asp:RequiredFieldValidator ID="rfv2" runat="server" ControlToValidate="exRateMenu"
                                    ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="receivingmode"
                                    SetFocusOnError="True">
                                </asp:RequiredFieldValidator>

                                <asp:DropDownList ID="exRateMenu" runat="server" CssClass="form-control" Width="140px">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="receivingmode" OnClick="btnSave_Click" />
                                <input type="button" value="New" onclick=" NewRecord(); " class="button" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="12">
                    <br />
                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>