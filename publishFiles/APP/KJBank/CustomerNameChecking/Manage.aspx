<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.KJBank.CustomerNameChecking.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/functions.js"> </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            $(".date-field").attr("readonly", "readonly");
			ShowCalDefault(".date-field");
			$('.date-field').mask('0000-00-00');
        });
    </script>
    <style>
        legend {
            background-color: #ed1c24;
            color: white;
            margin-bottom: 0 !important;
        }

        fieldset {
            padding: 10px !important;
            margin: 5px !important;
            border: 1px solid rgba(158, 158, 158, 0.21) !important;
        }
    </style>

    <script>
        function CheckFormValidation() {
            var reqField = "searchBy,searchValue,";
            if (ValidRequiredField(reqField) == false) {
                alert("Sorry, you can't keep seachBy field and searchByValue empty!");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hddbankCode" runat="server" />
        <asp:HiddenField ID="hddobpId" runat="server" />
        <asp:HiddenField ID="hddwallletNo" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="Manage.aspx">Customer Real Name Verification</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Verification Details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="">
                                    <label>Search By:</label>
                                    <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Email" Value="email"></asp:ListItem>
                                        <asp:ListItem Text="Id Number" Value="idNumber" Selected="True"></asp:ListItem>
                                    </asp:DropDownList>
                                </label>
                                <div class="col-md-4">
                                    <label>Search Value:</label>
                                    <asp:TextBox ID="searchValue" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <asp:Button Style="margin-top: 30px" ID="btnViewDetail" runat="server" Text="Search Details" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation();" OnClick="btnViewDetail_Click" />
                                </div>
                            </div>
                            <hr />
                            <div id="hiddenError" runat="server" visible="false">
                                <fieldset>
                                    <legend>Verification Details</legend>
                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-lg-12 col-md-12 form-group">
                                                <div id="errorMsg" runat="server" style="color: red; font-size: 15px"></div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="row">
                                                <div class="col-lg-12 col-md-12 form-group">
                                                    <asp:Button ID="btnClear1" runat="server" Text="Clear Data" CssClass="btn btn-primary m-t-25" OnClick="btnClear_Click" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                            <div id="hiddenSearch" runat="server" visible="false">
                                <fieldset>
                                    <legend>Verification Details</legend>
                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Customer Name:
                                                </label>
                                                <asp:TextBox ID="customerName" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Customer Mobile No:
                                                </label>
                                                <asp:TextBox ID="mobile" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Gender:
                                                </label>
                                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    ID Type:
                                                </label>
                                                <asp:DropDownList ID="ddlIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    ID Number:
                                                </label>
                                                <asp:TextBox ID="idNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Date of Birth: </label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date dpYears">
                                                            <asp:TextBox runat="server" ID="dob" CssClass="form-control date-field"></asp:TextBox>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Bank Name:
                                                </label>
                                                <asp:DropDownList ID="ddlBankName" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Account Number:
                                                </label>
                                                <asp:TextBox ID="accountNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Country Name:
                                                </label>
                                                <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-lg-4 col-md-4 form-group">
                                                <asp:Button ID="btnVerification" runat="server" Text="Click For Verification" CssClass="btn btn-primary m-t-25" OnClick="btnVerification_Click" />
                                                &nbsp;&nbsp;<asp:Button ID="btnClear" runat="server" Text="Clear Data" CssClass="btn btn-primary m-t-25" OnClick="btnClear_Click" />
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
    </form>
</body>
</html>