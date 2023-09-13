﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="txnRBACalcDetails.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.txnRBACalcDetails" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../Css/style.css" rel="Stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"></script>
    <style type="text/css">
        .header
        {
            font-size: 20px;
            background: red;
            color: White;
            height: 40px;
        }
        .sub-header
        {
            font-size: 15px;
            background: black;
            color: White;
            height: 20px;
        }
        table
        {
          /*width:80%;*/
           border-collapse: collapse;
        }
          table, th
        {
            font-size: 18px;
            font:Verdana;
            text-decoration:none;
            border: 1px solid black;
             
        }
        table, td
        {
            font-size: 13px;
            font:Verdana;
            text-decoration:none;
            border: 1px solid black;
            padding:4px; 
        }
        .clear-fix
        {
            clear:both;
            height:15px;
        }
        .low
        {
            background-color: Green;            
        }
        .high
        {
            background-color:Red;
                     
        }
        .medium
        {            
            background-color: Yellow;
        }
        
    </style>
    <script type="text/javascript">

        function OpenCustomerRBA() {
            var tranID = getQuerystring("tranId");
            OpenInNewWindow('cusRBACalcDetails.aspx?reportName=cusrbacalcdetails&tranId=' + tranID);
        }

        function getQuerystring(key, default_) {
            if (default_ == null) default_ = "";
            key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
            var regex = new RegExp("[\\?&]" + key + "=([^&#]*)");
            var qs = regex.exec(window.location.href);
            if (qs == null)
                return default_;
            else
                return qs[1];
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div class="breadCrumb">
            Risk Base Analysis » RBA Calculation Details - TXN RBA</div>
        <div class="clear-fix"></div>
        <div style="margin-left:10px">
            <div>
            <table style="width:80%;">
                <tr class="header">
                    <th nowrap="nowrap">
                        RBA Level:
                    </th>
                    <th nowrap="nowrap">
                        <asp:Label runat="server" ID="rbaLevel"></asp:Label>
                    </th>
                    <th nowrap="nowrap">
                        RBA Rating:
                    </th>
                    <th nowrap="nowrap">
                        <asp:Label runat="server" ID="rbaRating"></asp:Label>
                    </th>
                </tr>
                <tr>
                    <td>
                       <strong> Full Name:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="fullName"></asp:Label>
                    </td>
                    <td>
                         <strong>DOB:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="dob"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <strong>Gender:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="gender"></asp:Label>
                    </td>
                    <td>
                         <strong>Native Country:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="nativeCountry"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <strong>Id Type:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="idType"></asp:Label>
                    </td>
                    <td>
                         <strong>Id Number:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="idNumber"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <strong>Country:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="country"></asp:Label>
                    </td>
                    <td>
                         <strong>State:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="state"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <strong>City:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="city"></asp:Label>
                    </td>
                    <td>
                         <strong>Address:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="address"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <strong>Mobile No:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="mobileNo"></asp:Label>
                    </td>
                    <td>
                         <strong>E-mail:</strong>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="email"></asp:Label>
                    </td>
                </tr>
            </table>
        </div>
        <div class="clear-fix">
        </div>
        <div>
            <table>
                <tr class="header">
                    <th colspan="5">
                        RBA Calculation Summary-Transaction Assesement
                    </th>
                </tr>
                <tr class="sub-header">
                     <th style="width: 250px;">
                        Criteria
                    </th>
                    <th style="width: 350px;">
                        Description
                    </th>
                    
                   
                     <th style="width: 100px;">
                        Rating
                    </th>
                     <th style="width: 100px;">
                        Weight
                    </th>
                    <th style="width: 100px;">
                        Score
                    </th>
                </tr>
                <tr>
                    <td>
                        FATFReceiver
                    </td>
                    <td>
                        As per FATF Rating of payout country
                    </td>
                    
                   
                    <td style="text-align:right;">
                        <asp:Label ID="FATFReceivingCountryRating" runat="server" ></asp:Label>
                    </td>
                     <td style="text-align:right;">
                        <asp:Label ID="FATFReceivingCountryWeight" runat="server" ></asp:Label>
                    </td>
                    <td style="text-align:right;">
                        <asp:Label ID="FATFReceivingCountryScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                <tr>
                <td>PCOUNTRY</td>
                <td>TXN to Non native country</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="txnToNonNativeCountryRating" runat="server" ></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label ID="txnToNonNativeCountryWeight" runat="server" ></asp:Label>
                    </td>
                <td style="text-align:right;">
                    <asp:Label ID="txnToNonNativeCountryScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                 <tr>
                <td>CAMT</td>
                <td>TXN Greater than 10,000.00</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="cAmtRating" runat="server" ></asp:Label>
                     </td>
                     <td style="text-align:right;">
                    <asp:Label ID="cAmtWeight" runat="server"></asp:Label>
                     </td>
                <td style="text-align:right;">
                    <asp:Label ID="cAmtScore" runat="server" ></asp:Label>
                     </td>
                </tr>
                <tr>
                <td>PaymentMethod</td>
                <td>Payment Method</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="paymentModeRating" runat="server" ></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label ID="paymentModeWeight" runat="server" ></asp:Label>
                    </td>
                <td style="text-align:right;">
                    <asp:Label ID="paymentModeScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                 <tr>
                <td>Residency</td>
                <td>Send Country=Native Country</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="residencyRating" runat="server" ></asp:Label>
                     </td>
                     <td style="text-align:right;">
                    <asp:Label ID="residencyWeight" runat="server" ></asp:Label>
                     </td>
                <td style="text-align:right;">
                    <asp:Label ID="residencyScore" runat="server" ></asp:Label>
                     </td>
                </tr>
                <tr>
                <td>FATFSender</td>
                <td>As per FATF Rating of customer's native country</td>
                
               
                <td style="text-align:right;">
                    <asp:Label ID="FATFCustomerNativeCountryRating" runat="server" ></asp:Label>
                    </td>
                     <td style="text-align:right;">
                    <asp:Label ID="FATFCustomerNativeCountryWeight" runat="server" ></asp:Label>
                    </td>
                <td style="text-align:right;">
                    <asp:Label ID="FATFCustomerNativeCountryScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                <tr>
                <td>Occupation</td>
                <td>Occupation Master</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="senderOccupationRating" runat="server" ></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label ID="senderOccupationWeight" runat="server" ></asp:Label>
                    </td>
                <td style="text-align:right;">
                    <asp:Label ID="senderOccupationScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                 <tr>
                <td>PEPReceiver</td>
                <td>Beneficiary Positively identified as PEP</td>
                
                
                <td style="text-align:right;">
                    <asp:Label ID="PEPReceiverRating" runat="server" ></asp:Label>
                     </td>
                     <td style="text-align:right;">
                    <asp:Label ID="PEPReceiverWeight" runat="server" ></asp:Label>
                     </td>
                <td style="text-align:right;">
                    <asp:Label ID="PEPReceiverScore" runat="server" ></asp:Label>
                     </td>
                </tr>
                  <tr>
                <td>PEPSender</td>
                <td>Customer Positively identified as PEP</td>
                
               
                <td style="text-align:right;">
                    <asp:Label ID="PEPSenderRating" runat="server" ></asp:Label>
                      </td>
                       <td style="text-align:right;">
                    <asp:Label ID="PEPSenderWeight" runat="server" ></asp:Label>
                      </td>
                <td style="text-align:right;">
                    <asp:Label ID="PEPSenderScore" runat="server" ></asp:Label>
                      </td>
                </tr>
                  <tr>
                <td style="text-align:center;font-weight:bold;">TOTAL</td>
                <td>&nbsp;</td>
                
               
                <td style="text-align:right;font-weight:bold;">
                    <asp:Label ID="ratingTotal" runat="server"></asp:Label>
                      </td>
                       <td style="text-align:right;font-weight:bold;">
                           <asp:Label ID="weightTotal" runat="server">100.00</asp:Label>
                      </td>
                <td style="text-align:right;font-weight:bold;">
                    <asp:Label ID="ScoreTotal" runat="server"></asp:Label>&nbsp;<asp:Label ID="Rating" runat="server"></asp:Label>
                      </td>
                </tr>
                  <%--<tr>
                <td style="font-weight:bold;text-align:center" colspan="5">Customer Periodic RBA : 
                 <a href="#" onclick="OpenCustomerRBA();"> <asp:Label ID="customerScoreTotal" runat="server"></asp:Label> </a>&nbsp;<asp:Label ID="customerRating" runat="server"></asp:Label></td>
               
                </tr>--%>
            </table>
        </div>
     
         <div class="clear-fix">
        </div>
        <div>
            <table id="tblCusRBA" runat="server">
                <tr class="header">
                    <th colspan="4">
                        RBA Calculation Summary - Periodic Assessement
                    </th>
                </tr>
                <tr class="sub-header">
                     <th style="width: 250px;">
                        Criteria
                    </th>                   
                     <th style="width: 100px;">
                        Rating
                    </th>
                      <th style="width: 100px;">
                        Weight
                    </th>
                    <th style="width: 100px;">
                        Score
                    </th>
                </tr>
                <tr>
                    <td>
                        Number of TXN for the period
                    </td>
                    
                   
                   
                    <td style="text-align:right;">
                        <asp:Label ID="txnCountRating" runat="server" ></asp:Label>
                    </td>
                     <td style="text-align:right;">
                        <asp:Label ID="txnCountWeight" runat="server" ></asp:Label>
                    </td>
                     <td style="text-align:right;">
                        <asp:Label ID="txnCountScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                <tr>
                <td>Volume (Amount) of TXN for the period</td>
               
               
                
                <td style="text-align:right;">
                    <asp:Label ID="txnAmountRating" runat="server" ></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label ID="txnAmountWeight" runat="server" ></asp:Label>
                    </td>
                 <td style="text-align:right;">
                    <asp:Label ID="txnAmountScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                 <tr>
                <td>Number of Outlets used for the period</td>
               
                
               
                <td style="text-align:right;">
                    <asp:Label ID="outletsUsedRating" runat="server" ></asp:Label>
                     </td>
                      <td style="text-align:right;">
                    <asp:Label ID="outletsUsedWeight" runat="server"></asp:Label>
                     </td>
                <td style="text-align:right;">
                    <asp:Label ID="outletsUsedScore" runat="server" ></asp:Label>
                     </td>
                </tr>
                <tr>
                <td>Number of Beneficiary Country</td>
            
                
               
                <td style="text-align:right;">
                    <asp:Label ID="bnfcountrycountRating" runat="server" ></asp:Label>
                    </td>
                     <td style="text-align:right;">
                    <asp:Label ID="bnfcountrycountWeight" runat="server" ></asp:Label>
                    </td>
                <td style="text-align:right;">
                    <asp:Label ID="bnfcountrycountScore" runat="server" ></asp:Label>
                    </td>
                </tr>
                 <tr>
                <td>Number of Beneficiary</td>
              
                
               
                <td style="text-align:right;">
                    <asp:Label ID="bnfcountRating" runat="server" ></asp:Label>
                     </td>
                      <td style="text-align:right;">
                    <asp:Label ID="bnfcountWeight" runat="server" ></asp:Label>
                     </td>
                <td style="text-align:right;">
                    <asp:Label ID="bnfcountScore" runat="server" ></asp:Label>
                     </td>
                </tr>
                 <tr>
                <td style="text-align:center;font-weight:bold;">TOTAL</td>
              
                
               
               <td style="text-align:right;font-weight:bold;">
                    <asp:Label ID="customerRatingTotal" runat="server"></asp:Label>
                      </td>
                       <td style="text-align:right;font-weight:bold;">
                           <asp:Label ID="customerWeightTotal" runat="server">100.00</asp:Label>
                      </td>
                <td style="text-align:right;font-weight:bold;">
                    <asp:Label ID="customerScoreTotal" runat="server"></asp:Label>&nbsp;<asp:Label ID="customerRating" runat="server"></asp:Label>
                      </td>
                </tr>
            </table>
        </div>

         <div class="clear-fix">
        </div>
        <div>
            <table id="tblRBASummary" runat="server">
                <tr class="header">
                    <th colspan="4">
                        RBA Calculation Summary
                    </th>
                </tr>
                <tr class="sub-header">
                    <th style="width: 253px;">
                        Description
                    </th>
                    <th>
                        Rating
                    </th>
                    <th>
                        Weight
                    </th>
                    <th>
                        Score
                    </th>
                </tr>
                <tr>
                    <th>
                        Transaction Assesement
                    </th>
                    <td style="text-align:right;">
                        <asp:Label runat="server" ID="taRating"></asp:Label>
                    </td>
                    <td style="text-align:right;">
                        <asp:Label runat="server" ID="taWeight"></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label runat="server" ID="taScore"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <th>
                        Periodic Assesement
                    </th>
                    <td style="text-align:right;">
                        <asp:Label runat="server" ID="paRating"></asp:Label>
                    </td>
                    <td style="text-align:right;">
                        <asp:Label runat="server" ID="paWeight"></asp:Label>
                    </td>
                    <td style="text-align:right;">
                    <asp:Label runat="server" ID="paScore"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: center; font-weight: bold;">
                        TOTAL
                    </td>
                    <td style="text-align: right; font-weight: bold;">
                        
                    </td>
                    <td style="text-align: right; font-weight: bold;">
                        <asp:Label ID="rbaSummaryWeight" runat="server">100.00</asp:Label>
                    </td>
                    <td style="text-align: right; font-weight: bold;">
                        <asp:Label ID="rbaSummaryTotal" runat="server"></asp:Label>&nbsp;<asp:Label ID="rbaSummaryRating" runat="server"></asp:Label>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    </form>
</body>
</html>
