<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckStatus.aspx.cs" Inherits="Swift.web.Remit.Transaction.ThirdPartyTXN.KumariBank.CheckStatus.CheckStatus" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <title></title>
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
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Transaction </a></li>
                            <li class="active"><a href="List.aspx">Check Status</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Check Status
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Control Number:<span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="rfv" runat="server" ControlToValidate="controlNumberTextBox" Display="Dynamic"
                                        SetFocusOnError="true" ErrorMessage="Required!" ForeColor="Red">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="controlNumberTextBox" runat="server" Category="acInfo" CssClass="form-control"
                                        Title="Blank for All" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-3">
                                    <%--<input type="button" value="Search" onclick="CheckFormValidation();" class="btn btn-primary m-t-25" />--%>
                                    <asp:Button runat="server" Text="Search" ID="SearchButton" CssClass="btn btn-primary m-t-25" OnClick="SearchButton_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>CODE</th>
                                    <th>AGENT_SESSION_ID</th>
                                    <th>MESSAGE</th>
                                    <th>REFNO</th>
                                    <th>SENDER_NAME</th>
                                    <th>RECEIVER_NAME</th>
                                    <th>PAYOUTAMT</th>
                                    <th>PAYOUTCURRENCY</th>
                                    <th>STATUS</th>
                                    <th>STATUS_DATE</th>
                                </tr>
                            </thead>
                            <tbody id="statusCheckTableResult" runat="server">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

