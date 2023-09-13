<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyBank.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.CustomerControls.ModifyBank" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Operation</title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.min.js"></script>
    <script src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/js/functions.js"> </script>
    <script type="text/javascript">
        function CheckFormValidation() {
            var reqField = "searchBy,searchValue,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }

        function CheckFormValidation1() {
            var reqField = "acNameInBank,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }

        function CheckFormValidation2() {
            var reqField = "newAccountNumber,newBank,";
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
                            <li><a href="#">Customer Management</a></li>
                            <li class="active"><a href="List.aspx">Modify Customer Bank </a></li>
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
                            <h4 class="panel-title">Modify Customer Bank
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="">
                                    <label>
                                        Search By:</label>
                                    <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Alien/National Id" Value="idNumber"></asp:ListItem>
                                        <asp:ListItem Text="Email Id" Value="email"></asp:ListItem>
                                        <asp:ListItem Text="Wallet Number" Value="walletAccountNo"></asp:ListItem>
                                    </asp:DropDownList>
                                </label>
                                <div class="col-md-4">
                                    <label>
                                        Search Value:</label>
                                    <asp:TextBox ID="searchValue" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4" style="margin-top: 20px;">
                                    <asp:Button ID="searchButton" runat="server" Text="Search Customer" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation();" OnClick="searchButton_Click" />
                                </div>
                            </div>
                            <div id="hideDivSearch" runat="server" visible="false">
                                <div class="form-group">
                                    <label class="col-md-6">
                                        <label>
                                            Full Name:</label>
                                        <asp:Label ID="fullName" runat="server"></asp:Label>
                                    </label>
                                    <div class="col-md-6">
                                        <label>
                                            Alien/National ID:</label>
                                        <asp:Label ID="alienNationId" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-6">
                                        <label>
                                            Old Bank:</label>
                                        <asp:Label ID="oldBank" runat="server"></asp:Label>
                                    </div>
                                    <div class="col-md-6">
                                        <label>
                                            Old A/c Number:</label>
                                        <asp:Label ID="oldAccNumber" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-1 control-label" for="">
                                        <label>
                                            New Bank:</label>
                                    </label>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="newBank" CssClass="form-control" runat="server"></asp:DropDownList>
                                    </div>
                                    <label class="col-md-1 control-label" for="">
                                        <label>
                                            New A/c Number:</label>
                                    </label>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="newAccountNumber" CssClass="form-control" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-6">
                                        <asp:Button ID="checkBtn" runat="server" Text="CHECK" OnClientClick="return CheckFormValidation2();" CssClass="btn btn-primary m-t-25" OnClick="checkBtn_Click" />
                                    </div>
                                </div>
                            </div>
                            <div id="hiddenDivCheck" runat="server" visible="false">
                                <div class="form-group">
                                    <label class="col-md-6">
                                        <label>
                                            A/C Name In Bank:</label>
                                        <asp:TextBox ID="acNameInBank" runat="server" CssClass="form-control"></asp:TextBox>
                                    </label>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-6">
                                        <label>
                                            A/C Name In Bank:</label>
                                        <asp:FileUpload ID="VerificationDoc3" runat="server" CssClass="form-control" />
                                        <asp:Image runat="server" ID="verfDoc3" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                    </label>
                                </div>
                                <div class="form-group">
                                    <asp:Button ID="Modify" runat="server" Text="MODIFY" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation1();" OnClick="Modify_Click" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddHomePhone" runat="server" />
        <asp:HiddenField ID="hddImageName" runat="server" />
        <asp:HiddenField ID="hddCustomerId" runat="server" />

        <!-- @Max-2018.09 -->
        <asp:HiddenField ID="hddDob" runat="server" />
        <asp:HiddenField ID="hddCountryCode" runat="server" />
        <asp:HiddenField ID="hddGender" runat="server" />
        <asp:HiddenField ID="hddBankCode" runat="server" />
        <asp:HiddenField ID="hddIdType" runat="server" />
    </form>
    <script type="text/javascript">
        $(document).ready(function () {
            $("#<% =VerificationDoc3.ClientID %>").change(function () {
                readURL(this, "verfDoc3");
            });
        });

        function readURL(input, id) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#' + id).attr('src', e.target.result);
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };
    </script>
</body>
</html>