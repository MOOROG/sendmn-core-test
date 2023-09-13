<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CashPaymentCodeComplete.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.CashPaymentCodeComplete" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <!--new css and js -->
  <%--    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
	<script src="/js/swift_calendar.js"></script>--%>

  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/js/swift_autocomplete.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/pickers-init.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <style>
    .panel {
      width: 1000px;
      margin-left: calc(50% - 500px);
      margin-top: 100px
    }

    @media only screen and (max-width: 1200px) {
      .panel {
        width: 100%;
        margin-left: 0;
        margin-top: 100px
      }
    }
  </style>
</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
        <div class="page-wrapper">
          <div class="row">
            <img src="../../Images/logosend.png" style="width: 200px; margin-left: calc(50% - 100px); margin-top: 20px; margin-bottom: 20px;">
            <div class="col-sm-12" style="background-color: #00D2FF; height: 30px; width: 100%">
            </div>
          </div>
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites" style="">
                <div class="panel-heading">
                  <h4 class="panel-title">Мөнгө хүлээж авах</h4>
                </div>
                <div class="panel-body" style="padding: 35px;">
                  Таны хүсэлтийг хүлээн авлаа. Баярлалаа.
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
  </form>
</body>
</html>
