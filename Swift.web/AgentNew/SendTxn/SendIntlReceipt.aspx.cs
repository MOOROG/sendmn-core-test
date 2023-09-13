using Swift.API.Common;
using Swift.API.Common.SMS;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.AgentNew.SendTxn
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            var methodName = Request.Form["MethodName"];
            if (methodName == "SendSMS")
                SendSMS();

            if (!IsPostBack)
            {
                ShowData();
                ShowMultipleReceipt();
            }
            GetStatic.AlertMessage(this.Page);
        }

        private void ShowMultipleReceipt()
        {
            if (GetInvoicePrintMode() != "")
            {
                if (GetInvoicePrintMode() == "s")
                {
                    divInvoiceSecond.Attributes.Add("style", "margin: 15px 0; display: none;");
                    divInvoiceSecond1.Attributes.Add("style", "display: none;");
                }
            }
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        private string GetInvoicePrintMode()
        {
            return GetStatic.ReadQueryString("invoicePrint", "");
        }

        protected void ShowData()
        {
            //lblControlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >= 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    //Load Sender Information
                    DataRow sRow = ds.Tables[0].Rows[0];
                    senderName.Text = sRow["senderName"].ToString();
                    sMemId.Text = sRow["sMemId"].ToString();
                    sAddress.Text = sRow["sAddress"].ToString();
                    sNativeCountry.Text = sRow["sNativeCountry"].ToString();
                    purpose.Text = sRow["purpose"].ToString();
                    sDob.Text = sRow["sDob"].ToString();
                    sContactNo.Text = sRow["sContactNo"].ToString();
                    visaStatus.Text = sRow["visaStatus"].ToString();

                    txnSenderMobile.Text = sRow["sContactNo"].ToString();
                    smsToSend.Text = GetSMSText(sRow);
                    //Load Receiver Information
                    receiverName.Text = sRow["receiverName"].ToString();
                    pAgentCountry.Text = sRow["pAgentCountry"].ToString();
                    paymentMode.Text = sRow["paymentMode"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();

                    pAgent.Text = sRow["pAgent"].ToString();
                    rAddress.Text = sRow["rAddress"].ToString();
                    pBankName.Text = sRow["pBankName"].ToString();
                    relationShip.Text = sRow["relwithSender"].ToString();

                    serial1.Text = sRow["tranId"].ToString();
                    serial2.Text = sRow["tranId"].ToString();

                    //comment by gunn
                    //pBranchName.Text = sRow["pBranchName"].ToString();
                    pBranchName.Text = sRow["BranchName"].ToString();
                    accountNo.Text = sRow["accountNo"].ToString();
                    rAmtWords.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
                    controlNo.Text = sRow["controlNo"].ToString();
                    createdBy.Text = sRow["createdBy"].ToString();
                    approvedDate.Text = DateTime.Parse(sRow["createdDate"].ToString()).ToString("yyyy-MM-dd hh:mm:ss tt");
                    cAmt.Text = GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
                    serviceCharge.Text = GetStatic.ShowWithoutDecimal(sRow["serviceCharge"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
                    tAmt.Text = GetStatic.ShowWithoutDecimal(sRow["tAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
                    exRate.Text = sRow["exRate"].ToString() + "&nbsp" + sRow["payoutCurr"].ToString();
                    pAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + "&nbsp" + sRow["payoutCurr"].ToString();
                    depositType.Text = sRow["collMode"].ToString();
                    depositType1.Text = sRow["collMode"].ToString();
                    operator1.Text = sRow["createdBy"].ToString();

                    //for second from
                    //Load Sender Information
                    senderName1.Text = sRow["senderName"].ToString();
                    sMemId1.Text = sRow["sMemId"].ToString();
                    sAddress1.Text = sRow["sAddress"].ToString();
                    sNativeCountry1.Text = sRow["sNativeCountry"].ToString();
                    purpose1.Text = sRow["purpose"].ToString();
                    sDob1.Text = sRow["sDob"].ToString();
                    sContactNo1.Text = sRow["sContactNo"].ToString();
                    visaStatus1.Text = sRow["visaStatus"].ToString();

                    //Load Receiver Information
                    receiverName1.Text = sRow["receiverName"].ToString();
                    pAgentCountry1.Text = sRow["pAgentCountry"].ToString();
                    paymentMode1.Text = sRow["paymentMode"].ToString();
                    rContactNo1.Text = sRow["rContactNo"].ToString();
                    pAgent1.Text = sRow["pAgent"].ToString();
                    rAddress1.Text = sRow["rAddress"].ToString();
                    pBankName1.Text = sRow["pBankName"].ToString();
                    relationship1.Text = sRow["relwithSender"].ToString();

                    pBranchName1.Text = sRow["BranchName"].ToString();
                    accountNo1.Text = sRow["accountNo"].ToString();
                    rAmtWords1.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
                    controlNo1.Text = sRow["controlNo"].ToString();
                    createdBy1.Text = sRow["createdBy"].ToString();
                    approvedDate1.Text = DateTime.Parse(sRow["createdDate"].ToString()).ToString("yyyy-MM-dd hh:mm:ss tt");

                    cAmt1.Text = GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
                    serviceCharge1.Text = GetStatic.ShowWithoutDecimal(sRow["serviceCharge"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();

                    tAmt1.Text = GetStatic.ShowWithoutDecimal(sRow["tAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
                    exRate1.Text = sRow["exRate"].ToString() + "&nbsp" + sRow["payoutCurr"].ToString();
                    pAmt1.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + "&nbsp" + sRow["payoutCurr"].ToString();
                    operator2.Text = sRow["createdBy"].ToString();

                    if (sRow["paymentMethod"].ToString().ToUpper().Equals("CASH PAYMENT"))
                    {
                        bank3.Attributes.Add("style", "display: none;");
                        bank4.Attributes.Add("style", "display: none;");
                        bank5.Attributes.Add("style", "display: none;");
                        bank6.Attributes.Add("style", "display: none;");
                        bank7.Attributes.Add("style", "display: none;");
                        bank8.Attributes.Add("style", "display: none;");
                        bank9.Attributes.Add("style", "display: none;");
                        bank10.Attributes.Add("style", "display: none;");
                        bankLable.InnerHtml = "Cash Location";
                        bankLable1.InnerHtml = "Cash Location";
                    }
                }
            }
        }

        protected string GetSMSText(DataRow sRow)
        {
            FullName _fullNameS = GetStatic.ParseName(sRow["senderName"].ToString());
            FullName _fullNameR = GetStatic.ParseName(sRow["receiverName"].ToString());

            string sms = "";
            if (sRow["paymentMethod"].ToString().ToLower() == "bank deposit")
            {
                FullName _bankName = GetStatic.ParseName(sRow["pBankName"].ToString());

                sms += "Dear Mr/Ms " + _fullNameS.FirstName + ", your money sent to account of Mr/Ms " + _fullNameR.FirstName + " in ";
                sms += _bankName.FirstName + "... Bank. Amt sent: "+ GetStatic.ReadWebConfig("currencyJP", "") + " " + GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString());
                sms += ", Deposit Amt " + sRow["payoutCurr"].ToString() + " " + GetStatic.ShowWithoutDecimal(sRow["pAmt"].ToString()) + ". Thank you-"+GetStatic.ReadWebConfig("jmeName", "") +".";
            }
            else
            {
                sms += "Dear Mr/Ms " + _fullNameS.FirstName + ", your money sent to Mr/Ms " + _fullNameR.FirstName + ". Amt sent: "+ GetStatic.ReadWebConfig("currencyJP", "") + " ";
                sms += GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + ", Payout Amt " + sRow["payoutCurr"].ToString() + " " + GetStatic.ShowWithoutDecimal(sRow["pAmt"].ToString()) + ". PIN NO: " + sRow["controlNo"].ToString() + ". Thank you-"+GetStatic.ReadWebConfig("jmeName", "") +".";
            }

            return sms;
        }

        public void SendSMS()
        {
            string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":sendSms";
            SendSMSApiService _sendAPI = new SendSMSApiService();
            //GetSMSTextForTxn
            SMSRequestModel _req = new SMSRequestModel
            {
                ProviderId = "onewaysms",
                MobileNumber = Request.Form["mobileNumber"].Trim().Replace("+", ""),
                SMSBody = Request.Form["smsToSend"],
                ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40),
                RequestedBy = GetStatic.GetUser(),
                UserName = GetStatic.GetUser(),
                method = "send"
            };

            JsonResponse _resp = _sendAPI.SMSTPApi(_req);

            string isSuccess = (_resp.ResponseCode == "0") ? "1" : "0";

            obj.LogSMS(GetControlNo(), GetStatic.GetUser(), Request.Form["smsToSend"], Request.Form["mobileNumber"].Trim().Replace("+", ""),
                            ProcessId, _resp.Extra, isSuccess);

            GetStatic.JsonResponse(_resp, this);
        }
    }
}