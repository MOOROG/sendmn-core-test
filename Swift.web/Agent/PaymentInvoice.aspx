<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentInvoice.aspx.cs" Inherits="Swift.web.Agent.PaymentInvoice" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - login</title>
  <link rel="icon" type="image/ico" sizes="32x32" href="../ui/index/images/favicon.ico">
  <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="../ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="../ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<style>
  html {
    box-sizing: border-box;
  }

  *, *:before, *:after {
    box-sizing: inherit;
  }

  html,
  body {
    min-height: 50%;
    height: 50%;
    width: 100%;
  }

  .img-btn-container {
    width: 80%;
    min-height: 100%;
    height: 100%;
    display: flex;
    align-items: center !important;
    justify-content: center;
    margin-top: 50px;
  }

  .col-2 {
    position: relative;
    width: 20%;
    height: 100%;
    float: left;
    margin-right: 50px;
    border: 1px solid black;
    border-radius: 11%;
  }

  .mcol {
    position: relative;
    height: 100%;
    float: left;
    border: 1px solid black;
    border-radius: 11%;
  }

  .img-col-2 {
    position: relative;
    width: 20%;
    height: 120%;
    margin-right: 50px;
  }

  .image-btn-wrapper {
    position: relative;
    overflow: hidden;
    width: 100%;
    height: 100%;
    border-radius: 10%;
  }

    .image-btn-wrapper:hover .image-btn-bg {
      opacity: 0.6;
      transform: scale(0.5);
    }

  .line-bottom:before {
    position: absolute;
    content: "";
    width: 100%;
    height: 5px;
    bottom: 0;
    left: 0;
    background: #3DAB47;
    z-index: 1;
    transform: scaleX(0) translateZ(0);
    transform-origin: 0 0;
    transition: 0.5s cubic-bezier(0.23, 1, 0.32, 1);
  }

  .line-bottom:hover:before {
    transform: scaleX(1) translateZ(0);
  }

  .image-btn-bg {
    position: absolute;
    width: 100%;
    height: 100%;
    transition: all 0.5s ease-in-out;
  }

    .image-btn-bg.btn-1 {
      background: url(/images/qpay.png) center/cover no-repeat;
    }

    .image-btn-bg.btn-2 {
      background: url(/images/sp.png) center/cover no-repeat;
    }

    .image-btn-bg.btn-3 {
      background: url(/images/bdeposit.png) center/cover no-repeat;
    }

  .img-4 {
    background: url(/images/qr-code.png) center/cover no-repeat;
  }

  #sidebar-wrapper {
    position: fixed;
    width: 20%;
    min-height: 100vh;
    background: #1f1e2e;
    top: 0;
    right: 0;
  }



  .img-btn-container1 {
    width: 100%;
    min-height: 100%;
    height: 100%;
    display: flex;
    align-items: center !important;
    justify-content: center;
    margin-top: 10px;
  }

  .col-1 {
    position: relative;
    width: 80%;
    height: 100%;
    float: left;
    margin: 10px;
    margin-left: 35px;
    border: 1px solid black;
    border-radius: 11%;
  }

  .img-col-1 {
    position: relative;
    width: 70%;
    height: 100%;
    margin-top: 20px;
    margin-left: 60px;
  }
</style>
<body>
  <%--desktop--%>
  <div class="login-head hidden-xs" style="width: 80%;">
    <h1>Please choose your payment method</h1>
  </div>
  <div class="img-btn-container hidden-xs">
    <div class="col-2">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-1">
        </div>
      </div>
    </div>
    <div class="col-2">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-2">
        </div>
      </div>
    </div>
    <div class="col-2">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-3">
        </div>
      </div>
    </div>
  </div>

  <div class="img-btn-container hidden-xs" style="border-top: 1px solid black">
  </div>
  <div class="img-btn-container hidden-xs" style="margin: -160px 0 0 -50px;">
    <img class="img-col-2" src="/images/qr-code.png" />
    <div class="row">
      <h1>Please scan the qr code or select
        <br />
        one of the banks in the list</h1>
    </div>
  </div>

  <div id="sidebar-wrapper" class="hidden-xs">
    <img src="/images/logo.png" class="pull-right" id="logo" />
    <div style="margin: 25%; color: white">
      <div class="row form-group">
        <span>Amount: <b id="amount">1,200,000</b></span>
      </div>
      <div class="row form-group">
        <span>Invoice: <b id="invoice">TRQ124566</b></span>
      </div>
      <div class="row form-group">
        <span>Status: <b id="paid">Paid</b></span>
      </div>
    </div>
  </div>


  <%--mobile--%>
  <div class="login-head visible-xs" style="padding: 5px; padding-left: 20px">
    <img src="/images/logo.png" class="pull-right" />
    <h2>Please choose your
      <br />
      payment method</h2>
  </div>
  <div class="col-md-12 visible-xs">
    <div class="row form-group img-btn-container1">
      <span>Amount: <b>1,200,000</b></span>
    </div>
    <div class="row form-group img-btn-container1">
      <span>Invoice: <b>TRQ124566</b></span>
    </div>
    <div class="row form-group img-btn-container1">
      <span>Status: <b>Paid</b></span>
    </div>
  </div>
  <div class="img-btn-container1 visible-xs">
    <div class="col-1">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-1">
        </div>
      </div>
    </div>
    <div class="col-1">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-2">
        </div>
      </div>
    </div>
    <div class="col-1">
      <div class="image-btn-wrapper line-bottom">
        <div class="image-btn-bg btn-3">
        </div>
      </div>
    </div>
  </div>

  <div class="img-btn-container1 visible-xs">
    <img class="img-col-1" src="/images/qr-code.png" />
    <div class="form-group" style="padding: 50px">
      <h2>Please scan the qr code or select one of the banks in the list</h2>
    </div>
  </div>


  <script src="/ui/js/jquery.min.js" type="text/javascript"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
  <script src="/js/functions.js" type="text/javascript"></script>

  <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.2.8/jquery.form-validator.min.js" type="text/javascript"></script>

  <script type="text/javascript">

</script>
</body>
</html>
