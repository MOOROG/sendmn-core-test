using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System.Text;
using Swift.DAL.Common;
using Swift.DAL.SwiftDAL;
using System.Web.Script.Serialization;

namespace Swift.web.Remit.Transaction.Cancel
{
    public partial class CancelReceipt : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CancelTransactionDao _obj = new CancelTransactionDao();
        private const string ViewFunctionId = "20121400";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadReceipt();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        private long GetTranId()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranId");
        }

        private void LoadReceipt()
        {
            var dr = _obj.LoadReceipt(GetStatic.GetUser(), GetTranId().ToString());
            if (dr == null)
                return;

            controlNo.Text = dr["controlNo"].ToString();
            postedBy.Text = dr["postedBy"].ToString();
            sender.Text = dr["sender"].ToString();
            receiver.Text = dr["receiver"].ToString();
            rContactNo.Text = dr["rContactNo"].ToString();
            collCurr.Text = dr["collCurr"].ToString();
            cAmt.Text = GetStatic.FormatData(dr["cAmt"].ToString(), "M");
            serviceCharge.Text = GetStatic.FormatData(dr["serviceCharge"].ToString(), "M");
            pAmt.Text = GetStatic.FormatData(dr["pAmt"].ToString(), "M");
            cancelCharge.Text = GetStatic.FormatData(dr["cancelCharge"].ToString(), "M");
            returnAmt.Text = GetStatic.FormatData(dr["returnAmt"].ToString(), "M");
            sendDate.Text = dr["createdDate"].ToString();
            cancelDate.Text = dr["cancelDate"].ToString();

            if (!string.IsNullOrWhiteSpace(dr["BankName"].ToString()))
            {
                autoDebitTR.Visible = true;
                accName.Text = dr["AccName"].ToString();
                accNo.Text = dr["AccNo"].ToString();
                bankName.Text = dr["BankName"].ToString();

                // REQUEST FOR KFCT AUTO REFUND TRANSACTION 
                KJAutoRefundModel postData = new KJAutoRefundModel()
                {
                    flag = "Autodebit_REQ",
                    customerId = dr["customerId"].ToString(),
                    customerSummary = "",
                    amount = GetStatic.RemoveComaFromMoney(dr["returnAmt"].ToString()),
                    action = "REQ",
                    actionBy = GetStatic.GetUser(),
                    bankCode = dr["bankCode"].ToString(),
                    bankAccountNo = dr["AccNo"].ToString()
                };
                // REFUNDING KFTC AUTO DEBIT TRANSACTION
                var Response = RefundAutodebitTxnAmount(postData);
                if (Response.ErrorCode == "1")
                {
                    SendEmail();
                }
            }
        }
        private DbResult RefundAutodebitTxnAmount(KJAutoRefundModel postData)
        {

            DbResult dbResult = new DbResult()
            {
                ErrorCode = "1",
                Msg = "Fail!"
            };

            /* 1. KFTC AUTO REFUND LOG 입금이체 데이타 추가
             * */
            dbResult = _obj.SendAutoRefund(postData);
            postData.rowId = dbResult.Id;

            if (dbResult.ErrorCode != "0")
            {
                return dbResult;
            }
            /*
             * 3. KJ API FOR AUTO REFUND 라이브러리 사용
             * */
            AccountTransferToBank req = new AccountTransferToBank()
            {
                obpId = "", // "001-90010001-000001-6000001", //GME OBPID
                accountNo = "",// "1107020345626", //GME 계좌코드
                accountPassword = "", // "1212", //GME 패스워드
                receiveInstitution = postData.bankCode,
                receiveAccountNo = postData.bankAccountNo,

                //receiveInstitution = data.Msg,
                //receiveAccountNo = data.Id,
                amount = Convert.ToString(postData.amount),
                bankBookSummary = String.Format("REFUND{0}", postData.bankAccountNo),
                transactionSummary = "GME Refund"
            };

            var baseUrl = GetStatic.ReadWebConfig("KJURL", "");
            var kjSecretKey = GetStatic.ReadWebConfig("KJsecretKey", "");
            var clientId = GetStatic.ReadWebConfig("client_id", "");

            string body = new JavaScriptSerializer().Serialize((req));

            // KJ BANK API CALLING FOR AMOUNT REFUND IN BANK
            var apiResponse = KJBankAPIConnection.AccountTransferKJBank(body, baseUrl, kjSecretKey, clientId);

            if (apiResponse.ErrorCode != "0")
            {
                postData.flag = "Autodebit_FAIL";
                postData.action = "FAIL";
            }
            else
            {
                postData.flag = "SUCCESS";
                postData.action = "SUCCESS";
            }

            dbResult = _obj.SendAutoRefund(postData);
            return apiResponse;
        }
        private void SendEmail()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("KFTC auto refund process has failed!.");
            sb.AppendLine("Kindly refund JPY " + returnAmt.Text + " to customer's account for cancelled auto debit transaction " + controlNo.Text);
            sb.AppendLine("</br>");
            sb.AppendLine("Account Name: <strong>" + accName.Text + "</strong>");
            sb.AppendLine("</br>");
            sb.AppendLine("Account Number: <strong>" + accNo.Text + "</strong>");
            sb.AppendLine("</br>");
            sb.AppendLine("Bank Name: <strong>" + bankName.Text + "</strong>");

            sb.AppendLine("Regards,");
            sb.AppendLine("JME Remittance<br>, Japan");

            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = sb.ToString(),
                MsgSubject = "AUTODEBIT CANCELLATION REFUND",
                ToEmails = "atit.pandey@gmeremit.com",
                CcEmails = "itsupport@gmeremit.com"
            };

            mail.SendSmtpMail(mail);
        }
    }
}