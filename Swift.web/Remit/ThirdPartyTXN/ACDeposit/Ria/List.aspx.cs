using Swift.API;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices.PayTransaction;
using Swift.DAL.BL.ThirdParty.GME;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.ThirdPartyTXN.ACDeposit.Ria
{
    public partial class List : Page
    {
        private const string ViewFunctionID = "20122900";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly PayTransactionApiService _ria = new PayTransactionApiService();
        private IGMEDao _gme = new GMEDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionID);
        }

        protected void downloadTxn_Click(object sender, EventArgs e)
        {
            var providerId = GetStatic.ReadWebConfig("riapartnerid");
            JsonResponse jsonResult = _ria.DownloadRiaTxn(new RiaTxnDownload() { UserName = GetStatic.GetUser(), ProviderId = providerId, ProcessId = providerId });
            GetStatic.AlertMessage(Page, jsonResult.Msg);
        }

        protected void btnRunPayProcess_Click(object sender, EventArgs e)
        {
            RunBankDepositPayConfirmProcess();
            GetStatic.AlertMessage(this, "Process started to update Bank deposit Transaction.");
        }

        private delegate void DoStuff(); //delegate for the action

        private void RunBankDepositPayConfirmProcess()
        {
            var myAction = new DoStuff(AsyncPayConfirmProcess);
            //invoke it asynchrnously, control passes to next statement
            myAction.BeginInvoke(null, null);
        }

        private void AsyncPayConfirmProcess()
        {
            var bw = new BackgroundWorker();

            // this allows our worker to report progress during work
            bw.WorkerReportsProgress = true;

            // what to do in the background thread
            bw.DoWork += new DoWorkEventHandler(
            delegate (object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                PayConfirm();
                //_smtpMailSetting.SendSmtpMail(_smtpMailSetting);
                //_mailToAgent.SendSmtpMail(_mailToAgent);
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
                GetStatic.PrintSuccessMessage(Page, "Txns marked as paid successfully");
            });

            bw.RunWorkerAsync();
        }

        private void PayConfirm()
        {
            DbResult _dbRes = SynchronizeTransaction(GetStatic.ReadWebConfig("riapartnerid"), "System");
            GetStatic.AlertMessage(Page, _dbRes.Msg);
            return;
        }

        private DbResult SynchronizeTransaction(string provider, string username)
        {
            DataTable dt = _gme.GetDataForPaidSyncToPartner(provider);
            if (dt == null || dt.Rows.Count <= 0)
            {
                return new DbResult() { Msg = "", ErrorCode = "1" };
            }
            string[] ContNoInArray = GetControlNoAsArray(dt);

            var _requestData = new
            {
                ProcessId = provider,
                UserName = username,
                ProviderId = provider,
                SessionId = provider,
                controlInArray = ContNoInArray
            };

            JsonResponse _syncStatusResponse = _ria.GetTxnStatus(_requestData);
            var dbResult = new DbResult() { ErrorCode = _syncStatusResponse.ResponseCode, Msg = _syncStatusResponse.Msg };
            return dbResult;
        }

        private string[] GetControlNoAsArray(DataTable _controlNoList)
        {
            List<string> controlNo = new List<string>();
            foreach (DataRow item in _controlNoList.Rows)
            {
                controlNo.Add(item["controlNo"].ToString());
            }
            return controlNo.ToArray();
        }
    }
}