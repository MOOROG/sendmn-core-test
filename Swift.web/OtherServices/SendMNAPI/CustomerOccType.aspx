<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerOccType.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.CustomerOccType" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta name="" content="noopen" />

  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <script src="/js/functions.js"></script>
  <script type="text/javascript">

</script>
  <style>
    .link {
      color: red;
    }
  </style>

</head>
<body>

  <form id="form1" runat="server">
    <div class="row">
      <div class="col-md-12">
        <div class="panel panel-default ">
          <div class="panel-heading">
            <h2 class="panel-title"></h2>
          </div>

          <div class="panel-body">
            <div class="form-group">
              <hr id="hr2" runat="server" />
              <hr id="h3" runat="server" />
              <asp:RadioButtonList ID="occType" runat="server" RepeatLayout="Table" RepeatColumns="3" Width="100%"></asp:RadioButtonList>
            </div>
            <div class="form-group">
              <label class="control-label col-md-4"></label>
              <div class="col-md-12">
                <asp:Button runat="server" ID="submitBtn" Text="Submit" class="btn btn-primary m-t-25" OnClick="submitBtn_Click"/>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
