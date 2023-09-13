using System;
using System.Data;
using System.IO;
using System.Text;
using AjaxControlToolkit;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.Domain;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.API.TPAPIs.MerchatradePushAPI;

namespace Swift.web.Responsive.Send.SendMoneyv2
{
    public partial class Confirm : System.Web.UI.Page
    {
        readonly SendTranIRHDao _st = new SendTranIRHDao();
        readonly RemittanceLibrary _sl = new RemittanceLibrary();

        #region Get Sender Details
        public readonly string _senderId = GetStatic.ReadQueryString("senderId", "");
        readonly string _senfName = GetStatic.ReadQueryString("sfName", "");
        readonly string _senmName = GetStatic.ReadQueryString("smName", "");
        readonly string _senlName = GetStatic.ReadQueryString("slName", "");
        readonly string _senlName2 = GetStatic.ReadQueryString("slName2", "");
        readonly string _senIdType = GetStatic.ReadQueryString("sIdType", "");
        readonly string _senIdNo = GetStatic.ReadQueryString("sIdNo", "");
        readonly string _senIdValid = GetStatic.ReadQueryString("sIdValid", "");
        readonly string _senGender = GetStatic.ReadQueryString("sGender", "");
        readonly string _sendob = GetStatic.ReadQueryString("sdob", "");
        readonly string _senTel = GetStatic.ReadQueryString("sTel", "");
        readonly string _senMobile = GetStatic.ReadQueryString("sMobile", "");
        readonly string _senNaCountry = GetStatic.ReadQueryString("sNaCountry", "");
        readonly string _sencity = GetStatic.ReadQueryString("sCity", "");
        readonly string _senPostCode = GetStatic.ReadQueryString("sPostCode", "");
        readonly string _senAdd1 = GetStatic.ReadQueryString("sAdd1", "");
        readonly string _senAdd2 = GetStatic.ReadQueryString("sAdd2", "");
        readonly string _senEmail = GetStatic.ReadQueryString("sEmail", "");
        readonly string _smsSend = GetStatic.ReadQueryString("smsSend", "");
        readonly string _memberCode = GetStatic.ReadQueryString("memberCode", "");
        private readonly string _senCompany = GetStatic.ReadQueryString("sCompany", "");
        #endregion

        #region Get RECEIVER Details
        readonly string _benId = GetStatic.ReadQueryString("benId", "");
        readonly string _recfName = GetStatic.ReadQueryString("rfName", "");
        readonly string _recmName = GetStatic.ReadQueryString("rmName", "");
        readonly string _reclName = GetStatic.ReadQueryString("rlName", "");
        readonly string _reclName2 = GetStatic.ReadQueryString("rlName2", "");
        readonly string _recIdType = GetStatic.ReadQueryString("rIdType", "");
        readonly string _recIdNo = GetStatic.ReadQueryString("rIdNo", "");
        readonly string _recIdValid = GetStatic.ReadQueryString("rIdValid", "");
        readonly string _recGender = GetStatic.ReadQueryString("rGender", "");
        readonly string _recdob = GetStatic.ReadQueryString("rdob", "");
        readonly string _recTel = GetStatic.ReadQueryString("rTel", "");
        readonly string _recMobile = GetStatic.ReadQueryString("rMobile", "");
        //readonly string recNaCountry = GetStatic.ReadQueryString("rNaCountry", "");
        readonly string _reccity = GetStatic.ReadQueryString("rCity", "");
        readonly string _recPostCode = GetStatic.ReadQueryString("rPostCode", "");
        readonly string _recAdd1 = GetStatic.ReadQueryString("rAdd1", "");
        readonly string _recAdd2 = GetStatic.ReadQueryString("rAdd2", "");
        readonly string _recEmail = GetStatic.ReadQueryString("rEmail", "");
        readonly string _recaccountNo = GetStatic.ReadQueryString("accountNo", "");
        #endregion

        #region Get Transaction Details

        readonly string _pCountryName = GetStatic.ReadQueryString("pCountry", "");
        readonly long _pCountryId = GetStatic.ReadNumericDataFromQueryString("payCountryId");
        readonly string _dm = GetStatic.ReadQueryString("collMode", "");
        private readonly long _dmId = GetStatic.ReadNumericDataFromQueryString("collModeId");
        readonly string _pBank = GetStatic.ReadQueryString("pBank", "").Replace("undefined", "");
        readonly string _pBankName = GetStatic.ReadQueryString("pBankText", "");
        readonly string _pBankBranch = GetStatic.ReadQueryString("pBankBranch", "").Replace("undefined", "");
        readonly string _pBankBranchName = GetStatic.ReadQueryString("pBankBranchText", "");
        private readonly string _pBankType = GetStatic.ReadQueryString("pBankType", "");
        readonly string _pAgent = GetStatic.ReadQueryString("pAgent", "");
        private readonly string _pAgentName = GetStatic.ReadQueryString("pAgentName", "");
        readonly string _pCurr = GetStatic.ReadQueryString("pCurr", "");
        readonly string _collCurr = GetStatic.ReadQueryString("collCurr", "");
        readonly decimal _cAmt = GetStatic.ReadDecimalDataFromQueryString("collAmt");
        readonly decimal _pAmt = GetStatic.ReadDecimalDataFromQueryString("payAmt");
        readonly decimal _tAmt = GetStatic.ReadDecimalDataFromQueryString("sendAmt");
        private readonly decimal _customerTotalAmt = GetStatic.ReadDecimalDataFromQueryString("customerTotalAmt");
        readonly decimal _serviceCharge = GetStatic.ReadDecimalDataFromQueryString("scharge");
        readonly decimal _discount = GetStatic.ReadDecimalDataFromQueryString("discount");
        readonly decimal _customerRate = GetStatic.ReadDecimalDataFromQueryString("exRate");
        readonly string _schemeType = GetStatic.ReadQueryString("schemeType", "");
        readonly string schemeName = GetStatic.ReadQueryString("schemeName", "");
        readonly string scDiscount = GetStatic.ReadQueryString("scDiscount", "");
        readonly string exRateOffer = GetStatic.ReadQueryString("exRateOffer", "");
        private readonly string _couponId = GetStatic.ReadQueryString("couponId", "");

        private readonly string _pLocation = GetStatic.ReadQueryString("pLocation", "");
        private readonly string _pLocationText = GetStatic.ReadQueryString("pLocationText", "");
        private readonly string _pSubLocation = GetStatic.ReadQueryString("pSubLocation", "");
        private readonly string _pSubLocationText = GetStatic.ReadQueryString("pSubLocationText", "");

        private readonly string _tpExRate = GetStatic.ReadQueryString("tpExRate", "");

        #endregion

        #region additional information
        readonly string _por = GetStatic.ReadQueryString("por", "");
        readonly string _sof = GetStatic.ReadQueryString("sof", "");
        readonly string _rel = GetStatic.ReadQueryString("rel", "");
        readonly string _occupation = GetStatic.ReadQueryString("occupation", "");
        readonly string _payMsg = GetStatic.ReadQueryString("payMsg", "");
        readonly string _company = GetStatic.ReadQueryString("company", "");
        readonly string _nCust = GetStatic.ReadQueryString("newCustomer", "");
        readonly string _eCust = GetStatic.ReadQueryString("EnrollCustomer", "");
        readonly string _cancelrequestId = GetStatic.ReadQueryString("cancelrequestId", "");
        readonly string _pSuperAgent = GetStatic.ReadQueryString("pSuperAgent", "");
        private readonly string _salary = GetStatic.ReadQueryString("salary", "");

        //readonly string _hdnreqAgent = GetStatic.ReadQueryString("hdnreqAgent", "");
        readonly string _hdnreqBranch = GetStatic.ReadQueryString("hdnreqBranch", "");

        //new fields added
        readonly string _isManualSC = GetStatic.ReadQueryString("isManualSC", "");
        readonly string _manualSC = GetStatic.ReadQueryString("manualSC", "");
        readonly string _sCustStreet = GetStatic.ReadQueryString("sCustStreet", "");
        readonly string _sCustLocation = GetStatic.ReadQueryString("sCustLocation", "");
        readonly string _sCustomerType = GetStatic.ReadQueryString("sCustomerType", "");
        readonly string _sCustBusinessType = GetStatic.ReadQueryString("sCustBusinessType", "");
        readonly string _sCustIdIssuedCountry = GetStatic.ReadQueryString("sCustIdIssuedCountry", "");
        readonly string _sCustIdIssuedDate = GetStatic.ReadQueryString("sCustIdIssuedDate", "");
        readonly string _receiverId = GetStatic.ReadQueryString("receiverId", "");

        #endregion

        private const string ViewFunctionId = "40101400";
        private const string AddEditFunctionId = "40101420";
        protected bool isProcessedBtnEnabled = true;

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            voucherDate1.Attributes.Add("readonly", "readonly");
            voucherDate2.Attributes.Add("readonly", "readonly");
            voucherDate1.Text = DateTime.Now.ToString("d");
            voucherDate2.Text = DateTime.Now.ToString("d");
            if (!IsPostBack)
            {
                ShowData();
                CheckForCdd();
                InvoicePrintMode();
                PopulateDDL();
                RBAScreening();
            }
            trRnc.Attributes.Add("style", "display: none;");
            trWp.Attributes.Add("style", "display: none;");
            trRnc.Visible = false;
        }

        private void RBAScreening()
        {
            var agentRefId = Guid.NewGuid().ToString();
            agentRefId = agentRefId.Substring(0, 18);
            hdnAgentRefId.Value = agentRefId;
            var dt = _st.RBAScreening(_senderId.ToString(), _cAmt.ToString(), GetStatic.GetUser(), _senNaCountry, hdnAgentRefId.Value);

            if (dt == null)
                return;

            var dr = dt.Rows[0];
            var errCode = dt.Rows[0][0].ToString();

            if (errCode == "0" || errCode == "2" || errCode == "3")
            {
                if (errCode == "2" || errCode == "3")
                {
                    divEcdd.Visible = true;

                    if (dr["spanMsg"].ToString() != "")
                    {
                        spnEcdd.InnerHtml = dr["spanMsg"].ToString();
                    }
                }

                //hdnRBAScoreTxn.Value = dr["RBAScoreTxn"].ToString();
                //hdnRBAScoreCustomer.Value = dr["RBAScoreCustomer"].ToString();
                hdnRBATxnRisk.Value = dr["TransactionRisk"].ToString();
                hdnRBACustomerRisk.Value = dr["CustomerRisk"].ToString();
                hdnRBACustomerRiskValue.Value = dr["customerRiskValue"].ToString();
                return;
            }
            else if (errCode == "11")
            {
                dvAlertSummary.InnerHtml = dt.Rows[0][1].ToString();
                btnProceed.Attributes.Add("disabled", "disabled");
                isProcessedBtnEnabled = false;
            }
        }

        private void PopulateDDL()
        {
            _sl.SetDDL(ref bankList1, "SELECT rowId, bankName FROM vwBankLists (NOLOCK)", "rowId", "bankName", "", "Select Bank");
            _sl.SetDDL(ref bankList2, "SELECT rowId, bankName FROM vwBankLists (NOLOCK)", "rowId", "bankName", "", "Select Bank");
        }

        private void InvoicePrintMode()
        {
            var obj = new ReceiptDao();
            DataRow dr = obj.GetInvoiceMode(GetStatic.GetAgent());
            if (dr == null)
                return;

            if (dr["mode"].ToString().Equals("Single"))
                invoicePrintMode.Text = "s";
            else
                invoicePrintMode.Text = "d";
        }

        //Customer Due Diligence
        private void CheckForCdd()
        {
            var customerTotalAmt = _customerTotalAmt + _cAmt;
            if (customerTotalAmt > GetStatic.ParseInt(GetStatic.ReadWebConfig("cddEddBal", "300000")))
            {
                spnCdd.Visible = true;
                chkCdd.Visible = true;
                btnProceed.Enabled = false;
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        protected void ShowData()
        {
            var confirmText = "Confirmation:\n_____________________________________";
            confirmText += "\n\nAre you sure to send this transaction?";
            btnProceedCc.ConfirmText = confirmText;

            if (!ValidateTransaction())
                return;

            if (_dm.ToUpper() == "BANK DEPOSIT")
            {
                tdAccountNoLbl.Visible = true;
                tdAccountNoTxt.Visible = true;
                accountNo.Text = _recaccountNo;
            }
            else if (_dm.ToUpper() == "CASH PAYMENT TO OTHER BANK")
            {
                trPaymentThrough.Visible = true;
                paymentThrough.Text = _pAgentName;
            }

            sName.Text = _senfName + " " + _senmName + " " + _senlName + " " + _senlName2;
            sAddress.Text = string.IsNullOrWhiteSpace(_senAdd1) ? _senAdd2 : _senAdd1;
            sCity.Text = _sencity;
            sEmail.Text = _senEmail;
            sIdType.Text = _senIdType;
            sIdNo.Text = _senIdNo;
            sIdValidty.Text = _senIdValid;
            sdob.Text = _sendob;
            sCountry.Text = _senNaCountry;
            sContactNo.Text = _senMobile;
            sTelNo.Text = _senTel;

            rName.Text = _recfName + " " + _recmName + " " + _reclName + " " + _reclName2;
            rAddress.Text = string.IsNullOrWhiteSpace(_recAdd1) ? _recAdd2 : _recAdd1;
            rCity.Text = _reccity;
            remail.Text = _recEmail;
            //rCountry.Text = recNaCountry;
            rContactNo.Text = _recMobile;
            rIdtype.Text = _recIdType;
            ridNo.Text = _recIdNo;
            ridvalidity.Text = _recIdValid;
            rdob.Text = _recdob;
            rTelNo.Text = _recTel;

            transferAmount.Text = GetStatic.ShowDecimal(_tAmt.ToString());
            serviceCharge.Text = GetStatic.FormatData(_serviceCharge.ToString(), "M");
            total.Text = GetStatic.ShowDecimal(_cAmt.ToString());

            exchangeRate.Text = _customerRate.ToString();
            payoutAmt.Text = GetStatic.ShowDecimal(_pAmt.ToString());
            sCurr1.Text = _collCurr;
            sCurr2.Text = _collCurr;
            sCurr3.Text = _collCurr;
            pCurr1.Text = _pCurr;
            pCurr2.Text = _pCurr;

            if (!string.IsNullOrEmpty(_schemeType))
            {
                tdSchemeLbl.Visible = true;
                tdSchemeTxt.Visible = true;
                var html = schemeName + "<br/> <div style='font-size:11px;'><span style='color: red;'>" + exRateOffer +
                           "</span> (Ex. Rate)";
                html += " <span style='color: red;'>" + scDiscount + "</span> (S.C.)</div>";
                spnSchemeOffer.InnerHtml = html;
            }

            if (!string.IsNullOrEmpty(_payMsg))
            {
                msgToReceiver.Visible = true;
                payoutMsg.InnerHtml = @"<b>Message:</b> <br /><pre><span>" + _payMsg + "</span></pre>";
            }

            if (_pCountryId.ToString() != "151")
            {
                pLocationDetail.Visible = true;
                pLocation.Text = _pLocationText;
                pSubLocation.Text = _pSubLocationText;
            }

            pCountry.Text = _pCountryName;
            pAgentBranch.Text = "Anywhere";
            if (!string.IsNullOrEmpty(_pBankName))
                pAgentBranch.Text = _pBankName;
            if (!string.IsNullOrEmpty(_pBankBranchName))
                pAgentBranch.Text = _pBankName + " - " + _pBankBranchName;
            modeOfPayment.Text = _dm;

            //Load Tran Details
        }

        private string Msg = "";

        private bool RequiredFieldValidate()
        {
            if (_nCust == "N")
            {
                if (_senderId == "")
                {
                    Msg = "Please choose Sender";
                    return false;
                }
            }

            if (string.IsNullOrWhiteSpace(_pLocation) && _pCountryId.ToString() != "151")
            {
                Msg = " Payout Location is missing";
                return false;
            }

            if (string.IsNullOrWhiteSpace(_pSubLocation) && _pCountryId.ToString() != "151")
            {
                Msg = " Payout Sub Location is missing";
                return false;
            }

            if (string.IsNullOrWhiteSpace(_senfName))
            {
                Msg = " Sender First Name missing";
                return false;
            }

            if (string.IsNullOrWhiteSpace(_recfName))
            {
                Msg = " Receiver First Name missing";
                return false;
            }

            if (!string.IsNullOrEmpty(_senIdValid))
            {
                if (Convert.ToDateTime(_senIdValid) < DateTime.Now)
                {
                    Msg = "Sender ID is expired";
                    return false;
                }
            }

            if (!string.IsNullOrEmpty(_recIdValid))
            {
                if (Convert.ToDateTime(_recIdValid) < DateTime.Now)
                {
                    Msg = "Receiver ID is expired";
                    return false;
                }
            }

            if (string.IsNullOrWhiteSpace(_memberCode) && _eCust == "Y")
            {
                Msg = "MemberCode is missing for Customer Enrollment";
                return false;
            }
            if (string.IsNullOrWhiteSpace(_dm))
            {
                Msg = "Please choose payment mode";
                return false;
            }
            if (_tAmt == 0)
            {
                Msg = "Transfer Amount missing";
                return false;
            }
            if (_customerRate == 0)
            {
                Msg = "Exchange Rate missing";
                return false;
            }
            if (_cAmt == 0)
            {
                Msg = "Collection Amount is missing. Cannot send transaction";
                return false;
            }
            if (_tAmt >= GetStatic.ParseInt(GetStatic.ReadWebConfig("cddEddBal", "300000")))
            {
                if (string.IsNullOrWhiteSpace(_por) || string.IsNullOrWhiteSpace(_sof))
                {
                    Msg = "Purpose of remittance and source of fund is required for Sending Amt " + GetStatic.ReadWebConfig("cddEddBal", "300000");
                    return false;
                }
            }

            return true;
        }
        //Sender ID is expired
        private bool ValidateTransaction()
        {
            if (!RequiredFieldValidate())
            {
                string Message = "1-:::-" + Msg;
                GetStatic.CallBackJs1(Page, "Print Message", "ManageMessage('" + Message + "');");
                return false;
            }
            var trn = new IRHTranDetail();
            var randObj = new Random();

            var agentRefId = randObj.Next(1000000000, 1999999999).ToString();
            hdnAgentRefId.Value = agentRefId;
            trn.AgentRefId = agentRefId;
            trn.User = GetStatic.GetUser();
            trn.SessionId = GetStatic.GetSessionId();
            trn.SenderId = _senderId.ToString();
            trn.SenFirstName = _senfName;
            trn.SenMiddleName = _senmName;
            trn.SenLastName = _senlName;
            trn.SenLastName2 = _senlName2;
            trn.SenGender = _senGender;
            trn.SenIdType = _senIdType;
            trn.SenIdNo = _senIdNo;
            trn.SenIdValid = _senIdValid;
            trn.SenDob = _sendob;
            trn.SenEmail = _senEmail;
            trn.SenTel = _senTel;
            trn.SenMobile = _senMobile;
            trn.SenNaCountry = _senNaCountry;
            trn.SenCity = _sencity;
            trn.SenPostCode = _senPostCode;
            trn.SenAdd1 = _senAdd1;
            trn.SenAdd2 = _senAdd2;
            trn.SenEmail = _senEmail;
            trn.SmsSend = _smsSend;
            trn.ReceiverId = _benId.ToString();
            trn.RecFirstName = _recfName;
            trn.RecMiddleName = _recmName;
            trn.RecLastName = _reclName;
            trn.RecLastName2 = _reclName2;
            trn.RecGender = _recGender;
            trn.RecIdType = _recIdType;
            trn.RecIdNo = _recIdNo;
            trn.RecIdValid = _recIdValid;
            trn.RecDob = _recdob;
            trn.RecTel = _recTel;
            trn.RecMobile = _recMobile;
            trn.RecNaCountry = "";
            trn.RecCity = _reccity;
            trn.RecPostCode = _recPostCode;
            trn.RecAdd1 = _recAdd1;
            trn.RecAdd2 = _recAdd2;
            trn.RecEmail = _recEmail;
            trn.RecAccountNo = _recaccountNo;
            trn.RecCountryId = _pCountryId.ToString();
            trn.RecCountry = _pCountryName;
            trn.DeliveryMethod = _dm;
            trn.DeliveryMethodId = _dmId.ToString();
            trn.PBank = _pBank;
            trn.PBankName = _pBankName;
            trn.PBankBranch = _pBankBranch;
            trn.PBankBranchName = _pBankBranchName;
            trn.PBankType = _pBankType;
            trn.PAgent = _pAgent;
            trn.PAgentName = _pAgentName;
            trn.PBankType = _pBankType;

            trn.PCurr = _pCurr;
            trn.CollCurr = _collCurr;
            trn.CollAmt = _cAmt.ToString();
            trn.PayoutAmt = _pAmt.ToString();
            trn.TransferAmt = _tAmt.ToString();
            trn.ServiceCharge = _serviceCharge.ToString();
            trn.Discount = _discount.ToString();
            trn.ExRate = _customerRate.ToString();
            trn.SchemeCode = _schemeType;
            trn.CouponTranNo = _couponId;
            trn.PurposeOfRemittance = _por;
            trn.SourceOfFund = _sof;
            trn.RelWithSender = _rel;
            trn.Occupation = _occupation;
            trn.PayoutMsg = _payMsg;
            trn.Company = _company;
            trn.NCustomer = _nCust;
            trn.ECustomer = _eCust;
            trn.MemberCode = _memberCode;

            trn.SBranch = GetStatic.GetBranch();
            trn.SBranchName = GetStatic.GetBranchName();
            trn.SAgent = GetStatic.GetAgent();
            trn.SAgentName = GetStatic.GetAgentName();
            trn.SSuperAgent = GetStatic.GetSuperAgent();
            trn.SSuperAgentName = GetStatic.GetSuperAgentName();
            trn.SettlingAgent = GetStatic.GetSettlingAgent();
            trn.SCountry = GetStatic.GetCountry();
            trn.SCountryId = GetStatic.GetCountryId();

            trn.CwPwd = cwPwd.Text;
            trn.TtName = ttName.Text;

            trn.isManualSC = _isManualSC;
            trn.manualSC = _manualSC;
            trn.sCustStreet = _sCustStreet;
            trn.sCustLocation = _sCustLocation;
            trn.sCustomerType = _sCustomerType;
            trn.sCustBusinessType = _sCustBusinessType;
            trn.sCustIdIssuedCountry = _sCustIdIssuedCountry;
            trn.sCustIdIssuedDate = _sCustIdIssuedDate;
            trn.receiverId = _receiverId;

            trn.tpExRate = _tpExRate;

            DataSet ds = new DataSet();
            //if (_pCountryId.ToString() != "151" && _pCountryId.ToString() != "203")
            //{
            //    ds = _st.ValidateTransactionTP(trn);
            //}
            //else
            //{
            //    ds = _st.ValidateTransaction(trn);
            //}
            ds = _st.ValidateTransaction(trn);

            var dbResult = _st.ParseDbResult(ds.Tables[0]);

            if (dbResult.ErrorCode != "0")
            {
                complianceField.Visible = true;
                divCompliance.Visible = true;
                if (dbResult.ErrorCode == "100")
                {
                    var result = dbResult.Id.Split('|');
                    hdnOfacRes.Value = result[0];
                    hdnOfacReason.Value = result[1];
                    if (ds.Tables[1].Rows.Count > 0)
                        LoadOfacList(dbResult, ds.Tables[1]);
                    if (ds.Tables.Count > 2)
                    {
                        var dbResult2 = _st.ParseDbResult(ds.Tables[2]);
                        if (ds.Tables[3].Rows.Count > 0)
                            LoadComplianceListNew(dbResult2, ds.Tables[3]);
                    }
                    return true;
                }

                if (dbResult.ErrorCode == "101")
                {
                    btnProceed.Enabled = false;
                    btnProceed.Visible = false;
                    if (ds.Tables[1].Rows.Count > 0)
                        LoadComplianceListNew(dbResult, ds.Tables[1]);
                    return true;
                }

                if (dbResult.ErrorCode == "102")
                {
                    btnProceed.Enabled = true;
                    btnProceed.Visible = true;
                    if (ds.Tables[1].Rows.Count > 0)
                        LoadComplianceListNew(dbResult, ds.Tables[1]);
                    return true;
                }
                var mes = GetStatic.ParseResultJsPrint(dbResult);
                GetStatic.CallBackJs1(Page, "Print Message", "ManageMessage('" + mes + "');");
                return false;
            }
            else
            {
                var html = new StringBuilder();
                var dt1 = ds.Tables[1];
                if (dt1.Rows.Count > 0)
                {
                    var totalAmt = 0.0;
                    divComplianceMultipleTxn.Visible = true;
                    btnProceed.Enabled = true;
                    chkMultipleTxn.Visible = true;
                    html.Append("<table class='table table-responsive table-striped table-bordered'>");
                    html.Append("<td colspan=\"6\" style=\"color: red; font-weight: bold; font-family: verdana;\">");
                    html.Append("WARNING!! Previous transaction found with same name");
                    html.Append("</td>");

                    html.Append("<tr>");
                    html.Append("<th>Tran No.</th>");
                    html.Append("<th>Sender Name</th>");
                    html.Append("<th>Sender Id Type</th>");
                    html.Append("<th>Sender Id No.</th>");
                    html.Append("<th>Amount</th>");
                    html.Append("<th>Receiving Country</th>");
                    html.Append("</tr>");

                    foreach (DataRow dr in dt1.Rows)
                    {
                        html.Append("<tr style=\"background-color: #F9CCCC;\">");
                        html.Append("<td>" + dr["tranId"] + "</td>");
                        html.Append("<td>" + dr["senderName"] + "</td>");
                        html.Append("<td>" + dr["sIdType"] + "</td>");
                        html.Append("<td>" + dr["sIdNo"] + "</td>");
                        html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(dr["cAmt"].ToString()) + "</td>");
                        html.Append("<td>" + dr["pCountry"] + "</td>");
                        html.Append("</tr>");
                        totalAmt += Convert.ToDouble(dr["cAmt"]);
                    }
                    html.Append("<tr>");
                    html.Append("<td>Current</td>");
                    html.Append("<td>" + GetStatic.GetFullName(_senfName, _senmName, _senlName, _senlName2) + "</td>");
                    html.Append("<td>" + _senIdType + "</td>");
                    html.Append("<td>" + _senIdNo + "</td>");
                    html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(_cAmt.ToString()) + "</td>");
                    html.Append("<td>" + _pCountryName + "</td>");
                    html.Append("</tr>");
                    totalAmt += Convert.ToDouble(_cAmt);

                    html.Append("<tr>");
                    html.Append("<td colspan=\"4\" style=\"text-align: right;\"><b>Total</b></td>");
                    html.Append("<td style=\"text-align: right;\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td>");
                    html.Append("</tr>");
                    html.Append("</table>");
                }

                var dt2 = ds.Tables[2];
                if (dt2.Rows.Count > 0)
                {
                    var totalAmt = 0.0;
                    divComplianceMultipleTxn.Visible = true;
                    btnProceed.Enabled = true;
                    chkMultipleTxn.Visible = true;
                    html.Append("<table class='table table-responsive table-striped table-bordered'>");
                    html.Append("<td colspan=\"6\" style=\"color: red; font-weight: bold; font-family: verdana;\">WARNING!! Previous transaction found with same ID Detail</td>");

                    html.Append("<tr>");
                    html.Append("<th>Tran No.</th>");
                    html.Append("<th>Sender Name</th>");
                    html.Append("<th>Sender Id Type</th>");
                    html.Append("<th>Sender Id No.</th>");
                    html.Append("<th>Amount</th>");
                    html.Append("<th>Receiving Country</th>");
                    html.Append("</tr>");

                    foreach (DataRow dr in dt1.Rows)
                    {
                        html.Append("<tr style=\"background-color: #F9CCCC;\">");
                        html.Append("<td>" + dr["tranId"] + "</td>");
                        html.Append("<td>" + dr["senderName"] + "</td>");
                        html.Append("<td>" + dr["sIdType"] + "</td>");
                        html.Append("<td>" + dr["sIdNo"] + "</td>");
                        html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(dr["cAmt"].ToString()) + "</td>");
                        html.Append("<td>" + dr["pCountry"] + "</td>");
                        html.Append("</tr>");
                        totalAmt += Convert.ToDouble(dr["cAmt"]);
                    }
                    html.Append("<tr>");
                    html.Append("<td>Current</td>");
                    html.Append("<td>" + GetStatic.GetFullName(_senfName, _senmName, _senlName, _senlName2) + "</td>");
                    html.Append("<td>" + _senIdType + "</td>");
                    html.Append("<td>" + _senIdNo + "</td>");
                    html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(_cAmt.ToString()) + "</td>");
                    html.Append("<td>" + _pCountryName + "</td>");
                    html.Append("</tr>");
                    totalAmt += Convert.ToDouble(_cAmt);

                    html.Append("<tr>");
                    html.Append("<td colspan=\"4\" style=\"text-align: right;\"><b>Total</b></td>");
                    html.Append("<td style=\"text-align: right;\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td>");
                    html.Append("</tr>");
                    html.Append("</table>");
                }
                divComplianceMultipleTxn.InnerHtml = html.ToString();
            }
            return true;
        }

        private void LoadOfacList(DbResult dbResult, DataTable dt)
        {
            var confirmText = "Confirmation:\n_____________________________________";
            confirmText += "\n\nYou are confirming to send this OFAC suspicious transaction!!!";
            confirmText += "\n\nPlease note if this customer is found to be valid person from OFAC List then Teller will be charged fine from management";
            confirmText += "\n\n\nPlease make sure you have proper evidence that show this customer is not from OFAC List";
            btnProceedCc.ConfirmText = confirmText;
            int cols = dt.Columns.Count;
            spnWarningMsg.InnerHtml = dbResult.Msg;
            var str = new StringBuilder("<table class='TBLData' border=\"1\" cellspacing=0 cellpadding=\"3\">");
            str.Append("<tr>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align=\"left\">" + dr[0] + "</td>");

                string[] strArr = {
                                        _senfName.ToUpper(), _senmName.ToUpper(), _senlName.ToUpper(), _senlName2.ToUpper(), 
                                        _recfName.ToUpper(), _recmName.ToUpper(), _reclName.ToUpper(), _reclName2.ToUpper()
                                    };
                var arrlen = strArr.Length;
                string value = dr[1].ToString();
                for (int j = 0; j < arrlen; j++)
                {
                    if (!string.IsNullOrWhiteSpace(strArr[j]))
                    {
                        //if (j == 0 && !string.IsNullOrWhiteSpace(strArr[j]))
                        value = value.ToUpper().Replace(strArr[j],
                                                        GetStatic.PutRedBackGround(strArr[j]));
                        //if (j == 1 && !string.IsNullOrWhiteSpace(strArr[j]))
                        //    value = value.ToUpper().Replace(strArr[j],
                        //                                    GetStatic.PutYellowBackGround(strArr[j]));
                        //if (j == 2 && !string.IsNullOrWhiteSpace(strArr[j]))
                        //    value = value.ToUpper().Replace(strArr[j],
                        //                                    GetStatic.PutBlueBackGround(strArr[j]));
                        //if (j == 3 && !string.IsNullOrWhiteSpace(strArr[j]))
                        //    value = value.ToUpper().Replace(strArr[j],
                        //                                    GetStatic.PutHalfYellowBackGround(strArr[j]));
                    }
                }
                str.Append("<td align=\"left\">" + value + "</td>");
                str.Append("</tr>");
            }
            //str.Append("<tr><td>");
            //str.Append("<input type=\"button\" id=\"btnProceedOfac\" value=\"Proceed\" onclick=\"ProceedOfac();\" />");
            //str.Append("</td></tr>");
            str.Append("<tr>");
            str.Append("<td colspan=\"2\">OFAC Listed Customer are BLACK Listed customer or Suspicious for terrorist or Money Loundery Customer" +
                        ", please ask for valid documentation from customer</td>");
            str.Append("</tr>");
            str.Append("</table>");
            divOfac.InnerHtml = str.ToString();
        }

        private void LoadComplianceListNew(DbResult dbResult, DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str =
                new StringBuilder("<table class='table table-responsive table-striped table-bordered'>");
            str.Append("<tr>");
            for (int i = 2; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td>" + dr["S.N."].ToString() + "</td>");
                str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" +
                            dr["Id"].ToString() + "&type=compNew')\">" + dr["Remarks"].ToString() + "</a></td>");
                str.Append("<td align='center' class='bg-danger'></strong>" + dr["Action"].ToString() + "</strong></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            divCompliance.InnerHtml = str.ToString();
        }

        private void LoadComplianceList(DbResult dbResult, DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str =
                new StringBuilder("<table class='table table-responsive table-striped table-bordered'>");
            str.Append("<tr>");
            for (int i = 2; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                for (int i = 2; i < cols; i++)
                {
                    if (i == 4)
                    {
                        var strArr = dr["Matched Tran ID"].ToString().Split(',');
                        var arrlen = strArr.Length;
                        str.Append("<td>");
                        for (int j = 0; j < arrlen; j++)
                        {
                            str.Append(
                                "<a href=\"#\" onclick=\"OpenInNewWindow('/Remit/Transaction/Reports/SearchTransaction.aspx?tranId=" +
                                strArr[j] + "')\">" + strArr[j] + "</a> &nbsp;");
                        }
                        str.Append("</td>");
                    }
                    else if (i == 3)
                    {
                        str.Append(
                            "<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" +
                            dr["Id"].ToString() + "&csID=" + dr["csDetailRecId"] + "')\">" +
                            dr[i].ToString() + "</a></td>");
                    }
                    else
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                }
                str.Append("</tr>");
            }
            str.Append("</table>");
            divCompliance.InnerHtml = str.ToString();
        }

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            Proceed();
        }

        private void Proceed()
        {
            if (chkCdd.Visible && !chkCdd.Checked)
            {
                GetStatic.AlertMessage(Page, "Please assure that you have conducted Customer Due Diligence");
                return;
            }
            var dbResult = Save();
            if (dbResult.ErrorCode == "0" || dbResult.ErrorCode == "100" || dbResult.ErrorCode == "101")
            {
                GetStatic.SetMessage(dbResult);
                //SendToBestRemit(dbResult.Id);
                //string url = "../../../Remit/Transaction/Agent/ReprintReceipt/SendIntlReceipt.aspx?controlNo=" + dbResult.Id;
                //Response.Redirect(url);
                ManageMessage1(dbResult);
            }
            else
            {
                var message = "alert('" + GetStatic.FilterMessageForJs(dbResult.Msg) + "');";
                GetStatic.CallBackJs1(Page, "cb", message);
            }
        }

        //private void SendToBestRemit(string controlNo)
        //{
        //    IBestRemitDao _bestRemit = new BestRemitDao();

        //    SendTransactionDetails _details = SetTxnDetails(controlNo);
        //    _bestRemit.SendTransaction(_details);
        //}

        //private SendTransactionDetails SetTxnDetails(string controlNo)
        //{
        //    SendTransactionDetails _txnDetails = new SendTransactionDetails
        //    {
        //        MembershipId = _memberCode,
        //        ControlNo = controlNo,
        //        CustomerName = GetStatic.GetFullName(_senfName, _senmName, _senlName, _senlName2),
        //        CustomerAddress = _senAdd1,
        //        CustomerContact = _senMobile,
        //        CustomerCity = _sencity,
        //        CustomerCountry = "",
        //        CustomerIdType = _senIdType,
        //        CustomerIdNumber = _senIdNo,
        //        BeneName = GetStatic.GetFullName(_recfName, _recmName, _reclName, _reclName2),
        //        BeneAddress = _recAdd1,
        //        BeneContact = _recMobile,
        //        BeneCity = _reccity,
        //        BeneCountry = "Nepal",
        //        Profession = _occupation,
        //        IncomeSource = _sof,
        //        Relationship = _rel,
        //        PurposeOfRemittance = _por,
        //        SendingAmount = _tAmt.ToString(),//_cAmt
        //        ReceivingAmount = _pAmt.ToString(),
        //        PaymentMethod = _dm,
        //        BankCode = _pBank,
        //        BankName = _pBankName,
        //        BankBranchName = _pBankBranchName,
        //        BankAccountNumber = _recaccountNo
        //    };
        //    return _txnDetails;
        //}

        private void ManageMessage1(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "ManageMessage";
            var functionName = "ManageMessage('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }
        private DbResult Save()
        {
            var trn = new IRHTranDetail();

            trn.AgentRefId = hdnAgentRefId.Value;
            trn.User = GetStatic.GetUser();
            trn.SessionId = GetStatic.GetSessionId();
            trn.SenderId = _senderId.ToString();
            trn.SenFirstName = _senfName;
            trn.SenMiddleName = _senmName;
            trn.SenLastName = _senlName;
            trn.SenLastName2 = _senlName2;
            trn.SenGender = _senGender;
            trn.SenIdType = _senIdType;
            trn.SenIdNo = _senIdNo;
            trn.SenIdValid = _senIdValid;
            trn.SenDob = _sendob;
            trn.SenEmail = _senEmail;
            trn.SenTel = _senTel;
            trn.SenMobile = _senMobile;
            trn.SenNaCountry = _senNaCountry;
            trn.SenCity = _sencity;
            trn.SenPostCode = _senPostCode;
            trn.SenAdd1 = _senAdd1;
            trn.SenAdd2 = _senAdd2;
            trn.SenEmail = _senEmail;
            trn.SenCompany = _senCompany;

            trn.SmsSend = _smsSend;
            trn.ReceiverId = _benId.ToString();
            trn.RecFirstName = _recfName;
            trn.RecMiddleName = _recmName;
            trn.RecLastName = _reclName;
            trn.RecLastName2 = _reclName2;
            trn.RecGender = _recGender;
            trn.RecIdType = _recIdType;
            trn.RecIdNo = _recIdNo;
            trn.RecIdValid = _recIdValid;
            trn.RecDob = _recdob;
            trn.RecTel = _recTel;
            trn.RecMobile = _recMobile;
            trn.RecNaCountry = "";
            trn.RecCity = _reccity;
            trn.RecPostCode = _recPostCode;
            trn.RecAdd1 = _recAdd1;
            trn.RecAdd2 = _recAdd2;
            trn.RecEmail = _recEmail;
            trn.RecAccountNo = _recaccountNo;
            trn.RecCountryId = _pCountryId.ToString();
            trn.RecCountry = _pCountryName;

            trn.DeliveryMethod = _dm;
            trn.DeliveryMethodId = _dmId.ToString();
            trn.PBank = _pBank;
            trn.PBankName = _pBankName;
            trn.PBankBranch = _pBankBranch;
            trn.PBankBranchName = _pBankBranchName;
            trn.PBankType = _pBankType;
            trn.PAgent = _pAgent;
            trn.PAgentName = _pAgentName;

            trn.PCurr = _pCurr;
            trn.CollCurr = _collCurr;
            trn.CollAmt = _cAmt.ToString();
            trn.PayoutAmt = _pAmt.ToString();
            trn.TransferAmt = _tAmt.ToString();
            trn.ServiceCharge = _serviceCharge.ToString();
            trn.Discount = _discount.ToString();
            trn.ExRate = _customerRate.ToString();
            trn.SchemeCode = _schemeType;
            trn.CouponTranNo = _couponId;
            trn.PurposeOfRemittance = _por;
            trn.SourceOfFund = _sof;
            trn.RelWithSender = _rel;
            trn.Occupation = _occupation;
            trn.PayoutMsg = _payMsg;
            trn.Company = _company;
            trn.NCustomer = _nCust;
            trn.ECustomer = _eCust;
            trn.MemberCode = _memberCode;

            trn.CancelRequestId = _cancelrequestId;
            trn.Salary = _salary;
            trn.TxnPassword = txnPassword.Text;

            trn.SBranch = GetStatic.GetBranch();
            trn.SBranchName = GetStatic.GetBranchName();
            trn.SAgent = GetStatic.GetAgent();
            trn.SAgentName = GetStatic.GetAgentName();
            trn.SSuperAgent = GetStatic.GetSuperAgent();
            trn.SSuperAgentName = GetStatic.GetSuperAgentName();
            trn.SettlingAgent = GetStatic.GetSettlingAgent();
            trn.SCountry = GetStatic.GetCountry();
            trn.SCountryId = GetStatic.GetCountryId();

            trn.CwPwd = cwPwd.Text;
            trn.TtName = ttName.Text;

            trn.OfacRes = hdnOfacRes.Value;
            trn.OfacReason = hdnOfacReason.Value;

            trn.RBATxnRisk = hdnRBATxnRisk.Value;
            trn.RBACustomerRisk = hdnRBACustomerRisk.Value;
            trn.RBACustomerRiskValue = hdnRBACustomerRiskValue.Value;

            trn.DcInfo = "";
            trn.DcInfo = GetStatic.GetDcInfo();
            trn.IpAddress = GetStatic.GetIp();

            //trn.pLocation = _pLocation;
            //trn.pLocationText = _pLocationText;
            //trn.pSubLocation = _pSubLocation;
            //trn.pSubLocationText = _pSubLocationText;


            trn.tpExRate = _tpExRate;
            
            trn.manualSC = _manualSC;
            trn.isManualSC = _isManualSC;
            trn.sCustStreet = _sCustStreet;
            trn.sCustLocation = _sCustLocation;
            trn.sCustomerType = _sCustomerType;
            trn.sCustBusinessType = _sCustBusinessType;
            trn.sCustIdIssuedCountry = _sCustIdIssuedCountry;
            trn.sCustIdIssuedDate = _sCustIdIssuedDate;
            trn.receiverId = _receiverId;

            trn.VoucherDetail = GetVoucherDetail();
            //if (_pCountryId.ToString() != "151" && _pCountryId.ToString() != "203")
            //{
            //    DbResult _dbRes = new DbResult();
            //    DataRow _tpDetails = null;
            //    DataSet ds = _st.SendTransactionIRHNew(trn);

            //    _dbRes = _st.ParseDbResult(ds.Tables[0]);
            //    if (ds.Tables.Count > 1)
            //    {
            //        _tpDetails = ds.Tables[1].Rows[0];
            //    }
                
            //    if (_dbRes.ErrorCode == "0" || _dbRes.ErrorCode == "100" || _dbRes.ErrorCode == "101")
            //    {
            //        DbResult _mtradeResp = new DbResult();
            //        IMtradeSendAPIDao _mtrade = new MtradeSendAPIDao();
            //        MtradePushDetail _mtradePushDetails = SetPushDetails(trn, _dbRes.Id, _tpDetails);
            //        _mtradeResp = _mtrade.SendTxnMtrade(GetStatic.GetUser(), "mtrade", _mtradePushDetails);

            //        if (_mtradeResp.ErrorCode != "1000")
            //        {
            //            _dbRes.ErrorCode = "1";
            //            _dbRes.Msg = _mtradeResp.Msg;
            //            _st.RevertTPTxns(_mtradePushDetails.collTranId, GetStatic.GetUser());
            //            return _dbRes;
            //        }
            //        else
            //        {
            //            trn.tpRefNo = _mtradeResp.Extra;
            //            trn.tpTranId = _mtradeResp.Id;
            //            trn.tpExRate = _mtradeResp.Extra2;

            //            _dbRes = _st.UpdateTPTxns(trn, _dbRes.Id, GetStatic.GetUser());

            //            return _dbRes;
            //        }
            //    }
            //    else
            //    {
            //        return _dbRes;
            //    }
            //}
            
            return _st.SendTransactionIRH(trn);
        }

        private MtradePushDetail SetPushDetails(IRHTranDetail trn, string controlNo, DataRow _tpDetails)
        {
            FullName _senderName = new FullName();
            FullName _recName = new FullName();
            _senderName = GetStatic.ParseName(_senfName);
            _recName = GetStatic.ParseName(_recfName);

            return new MtradePushDetail
            {
                collTranId = controlNo,
                payoutAgentCd = _tpDetails["pAgentCode"].ToString(),
                payoutAmount = String.Format("{0:0,0}", double.Parse(trn.PayoutAmt)).Replace(",", ""),
                payoutCurrency = trn.PCurr,
                payoutMode = (trn.DeliveryMethod.Equals("CASH PAYMENT")) ? "2" : "1",
                senderFirstName = _senderName.FirstName,
                senderMiddleName = _senderName.MiddleName,
                senderLastName = _senderName.LastName1,
                senderAddress = trn.SenAdd1,
                senderNationalityCd = _tpDetails["sederNationalityCode"].ToString(),
                senderIdCardTypeCd = _tpDetails["sIdTypeCode"].ToString(),
                senderIdCardTypeNo = _senIdNo,
                receiverFirstName = _recName.FirstName,
                receiverMiddleName = _recName.MiddleName,
                receiverLastName = _recName.LastName1 + " " + _recName.LastName2,
                receiverAddress = _recAdd1,
                senderPhoneNo = _senMobile,
                receiverPhoneNo = _recMobile,
                receiverNationalityCd = _tpDetails["receiverNationalityCode"].ToString(),
                receiverBankCd = _tpDetails["rBankCode"].ToString(),
                receiverBankBranchCd = _tpDetails["rBankBranchCode"].ToString(),
                receiverBankAcNo = _recaccountNo,
                receiverIdCardTypeCd = _tpDetails["rIdTypeCode"].ToString(),
                receiverIdCardTypeNo = _recIdNo,
                senderRelationWithReceiverCd = "",
                sourceOfFundCd = _tpDetails["sourceOfFund"].ToString(),
                reasonOfRemittanceCd = _tpDetails["reasonOfRemittance"].ToString(),
                senderOccupationCd = _tpDetails["senderOccoupation"].ToString(),
                senderBirthDate = _sendob,
                reasonOfRemittanceText = _por,
                sourceOfFundText = _sof,
                remarks = "",
                occupationText = "",
                relationshipText = "",
                remitType = _tpDetails["remitType"].ToString(),
                countryofBusiness = "",
                personName = "",
                personIdCardTypeCd = "",
                personIdCardTypeNo = "",
                personDateofBirth = "",
                personDesignation = "",
                personNationalityCd = "",
            };
        }

        private string GetVoucherDetail()
        {
            StringBuilder sb = new StringBuilder("<root>");
            sb.AppendLine("<row");
            sb.AppendLine("voucherNo=\"" + voucherNo1.Text + "\" ");
            sb.AppendLine("voucherDate=\"" + voucherDate1.Text + "\" ");
            sb.AppendLine("voucherAmount=\"" + voucherAmount1.Text + "\" ");
            sb.AppendLine("bankId=\"" + bankList1.SelectedValue + "\" ");
            sb.AppendLine("/>");

            if (!string.IsNullOrEmpty(voucherNo2.Text))
            {
                sb.AppendLine("<row");
                sb.AppendLine("voucherNo=\"" + voucherNo2.Text + "\" ");
                sb.AppendLine("voucherDate=\"" + voucherDate2.Text + "\" ");
                sb.AppendLine("voucherAmount=\"" + voucherAmount2.Text + "\" ");
                sb.AppendLine("bankId=\"" + bankList2.SelectedValue + "\" ");
                sb.AppendLine("/>");
            }
            sb.AppendLine("</root>");
            return sb.ToString();
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var invPrintMode = invoicePrintMode.Text;
            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "','" + invPrintMode  + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        protected void btnProceed2_Click(object sender, EventArgs e)
        {
            Proceed();
        }

        protected void chkMultipleTxn_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkCdd.Visible)
                btnProceed.Enabled = chkMultipleTxn.Checked;
            else
            {
                if (chkMultipleTxn.Checked && chkCdd.Checked)
                    btnProceed.Enabled = true;
                else
                    btnProceed.Enabled = false;
            }
        }

        protected void chkCdd_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkMultipleTxn.Visible)
                btnProceed.Enabled = chkCdd.Checked;
            else
            {
                if (chkMultipleTxn.Checked && chkCdd.Checked)
                    btnProceed.Enabled = true;
                else
                    btnProceed.Enabled = false;
            }
        }
    }
}