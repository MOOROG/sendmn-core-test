<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoanCustomerListEdit.aspx.cs" Inherits="Swift.web.OtherServices.Loan.LoanCustomerListEdit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
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
  <script type="text/javascript">
    $(document).ready(function () {
      $('#file1').change(function () {
        var path = $(this).val();
        if (path != '' && path != null) {
          var q = path.substring(path.lastIndexOf('\\') + 1);
          $('#fileName').html(q);
        }
      });
    });

    delFunction = function (file) {
      if (confirm('This file will be permanently deleted!')) {
        file.parentNode.remove();
        $.ajax({
          type: "POST",
          url: "../../../../Autocomplete.asmx/DeleteLoanFiles",
          data: '{ filePath: "' + file.getAttribute('data-fname') + '"}',
          contentType: "application/json; charset=utf-8",
          dataType: "json",
          success: function (data, textStatus, XMLHttpRequest) {
            textStatus: '1';
          },
          error: function (xhr, ajaxOptions, thrownError) {
            console.log("Status: " + xhr.status + " Error: " + thrownError);
            alert("Due to unexpected errors we were unable to load data");
          }
        });
      }
      return false;
    }
   
  </script>
  <style>
    .DeleteBtn, .DeleteBtn:Focus {
     background-color: #00c864;
      border: none;
      border-radius: 50%;
      color: white;
      padding: 4px 10px;
      font-size: 10px;
      cursor: pointer;
      float: right;
    }

    .DeleteBtn:hover, .DeleteBtn:focus:hover {
      background-color: #990000;
      color: white;
    }
  </style>
</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="up" runat="server">
      <Triggers>
        <asp:PostBackTrigger ControlID="btnEdit" />
      </Triggers>
      <ContentTemplate>
        <asp:HiddenField ID="delFiles" runat="server" />
        <div class="page-wrapper">
          <div class="row">
            <div class="col-sm-12">
              <div class="page-title">
                <ol class="breadcrumb">
                  <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                  <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                  <li><a href="LoanCustomerList.aspx">Loan Customer List</a></li>
                  <li class="active"><a href="#">Edit Loan</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Loan Number: <%= loanNumber %></h4>
                </div>
                <div class="panel-body">
                  <ContentTemplate>
                    <div class="row">
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="loanAmount">Зээлийн хэмжээ:</label>
                        <asp:TextBox ID="loanAmount" runat="server" CssClass="form-control" Visible="true"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="loanTime">Хугацаа:</label>
                        <asp:DropDownList ID="loanTime" runat="server" CssClass="form-control" Visible="true">
                        </asp:DropDownList>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="interestRate">Зээлийн хүү:</label>
                        <asp:TextBox ID="interestRate" runat="server" CssClass="form-control" Visible="true"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="createdDate">Хүсэлт гаргасан огноо:</label>
                        <asp:TextBox ID="createdDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="extendedDate">Зээл сунгасан огноо:</label>
                        <asp:TextBox ID="extendedDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <label class="control-label" for="stateName">Төлөв:</label>
                        <asp:DropDownList ID="stateName" runat="server" CssClass="form-control">
                          <asp:ListItem Enabled="true" Text="Сонгох" Value="" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                      </div>
                      <div class="col-lg-6 col-md-6 form-group">
                        <label class="control-label" for="lnDescription">Тайлбар:</label>
                        <asp:TextBox ID="lnDescription" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>

                      <div class="col-lg-2 col-md-6 form-group">
                        <div></div>
                      </div>

                    </div>
                    <div class="row">
                      <div class="col-lg-2 col-md-2 form-group">
													<label class="control-label" for="file1">File 1:</label>
													<asp:FileUpload ID="file1" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[0] %>
											</div>
                      <div class="col-lg-2 col-md-2 form-group">
													<label class="control-label" for="file2">File 2:</label>
													<asp:FileUpload ID="file2" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[1] %>
											</div>
                      <div class="col-lg-2 col-md-2 form-group">
													<label class="control-label" for="file3">File 3:</label>
													<asp:FileUpload ID="file3" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[2] %>
											</div>
                      <div class="col-lg-2 col-md-2 form-group">
													<label class="control-label" for="file4">File 4:</label>
													<asp:FileUpload ID="file4" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[3] %>
											</div>
                      <div class="col-lg-2 col-md-2 form-group">
													<label class="control-label" for="file5">File 5:</label>
													<asp:FileUpload ID="file5" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[4] %>
											</div>
                    </div>
                    <div class="row">
                      <div class="col-lg-2 col-md-6 form-group">
													<label class="control-label" for="file6">File 6:</label>
													<asp:FileUpload ID="file6" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[5] %>
											</div>
                      <div class="col-lg-2 col-md-6 form-group">
													<label class="control-label" for="file7">File 7:</label>
													<asp:FileUpload ID="file7" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[6] %>
											</div>
                      <div class="col-lg-2 col-md-6 form-group">
													<label class="control-label" for="file8">File 8:</label>
													<asp:FileUpload ID="file8" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[7] %>
											</div>
                      <div class="col-lg-2 col-md-6 form-group">
													<label class="control-label" for="file9">File 9:</label>
													<asp:FileUpload ID="file9" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[8] %>
											</div>
                      <div class="col-lg-2 col-md-6 form-group">
													<label class="control-label" for="file10">File 10:</label>
													<asp:FileUpload ID="file10" runat="server" CssClass="form-control" accept="" />
													<%= filePreview[9] %>
											</div>

                    </div>
                  </ContentTemplate>
                  <div class="row">
                    <div class="col-lg-12 form-group">
                      <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnEdit_Click" />
                      <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-default m-t-25" OnClick="btnCancel_Click" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>
  </form>
</body>
</html>
