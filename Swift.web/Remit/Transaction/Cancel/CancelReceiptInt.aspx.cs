using System;
using System.ComponentModel;
using System.Data;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Cancel
{
    public partial class CancelReceiptInt : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CancelTransactionDao _obj = new CancelTransactionDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadReceipt();
        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo","");
        }

        private void LoadReceipt()
        {
            var dr = _obj.LoadReceiptInt(GetStatic.GetUser(), GetControlNo().ToString());
            if (dr == null)
                return;

           // hdnBranchEmail.Value ="";
           hdnBranchEmail.Value = _sl.GetBranchEmail(dr["sBranchId"].ToString(), dr["createdBy"].ToString());
            controlNo.Text = dr["controlNo"].ToString();
            postedBy.Text = dr["sBranch"].ToString();
            sender.Text = dr["sender"].ToString();
            receiver.Text = dr["receiver"].ToString();
            rContactNo.Text = dr["rContactNo"].ToString();
            collCurr.Text = dr["collCurr"].ToString();
            scCurr1.Text = dr["collCurr"].ToString();
            pCurr.Text = dr["pCurr"].ToString();
            cAmt.Text = GetStatic.FormatData(dr["cAmt"].ToString(), "M");
            serviceCharge.Text = GetStatic.FormatData(dr["serviceCharge"].ToString(), "M");
            pAmt.Text = GetStatic.FormatData(dr["pAmt"].ToString(), "M");
            cancelCharge.Text = GetStatic.FormatData(dr["cancelCharge"].ToString(), "M");
            returnAmt.Text = GetStatic.FormatData(dr["returnAmt"].ToString(), "M");
            sendDate.Text = dr["sendDate"].ToString();
            cancelDate.Text = dr["cancelAppDate"].ToString();
            cancelReqBy.Text = dr["cancelReqBy"].ToString();
            cancelReqDate.Text = dr["cancelReqDate"].ToString();
            cancelReason.Text = dr["cancelReason"].ToString();

            ComposeAndSendMail();
        }

        #region Mail Send
        private void ComposeAndSendMail()
        {
            ComposeMail();
           // SendMail();
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

                if(!string.IsNullOrEmpty(hdnBranchEmail.Value))
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
            var ds = obj.GetDataForEmail(GetStatic.GetUser(), "Cancel", controlNo.Text, cancelReason.Text);

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
                        _mailToAgent.ToEmails = hdnBranchEmail.Value;
                    }
                }
            }
        }

        #endregion

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("ApproveReqUnapprovedTxn.aspx");
        }
    }
}