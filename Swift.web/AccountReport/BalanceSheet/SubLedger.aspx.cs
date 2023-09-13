using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.BalanceSheet
{
    public partial class SubLedger : System.Web.UI.Page
    {
        private readonly SwiftLibrary _s1 = new SwiftLibrary();
        private readonly AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _s1.CheckSession();
            GenerateReport();
        }

        protected string GetMapCode()
        {
            return GetStatic.ReadQueryString("mapcode", "");
        }

        protected string GetHead()
        {
            return GetStatic.ReadQueryString("head", "");
        }

        protected string GetTreeSape()
        {
            return GetStatic.ReadQueryString("treeSape", "");
        }

        protected string GetDate()
        {
            return GetStatic.ReadQueryString("dt", "");
        }


        protected string GetDate2()
        {
            return GetStatic.ReadQueryString("st", "");
        }

        protected string GetDate1()
        {
            return GetStatic.ReadQueryString("dt1", "");
        }

        protected string GetSentFromFlag()
        {
            return GetStatic.ReadQueryString("sentfrom", "");
        }

        private void GenerateReport()
        {
            string mapcode = GetMapCode();
            string head = GetHead();
            string treeSape = GetTreeSape();
            string rdate = GetDate();
            string sdate = GetDate2();
            string date = (GetSentFromFlag() == "pl_account_dt") ? GetDate1() : "";
            var secondCall = "";
            var secondCallDate = "";
            if (GetSentFromFlag() == "pl_account")
            {
                secondCall = "&sentfrom=pl_account";
                secondCallDate = date;
            }

            var sb = new StringBuilder("");
            var sb2 = new StringBuilder("");
            var dt = st.GetSubLedgerReport(mapcode, treeSape, rdate, date);

            int sno = 0;
            double total = 0, DR = 0, CR = 0;
            if (dt.Rows.Count > 0 && dt != null)
            {
                foreach (DataRow item in dt.Rows)
                {
                    sno++;

                    total = total + Convert.ToDouble(item["Total"].ToString());
                    DR = DR + Convert.ToDouble(item["DR"].ToString());
                    CR = CR + Convert.ToDouble(item["CR"].ToString());
                    var drcrMode = " (CR)";
                    if (Convert.ToDouble(item["DR"].ToString()) - Convert.ToDouble(item["CR"].ToString()) > 0)
                    {
                        drcrMode = " (DR)";
                    }
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td nowrap='nowrap'>" + sno.ToString() + "</td>");
                    sb.AppendLine("<td >" + item["acct_name"].ToString() + "</td>");
                    sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowAbsDecimal(item["DR"].ToString()) + "</td>");
                    sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowAbsDecimal(item["CR"].ToString()) + "</td>");
                    sb.AppendLine("<td nowrap='nowrap' align='right'> <a href='SubLedger.aspx?company_id=1&dt=" + rdate.ToString() + "&dt1=" + secondCallDate + secondCall + "&mapcode=" + item["acct_num"].ToString() + "&head =" + head.ToString() + "&treeSape=" + item["tree_sape"].ToString() + "' title='Account Statement' > " + GetStatic.ShowAbsDecimal(item["Total"].ToString()) + drcrMode + "</a> </td>");

                    sb.AppendLine("</tr>");
                }
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='2' nowrap='nowrap' align='right'><strong>TOTAL:</strong></td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(DR.ToString()) + "</strong></td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(CR.ToString()) + "</strong></td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(total.ToString()) + "</strong></td>");

                sb.AppendLine("</tr>");
                rptBody.InnerHtml = sb.ToString();
            }

            if (mapcode.Length == 4 || mapcode.Length.ToString() == "4")
            {
                mapcode = mapcode + "00";
            }

            sno = 0;
            total = DR = CR = 0;

            //if (string.IsNullOrEmpty(GetStatic.ReadQueryString("dt1", "")))
            //{
            //    //2/5/2016
            //    DateTime reportdate = Convert.ToDateTime(rdate);
            //    date = "1/" + reportdate.Month + "/" + reportdate.Year;
            //}
            var dt2 = st.GetSubLedgerReport2(mapcode, date, rdate);

            if (dt2.Rows.Count > 0 && dt2 != null)
            {
                sb2.AppendLine("<div class=\"table-responsive\"><table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\"><tr>");
                sb2.AppendLine("<th nowrap='nowrap'><strong>SN</strong></th>");
                sb2.AppendLine("<th nowrap='nowrap' ><strong>AC Num </strong></th>");
                sb2.AppendLine("<th  ><strong>AC Name </strong></th>");
                sb2.AppendLine("<th nowrap='nowrap' align='right' ><strong>DR Closing &nbsp; </strong></th>");
                sb2.AppendLine("<th nowrap='nowrap' align='right' ><strong>CR Closing &nbsp;</strong></th>");
                sb2.AppendLine("<th nowrap='nowrap' align='right' ><strong>Balance &nbsp;</strong></th>");
                sb2.AppendLine("</tr>");

                foreach (DataRow item in dt2.Rows)
                {
                    sno++;
                    total = total + Convert.ToDouble(item["total"].ToString());
                    DR = DR + Convert.ToDouble(item["dr_closing"].ToString());
                    CR = CR + Convert.ToDouble(item["cr_closing"].ToString());

                    //         var startDate = $("#startDate").val();
                    //var endDate = $("#endDate").val();
                    //var acInfo = GetItem("acInfo")[0];
                    //var acInfotxt = GetItem("acInfo")[1];

                    //var url = "StatementDetails.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&acName=" + acInfotxt;
                    var drcrMode = " (CR)";
                    if (Convert.ToDouble(item["dr_closing"].ToString()) - Convert.ToDouble(item["cr_closing"].ToString()) > 0)
                    {
                        drcrMode = " (DR)";
                    }

                    sb2.AppendLine("<tr>");
                    sb2.AppendLine("<td nowrap='nowrap'>" + sno.ToString() + "</td>");
                    sb2.AppendLine("<td nowrap='nowrap'><a href='../AccountStatement/StatementDetails.aspx?startDate=" + sdate.ToString() + "&endDate=" + rdate.ToString() + "&acNum=" + item["acct_num"].ToString() + "&acName=" + item["acct_name"].ToString() + "' styel='text-decoration:none;'> <strong>" + item["acct_num"].ToString() + "</strong></a></td>");//link here in account number
                    sb2.AppendLine("<td > <strong>" + item["acct_name"].ToString() + "</strong></td>");
                    sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(item["dr_closing"].ToString()) + "</strong></td>");
                    sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(item["cr_closing"].ToString()) + "</strong></td>");
                    sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(item["total"].ToString()) + drcrMode + "</strong></td>");
                    sb2.AppendLine("</tr>");
                }
                sb2.AppendLine("<tr>");
                sb2.AppendLine("<td colspan='3' nowrap='nowrap' align='right'><strong>TOTAL:</strong></td>");
                sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(DR.ToString()) + "</strong></td>");
                sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(CR.ToString()) + "</strong></td>");
                sb2.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(total.ToString()) + "</strong></td>");

                
                sb2.AppendLine("</tr>");
                sb2.AppendLine("</table></div>");

                bottomRptBody.InnerHtml = sb2.ToString();
            }
        }
        
    }
}