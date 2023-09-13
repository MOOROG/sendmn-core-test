<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoanMortgagePayment.aspx.cs" Inherits="Swift.web.OtherServices.Loan.LoanMortgagePayment" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title></title>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/js/swift_calendar.js" type="text/javascript"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
  <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
  <script type="text/javascript">

  </script>

</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="panel panel-default ">
            <div class="panel-heading">
              <h4 class="panel-title">Төлбөр төлсөн түүх: </h4>
            </div>
            <div class="panel-body">
              <div ID="loanPayment_grid" runat="server" AutoGenerateColumns="false" Width="100%"> </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
  <div id="poppage" runat="server" style="display:none">
</div>
</body>
</html>