<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RiaEntryForm.aspx.cs" Inherits="Swift.web.Remit.Transaction.RiaTransaction.RiaEntryForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Send Transaction</title>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function CheckFormValidation() {
            var reqField = "remitDate,cAmt,exRateUSD,sCharge,senderName,sIdNumber,sCountry,sEmail,controlNumber,receiverName,rCountry,orderNumber,seqNumber,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Transaction</a></li>
                            <li class="active"><a href="RiaEntryForm.aspx">RIA Transaction Entry </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">RIA Transaction Entry
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Remittance Date(Transaction Date): <span class="notifyRequired">*</span></label>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="remitDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Collect Amount: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="cAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        <%=Swift.web.Library.GetStatic.ReadWebConfig("currencyUSA","") %> Exchange Rate: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="exRateUSD" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Service Charge: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="sCharge" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender Name: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="senderName" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender ID Type: <span class="notifyRequired">*</span></label>
                                    <asp:DropDownList ID="idType" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender ID Number: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="sIdNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender Native Country: <span class="notifyRequired">*</span></label>
                                    <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender Mobile: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="sMobile" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sender Email: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="sEmail" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Pin Number: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="controlNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Receiver Name: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="receiverName" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                
                            </div>
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Receiver Country: <span class="notifyRequired">*</span></label>
                                    <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Payout Amount: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="pAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Payout Currency: <span class="notifyRequired">*</span></label>
                                    <asp:DropDownList ID="pCurr" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                                
                            </div>
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Sequence Number: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="seqNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label class="control-label" for="">
                                        Order Number: <span class="notifyRequired">*</span></label>
                                    <asp:TextBox ID="orderNumber" placeholder="KRXXXXXXXXXX" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 form-group">
                                    <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary m-t-25" Text="Save" OnClick="btnSave_Click" OnClientClick="return CheckFormValidation()" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
