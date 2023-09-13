using System;
using System.ComponentModel;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ApproveModification
{
    public partial class Summary : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly ModifyTransactionDao _obj = new ModifyTransactionDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadSummary();
        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        private string GetEmailId()
        {
            return GetStatic.ReadQueryString("email", "");
        }
        private string GetpayStatus()
        {
            return GetStatic.ReadQueryString("payStatus", "");
        }

        private void LoadSummary()
        {
            hdnEmail.Value = GetEmailId();
            controlNo.Text = GetControlNo();
            controlNoLbl.Text = GetStatic.GetTranNoName();
            PopulateModification(controlNo.Text);
            ComposeAndSendMail();
        }

        private void PopulateModification(string cNo)
        {
            var dt = _obj.DisplayApprovedModification(GetStatic.GetUser(), cNo);

            if (dt == null)
                return;

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='table table-bordered' border='1' style=\"width:600px;border: 1px solid black;\" cellspacing='3' cellpadding='3'>");
            str.Append("<tr>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
                }
                str.Append("</tr>");
            }
            str.Append("</table>");
            DvModification.InnerHtml = str.ToString();

            // for post and paid alert message
            if (GetpayStatus().ToUpper() == "PAID" || GetpayStatus().ToUpper() == "POST")
            {
                postPaidAlertMsg.Visible = true;
                var sb = new StringBuilder("");
                sb.AppendLine("<h2>Transaction is in " + GetpayStatus().ToUpper() + " Status</h2>");
                sb.AppendLine("<h3>Please Notify the agent of amendment</h3>");
                postPaidAlertMsg.InnerHtml = sb.ToString(); 
            }
            
        }

        #region Mail Send
        private void ComposeAndSendMail()
        {
            ComposeMail();
            SendMail();
        }

        readonly SmtpMailSetting _smtpMailSetting = new SmtpMailSetting();

        readonly SmtpMailSetting _mailToAgent = new SmtpMailSetting();

        private delegate void DoStuff(); //delegate for the action

        private void SendMail()
        {
            var myAction = new DoStuff(AsyncMailProcessing);
            //invoke it asynchrnously, control passes to next statement
            myAction.BeginInvoke(null, null);
        }

        private void AsyncMailProcessing()
        {
            var bw = new BackgroundWorker();

            // this allows our worker to report progress during work
            bw.WorkerReportsProgress = true;

            // what to do in the background thread
            bw.DoWork += new DoWorkEventHandler(
            delegate(object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                _smtpMailSetting.SendSmtpMail(_smtpMailSetting);

                if (!string.IsNullOrEmpty(hdnEmail.Value))
                    _mailToAgent.SendSmtpMail(_mailToAgent);
            });

            // what to do when progress changed (update the progress bar for example)
            bw.ProgressChanged += new ProgressChangedEventHandler(
            delegate(object o, ProgressChangedEventArgs args)
            {
                //label1.Text = string.Format("{0}% Completed", args.ProgressPercentage);
            });

            // what to do when worker completes its task (notify the user)
            bw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(
            delegate(object o, RunWorkerCompletedEventArgs args)
            {
                GetStatic.PrintSuccessMessage(Page, "Mail sent successfully");
            });

            bw.RunWorkerAsync();
        }

        //Compose Email From Email Template for Admin
        private void ComposeMail()
        {
            var obj = new SystemEmailSetupDao();
            var ds = obj.GetDataForEmail(GetStatic.GetUser(), "Modification Approve", GetControlNo(), DvModification.InnerHtml);
            if (ds == null)
                return;
            if (ds.Tables.Count == 0)
                return;
            if (ds.Tables.Count > 1)
            {
                //Email Server Settings
                if (ds.Tables[0].Rows.Count > 0)
                {
                    var dr1 = ds.Tables[0].Rows[0];
                    _smtpMailSetting.SmtpServer = dr1["smtpServer"].ToString();
                    _smtpMailSetting.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
                    _smtpMailSetting.SendEmailId = dr1["sendID"].ToString();
                    _smtpMailSetting.SendEmailPwd = dr1["sendPSW"].ToString();
                    _smtpMailSetting.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());

                    _mailToAgent.SmtpServer = dr1["smtpServer"].ToString();
                    _mailToAgent.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
                    _mailToAgent.SendEmailId = dr1["sendID"].ToString();
                    _mailToAgent.SendEmailPwd = dr1["sendPSW"].ToString();
                    _mailToAgent.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());
                }
                if (ds.Tables[1].Rows.Count == 0)
                    return;

                //Email Receiver
                if (ds.Tables[1].Rows.Count > 0)
                {
                    var dt = ds.Tables[1];
                    foreach (DataRow dr2 in dt.Rows)
                    {
                        if (!string.IsNullOrEmpty(_smtpMailSetting.ToEmails))
                            _smtpMailSetting.ToEmails = _smtpMailSetting.ToEmails + ",";
                        _smtpMailSetting.ToEmails = _smtpMailSetting.ToEmails + dr2["email"].ToString();
                    }
                }

                var mailTo = hdnEmail.Value == ""
                                 ? "bijay@swifttech.com.np"
                                 : hdnEmail.Value;

                _mailToAgent.ToEmails = mailTo;

                //Email Subject and Body
                if (ds.Tables[2].Rows.Count > 0)
                {
                    var dr3 = ds.Tables[2].Rows[0];
                    if (dr3 == null)
                        return;
                    _smtpMailSetting.MsgSubject = dr3[0].ToString();
                    _smtpMailSetting.MsgBody = dr3[1].ToString();

                    _mailToAgent.MsgSubject = _smtpMailSetting.MsgSubject;
                    _mailToAgent.MsgBody = _smtpMailSetting.MsgBody;
                }
            }
        }

        #endregion

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }
    }
}