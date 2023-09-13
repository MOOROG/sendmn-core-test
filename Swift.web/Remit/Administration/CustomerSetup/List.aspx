<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.customerSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grid_list_fromDate", "#grid_list_toDate");
            $('#grid_list_fromDate').mask('0000-00-00');
            $('#grid_list_toDate').mask('0000-00-00');
        });

      function ddlRiskChanged(ece) {
        alert("Are u sure for this change?" + ece.value);
        var data = { MethodName: "UpdateCustomerRiskLvl", customerId: ece.id, riskLvl: ece.value };
        $.ajax({
          url: "",
          type: "post",
          data: data,
          dataType: "json",
          async: false,
          success: function (response) {
            if (response != null) {
              alert(response.Msg);
            }
          },
          error: function (xhr, status, error) {
            alert("Something went wrong!!!")
          }
        });
      }

      function ApproveCustomer(custId, userName) {
        alert("Are u sure approve document?" + custId);
        $.ajax({
          type: "POST",
          url: "../../../../Autocomplete.asmx/ApproveDocument",
          data: '{ id: "' + custId + '", userId: "' + userName +'"}',
          contentType: "application/json; charset=utf-8",
          dataType: "json",
          success: function (data, textStatus, XMLHttpRequest) {
            alert('Approved');
          },
          error: function (xhr, ajaxOptions, thrownError) {
            console.log("Status: " + xhr.status + " Error: " + thrownError);
            alert("Due to unexpected errors we were unable to load data");
          }
        });
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
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="List.aspx">Customer Registration </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Registration List</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>