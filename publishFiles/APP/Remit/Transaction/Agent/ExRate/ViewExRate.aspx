<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewExRate.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ExRate.ViewExRate" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/menucontrol.js" type="text/javascript"></script>
    <style>
        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }

    </style>

</head>
<body>
    <form id="form1" runat="server">
         <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>TODAY'S EXCHANGE RATE
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Services</a></li>
                            <li class="active"><a href="#">Today's Exchange Rate</a></li>
                        </ol>
                    </div>
                </div>
            </div>  
          <div class="row">
              <div class="col-md-12">

        
                 <div class="row panels">
                      <div class="col-sm-4">
                     <span class="errormsg">*</span> Fields are mandatory
                 </div>
                 </div>
                <div class="panel panel-default">
                    <div class="panel-heading">

                    </div>
                    <div class="panel-body">
                         <div class="row panels">
                     <div class="col-sm-2"></div>
                     <div class="col-sm-4">
                         <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></div>
                 </div>
                 <div class="row panels">
                     <div class="col-sm-2 ">
                         <label>Collection Currency: <span class="errormsg">*</span></label>
                         </div>
                     <div class="col-sm-4 ">
                           <asp:DropDownList ID="collCurrency" runat="server" CssClass="input form-control"
                             AutoPostBack="True" OnSelectedIndexChanged="sendCurrency_SelectedIndexChanged" Width="100%">
                         </asp:DropDownList>
                        
                         <asp:RequiredFieldValidator ID="rv1" runat="server"
                             ControlToValidate="collCurrency" Display="Dynamic" ErrorMessage="Required"
                             ForeColor="Red" SetFocusOnError="True" ValidationGroup="cal">
                         </asp:RequiredFieldValidator>
                     </div>
                     <div class="col-sm-2 ">                       
                          <label>Tran Type:<span class="errormsg">*</span></label> 
                         </div>
                     <div class="col-sm-4 ">
                         <asp:DropDownList ID="txnType" runat="server" CssClass="input form-control" Width="100%">
                         </asp:DropDownList>
                         <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                             ControlToValidate="txnType" Display="Dynamic" ErrorMessage="Required!"
                             ForeColor="Red" ValidationGroup="cal">
                         </asp:RequiredFieldValidator>                    

                     </div>
              </div>  
                     <div class="row panels">
                         <div class="col-sm-2 ">
                             <label>Payment Country:<span class="errormsg">*</span></label>
                             </div>
                         <div class="col-sm-4 ">
                              <asp:DropDownList ID="payCountry" runat="server" CssClass="input form-control" 
                                 AutoPostBack="True" OnSelectedIndexChanged="payCountry_SelectedIndexChanged" Width="100%">
                             </asp:DropDownList>

                             <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                 ControlToValidate="payCountry" Display="Dynamic" ErrorMessage="Required!"
                                 ForeColor="Red" ValidationGroup="cal">
                             </asp:RequiredFieldValidator>
                         </div>
                        
                            
                         <div class="col-sm-2 ">
                             <label>Payment Currency:<span class="errormsg">*</span></label>
                             </div>
                         <div class="col-sm-4 ">
                             <asp:DropDownList ID="payCurrency" runat="server" CssClass="input form-control" Width="100%">
                             </asp:DropDownList>

                             <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                 ControlToValidate="payCurrency" Display="Dynamic" ErrorMessage="Required!"
                                 ForeColor="Red" ValidationGroup="cal">
                             </asp:RequiredFieldValidator>
                         </div>                        
                     </div>
                     <div class="row ">   
                         <div class="col-sm-2"></div>                      
                         <div class="col-sm-2"><asp:Button ID="btnSave" runat="server" CssClass="button btn-primary"
                             OnClick="btnSave_Click" Text=" View " ValidationGroup="cal" />
                         </div>
                     </div>
                    </div>
                </div>
                
                   
                             <div id="result" runat="server">
                                 <table style="width: 100%">
                                     <tr>
                                         <td>
                                             <fieldset>
                                                 <legend>Result</legend>
                                                 <table>
                                                     <tr>
                                                         <td class="label">Collection Currency</td>
                                                         <td class="text">:
                                                    <asp:Label ID="cCurrency" runat="server"></asp:Label>
                                                         </td>
                                                     </tr>
                                                     <tr>
                                                         <td class="label">Payment Country </td>
                                                         <td class="text">:
                                                    <asp:Label ID="pCountry" runat="server"></asp:Label>
                                                         </td>
                                                     </tr>
                                                     <tr>
                                                         <td class="label">Payment Currency </td>
                                                         <td class="text">:
                                                    <asp:Label ID="pCurrency" runat="server"></asp:Label>
                                                         </td>
                                                     </tr>
                                                     <tr>
                                                         <td class="label">Tran Type</td>
                                                         <td class="text">:
                                                    <asp:Label ID="tranType" runat="server"></asp:Label>
                                                         </td>
                                                     </tr>
                                                     <tr>
                                                         <td class="label">Customer Rate</td>
                                                         <td class="text">:
                                                    <asp:Label ID="customerRate" runat="server"></asp:Label>
                                                         </td>
                                                     </tr>

                                                 </table>
                                             </fieldset>
                                         </td>
                                     </tr>
                                 </table>
                             </div>
          
                 </div>
          </div>    
            
</div>
    </form>
</body>
</html>
