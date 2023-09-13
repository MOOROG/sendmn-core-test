using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Threading.Tasks;

namespace Swift.web.AgentNew.Transaction.ApproveTxn
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40101800";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ApproveTransactionDao atd = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadTransaction();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadTransaction()
        {
            string tranNo = GetTranNo();
            ucTran.SearchData(tranNo, "", "", "", "APPROVE", "ADMIN: VIEW TXN TO APPROVE");
            divTranDetails.Visible = ucTran.TranFound;
            if (!ucTran.TranFound)
            {
                divControlno.InnerHtml = "<h2>No Transaction Found</h2>";
                return;
            }
        }

        protected string GetTranNo()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private void Approve()
        {
            string newSession = Guid.NewGuid().ToString().Replace("-", "");
            var result = atd.GetHoldedTxnForApprovedByAdmin(GetStatic.GetUser(), GetTranNo(), newSession);
            if (!result.ResponseCode.Equals("NotForTPAPI"))
            {
                GetStatic.AlertMessage(Page, result.Msg);
                GetStatic.CallJSFunction(Page, "window.returnValue = true; window.close();");
                LoadTransaction();
            }
            //var dr = atd.ApproveHoldedTXN(GetStatic.GetUser(), GetTranNo());
            //SendApprovalMailToCustomers();
            //GetStatic.AlertMessage(Page, dr.Msg);
            //if (dr.ErrorCode.Equals("0"))
            //{
            //    GetStatic.CallJSFunction(Page, "window.returnValue = true; window.close();");
            //    LoadTransaction();
            //}
        }

        private void SendApprovalMailToCustomers()
        {
            Task.Factory.StartNew(() => { SendEmail(); });
        }

        private void SendEmail()
        {
            DataTable mailDetails = atd.GetMailDetails("system");

            if (mailDetails.Rows.Count == 0 || mailDetails == null)
            {
                return;
            }
            foreach (DataRow item in mailDetails.Rows)
            {
                string res = SendEmailNotification(item);

                if (res != "Mail Send")
                {
                    atd.ErrorEmail("system", item["rowId"].ToString());
                }
            }
        }

        private string SendEmailNotification(DataRow item)
        {
            string msgSubject = GetStatic.ReadWebConfig("jmeName", "")+" Control No.: " + item["controlNoDec"].ToString();
            string toEmailId = item["createdBy"].ToString();
            string msgBody = "Dear " + item["SenderName"];
            msgBody += "<br/><br/>This is to acknowledge that you have successfully completed your transaction through "+ GetStatic.ReadWebConfig("jmeName", "") + " Online Remit System.";
            msgBody += "<br/><br/>Kindly take a note of the following transaction details for your record.";

            msgBody += "<br/><br/>"+ GetStatic.ReadWebConfig("jmeName", "") + " Number: " + item["controlNoDec"].ToString();
            msgBody += "<br/>Amount sent: " + item["collCurr"].ToString() + " " + GetStatic.ShowDecimal(item["tAmt"].ToString());
            msgBody += "<br/>Payment method: " + item["paymentMethod"].ToString();
            msgBody += "<br/>Pay-out country: " + item["pcountry"].ToString();
            msgBody += "<br/>Account holding bank Name: " + item["payountBankOrAgent"].ToString();
            msgBody += "<br/>Account number: " + item["accNo"].ToString();
            msgBody += "<br/>Account holder’s name: " + item["receiverName"].ToString();
            msgBody += "<br/>Payout Amount: " + item["payoutCurr"].ToString() + " " + GetStatic.ShowDecimal(item["pAmt"].ToString());

            msgBody += "<br/><br/>You can keep track of your payment status by https://online.gmeremit.com/.";
            msgBody +=
               "<br><br>If you need further assistance kindly email us at support@jme.com.np or call us at 15886864 or 01029596864. or visit our website <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a>";
            msgBody +=
                "<br><br><br>We look forward to provide you excellent service.";
            msgBody +=
               "<br><br>Thank You.";
            msgBody +=
               "<br><br><br>Regards,";
            msgBody +=
               "<br>"+ GetStatic.ReadWebConfig("jmeName", "") + " Online Team";
            msgBody +=
               "<br>Seoul, Korea ";
            msgBody +=
               "<br>Phone number 15886864 ";

            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };

            return mail.SendSmtpMail(mail);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            Approve();
        }
    }
}