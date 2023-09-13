<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDocument.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerRegistration.CustomerDocument" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="../../../ui/css/menu1.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>

    <script>
        $(document).ready(function () {
            var reqFromCustDetail = '<%=ReqFromCustDetail()%>';
            if (reqFromCustDetail == "true") {
                HideSearchDiv();
            }

            $("#<% =fileDocument.ClientID %>").change(function () {
                readURL(this, "fileDisplay");
            });
            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                <% = txtSearchData.InitFunction() %>
                $('.displayForm').hide();
                $('#txtSearchData_aText').val('');
            });
            $('#txtSearchData_aSearch').change(function () {
                searchValue = $(this).val();
                if (searchValue === null || searchValue === "") {
                    $('#<%=ddlDocumentType.ClientID%>').val('');
                    $('#<%=fileDocument.ClientID%>').val('');
                    $('#<%=txtDocumentDescription.ClientID%>').val('');
                    $('.displayForm').hide();
                }
            });
        });
        function ReloadParent() {
            window.onunload = window.opener.location.reload();
        }

        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        };
        function HideFormDisplay() {
            $('.displayForm').hide();
        }

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hdncustomerId.ClientID%>').val(d[0]);
            $('#<%=hdncustomerName.ClientID%>').val(d[1]);
            $('#<%=clickBtnForGetCustomerDetails.ClientID%>').click();
            $('.displayForm').show();
        };
        function editPage(documentId) {
            $('#<%=hdnDocumentTypeId.ClientID%>').val(documentId);
            $('#<%=clickEditCustomerDocument.ClientID%>').click();
        }

        function CheckFormValidation() {
            var reqField = "<% =ddlDocumentType.ClientID %>,<% =fileDocument.ClientID %>,txtSearchData_aText,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
        function showImage(param) {
            var url = $(param).attr("src");
            var imageName = url.split('?imageName=')[1];
            if (imageName === undefined) {
                var image = new Image(825, 500);
                image.src = $(param).attr('src');
                var w = window.open("", 'targetWindow', 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=825,height=500');
                w.document.write(image.outerHTML);
                w.document.close();
                return;
            }
            if (imageName === "") {
                url = "../../../../Images/na.gif";
            }
            var param = "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
            PopUpWindow(url, param);
        };

        function showDocument(cdId, fileType) {
            var url = "DocumentView.aspx?cdId=" + cdId + "&fileType=" + fileType;
            var param = "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1";
            PopUpWindow(url, param);
        };
        function PopulateAutoComplete(custInfo) {
            var custInfoArray = custInfo.split(',');
            var custId = custInfoArray[0];
            var custName = custInfoArray[1];
            var d = [custId, custName];
            SetItem("txtSearchData", d);
            ReloadParent();
        }
        function HideSearchDiv() {
            $("#SearchDiv").attr("style", "display:none");
        }
        function readURL(input, id) {
            if (input.files && input.files[0]) {
                a = input.files.fil
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#' + id).attr('src', e.target.result);
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
        function ClearClicked() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            $('.displayForm').hide();
            $('#membershipId').text('');
            $('#customerName').text('');
            event.preventDefault();
        }
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            CalTillToday("#grid_list_createdDate");
        });
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
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="CustomerDocument.aspx?customerId=<%=hdncustomerId.Value %>&cdId=<%=hdnDocumentTypeId.Value %>&hideSearchDiv=<%=hideSearchDiv.Value %>">Customer Document </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <%--<li role="presentation"><a href="List.aspx">Customer List</a></li>--%>
                        <li class="active"><a href="CustomerDocument.aspx?customerId=<%=hdncustomerId.Value %>&cdId=<%=hdnDocumentTypeId.Value %>">Customer Document </a></li>
                    </ul>
                </div>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Document Type :<label id="customerName" runat="server"></label><span id="membershipId">(<%=hdnMembershipId.Value %>)</span></h4>
                                        </div>
                                        <asp:HiddenField ID="hdnFileName" runat="server" />
                                        <asp:HiddenField ID="hdnDocumentTypeId" runat="server" />
                                        <asp:HiddenField ID="hdncustomerId" runat="server" />
                                        <asp:HiddenField ID="hdncustomerName" runat="server" />
                                        <asp:HiddenField ID="hdnRegisterDate" runat="server" />
                                        <asp:HiddenField ID="hdnMembershipId" runat="server" />
                                        <asp:HiddenField ID="hdnFileType" runat="server" />
                                        <asp:HiddenField ID="hideSearchDiv" runat ="server" />
                                        <%--<asp:Button ID ="test" runat="server" style="display:none" OnClick="test_Click"/>--%>
                                        <div class="hidden">
                                            <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click" OnClick="clickBtnForGetCustomerDetails_Click" />
                                            <asp:Button ID="clickEditCustomerDocument" runat="server" Text="click" OnClick="clickEditCustomerDocument_Click" />
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-8">
                                                    <div class="row">
                                                        <div id="displayOnlyOnEdit" runat="server">
                                                            <div id="SearchDiv">
                                                                <div class="col-sm-4 col-xs-6">
                                                                    <label class="control-label">Search By</label>
                                                                    <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                                                    </asp:DropDownList>
                                                                </div>
                                                                <div class="col-sm-4 col-xs-6">
                                                                    <div class="form-group">
                                                                        <label>Choose Customer :<span class="errormsg">*</span></label>
                                                                        <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-4 col-xs-6">
                                                                    <div class="form-group">
                                                                        <label>&nbsp;</label><br />
                                                                        <asp:Button runat="server" class="btn btn-primary m-t-25" ID="clear" OnClientClick="ClearClicked()" Text="Clear" />
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="displayForm">
                                                                <div class="col-md-12">
                                                                    <div id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                                        <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-12">
                                                                    <div class="form-group">
                                                                        <label class="form-label">Document Type:<span class="errormsg">*</span></label>
                                                                        <asp:DropDownList runat="server" ID="ddlDocumentType" name="ddlDocumentType" CssClass="form-control">
                                                                        </asp:DropDownList>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-12">
                                                                    <div class="form-group">
                                                                        <label class="form-label">Document:<span class="errormsg">*</span></label>
                                                                        <asp:FileUpload ID="fileDocument" runat="server" onChange="readURL(this, 'fileDisplay')" CssClass="form-control-plaintext form-control" />
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-12">
                                                                    <div class="form-group">
                                                                        <label class="form-label">Description</label>
                                                                        <asp:TextBox CssClass="form-control-plaintext form-control" TextMode="MultiLine" runat="server" ID="txtDocumentDescription"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-4 displayForm">
                                                    <div class="row">
                                                        <div class="col-md-12">
                                                            <label>&nbsp;</label><br />
                                                            <asp:Image runat="server" ID="fileDisplay" Style="height: 200px; width: 300px; object-fit: contain;" onclick="showImage(this);" />
                                                            <br />
                                                            <div class="form-group">
                                                                <asp:Button runat="server" ID="downloadFile" CssClass="btn btn-primary m-t-25" Text="Download" OnClick="downloadFile_Click" />
                                                                <%--<a href="" runat="server" id="downloadFile" visible="false" class="btn btn-primary m-t-25" >Download</a>--%>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row displayForm">
                                                <div class="col-md-12">
                                                    <div class="form-group">
                                                        <asp:Button ID="saveDocument" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="saveDocument_Click" />
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

                <div class="row displayForm">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Customer Document Type</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div id="rpt_grid" runat="server"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
