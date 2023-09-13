<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeclinedCurrencyOrderHistory.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.DeclinedCurrencyOrderHistory" %>

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
  <script type="text/javascript">
    $(document).ready(function () {
    });
  </script>
</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li class="active"><a href="CurrencyExchangeReport.aspx">Exchange Currency Report</a></li>
            </ol>
          </div>
        </div>
      </div>

      <!-- Nav tabs -->
      <div class = "listtabs">
        <ul class = "nav nav-tabs" role = "tablist">
          <li><a href="CurrencyOrderHistory.aspx">Pending orders</a></li>
          <li><a href="ApprovedCurrencyOrderHistory.aspx">Received Orders</a></li>
            <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="table">Canceled Orders</a></li>
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
                  <div id="table_grid" runat="server"></div>
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
