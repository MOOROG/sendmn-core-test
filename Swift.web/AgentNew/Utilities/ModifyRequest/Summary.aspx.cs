using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System;
using System.ComponentModel;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Utilities.ModifyRequest
{
    public partial class Summary : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly ModifyTransactionDao _obj = new ModifyTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            PrintSummary();
        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        private string GetEmail()
        {
            return GetStatic.ReadQueryString("email", "");
        }

        private void PrintSummary()
        {
            string cNo = GetControlNo();
            if (string.IsNullOrEmpty(cNo))
                return;

            PopulateModification(cNo);
            hdnEmail.Value = GetEmail();
            controlNoLbl.Text = GetStatic.GetTranNoName();
            controlNo.Text = GetControlNo();

            hdnEmail.Value = hdnEmail.Value == ""
                                 ? "bijay@swifttech.com.np"
                                 : hdnEmail.Value;

            ComposeAndSendMail();
        }

        private void PopulateModification(string cNo)
        {
            var ds = _obj.DisplayModification(GetStatic.GetUser(), cNo);

            if (ds == null)
                return;
            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='table table-bordered' border='0' style=\"width:600px;border: 0px solid black;\" cellspacing='3' cellpadding='3'>");
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
            }
        }

        #region Mail Send

        private void ComposeAndSendMail()
        {
            ComposeMail();
            SendMail();
        }

        private readonly SmtpMailSetting _smtpMailSetting = new SmtpMailSetting();

        private readonly SmtpMailSetting _mailToAgent = new SmtpMailSetting();

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
            delegate (object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                _smtpMailSetting.SendSmtpMail(_smtpMailSetting);

                if (!string.IsNullOrEmpty(hdnEmail.Value))
                    _mailToAgent.SendSmtpMail(_mailToAgent);
            });

            // what to do when progress changed (update the progress bar for example)
            bw.ProgressChanged += new ProgressChangedEventHandler(
            delegate (object o, ProgressChangedEventArgs args)
            {
                //label1.Text = string.Format("{0}% Completed", args.ProgressPercentage);
            });

            // what to do when worker completes its task (notify the user)
            bw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(
            delegate (object o, RunWorkerCompletedEventArgs args)
            {
                GetStatic.PrintSuccessMessage(Page, "Mail sent successfully");
            });

            bw.RunWorkerAsync();
        }

        //Compose Email From Email Template for Admin
        private void ComposeMail()
        {
            var obj = new SystemEmailSetupDao();
            var ds = obj.GetDataForEmail(GetStatic.GetUser(), "Modification Request", GetControlNo(), DvModification.InnerHtml);
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

                var mailTo = hdnEmail.Value;

                _mailToAgent.ToEmails = mailTo;

                //Email Subject and Body
                if (ds.Tables[2].Rows.Count > 0)
                {
                    var dr3 = ds.Tables[2].Rows[0];
                    if (dr3 == null)
                        return;
                    _smtpMailSetting.MsgSubject = dr3[0].ToString();
                    _smtpMailSetting.MsgBody = dr3[1].ToString();
                }

                //Email Subject and Body to Agent
                if (ds.Tables.Count > 3)
                {
                    if (ds.Tables[3].Rows.Count > 0)
                    {
                        var dr4 = ds.Tables[3].Rows[0];
                        if (dr4 == null)
                            return;
                        _mailToAgent.MsgSubject = dr4[0].ToString();
                        _mailToAgent.MsgBody = dr4[1].ToString();
                    }
                }
            }
        }

        #endregion Mail Send
    }
}