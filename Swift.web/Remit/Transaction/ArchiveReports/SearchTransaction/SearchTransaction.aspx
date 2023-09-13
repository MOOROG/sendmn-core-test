<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchTransaction.aspx.cs"
    Inherits="Swift.web.Remit.Transaction.ArchiveReports.SearchTransaction.SearchTransaction" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <link href="../../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
  <%--  <script language="javascript" type = "text/javascript">
        function resizeIframe()
        {
        }
    </script>--%>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server">
    </asp:ScriptManager>
         <div class="container-fluid">
            <div id="divControlno" runat="server">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Search Transaction By</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                <div class="col-md-6 ">
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        <b>
                                            <asp:Label ID="controlNoName" runat="server"></asp:Label></b> :
                                    </label>
                                    <div class="col-md-7    ">
                                        <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4 control-label">Tran Id : </label>
                                    <div class="col-md-7">
                                        <asp:TextBox ID="txnNo" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-4 col-md-offset-4">
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnSearch_Click" />
                                    </div>
                                </div>
                                </div>
                                    </div>
                                <div class="form-group">
                                    <div id="divTranDetails" runat="server" visible="false">
                                        <div>
                                            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    <%--<div class="bredCrom" style="width: 90%">
        Archive Reports » Search Transaction</div>
    <div>
        <div id="divControlno" runat="server">
            <table style="margin-left: 20px;">
                <tr>
                    <td valign="top" style="width: 800px;">
                        <fieldset>
                            <legend>Search By</legend>
                            <table>
                                <tr>
                                    <td>
                                        <b>
                                            <asp:Label ID="controlNoName" runat="server"></asp:Label></b>
                                        <br />
                                        <asp:TextBox ID="controlNo" runat="server" Width="120px"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="controlNo"
                                            ForeColor="Red" Display="Dynamic" ErrorMessage="*" ValidationGroup="" SetFocusOnError="True">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                    <td>
                                        <b>Tran Id</b>
                                        <br />
                                        <asp:TextBox ID="txnNo" runat="server" Width="120px"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search"
                                            CssClass="button" OnClick="btnSearch_Click" />
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divTranDetails" runat="server" visible="false">
            <div>
                <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true"
                    ShowCommentBlock="true" />
            </div>
        </div>
    </div>--%>
    </form>
</body>
</html>
