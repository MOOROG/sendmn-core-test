using System;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.GlobalBank;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using System.Text;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.BL.Remit.Transaction.ThirdParty;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.CashExpress;
using Swift.DAL.com.cashexpress.services.cash;
using Swift.DAL.com.riaremit.www;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.Ria;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.EzRemit;
using Swift.DAL.com.ezremit.www;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.Pay
{
    public partial class Pay : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20124600";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                PopulateDdl();
                Authenticate();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        void PopulateDdl()
        {
            _sdd.SetDDL(ref rIdType, "EXEC proc_countryIdType @flag = 'il-with-et', @countryId='151', @spFlag = '5201'", "detail", "idTitle", "", "Select");
            _sdd.SetDDL3(ref rIdPlaceOfIssue, "EXEC proc_zoneDistrictMap @flag = 'd'", "districtId", "districtName", "", "Select");
            _sdd.SetDDL3(ref relationType, "select valueId,detailTitle from staticDataValue where valueId in (2101,2102,2105,2106) and ISNULL(IS_DELETE,'N')<>'Y'", "valueId", "detailTitle", "", "Select");
        }

        protected void btnGo_Click(object sender, EventArgs e)
        {
            hddAgentName.Value = string.Concat(agentName.Text, '|', agentName.Value);
            SearchTransaction();
            GetStatic.ResizeFrame(Page);
        }
      
        protected void btnPay_Click(object sender, EventArgs e)
        {
            PayTran();
        }

        void SearchTransaction()
        {
            var dr = new TransactionUtilityDao().GetTxnStatus(GetStatic.GetUser(), partner.Text, controlNo.Text);

            if (dr.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, dr.Msg);
                return;
            }

            var tAgentId = partner.Text;
            if (tAgentId.Equals(Utility.GetgblAgentId()))
            {
                GblData(false);
            }
            else if (tAgentId.Equals(Utility.GetCEAgentId()))
            {
                CEData();
            }
            else if (tAgentId.Equals(Utility.GetezAgentID()))
            {
                EzData();
            }
            else if (tAgentId.Equals(Utility.GetriaAgentID()))
            {
                RiaData();
            }
            else if (tAgentId.Equals(Utility.GetmgAgentId()))
            {
                Response.Redirect("PayMg.aspx?branchId=" + agentName.Value + "&branchName=" + agentName.Text + "&referenceNo=" + controlNo.Text);
            }
            
        }

        void PayTran()
        {
            var tAgentId = partner.Text;
            var dr = new DbResult();

            if (tAgentId.Equals(Utility.GetgblAgentId()))
            {
                dr = PayGlobalTXN();
            }
            else if (tAgentId.Equals(Utility.GetCEAgentId()))
            {
                dr = PayCETXN();                
            }
            else if (tAgentId.Equals(Utility.GetriaAgentID()))
            {
                dr = PayRiaTXN();
            }
            else if (tAgentId.Equals(Utility.GetezAgentID()))
            {
                dr = PayEzTxn();
            }
            if (!dr.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, dr.Msg);
            }
            else
            {
                var url = "PayReceipt.aspx?controlNo=" + dr.Id;
                Response.Redirect(url);
            }
        }

        private void GblData(bool isCeTxn)
        {
            var gblDao = new GlobalBankDao();
            var dr = new DbResult();
            if (!isCeTxn)
            {
                dr = gblDao.GetStatus(GetStatic.GetUser(), controlNo.Text);
                if (dr.ErrorCode.Equals("1"))
                {
                    GetStatic.AlertMessage(Page, dr.Msg);
                    return;
                }
            }
            GlobalPayTransactionResponse response;
            var res = new DbResult();

            if (isCeTxn)
            {
                res = gblDao.SelectByPinNoCashExpress (GetStatic.GetUser(), agentName.Value, controlNo.Text, out response);
            }
            else
            {
                res = gblDao.SelectByPinNo(GetStatic.GetUser(), agentName.Value, controlNo.Text, out response);
            }

            if (!res.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, res.Msg);
                dvContent.InnerHtml = "";
                dvReceiver.Visible = false;
                return;
            }
            if (isCeTxn)
            {
                partner.SelectedIndex = 0;
            }

            HideSearchPanel();
            hddSCountry.Value = GetStatic.GetSendingCountryBySCurr(response.RCurrency);
            hddCeTxn.Value = res.Extra;
            var sb = new StringBuilder();

                    sb.Append(@"<table style=""margin-left: 20px;"" width=""800px"" cellspacing=""0"" cellpadding=""0"">            
                                <tr>
                                <td valign=""top"" colspan=""2"">");

                    sb.Append(@"<fieldset>
                                        <legend >Transaction Details</legend>
                                            <table border=""0"" width=""800px"" cellpadding=""0"">");
                    sb.Append("<tr>");
                    sb.Append("<td>");
                    sb.Append("<table width=\"400px\">");
                    sb.Append("<tr>");

                    sb.Append(@"<td nowrap=""nowrap"">Global Remit Control No: </td>
                                <td nowrap=""nowrap"" class=""HeighlightText"">"
                                    + controlNo.Text + @" 
                                </td>");
                    sb.Append("</tr>");

                    sb.Append("<tr>");
                    sb.Append(@"<td nowrap=""nowrap"" id= ""icn"">Transaction Date:</td>
                                    <td nowrap=""nowrap"">" + GetStatic.GetToday() + "</td>");

                    sb.Append("</tr>");
                    sb.Append("</table></td>");
                    sb.Append("<td><table width=\"400px\">");
                    sb.Append("<tr>");
                    sb.Append(@"<td nowrap=""nowrap""> Sending Country: </td>
                                <td nowrap=""nowrap"" >" + hddSCountry.Value + "</td>");

                    sb.Append("</tr>");
                    if (!string.IsNullOrWhiteSpace(response.RemitType))
                    {
                        sb.Append("<tr>");
                        sb.Append(@"<td nowrap=""nowrap""> Payment Mode: </td>
                                         <td nowrap=""nowrap"" class=""HeighlightText"" >" + GetStatic.GetPartnerPaymentMode(Utility.GetgblAgentId(), response.RemitType) + @"</td>");
                        sb.Append("</tr>");
                    }

                    sb.Append("</table>");
                    sb.Append("</td></tr>");

                    sb.Append(@"</table>
                                </fieldset> <br/>");

                    sb.Append(@"<tr>
                                    <td valign=""top"">
                    <fieldset style=""width: 400px;"">
                                        <legend>Sender Details</legend>
                                        <table width=""400px"" border=""0"" cellspacing=""0"" cellpadding=""0"">
                                            <tr>
                                                <td width=""19%"">
                                                    Name:
                                                </td>
                                                <td width=""81%"">
                                                    <span>" + response.SenderName + @"</span>
                                                </td>
                                            </tr>");

                    if (!string.IsNullOrWhiteSpace(response.SenderAddress))
                    {
                        sb.Append(@"<tr>
                                        <td>
                                            Address:
                                        </td>
                                        <td>" + response.SenderAddress + @"
                                        </td>
                                    </tr>");

                    }

                    sb.Append(@"<tr>
                                        <td>Country:</td>
                                        <td>" + GetStatic.GetSendingCountryBySCurr(response.RCurrency) + "</td></tr>");
                    if (!string.IsNullOrWhiteSpace(response.Remarks))
                    {

                        sb.Append(@"<tr>
                                                <td>
                                                    Message:
                                                </td>
                                                <td>"
                                +
                                response.Remarks
                                +
                            @"</td>
                                            </tr>");
                    }

                    sb.Append(@"</table>
                                    </fieldset>
                                </td>
                                <td valign=""top"">
                                    <fieldset style=""width: 400px;"">
                                        <legend>Receiver Details</legend>
                                        <table width=""400px"" border=""0"" cellspacing=""0"" cellpadding=""0"">");
                    sb.Append(@"<tr>
                                    <td width=""23%"">
                                        Name:
                                    </td>
                                    <td width=""77%"">
                                        <span >" + response.BenefName + @"</span>
                                    </td>
                                </tr>");

                    if (!string.IsNullOrWhiteSpace(response.BenefAddress))
                    {
                        sb.Append(@"<tr>
                                                <td>
                                                    Address:
                                                </td>
                                                <td>" + response.BenefAddress + @"</td>
                                            </tr>");
                    }


                    if (!string.IsNullOrWhiteSpace(response.BenefMobile))
                    {
                        sb.Append(@"
                                            <tr id=""isVrContactNo"">
                                                <td>
                                                    Contact No:
                                                </td>
                                                <td>" + response.BenefMobile + @"</td>
                                            </tr>");
                    }

                    if (!string.IsNullOrWhiteSpace(response.BenefAccIdNo))
                    {
                        sb.Append(@"<tr id=""isVrIdType"">
                                                <td nowrap='nowrap'>
                                                    " + response.BenefIdType + @"
                                                :</td>
                                                <td nowrap='nowrap'>
                                                    " + response.BenefAccIdNo + @"
                                                </td>
                                            </tr>");
                    }

                    sb.Append(@"</table>
                                    </fieldset>
                                </td>
                            </tr>
                                    <tr>
                                    <td colspan=""2"" class=""tableForm"" valign=""top"" >
                                        <br/>
                                        <fieldset>
                                        <legend>Transaction Amount</legend>
                                            <table border=""0"" cellspacing=""10"" cellpadding=""0"">
                                            <tr>");

                    if (!string.IsNullOrWhiteSpace(response.RCurrency))
                    {
                        sb.Append(@"<td nowrap=""nowrap"">" + response.PCurrency + @"</td>");
                    }

                    if (!string.IsNullOrWhiteSpace(response.Amount))
                    {
                        var amt = HideNoAfterDecimal(response.Amount);
                        sb.Append(@"<td nowrap=""nowrap"" class=""text-amount"">" + GetStatic.ShowDecimal(amt) + @"</td>

                                    <td nowrap=""nowrap""  colspan=""3"" >" + GetStatic.NumberToWord(amt) + @"</td>
                                   </tr>");
                    }

                    sb.Append(@"
                        </table>
                    </fieldset>
            
                </td>
            </tr>
            </table>");
            dvContent.InnerHtml = sb.ToString();
            dvReceiver.Visible = true;
            hddRowId.Value = res.Id;
            hddPayAmt.Value = HideNoAfterDecimal(response.Amount);
            hddControlNo.Value = controlNo.Text;
            hddTokenId.Value = response.TokenId;
            
        }        

        private void CEData()
        {
            var ceDao = new CashExpressDao();
            var pin = controlNo.Text;
            EnquiryTransactionResponseDTO xResponse = null;
            var res = ceDao.SelectByPinNo(GetStatic.GetUser(), agentName.Value, pin, out xResponse);
            if (!res.ErrorCode.Equals("0"))
            {
                partner.Text = Utility.GetgblAgentId();
                
                GblData(true);
                return;
            }

            if (xResponse.paymentMode.ToString() == "2")
            {
                GetStatic.AlertMessage(Page, "Sorry, You cannot proceed to pay. Mode: Bank Deposit.");
                return;
            }

            HideSearchPanel();
            var sb = new StringBuilder();
            sb.Append(@"<table style=""margin-left: 20px;"" width=""800px"" cellspacing=""0"" cellpadding=""0"">");

            sb.Append(@"<tr>
                            <td colspan=""2"" class=""tableForm"" valign=""top"" >
                            <fieldset>
                                <legend >Transaction Details</legend>
                                    <table border=""0"" width=""800px"" cellpadding=""0"">");
            sb.Append("<tr>");
            sb.Append("<td>");
            sb.Append("<table width=\"400px\">");
            sb.Append("<tr>");

            sb.Append(@"<td nowrap=""nowrap"">GIT No: </td>
                        <td nowrap=""nowrap"" class=""HeighlightText"">"
                            + controlNo.Text + @" 
                        </td>");
            sb.Append("</tr>");

            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap"" id= ""icn"">Transaction Date:</td>
                            <td nowrap=""nowrap"">" + GetStatic.GetToday() + "</td>");

            sb.Append("</tr>");
            sb.Append("</table></td>");
            sb.Append("<td><table width=\"400px\">");
            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap""> Sending Country: </td>
                        <td nowrap=""nowrap"" >" + GetStatic.GetAgentCountry(Utility.GetCEAgentId()) + @"</td>");

            sb.Append("</tr>");
            if (!string.IsNullOrWhiteSpace(xResponse.paymentMode.ToString()))
            {
                sb.Append("<tr>");
                sb.Append(@"<td nowrap=""nowrap""> Payment Mode: </td>
                                <td nowrap=""nowrap"" class=""HeighlightText"" >" + GetStatic.GetPartnerPaymentMode(Utility.GetCEAgentId(), xResponse.paymentMode.ToString()) + @"</td>");
                sb.Append("</tr>");


            }

            sb.Append("</table>");
            sb.Append("</td></tr>");

            sb.Append(@"</table>
                        </fieldset><br/>");
            sb.Append(@"<tr>
                            <td valign=""top"" class=""tableForm"" style=""width: 50%"">
                                <fieldset>
                                    <legend>Sender Information</legend>
                                    <table>");
            if (!string.IsNullOrWhiteSpace(xResponse.custName))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Name: </td>
                                <td>
                                    " + xResponse.custName + @"
                                </td>
                            </tr>");
            }

            if (!string.IsNullOrWhiteSpace(xResponse.custAddress))
            {
                sb.Append(@"<tr>
                                            <td nowrap=""nowrap"">Address: </td>
                                            <td >
                                                " + xResponse.custAddress + @" 
                                            </td>
                                        </tr>");
            }

            if (!string.IsNullOrWhiteSpace(xResponse.custPhone))
                sb.Append(@"<tr>
                            <td nowrap=""nowrap"" >Phone: </td>
                            <td >
                                " + xResponse.custPhone + @" 
                            </td>
                        </tr>");
            if (!string.IsNullOrWhiteSpace(xResponse.description))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"" >Message Form Remitter: </td>
                                <td>
                                    " + xResponse.description + @"
                                </td>
                            </tr>");
            }

            sb.Append(@"</table>
                           </fieldset>
                            </td>
                            <td valign=""top"" class=""tableForm"">
                                <fieldset>
                                    <legend>Receiver Information</legend>
                                    <table>");
            if (!string.IsNullOrWhiteSpace(xResponse.beneName))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Name: </td>
                                <td >
                                    " + xResponse.beneName + @" 
                                </td>
                            </tr>");
            }

            if (!string.IsNullOrWhiteSpace(xResponse.beneAddress))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Address: </td>
                                <td >
                                    " + xResponse.beneAddress + @" 
                                </td>
                            </tr>");
            }


            if (!string.IsNullOrWhiteSpace(xResponse.benePhone))
            {
                sb.Append(@"<tr>
                                            <td nowrap=""nowrap"">Phone: </td>
                                            <td >
                                                " + xResponse.benePhone + @" 
                                            </td>
                                        </tr>");
            }

            if (!string.IsNullOrWhiteSpace(xResponse.beneIdNo))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Beneficiary ID: </td>
                                <td >
                                    " + xResponse.beneIdNo + @"
                                </td>
                            </tr>");
            }

            sb.Append(@"</table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td colspan=""2"" class=""tableForm"" valign=""top"" >
                               <br/>
                                <fieldset>
                                <legend >Payout Amount</legend>
                                    <table border=""0"" cellspacing=""10"" cellpadding=""0"">
                                        <tr>");

            if (!string.IsNullOrWhiteSpace(xResponse.destinationCurrency))
            {
                sb.Append(@"<td nowrap=""nowrap"" id= ""payoutCurr"">" + xResponse.destinationCurrency + "</td>");
            }

            if (!string.IsNullOrWhiteSpace(xResponse.destinationAmount))
            {
                sb.Append(@"<td nowrap=""nowrap""  class=""HeighlightText"">" + GetStatic.ShowDecimal(HideNoAfterDecimal(xResponse.destinationAmount)) + @"</td>
                            <td nowrap=""nowrap"" colspan=""3"" >" + GetStatic.NumberToWord(xResponse.destinationAmount) + @"</td>
                        </tr>");
            }

            sb.Append(@"</table>
                        </fieldset>
                        <br/>
                    </td>
                </tr>
            </table>");

            dvContent.InnerHtml = sb.ToString();
            dvReceiver.Visible = true;
            hddRowId.Value = res.Id;
            hddPayAmt.Value = xResponse.destinationAmount;
            hddControlNo.Value = controlNo.Text;
        }

        private void RiaData()
        {
            var riaDao = new RiaDao();
            SearchTransactionResponse response;
            var res = riaDao.SelectByPinNo(GetStatic.GetUser(), agentName.Value, controlNo.Text, out response);
            if (!res.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, res.Msg);
                dvContent.InnerHtml = "";
                dvReceiver.Visible = false;
                return;
            }
            HideSearchPanel();
            hddSCountry.Value = response.CustCountry;
            var sb = new StringBuilder();

            sb.Append(@"<table style=""margin-left: 20px;"" width=""800px"" cellspacing=""0"" cellpadding=""0"">            
                        <tr>
                        <td valign=""top"" colspan=""2"">");

            sb.Append(@"<fieldset>
                                <legend >Transaction Details</legend>
                                    <table border=""0"" width=""800px"" cellpadding=""0"">");
            sb.Append("<tr>");
            sb.Append("<td>");
            sb.Append("<table width=\"400px\">");
            sb.Append("<tr>");

            sb.Append(@"<td nowrap=""nowrap"">Security No: </td>
                        <td nowrap=""nowrap"" class=""HeighlightText"">"
                            + controlNo.Text + @" 
                        </td>");
            sb.Append("</tr>");

            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap"" id= ""icn"">Transaction Date:</td>
                            <td nowrap=""nowrap"">" + GetStatic.GetToday() + "</td>");

            sb.Append("</tr>");
            sb.Append("</table></td>");
            sb.Append("<td><table width=\"400px\">");
            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap""> Sending Country: </td> 
                        <td nowrap=""nowrap"" >" + GetStatic.GetCountryNameFromCountryCode(response.CustCountry) + "(" + GetStatic.GetAgentNameFromAgentId(Utility.GetriaAgentID()) + ")</td>");


            sb.Append("</table>");
            sb.Append("</td></tr>");

            sb.Append(@"</table>
                        </fieldset> <br/>");

            sb.Append(@"<tr>
                            <td valign=""top"">
            <fieldset style=""width: 400px;"">
                                <legend>Sender Details</legend>
                                <table width=""400px"" border=""0"" cellspacing=""0"" cellpadding=""0"">
                                    <tr>
                                        <td width=""19%"">
                                            Name:
                                        </td>
                                        <td width=""81%"">
                                            <span>" + (response.CustNameFirst + " " + response.CustNameLast1 + " " + response.CustNameLast2).Replace("  "," ") + @"</span>
                                        </td>
                                    </tr>");

            if (!string.IsNullOrWhiteSpace(response.CustAddress))
            {
                sb.Append(@"<tr>
                                <td>
                                    Address:
                                </td>
                                <td>" + response.CustAddress + @"
                                </td>
                            </tr>");

            }
            if (!string.IsNullOrWhiteSpace(response.CustTelNo))
            {
                sb.Append(@"<tr>
                                <td>
                                    Phone:
                                </td>
                                <td>" + response.CustTelNo + @"
                                </td>
                            </tr>");

            }
            if (!string.IsNullOrWhiteSpace(response.CustCity))
            {
                sb.Append(@"<tr>
                                <td>
                                    City:
                                </td>
                                <td>" + response.CustCity + @"
                                </td>
                            </tr>");

            }
            if (!string.IsNullOrWhiteSpace(response.CustCountry))
            {
                sb.Append(@"<tr>
                                <td>Country:</td>
                                <td>");
                sb.Append(GetStatic.GetCountryNameFromCountryCode(response.CustCountry));
                sb.Append("</td></tr>");
            }
            
            sb.Append(@"</table>
                            </fieldset>
                        </td>
                        <td valign=""top"">
                            <fieldset style=""width: 400px;"">
                                <legend>Receiver Details</legend>
                                <table width=""400px"" border=""0"" cellspacing=""0"" cellpadding=""0"">");
            sb.Append(@"<tr>
                            <td width=""23%"">
                                Name:
                            </td>
                            <td width=""77%"">
                                <span >" + (response.BeneNameFirst + " " + response.BeneNameLast1 + " " + response.BeneNameLast2).Replace("  "," ") + @"</span>
                            </td>
                        </tr>");

            if (!string.IsNullOrWhiteSpace(response.BeneAddress))
            {
                sb.Append(@"<tr>
                                        <td>
                                            Address:
                                        </td>
                                        <td>" + response.BeneAddress + @"</td>
                                    </tr>");
            }


            if (!string.IsNullOrWhiteSpace(response.BeneTelNo))
            {
                sb.Append(@"
                                    <tr id=""isVrContactNo"">
                                        <td>
                                            Contact No:
                                        </td>
                                        <td>" + response.BeneTelNo + @"</td>
                                    </tr>");
            }


            sb.Append(@"</table>
                            </fieldset>
                        </td>
                    </tr>
                            <tr>
                            <td colspan=""2"" class=""tableForm"" valign=""top"" >
                                <br/>
                                <fieldset>
                                <legend>Payout Amount</legend>
                                    <table border=""0"" cellspacing=""10"" cellpadding=""0"">
                                    <tr>");


            sb.Append(@"<td nowrap=""nowrap"" id= ""payoutCurr"">" + (string.IsNullOrWhiteSpace(response.BeneCurrency) ? " NPR" : response.BeneCurrency) + "</td>");


            if (!string.IsNullOrWhiteSpace(response.BeneAmount))
            {

                sb.Append(@"<td nowrap=""nowrap"" class=""text-amount"">" + GetStatic.ShowDecimal(HideNoAfterDecimal(response.BeneAmount)) + @"</td>

                            <td nowrap=""nowrap""  colspan=""3"" >" + GetStatic.NumberToWord(HideNoAfterDecimal(response.BeneAmount)) + @"</td>
                           </tr>");
            }

            sb.Append(@"
                </table>
            </fieldset>
            
        </td>
    </tr>
</table>");
            dvContent.InnerHtml = sb.ToString();
            dvReceiver.Visible = true;
            hddRowId.Value = res.Id;
            hddPayAmt.Value = response.BeneAmount;
            hddControlNo.Value = controlNo.Text;
            hddTokenId.Value = response.TransRefID;
            hddOrderNo.Value = response.OrderNo;
            hddRCurrency.Value = response.BeneCurrency;
        }

        private DbResult PayGlobalTXN()
        {
            var isCeTxn = hddCeTxn.Value.Equals("1");
            var gblDao = new GlobalBankDao();
            return gblDao.PayConfirm(
                GetStatic.GetUser(), hddRowId.Value, hddControlNo.Value, hddTokenId.Value, hddSCountry.Value,
                GetPBranchId(), rIdType.Text, rIdNumber.Text, rIdPlaceOfIssue.SelectedItem.ToString(), rContactNo.Text, 
                relationType.SelectedItem.ToString(), relativeName.Text, isCeTxn,"","");
        }     

        private DbResult PayCETXN()
        {
            var ceDao = new CashExpressDao();
            var idType = rIdType.Text;
            return ceDao.PayConfirm(GetStatic.GetUser(), hddRowId.Value, hddControlNo.Value
                    , GetPBranchId(), idType, rIdNumber.Text, rIdPlaceOfIssue.SelectedItem.ToString(), rContactNo.Text, 
                    relationType.SelectedItem.ToString(), relativeName.Text, hddPayAmt.Value,"","");
        }

        private DbResult PayRiaTXN()
        {
            var riaDao = new RiaDao();
            var idType = rIdType.Text;
            return riaDao.PayConfirm(GetStatic.GetUser(), hddRowId.Value,
                                     hddTokenId.Value, hddOrderNo.Value, hddControlNo.Value, hddRCurrency.Value, hddPayAmt.Value, "", //CorrespLocID
                                     hddSCountry.Value,
                                     agentName.Value,
                                     idType, rIdNumber.Text, rIdPlaceOfIssue.SelectedItem.ToString(),
                                     DateTime.Now.ToString("yyyyMMdd"),
                                     rContactNo.Text, relationType.SelectedItem.ToString(), relativeName.Text,"","");
        }

        private void EzData()
        {
            var ezRemitDao = new EzRemitDao();
            EzTransaction ezTxnresponse = null;
            var res = ezRemitDao.SelectByPinNo(GetStatic.GetUser(), agentName.Value, controlNo.Text, out ezTxnresponse);
            if (!res.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, res.Msg);
                dvContent.InnerHtml = "";
                dvReceiver.Visible = false;
                return;
            }
            HideSearchPanel();
            var sb = new StringBuilder();
            sb.Append(@"<table style=""margin-left: 20px;"" width=""800px"" cellspacing=""0"" cellpadding=""0"">");

            sb.Append(@"<tr>
                            <td colspan=""2"" class=""tableForm"" valign=""top"" >
                            <fieldset>
                                <legend >Transaction Details</legend>
                                    <table border=""0"" width=""800px"" cellpadding=""0"">");
            sb.Append("<tr>");
            sb.Append("<td>");
            sb.Append("<table width=\"400px\">");
            sb.Append("<tr>");

            sb.Append(@"<td nowrap=""nowrap"">Security No: </td>
                        <td nowrap=""nowrap"" class=""HeighlightText"">"
                            + controlNo.Text + @" 
                        </td>");
            sb.Append("</tr>");

            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap"" id= ""icn"">Transaction Date:</td>
                            <td nowrap=""nowrap"">" + GetStatic.GetToday() + "</td>");

            sb.Append("</tr>");
            sb.Append("</table></td>");
            sb.Append("<td><table width=\"400px\">");
            sb.Append("<tr>");
            sb.Append(@"<td nowrap=""nowrap""> Sending Country: </td>
                        <td nowrap=""nowrap"" >" + GetStatic.GetAgentCountry(Utility.GetezAgentID()) + @"</td>");

            sb.Append("</tr>");
            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TypeOfTransaction))
            {
                sb.Append("<tr>");
                sb.Append(@"<td nowrap=""nowrap""> Payment Mode: </td>
                                <td nowrap=""nowrap"" class=""HeighlightText"" >" + GetStatic.GetPartnerPaymentMode(Utility.GetezAgentID(), ezTxnresponse.TypeOfTransaction) + @"</td>");
                sb.Append("</tr>");


            }

            sb.Append("</table>");
            sb.Append("</td></tr>");

            sb.Append(@"</table>
                        </fieldset><br/>");
            sb.Append(@"<tr>
                            <td valign=""top"" class=""tableForm"" style=""width: 50%"">
                                <fieldset>
                                    <legend>Sender Information</legend>
                                    <table>");
            if (!string.IsNullOrWhiteSpace(ezTxnresponse.SendingCustomer.CustomerName))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Name: </td>
                                <td>
                                    " + ezTxnresponse.SendingCustomer.CustomerName + @"
                                </td>
                            </tr>");
            }

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.SendingCustomer.CustomerAddress))
            {
                sb.Append(@"<tr>
                                            <td nowrap=""nowrap"">Address: </td>
                                            <td >
                                                " + ezTxnresponse.SendingCustomer.CustomerAddress + @" 
                                            </td>
                                        </tr>");
            }

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.SendingCustomer.CustTelephoneNumber))
                sb.Append(@"<tr>
                            <td nowrap=""nowrap"" >Phone: </td>
                            <td >
                                " + ezTxnresponse.SendingCustomer.CustTelephoneNumber + @" 
                            </td>
                        </tr>");
            if (!string.IsNullOrWhiteSpace(ezTxnresponse.SendingCustomer.CustMessage))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"" >Message Form Remitter: </td>
                                <td>
                                    " + ezTxnresponse.SendingCustomer.CustMessage + @"
                                </td>
                            </tr>");
            }

            sb.Append(@"</table>
                           </fieldset>
                            </td>
                            <td valign=""top"" class=""tableForm"">
                                <fieldset>
                                    <legend>Receiver Information</legend>
                                    <table>");
            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionBeneficiary.Name))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Name: </td>
                                <td >
                                    " + ezTxnresponse.TransactionBeneficiary.Name + @" 
                                </td>
                            </tr>");
            }

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionBeneficiary.Address))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Address: </td>
                                <td >
                                    " + ezTxnresponse.TransactionBeneficiary.Address + @" 
                                </td>
                            </tr>");
            }


            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionBeneficiary.TelephoneNumber))
            {
                sb.Append(@"<tr>
                                            <td nowrap=""nowrap"">Phone: </td>
                                            <td >
                                                " + ezTxnresponse.TransactionBeneficiary.TelephoneNumber + @" 
                                            </td>
                                        </tr>");
            }

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionBeneficiary.IdNumber))
            {
                sb.Append(@"<tr>
                                <td nowrap=""nowrap"">Beneficiary ID: </td>
                                <td >
                                    " + ezTxnresponse.TransactionBeneficiary.IdNumber + @"
                                </td>
                            </tr>");
            }

            sb.Append(@"</table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td colspan=""2"" class=""tableForm"" valign=""top"" >
                               <br/>
                                <fieldset>
                                <legend >Payout Amount</legend>
                                    <table border=""0"" cellspacing=""10"" cellpadding=""0"">
                                        <tr>");

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionPaymentDetails.FxCurrencyCode))
            {
                sb.Append(@"<td nowrap=""nowrap"" id= ""payoutCurr"">" + ezTxnresponse.TransactionPaymentDetails.FxCurrencyCode + "</td>");
            }

            if (!string.IsNullOrWhiteSpace(ezTxnresponse.TransactionPaymentDetails.FxAmount.ToString()))
            {
                sb.Append(@"<td nowrap=""nowrap""  class=""HeighlightText"">" + GetStatic.ShowDecimal(HideNoAfterDecimal(ezTxnresponse.TransactionPaymentDetails.FxAmount.ToString())) + @"</td>
                            <td nowrap=""nowrap"" colspan=""3"" >" + GetStatic.NumberToWord(HideNoAfterDecimal(ezTxnresponse.TransactionPaymentDetails.FxAmount.ToString())) + @"</td>
                        </tr>");
            }

            sb.Append(@"</table>
                        </fieldset>
                        <br/>
                    </td>
                </tr>
            </table>");

            dvContent.InnerHtml = sb.ToString();
            dvReceiver.Visible = true;
            hddRowId.Value = res.Id;
            hddPayAmt.Value = ezTxnresponse.TransactionPaymentDetails.LocalAmount.ToString();
            hddControlNo.Value = controlNo.Text;

        }

        private DbResult PayEzTxn()
        {
            var ezRemitDao = new EzRemitDao();
            var idType = rIdType.Text;
            var res = ezRemitDao.PayConfirm(GetStatic.GetUser(), hddRowId.Value, hddControlNo.Value, GetPBranchId(), 
                idType, rIdNumber.Text, rIdPlaceOfIssue.SelectedItem.ToString(), rContactNo.Text, relationType.SelectedItem.ToString(), 
                relativeName.Text,"","");
            return res;
        }

        private string GetPBranchId()
        {
            return hddAgentName.Value.Split('|')[1];
        }

        private void HideSearchPanel()
        {
            tblSearch.Visible = false;
            agentNameDiv.Visible = true;
            lblAgentName.Text = hddAgentName.Value;
        }

        private static string HideNoAfterDecimal(string amount)
        {
            return Math.Floor(Convert.ToDouble(amount)).ToString();
        }

    }
}