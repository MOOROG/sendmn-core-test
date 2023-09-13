using System;
using System.ComponentModel;
using System.Data;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10101370";
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private SmtpMailSetting smtpMailSetting = new SmtpMailSetting();

        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateUserName();
            if (!IsPostBack)
            {
                Authenticate();
                //LoadTab();
            }
        }

        //private void LoadTab()
        //{
        //    pnlBreadCrumb.Visible = true;
        //}

        protected void btnReset_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
            btnReset.Visible = _sl.HasRight(ViewFunctionId);
        }

        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected void PopulateUserName()
        {
            userName.Text = GetUserName();
            userName.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = _obj.ResetPassword(GetUserName(), pwd.Text, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                SetupEmailSetting();
                SendMail();
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

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
                smtpMailSetting.SendSmtpMail(smtpMailSetting);
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
                var dbResult = new DbResult();
                dbResult.SetError("0", "Mail Sent Successfully", "");
                GetStatic.PrintMessage(Page, dbResult);
            });

            bw.RunWorkerAsync();
        }

        private void SetupEmailSetting()
        {
            //var obj = new TranViewDao();
            //var ds = obj.GetEmailFormat(GetStatic.GetUser(), "PwdReset", userName.Text, "", "");
            //if (ds == null)
            //    return;
            //if (ds.Tables.Count == 0)
            //    return;
            //if (ds.Tables.Count > 1)
            //{
            //    //Email Server Settings
            //    if (ds.Tables[0].Rows.Count > 0)
            //    {
            //        var dr1 = ds.Tables[0].Rows[0];
            //        smtpMailSetting.SmtpServer = dr1["smtpServer"].ToString();
            //        smtpMailSetting.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
            //        smtpMailSetting.SendEmailId = dr1["sendID"].ToString();
            //        smtpMailSetting.SendEmailPwd = dr1["sendPSW"].ToString();
            //    }
            //    if (ds.Tables[1].Rows.Count == 0)
            //        return;
            //    //Email Receiver
            //    if (ds.Tables[1].Rows.Count > 0)
            //    {
            //        var dt = ds.Tables[1];
            //        foreach (DataRow dr2 in dt.Rows)
            //        {
            //            if (!string.IsNullOrEmpty(smtpMailSetting.ToEmails))
            //                smtpMailSetting.ToEmails = smtpMailSetting.ToEmails + ",";
            //            smtpMailSetting.ToEmails = smtpMailSetting.ToEmails + dr2["email"].ToString();
            //        }
            //    }
            //    //Email Subject and Body
            //    if (ds.Tables[2].Rows.Count > 0)
            //    {
            //        var dr3 = ds.Tables[2].Rows[0];
            //        if (dr3 == null)
            //            return;
            //        smtpMailSetting.MsgSubject = dr3[0].ToString();
            //        smtpMailSetting.MsgBody = dr3[1].ToString();
            //    }
            //}
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }
    }
}