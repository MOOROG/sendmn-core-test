using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.UnlockTransaction
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20121600";
        private const string UnlockFunctionId = "20121610";
        private readonly LockUnlock _obj = new LockUnlock();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            var ds = _obj.GetLockedTransaction(GetStatic.GetUser());
            var dt = ds.Tables[0];
            int cols = dt.Columns.Count;
            int rows = dt.Rows.Count;

            var str = new StringBuilder("<b>Result : [[totalRec]] records  </b>");
            str.Append("<table class='table table-striped table-bordered'>");
            str.Append("<tr>");
            str.Append("<th cssClass = \"hdtitle\">&nbsp;</th>");
            for (int i = 1; i < cols; i++)
            {
                str.Append("<th cssClass = \"hdtitle\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.Append("</tr>");
            var totalRec = 0;
            var cnt = 0;
            if (rows > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    str.AppendLine(++cnt % 2 == 1
                                            ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                            : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");

                    str.Append("<td align=\"center\">");
                    if (_sdd.HasRight(UnlockFunctionId))
                        str.Append("<img style=\"cursor:pointer;\" onclick = \"UnlockTxn('" + dr["Tran Id"] + "')\" border = '0' title = \"Unlock Transaction\" src=\"../../../Images/unlock.png\" />");
                    str.Append("</td>");
                    for (int i = 1; i < cols; i++)
                    {
                        if (i == 2)
                            str.Append("<td style=\"text-align:right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</td>");
                        else
                            str.Append("<td align=\"left\">" + dr[i] + "</td>");
                    }
                    str.Append("</tr>");
                    totalRec++;
                }
                str.Append("</table>");

            }
            else
                str.Append("<tr><td colspan = '9' style =\"color:red; font-weight:bold; text-align:center;\">Currently there are no lock transactions available.</td></tr></table>");

            rpt_grid.InnerHtml = str.ToString().Replace("[[totalRec]]", totalRec.ToString());
        }

        protected void btnUnlock_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                UnlockTxn();
            }
        }

        private void UnlockTxn()
        {
            DbResult dbResult = _obj.UnLockTransaction(GetStatic.GetUser(), hdnTranId.Value);
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
            }
        }

        #region Browser Refresh
        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion
    }
}