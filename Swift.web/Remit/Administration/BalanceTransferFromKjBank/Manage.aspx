<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.BalanceTransferFromKjBank.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
  
     <script type="text/javascript">
         function AccountDetailKJBank() {
             var receiverAccountNo = document.getElementById('txtReceiverAccountNo').value;
             var dataToSend = { MethodName: 'GetAccountDetailKJBank', body: receiverAccountNo };
             var options =
                         {
                             url: '<%=ResolveUrl("Manage.aspx")%>',
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                document.getElementById('lblReceiverName').innerText = response.Result;
                            }
                        };
                        $.ajax(options);
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Balance Transfer</a></li>
                            <li class="active"><a href="Modify.aspx">Balance Transfer From KjBank </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Balance Transfer From Kwangju Bank
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-6 form-group">
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-md-3">
                                                        Receiver AccountNo:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="txtReceiverAccountNo" runat="server" CssClass="form-control required"></asp:TextBox>
                                                        <asp:RequiredFieldValidator
                                                            ID="RequiredFieldValidator3" runat="server" ControlToValidate="txtReceiverAccountNo" ForeColor="Red"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="transfer" SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-md-3">
                                                        Receiver Name:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:Label ID="lblReceiverName" runat="server"></asp:Label>
                                                    </div>
                                                </div>
                                            </div>
                                             <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-md-3">
                                                        Amount:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control required"></asp:TextBox>
                                                        <asp:RequiredFieldValidator
                                                            ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtAmount" ForeColor="Red"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="transfer" SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-offset-3 col-md-8">
                                                        <asp:Button ID="btnTransfer" runat="server" Text="Transfer" ValidationGroup="transfer"
                                                            CssClass="btn btn-primary m-t-25" OnClick="btnTransfer_Click" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
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
