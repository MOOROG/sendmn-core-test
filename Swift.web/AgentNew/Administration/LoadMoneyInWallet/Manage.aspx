<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentNew.Administration.LoadMoneyInWallet.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js" type="text/javascript"></script>
    <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>

    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .label {
            color: #979797 !important;
            font-size: 12px;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

           legend {
            background-color: red !important;
            color: white !important;
            margin-bottom: 0 !important;
            font-family: Verdana, Arial;
            font-size: 18px;
            margin-right: 2px;
            padding-bottom: 6px !important;
            text-align: -webkit-center;
        }

        fieldset {
    padding: 5px !important;
    margin: 20px !important;
    border: 2px solid #943337 !important
}
    </style>
<script type="text/javascript">
  function commaSeparate(){
    var val = $('#<%=amountUpload.ClientID%>').val();
    val = val.replace(/,/g, '');
    val = val.replace(/[^0-9]/g,'');
    val = String(val).replace(/(.)(?=(\d{3})+$)/g,'$1,');
    $('#<%=amountUpload.ClientID%>').val(val);
  }
</script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="List.aspx">Load Money </a></li>
                        </ol>
                    </div>
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Load Money In Wallet</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="divControlno" runat="server">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                <b>Wallet No.</b> :
                                            </label>
                                            <div class="col-md-7    ">
                                                <asp:TextBox ID="walletNo" runat="server" CssClass="form-control" Required="required"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-md-4 col-md-offset-3">
                                                <asp:Button ID="btnSearch" runat="server" Text="Get Wallet Details To Load Money" CssClass="btn btn-primary m-t-25"
                                                    OnClick="btnSearch_Click" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                               <div id="divTranDetails" runat="server" visible="false">
                        <fieldset>
                            <legend>Wallet Details</legend>
                            <div class="row">
                                 <div class="col-md-12">
                                <div class="form-group">
                                    <div class="col-md-3">
                                        <label class="control-label">
                                            <b>Mobile No.</b> :
                                        </label>
                                        <br />
                                        <asp:TextBox ID="mobNo" disabled="disabled" runat="server" CssClass="form-control disabled"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="control-label">
                                            <b>Full Name</b> :
                                        </label>
                                        <br />
                                        <asp:TextBox ID="fullName" disabled="disabled" runat="server" CssClass="form-control disabled"></asp:TextBox>
                                    </div>
                                        <div class="col-md-3">
                                            <label class="control-label">
                                                <b>Upload Amount</b> :
                                            </label>
                                      <br />
                                            <asp:TextBox ID="amountUpload" runat="server" Placeholder="Enter Amount To be Upload" CssClass="form-control" onkeyup="javascript:commaSeparate();"></asp:TextBox>
                                        </div>
                                  <div class="col-md-3">
                                        <label class="control-label">
                                            </label>
                                      <br />
                                            <asp:Button ID="btnLoadMoney" runat="server" CssClass="btn btn-primary" Text="Load Money" OnClick="btnLoadMoney_Click" />
                                            &nbsp;<asp:Button ID="clearData" runat="server" CssClass="btn btn-primary" Text="Clear Data" OnClick="clearData_Click" />
                                          
                                              <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                ConfirmText="Are you sure to load money in this wallet number?" Enabled="True" TargetControlID="btnLoadMoney">
                                            </cc1:ConfirmButtonExtender>
                                        </div>
                                </div>
                                </div>
                            </div>
                          
                        </fieldset>
                      </div>
                        </div>
                    </div>
                 
                </div>
            </div>
        </div>
        <asp:HiddenField runat="server" ID="hddWalletNo" />
    </form>
</body>
</html>
