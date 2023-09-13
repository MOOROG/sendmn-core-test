using Swift.DAL.BL.ThirdParty.GME;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.ComponentModel;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ThirdPartyTXN.ACDeposit.GME
{
    public partial class List : System.Web.UI.Page
    {
        const string ViewFunctionID = "20122900";
        readonly RemittanceLibrary _sl = new RemittanceLibrary();
        IGMEDao _gme = new GMEDao();
        DataSet ds = new DataSet();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
               // Authenticate();
            }
            ds = _gme.ShowAcAllList(GetStatic.GetUser());
            LoadCeTxn(ds.Tables[0]);
            ShowLastDownloadInfo(ds.Tables[1]);
        }
        void ShowLastDownloadInfo(DataTable dt)
        {
            lastDownloaded.Text = "Never";
            if (dt == null) return;
            if (dt.Rows.Count == 0) return;

            lastDownloaded.Text = "&nbsp;" + dt.Rows[0][1].ToString() + " (" + dt.Rows[0][2].ToString() + " Records) " + " [ " + dt.Rows[0][0].ToString() + " ]";
        }

        protected void downloadTxn_Click(object sender, EventArgs e)
        {
            var dbResult = _gme.DownloadAcDepositTxn(GetStatic.GetUser());
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dr)
        {
            var url = "List.aspx";
            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dr.ErrorCode, dr.Msg.Replace("'", "") + "','" + url + "')"));

        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionID);
        }

        private void LoadCeTxn(DataTable dt)
        {

            var str = new StringBuilder();
            var totalAmt = 0.00;
            str.Append("<table class='table table-responsive table-bordered table-striped'>");
            if (dt.Rows.Count.Equals(0))
            {
                str.Append("<tr>");
                str.Append("<td><b>No Records Found.</b></td>");
                str.Append("</tr>");
                str.Append("</table>");
                rpt_grid.InnerHtml = str.ToString();
                return;
            }

            str.Append("<tr>");

            str.Append("<th>SN.</th>");
            for (var i = 0; i < dt.Columns.Count - 1; i++)
            {
                str.Append(string.Format("<th><div align=\"left\">{0}</div></th>", dt.Columns[i]));
            }
            str.Append("<th>&nbsp;</th></tr>");

            var rowCount = 0;
            var data = "";
            foreach (DataRow row in dt.Rows)
            {
                str.Append(
                            ++rowCount % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                                : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">"
                          );
                str.Append(string.Format("<td style=\"text-align:right;\">{0}</td>", rowCount.ToString()));
                for (var i = 0; i < dt.Columns.Count - 1; i++)
                {
                    data = row[i].ToString();
                    switch (i)
                    {
                        case 8:
                            str.Append(string.Format("<td style=\"text-align:right;\">{0}</td>", GetStatic.ShowDecimal(data)));
                            break;
                        case 10:
                            var color = data.Equals("UNASSIGNED") ? "red" : "green";
                            str.Append(string.Format("<td style=\"color:{0};\">{1}</td>", color, data));
                            break;
                        default:
                            str.Append(string.Format("<td align=\"left\">{0}</td>", data));
                            break;
                    }

                }
                totalAmt += double.Parse(row["Total Amount"].ToString());
                str.Append("<td nowrap='nowrap' valign='middle'><input type ='button' value='Delete' style='margin-right:5px;' onclick='DeleteTran(" + row["rowId"] + ");' /><a href=\"javascript:void(0)\" onclick=ViewDetail(" + row["rowId"] + ")>" + Misc.GetIcon("vd") + "</a></td>");
            }
            str.Append("<tr><td colspan=\"9\" style=\"text-align:right\"><b>Total Amount<b></td><td style=\"text-align:right\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td></tr>");

            str.Append("</table>");
            rpt_grid.InnerHtml = str.ToString();

        }

        protected void showAll_CheckedChanged(object sender, EventArgs e)
        {
            FilterTxn("ALL");
        }
        void FilterTxn(string FilterType)
        {

            var dt = _gme.ShowFilterTxnList(FilterType);
            LoadCeTxn(dt);
        }
        protected void showUnpaid_CheckedChanged(object sender, EventArgs e)
        {
            FilterTxn("A");
        }

        protected void showUnassigned_CheckedChanged(object sender, EventArgs e)
        {
            FilterTxn("UA");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }
        void Delete()
        {
            var dr = _gme.Delete(GetStatic.GetUser(), hddRowId.Value);
            GetStatic.AlertMessage(Page, dr.Msg);

            ds = _gme.ShowAcAllList(GetStatic.GetUser());

            LoadCeTxn(ds.Tables[0]);
            ShowLastDownloadInfo(ds.Tables[1]);
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
            delegate(object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                PayConfirm();
                //_smtpMailSetting.SendSmtpMail(_smtpMailSetting);
                //_mailToAgent.SendSmtpMail(_mailToAgent);
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
                GetStatic.PrintSuccessMessage(Page, "Txns marked as paid successfully");
            });

            bw.RunWorkerAsync();
        }

        private void PayConfirm()
        {
            DbResult _dbRes = _gme.PayConfirmProcess("system");
            GetStatic.AlertMessage(Page, _dbRes.Msg);
            return;
        }
    }
}