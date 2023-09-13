<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CurrencyOrderHistory.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.CurrencyOrderHistory" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <title></title>
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>

  <script src="/js/Swift_grid.js" type="text/javascript"></script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <script src="/js/functions.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/pickers-init.js"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/ui/js/metisMenu.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
  <style>
    button {
      border: none;
    }
  </style>
  <script type="text/javascript">
    $(document).ready(function () {
    });
    function approve(id, confirm) {
      var userConfirmation = prompt("Please enter the confirmation code:");
      if (userConfirmation !== null) {
          if (userConfirmation === confirm) {
              $.ajax({
                  url: '<%= ResolveUrl("CurrencyOrderHistory.aspx") %>',
                  type: 'POST',
                  data: { methodName: "approve", id: id }
              });
          window.location.href = "/AgentNew/Administration/CurrencyExchange/OrderExchange.aspx?orderId=" + id;
        } else {
          alert("Confirmation code does not match. Approval canceled.");
        }
      }
    }

    function cancel(id) {
      if (window.confirm("Are you sure you want to cancel?")) {
        $.ajax({
          url: '<%= ResolveUrl("CurrencyOrderHistory.aspx") %>',
                type: 'POST',
                data: { methodName: "cancel", id: id },
                success: function (data) {
                  alert("Order has been declined!" + id);
                },
                error: function (result) {
                  alert("Sorry! Due to unexpected errors operation terminates !");
                }
              });
      }
    }
  </script>
</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
              <li><a href="#">Currency Exchange</a></li>
              <li class="active"><a href="CurrencyOrderHistory.aspx">Currency Order History</a></li>
            </ol>
          </div>
        </div>
      </div>

      <!-- Nav tabs -->
      <div class="listtabs">
        <ul class="nav nav-tabs" role="tablist">
          <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="table">Pending orders</a></li>
          <li><a href="ApprovedCurrencyOrderHistory.aspx">Approved orders</a></li>
          <li><a href="DeclinedCurrencyOrderHistory.aspx">Canceled orders</a></li>
        </ul>
      </div>

      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Exchange Currency Report
                  </h4>
                  <div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                  </div>
                </div>
                <div class="panel-body">
                  <div id="table_grid" runat="server" class="gridDiv" enableviewstate="true"></div>
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
