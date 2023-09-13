<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Display.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.Display" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style type="text/css">
        .head {
            color: #FFFFFF;
            background: #FF0000;
            padding: 2px;
            border-radius: 2px;
        }

        .data {
            font-weight: bold;
        }

        .formTable .frmTitle {
            background-color: #0e96ec;
            font: bold 11px/normal Verdana;
            padding: 0px;
            text-align: center;
            color: rgb(255, 255, 255);
            font-size-adjust: none;
            font-stretch: normal;
            padding-top: 5px;
            width: 100%;
            border-radius: 2px;
        }

        .tableTitle {
            background: rgb(58, 79, 99);
            font: bold 11px/normal Verdana;
            padding: 5px;
            text-align: left;
            color: rgb(255, 255, 255);
            font-size-adjust: none;
            font-stretch: normal;
        }

        .formTable tr td {
            font: bold 11px/normal Arial, Helvetica, sans-serif;
            padding: 0px;
            font-size-adjust: none;
            font-stretch: normal;
        }

        .formTable tr .fromHeadMessage {
            font: 11px/normal Verdana;
            padding: 20px 5px;
            text-align: center;
            font-size-adjust: none;
            font-stretch: normal;
        }

        .formTable tbody tr .info {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 11px;
            font-style: normal;
            font-weight: normal;
            color: #666;
        }

        .formTable tbody tr .head {
            background-color: #0e96ec;
            font-size: 12px;
            font-style: normal;
            font-weight: bold;
            color: #fff;
            padding: 1px;
            margin-bottom: 5px 0 5px 0;
        }

        .formTable tbody tr td .data {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-style: normal;
            color: #000;
            padding: 0px;
            width: 10px;
        }

        /*.btn {
            background-color: #0e96ec;
            color: #fff;
        }*/

        .ui-dialog {
            width: 60% !important;
        }

        .table th, .table td {
            border-top: none !important;
        }
    </style>
    <script>
        $(document).ready(function () {
            //ReportPrint();
        });
        function ReportPrint() {
            $(".formTable").show();
            $(".print_hide").hide();
            window.print();
        }
    </script>
</head>

<body>
    <form id="form1" runat="server" class="info">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Information Details </h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Membership ID :
                                    </label>
                                    <asp:Label ID="customerCardNo" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Customer Name :
                                    </label>
                                    <asp:Label ID="firstName" runat="server" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Marital Status :
                                    </label>
                                    <asp:Label ID="maritalStatus" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Date of Birth (Eng. Date) :
                                    </label>
                                    <asp:Label ID="dobEng" runat="server" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Date of Birth (Nep. Date) :
                                    </label>
                                    <asp:Label ID="dobNep" runat="server" CssClass="data"></asp:Label></label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        <asp:Label runat="server" ID="idType" Text="Citizenship"></asp:Label>
                                        :
                                    </label>
                                    <asp:Label runat="server" ID="citizenShipNo" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Place of Issue :
                                    </label>
                                    <asp:Label runat="server" ID="placeOfIssue" CssClass="data"></asp:Label>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Gender :
                                    </label>
                                    <asp:Label runat="server" ID="gender" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        ID Expiry Date :
                                    </label>
                                    <asp:Label runat="server" ID="expiryDate" CssClass="data"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Parmanent Address</h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Tole :
                                    </label>
                                    <asp:Label runat="server" ID="pTole" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        House No. :
                                    </label>
                                    <asp:Label runat="server" ID="pHouseNo" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Municipality/VDC :
                                    </label>
                                    <asp:Label runat="server" ID="pMunicipality" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Ward No. :
                                    </label>
                                    <asp:Label runat="server" ID="pWardNo" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Country :
                                    </label>
                                    <asp:Label runat="server" ID="pCountry" Text="Nepal" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Zone :
                                    </label>
                                    <asp:Label ID="pZone" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        District :
                                    </label>
                                    <asp:Label ID="pDistrict" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                    </label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Temporary Address</h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Tole :
                                    </label>
                                    <asp:Label runat="server" ID="tTole" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        House No. :
                                    </label>
                                    <asp:Label runat="server" ID="tHouseNo" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Manicipality/VDC :
                                    </label>
                                    <asp:Label runat="server" ID="tMunicipality" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Ward No. :
                                    </label>
                                    <asp:Label runat="server" ID="tWardNo" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Country :
                                    </label>
                                    <asp:Label runat="server" ID="tCountry" Text="Nepal" CssClass="data">
                                    </asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Zone :
                                    </label>
                                    <asp:Label ID="tZone" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        District :
                                    </label>
                                    <asp:Label ID="tDistrict" runat="server" CssClass="data"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Other Information</h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Father's Name :
                                    </label>
                                    <asp:Label runat="server" ID="fatherName" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Mother's Name :
                                    </label>
                                    <asp:Label runat="server" ID="motherName" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Grandfather's Name :
                                    </label>
                                    <asp:Label runat="server" ID="grandFatherName" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Occupation :
                                    </label>
                                    <asp:Label runat="server" ID="occupation" CssClass="data"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Email Id :
                                    </label>
                                    <asp:Label runat="server" ID="emailId" CssClass="data"></asp:Label>
                                </div>
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Phone No. :
                                    </label>
                                    <asp:Label runat="server" ID="phoneNo" CssClass="data"></asp:Label></label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 form-group">
                                    <label class="control-label" for="">
                                        Mobile No. :
                                    </label>
                                    <asp:Label runat="server" ID="mobileNo" CssClass="data"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <%

                    DataSet ds = GetDocuments();
                    DataTable rowData = ds.Tables[0];
                    foreach (DataRow row in rowData.Rows)
                    {
                        var url = GetStatic.GetUrlRoot() + "/img.ashx?id=" + row["fileName"].ToString();
                        if (row["fileName"].ToString() != "")
                        {
                            %>

                            <div class="welcome"><%=row["fileDescription"].ToString()%></div>

                            <div height="100" width="400">
                                <img src="<%=url%>" border="1" width="700px" />
                            </div>

                            <%
                            }
                        }

                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>