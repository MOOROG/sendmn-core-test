using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.PLAccount
{
    public partial class PLAccount : System.Web.UI.Page
    {
        private readonly SwiftLibrary _s1 = new SwiftLibrary();
        private readonly AccountStatementDAO st = new AccountStatementDAO();
        private string Date = "";
        private string Date2 = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            _s1.CheckSession();

            letterHead.Text = GetStatic.getCompanyHead();
            Date = FromDate();
            fromDate.Text = Date;

            Date2 = ToDate();
            toDate.Text = Date2;

            GenerateReport();
        }

        protected string ToDate()
        {
            return GetStatic.ReadQueryString("toDate", "");
        }

        protected string FromDate()
        {
            return GetStatic.ReadQueryString("fromDate", "");
        }
        private void GenerateReport()
        {
            double directIncomeMonthTotal = 0, directIncomeYearTotal = 0;
            double directExpMonthTotal = 0, directExpYearTotal = 0;

            double indirectIncomeMonthTotal = 0, indirectIncomeYearTotal = 0;
            double indirectExpMonthTotal = 0, indirectExpYearTotal = 0;

            var dt = st.GetPLReport(fromDate.Text, toDate.Text);

            var directIncomes = dt.Select("fILTER = '0013.02.01'");
            var directExpenses = dt.Select("fILTER = '0013.02.02'");
            var indirectIncomes = dt.Select("fILTER = '0013.02.03'");
            var indirectExpenses = dt.Select(" fILTER = '0013.02.04'");

            var sb = new StringBuilder("");
            //<div class=\"row\"><div class=\"form-control col-md-12 col-md-offset-0\"> 
            sb.AppendLine("<div class=\"table-responsive\" ><table width='100%' class='table table-striped table-bordered' > ");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th rowspan='2' nowrap='nowrap' width='5%'> Particulars </th>");
            sb.AppendLine("<th nowrap='nowrap' width='3%'> For the period </th>");
            sb.AppendLine("<th nowrap='nowrap' width='3%'> Year to Date </th>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>Amount </th>");
            sb.AppendLine("<th nowrap='nowrap'>Amount </th>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3'><strong>Direct Incomes </strong> </td>");
            sb.AppendLine("</tr>");

            GenerateRows(ref sb, directIncomes, out directIncomeMonthTotal, out directIncomeYearTotal);

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3'><strong>Direct Expenses </strong> </td>");
            sb.AppendLine("</tr>");

            GenerateRows(ref sb, directExpenses, out directExpMonthTotal, out directExpYearTotal);

            sb.AppendLine("<tr>");
            sb.AppendLine("<td align='center'><strong> Gross Profit </strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((directIncomeMonthTotal + directExpMonthTotal).ToString()) + "</strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((directIncomeYearTotal + directExpYearTotal).ToString()) + "</strong></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3'><strong>Indirect Incomes </strong> </td>");
            sb.AppendLine("</tr>");

            GenerateRows(ref sb, indirectIncomes, out indirectIncomeMonthTotal, out indirectIncomeYearTotal);

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3'><strong>Indirect Expenses </strong> </td>");
            sb.AppendLine("</tr>");

            GenerateRows(ref sb, indirectExpenses, out indirectExpMonthTotal, out indirectExpYearTotal);

            sb.AppendLine("<tr>");
            sb.AppendLine("<td align='center'><strong> Net Profit </strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((directIncomeMonthTotal + directExpMonthTotal + indirectIncomeMonthTotal + indirectExpMonthTotal).ToString()) + "</strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((directIncomeYearTotal + directExpYearTotal + indirectIncomeYearTotal + indirectExpYearTotal).ToString()) + "</strong></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("</table></div>");


            plReport.InnerHtml = sb.ToString();

        }
        private void GenerateRows(ref StringBuilder sb, DataRow[] rowsArray, out double monthTotal, out double yearTotal)
        {
            monthTotal = yearTotal = 0;
            foreach (DataRow item in rowsArray)
            {
                if (rowsArray == null || rowsArray.Length == 0)
                {
                    break;
                }
                monthTotal = monthTotal + Convert.ToDouble(item["THISMONTH"].ToString());
                yearTotal = yearTotal + Convert.ToDouble(item["YEARTODATE"].ToString());


                sb.AppendLine("<tr>");
                sb.AppendLine("<td>");
                sb.AppendLine(item["GL_DESC"].ToString());
                sb.AppendLine("</td>");

                var THISMONTH = Convert.ToDouble(item["THISMONTH"].ToString());
                var YEARTODATE = Convert.ToDouble(item["YEARTODATE"].ToString());

                sb.AppendLine("<td align='right'> <a href='../BalanceSheet/SubLedger.aspx?company_id=&dt=" + Date2.ToString() + "&dt1=" + Date.ToString() + "&mapcode=" + item["gl_code"].ToString() + "&treeSape=" + item["tree_sape"].ToString() + "&head=" + item["GL_DESC"].ToString() + "' title='Account Statement'>");
                sb.AppendLine(GetStatic.GetNegativeFigureOnBrac(THISMONTH.ToString()));
                // sb.AppendLine(GetStatic.GetNegativeFigureOnBrac((THISMONTH < 0 ? THISMONTH * -1 : THISMONTH).ToString()));
                sb.AppendLine("</a></td>");

                //<a href="bl2_sub.asp?company_id=1&dt=<%=request("pl_date2")%>
                //&mapcode=<%=RST("gl_code")%>&head=<%=RST("GL_DESC")%>&tree_sape=<%=RST("tree_sape")%>" title="Account Statement" >

                sb.AppendLine("<td align='right'><a href='../BalanceSheet/SubLedger.aspx?company_id=&dt=" + Date2.ToString() + "&mapcode=" + item["gl_code"].ToString() + "&head=" + item["GL_DESC"].ToString() + "&treeSape=" + item["tree_sape"] + "' title='Account Statement'>");
                sb.AppendLine(GetStatic.GetNegativeFigureOnBrac(YEARTODATE.ToString()));
                //  sb.AppendLine(GetStatic.GetNegativeFigureOnBrac((YEARTODATE < 0 ? YEARTODATE * -1 : YEARTODATE).ToString()));
                sb.AppendLine("</a></td>");

                sb.AppendLine("</tr>");

            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td align='right'><strong> Total </strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac(monthTotal.ToString()) + "</strong></td>");
            // sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((monthTotal < 0 ? monthTotal * -1 : monthTotal).ToString()) + "</strong></td>");
            sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac(yearTotal.ToString()) + "</strong></td>");
            // sb.AppendLine("<td align='right'><strong>" + GetStatic.GetNegativeFigureOnBrac((yearTotal < 0 ? yearTotal * -1 : yearTotal).ToString()) + "</strong></td>");
            sb.AppendLine("</tr>");

        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}