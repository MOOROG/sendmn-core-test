<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Approve.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Approve.Approve" %>
<%--<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>--%>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
     <script type="text/javascript">
          function checkAll(me) {
              var checkBoxes = document.forms[0].chkTran;
              var boolChecked = me.checked;

              for (i = 0; i < checkBoxes.length; i++) {
                  checkBoxes[i].checked = boolChecked;
              }
          }

          function ClearField() {
              SetValueById("<% =controlNo.ClientID%>", "", false);

              SetValueById("<% =sFirstName.ClientID%>", "", false);
              SetValueById("<% =sMiddleName.ClientID%>", "", false);
              SetValueById("<% =sLastName1.ClientID%>", "", false);
              SetValueById("<% =sLastName2.ClientID%>", "", false);

              SetValueById("<% =rFirstName.ClientID%>", "", false);
              SetValueById("<% =rMiddleName.ClientID%>", "", false);
              SetValueById("<% =rLastName1.ClientID%>", "", false);
              SetValueById("<% =rLastName2.ClientID%>", "", false);
          }

          function GridCallBack() {
              GetElement("<% =btnTranSelect.ClientID%>").click();
          }

          function ShowCustomer() {
              var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
              var customerId = GetElement("<% =hddRCustomerId.ClientID%>").value;
              var url = urlRoot + "/Remit/Administration/CustomerSetup/Manage.aspx?customerId=" + customerId + "&section=p";
              param = "dialogHeight:600px;dialogWidth:750px;dialogLeft:300;dialogTop:100;center:yes";
              var Id = PopUpWindow(url, param);
          }

          function CallBack(mes, url) {
              var resultList = ParseMessageToArray(mes);
              alert(resultList[1]);

              if (resultList[0] != 0) {
                  return;
              }

              window.returnValue = resultList[0];
              window.location.replace(url);
          }
          
          function ShowHideSearchBox(id) {
              var obj = GetElement(id);
              if (obj.style.display == "none") {
                  obj.style.display = "block";
                  GetElement("showHideImg").innerHTML = "<img class=\"showHand\" src=\"../../../../Images/icon_hide.gif\" border=\"0\" />";
              }
              else {
                  obj.style.display = "none";
                  GetElement("showHideImg").innerHTML = "<img class=\"showHand\" src=\"../../../../Images/icon_show.gif\" border=\"0\" />";
              }
          }
    </script>
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
    
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
         <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>APPROVE TRANSACTION
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Services</a></li>
                            <li class="active"><a href="#">Approve Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>  
   
    <asp:UpdatePanel ID = "upd1" runat = "server" UpdateMode = "Conditional">
        <ContentTemplate>
            
                <div id="tblSearch" runat="server">               
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-search"></i>Find By Control No</div>
                        <div class="panel-body">

                            <div class="row panels">
                                <div class="col-sm-2">
                                    <b><%=GetStatic.GetTranNoName() %></b>
                                    <span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="rfv1" runat="server" ControlToValidate="controlNo"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="approve" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                                <div class="col-sm-4">
                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>                               
                            </div>                                   
                                   
                            <div class="row panels">
                                <div class="col-sm-2">
                                    <b>Collection Amount</b>
                                    <span class="errormsg">*</span>
                                </div>
                                <div class="col-sm-4">
                                     <asp:RequiredFieldValidator ID="rfv2" runat="server" ControlToValidate="collectAmt"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="approve" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                    <asp:TextBox ID="collectAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="row panels">
                                <div class="col-sm-2"></div>
                                <div class="col-sm-4">
                                    <asp:Button ID="btnSearchDetail" runat="server" Text="Search" CssClass="btn btn-primary"
                                        ValidationGroup="approve" OnClick="btnSearchDetail_Click" />
                                </div>
                            </div>

                        </div>
                    </div>
              
                <div style="margin-left: 20px"><h4>Advance Search&nbsp;&nbsp;<asp:ImageButton 
                        ID="ibtnShowHideSearch" runat="server" ImageUrl="../../../../Images/icon_show.gif" 
                        border="0" onclick="ibtnShowHideSearch_Click" /></h4>
                </div>
               <div id="tblAdvanceSearch" runat="server" Visible="false">
                        <div class="panel panel-primary">

                            <div class="panel-heading">Transaction List Search Criteria</div>
                            <div class="panel-body">
                                <div class="row panels">
                                    <div class="col-sm-4">
                                        <b><%=GetStatic.GetTranNoName() %></b>
                                        <asp:TextBox ID="controlNoForSearch" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row panels">
                                    <div class="col-sm-3">
                                        <b>Sender First Name</b>
                                        <asp:TextBox ID="sFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>Sender Middle Name</b>
                                        <asp:TextBox ID="sMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>S First Last Name</b>
                                        <asp:TextBox ID="sLastName1" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>S Second Last Name</b>
                                        <asp:TextBox ID="sLastName2" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row panels">
                                    <div class="col-sm-3">
                                        <b>Receiver First Name</b>
                                        <asp:TextBox ID="rFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>Receiver Middle Name</b>
                                        <asp:TextBox ID="rMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>R First Last Name</b>
                                        <asp:TextBox ID="rLastName1" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-3">
                                        <b>R Second Last Name</b>
                                        <asp:TextBox ID="rLastName2" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row panels">
                                    <div class="col-sm-4">
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="pay" CssClass="btn btn-primary"
                                            OnClick="btnSearch_Click" />&nbsp;&nbsp;
                                        <input type="button" value="Clear Field" id="btnSclearField" class="btn btn-primary" onclick=" ClearField('s'); " />

                                    </div>
                                   
                                </div>

                            </div>
                        </div>
                      
                        
                            
                        <div id="grd_tran" runat="server" class="grid-div">

                        </div>
                        <asp:HiddenField ID="hddTran" runat="server" />
                        <asp:HiddenField ID="hddRCustomerId" runat="server" />
                                                       
                       
                        
                       <div class="row panels form-inline col-sm-12">
                            <div style="clear: both; margin-bottom:100px;">
                                    <span style="font-size: 1.7em;"><b>Enter Collection Amount</b></span>
                                    <span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="cAmt"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="search"
                                        SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                    <asp:TextBox ID="cAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:Button ID="btnSearchTran" runat="server" Text="Search" CssClass="btn btn-primary" ValidationGroup="search"
                                        OnClick="btnSearchTran_Click" />
                                </div>
                       </div>
                    </div>
                <asp:Button ID="btnTranSelect" runat="server" Text="Select" style="display: none;" onclick="btnTranSelect_Click" />
                </div>
                <div id="divTranDetails" runat="server" visible="false">
                    <div id="div1" style="clear: both;" class="panels">
                        <div style=" text-align:center;">

                                <span style="font-size: 2em; font-weight: bold;">
                                    <asp:Label ID="tranNoName" runat="server"></asp:Label>:
                                    <span style="color: red;"><asp:Label ID="lblControlNo" runat="server"></asp:Label></span>
                                </span>

                                 <span style="width:100px;"></span>

                                   <span style="background:; font-size: 2em; font-weight: bold;"> 
                                     Transaction Status: 
                                     <span style="color: red;"> <asp:Label ID = "lblStatus" runat = "server"></asp:Label> </span>
                                   </span>
                           </div>
                        <table style="width:100%" cellspacing="0" cellpadding="0">
                            <tr>
                                <td class="tableForm" colspan="2">
                                    <fieldset>
                                        <table  style="width: 100%">
                                            <tr>
                                                <td>
                                                    <table id="tblCreatedLog" runat="server" Visible="false">
                                                        <tr>
                                                            <td>Created By:</td>
                                                            <td>
                                                                <asp:Label ID="createdBy" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Created Date:</td>
                                                            <td>
                                                                <asp:Label ID="createdDate" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td  width="400px" valign="top" class="tableForm">
                                    <fieldset>
                                        <legend>Sender</legend>
                                        <table style="width: 100%">
                                            <tr style="background-color: #FDF79D;">
                                                <td class = "label">Name: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Address: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAddress" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Country: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sCountry" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Contact No: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sContactNo" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Id Type: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sIdType" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Id Number: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sIdNo" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Email: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sEmail" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td valign="top" class="tableForm">
                                    <fieldset>
                                        <legend>Receiver</legend>
                                        <table style="width: 100%">
                                            <tr style="background-color: #F9CCCC;">
                                                <td class = "label">Name: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Address: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rAddress" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Country: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rCountry" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Contact No: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rContactNo" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Id Type: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rIdType" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Id Number: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "rIdNo" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Relationship with sender: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "relationship" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" class="tableForm">
                                    <fieldset>
                                        <legend>Sending Agent Detail</legend>
                                        <table style="width: 100%">
                                            <tr>
                                                <td class = "label">Agent: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAgentName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="label">Branch: </td>
                                                <td class="text">
                                                    <asp:Label ID="sBranchName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">S. Agent Location: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAgentLocation" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">District:</td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAgentDistrict" runat = "server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">City: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAgentCity" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Country: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "sAgentCountry" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td valign="top" class="tableForm">
                                    <fieldset>
                                        <legend>Payout Agent Detail</legend>
                                        <table style="width: 100%">
                                            <tr>
                                                <td class = "label">Agent: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "pAgentName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Branch: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "pBranchName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Payout Location: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "pAgentLocation" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">District:</td>
                                                <td class = "text">
                                                    <asp:Label ID = "pAgentDistrict" runat = "server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">City: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "pAgentCity" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Country: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "pAgentCountry" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td class = "tableForm" valign="top">
                                    <fieldset>
                                        <legend>Transaction Amount Detail</legend>

                                        <table class="rateTable" style="width: 100%" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td class = "label">Collection Amount: </td>

                                                <td class = "text-amount">
                                                    <asp:Label ID = "total" runat = "server"></asp:Label> 
                                                    <asp:Label ID = "totalCurr" runat="server"></asp:Label>
                                                </td>

                                            </tr>
                                            <tr>
                                                <td class = "label">Service Charge: </td>
                                                <td class = "text-amount">
                                                    <asp:Label ID = "serviceCharge" runat = "server"></asp:Label> 
                                                    <asp:Label ID="scCurr" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Sent Amount: </td>
                                
                                                <td class = "text-amount">
                                                    <asp:Label ID = "transferAmount" runat = "server"></asp:Label> 
                                                    <asp:Label ID="tAmtCurr" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "label">Payout Amount: </td>
                                                <td class = "text-amount DisFond">
                                                    <asp:Label ID = "payoutAmt" runat = "server"></asp:Label> 
                                                    <asp:Label ID = "pAmtCurr" runat="server" ></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td valign="top" class="tableForm">
                                    <fieldset>
                                        <legend>Other Detail</legend>
                                        <table style="width: 100%">
                                            <tr>
                                                <td class = "label">Mode of Payment: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "modeOfPayment" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class = "DisFond">Trn Status:</td>
                                                <td class = "DisFond">
                                                    <asp:Label ID = "tranStatus" runat = "server"></asp:Label>
                                                </td>
                                            </tr>
                                            <div id="pnlShowBankDetail" runat="server" visible="false">
                                            <tr id="trAc">
                                                <td class = "label">Account Number: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "accountNo" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr id="trBank">
                                                <td class = "label">Bank Name: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "bankName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            <tr id="trBranch">
                                                <td class = "label">Branch Name: </td>
                                                <td class = "text">
                                                    <asp:Label ID = "branchName" runat = "server"></asp:Label> 
                                                </td>
                                            </tr>
                                            </div>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <fieldset>
                                        <table>
                                            <tr>
                                                <td>
                                                    <b>Payout Message</b>
                                                    <br />
                                                    <asp:Label ID="payoutMsg" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:HiddenField ID="hddTranId" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divDetails" style="clear: both;" class="panels">
                        <table width="100%" cellspacing="0" cellpadding="0">
                            <tr>
                                <td colspan="2">
                                    <table width="400px">
                                        <tr>
                                            <td>
                                                <asp:Button ID="btnApprove" runat="server" Text = "Approve Transaction" CssClass="button" 
                                                            onclick="btnApprove_Click"/>&nbsp;&nbsp;
                                                <cc1:ConfirmButtonExtender ID="btnApprovecc" runat="server" 
                                                               ConfirmText="Confirm To Approve Transaction?" Enabled="True" TargetControlID="btnApprove">
                                                </cc1:ConfirmButtonExtender>
                                                <%--<asp:Button ID="btnReject" runat="server" Text = "Reject" CssClass="button" 
                                                        onclick="btnReject_Click" />&nbsp;&nbsp;--%>
                                                <input type="button" id="btnBack" value="Back" class="button" onclick="window.location.replace('Approve.aspx'); " />
                                                <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
                                                    <ProgressTemplate>       
                                                        <div style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black;">
                                                            <img alt="progress" src="../../../../Images/Loading_small.gif" /> 
                                                            Processing...
                                                        </div>       
                                                    </ProgressTemplate>
                                                </asp:UpdateProgress>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            
        </ContentTemplate>
    </asp:UpdatePanel>
             </div>
    </form>
</body>
</html>
