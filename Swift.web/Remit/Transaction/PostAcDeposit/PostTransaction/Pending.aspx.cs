using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.PayAcDepositV3.PostTransaction
{
    public partial class Pending : System.Web.UI.Page
    {
        private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private const string ViewFunctionId = "20122600";
        private string _fromDate = "";
        private string _toDate = "";
        private string _fromTime = "";
        private string _toTime = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
            GetStatic.PrintMessage(Page);
            GetStatic.ResizeFrame(Page);

        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _fromDate = GetStatic.ReadQueryString("fromDate", "");
            _toDate = GetStatic.ReadQueryString("toDate", "");
            _fromTime = GetStatic.ReadQueryString("fromTime", "");
            _toTime = GetStatic.ReadQueryString("toTime", "");
            var ds = _obj.GetPendingUnpaid(GetStatic.GetUser(), _fromDate, _toDate, _fromTime, _toTime);

            if (ds == null)
            {
                GetStatic.AlertMessage(Page, "Data not found!");
                return;
            }
            LoadIntlUnpaidList(ds.Tables[0]);
        }

        private void LoadIntlUnpaidList(DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='table table-responsive table-bordered table-striped'>");
            str.Append("<tr>");
            str.Append("<th><div align=\"left\">S.N.</div></th>");
            str.Append("<th><div align=\"left\">Bank Name</div></th>");
            str.Append("<th><div align=\"left\">Txn Count</div></th>");
            str.Append("<th><div align=\"left\">Amount</div></th>");
            str.Append("</tr>");
            int cnt = 0;
            double totAmt = 0.00;
            int totCount = 0;
            if (dt.Rows.Count == 0)
            {
                str.Append("<tr><td colspan='4'><b>No Record Found</td></tr></table>");
                rpt_grid.InnerHtml = str.ToString();
                return;
            }
            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;
                str.AppendLine(cnt % 2 == 1
                                            ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                            : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                str.Append("<td align=\"center\">" + cnt + "</td>");
                totCount = totCount + int.Parse(dr["txnCount"].ToString());
                totAmt = totAmt + double.Parse(dr["amt"].ToString());
                for (int i = 0; i < cols; i++)
                {
                    if (i == 1)
                    {
                        str.Append("<td align=\"left\"><a href=\"PendingIntl.aspx?fromDate=" + _fromDate + "&fromTime=" + _fromTime + "&toDate=" + _toDate + "&toTime=" + _toTime + "&pAgent=" + dr["pAgent"] + "&pAgentName=" + dr["pAgentName"] + "\">" + dr[i].ToString() + "</a></td>");
                    }
                    else if (i == 2)
                    {
                        str.Append("<td><div align=\"center\">" + dr[i].ToString() + "</div></td>");
                    }
                    else if (i == 3)
                    {
                        str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                    }
                }
                str.Append("</tr>");
            }
            str.Append("<tr>");
            str.Append("<td  colspan='2'><div align=\"right\"><b>Total</b> </div></td>");
            str.Append("<td><div align=\"center\"><b>" + totCount + "</b></div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(totAmt.ToString()) + "</b></div></td>");
            str.Append("</tr>");
            str.Append("</table>");
            rpt_grid.InnerHtml = str.ToString();
        }
    }
}