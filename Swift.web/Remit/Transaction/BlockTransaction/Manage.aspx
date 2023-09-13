<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.BlockTransaction.Manage" %>

<%@ Register Src="../../UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

</head>

<body>

    <form id="form1" runat="server">

        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="Manage.aspx">Block  Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <div class="panel-body">
                                    <div id="divSearch" runat="server" >
                                        <div class="row">
                                            <div class="col-md-12">
                                                <b>Find By Control No</b>
                                                <span class="errormsg">*</span>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="controlNo"
                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="approve" ForeColor="Red"
                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                <br />
                                                <asp:TextBox ID="controlNo" runat="server" class="form-control"></asp:TextBox>
                                                
                                                <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary" Style="margin-top:5px;"
                                                    ValidationGroup="approve" OnClick="btnSearchDetail_Click" />
                                            </div>
                                        </div>

                                    </div>
                                    <div id="divTranDetails" runat="server" visible="false">
                                        <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" />
                                    </div>
                                    <div id="divComments" runat="server" visible="false" style="margin-left: 20px">
                                        <h3>Comments</h3>

                                        <asp:TextBox ID="comments" runat="server" TextMode="MultiLine" Width="500px"
                                            Height="50px"></asp:TextBox>
                                        <br />
                                        <br />
                                        <asp:Button ID="btnBlock" runat="server" Text="Block" CssClass="btn btn-primary"
                                            OnClick="btnBlock_Click" />
                                        <asp:Button ID="btnUnBlock" runat="server" Text="UnBlock" CssClass="btn btn-primary"
                                            OnClick="btnUnBlock_Click" />


                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>


                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </form>
</body>
