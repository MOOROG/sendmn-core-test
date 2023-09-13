<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Continue.aspx.cs" Inherits="Swift.web.Remit.APIDataMapping.BankDataMapping.Continue" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function Validate() {
            var country = $('#countryDDL').val();
            var partner = $('#partnerDDL').val();
            var paymentType = $('#payoutMethodDDL').val();
            var noOfBanksDDL = $('#noOfBanksDDL').val();
            var partnerName = $("#partnerDDL option:selected").text();
            var countryName = $("#countryDDL option:selected").text();
            var paymentTypeName = $("#payoutMethodDDL option:selected").text();

            var qs = "paymentTypeName=" + paymentTypeName + "&countryName=" + countryName + "&partnerName=" + partnerName + "&country=" + country + "&partner=" + partner + "&paymentType=" + paymentType + "&noOfBanksDDL=" + noOfBanksDDL;

            window.location.href = "/Remit/APIDataMapping/BankDataMapping/ManageBankData.aspx?" + qs;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">API Data Mapping </a></li>
                            <li class="active"><a href="ManageBankData.aspx">Map Bank Data </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <asp:UpdatePanel ID="up1" runat="server">
                    <ContentTemplate>
                        <div class="col-md-6">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Map Bank Data
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Partner:</label>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="form-group">
                                            <asp:DropDownList ID="partnerDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Country:</label>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="form-group">
                                            <asp:DropDownList ID="countryDDL" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="countryDDL_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Payout Method:</label>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="form-group">
                                            <asp:DropDownList ID="payoutMethodDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-12 col-md-offset-3">
                                        <input type="button" class="btn btn-primary" onclick="return Validate();" value="Continue" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </form>
</body>
</html>
