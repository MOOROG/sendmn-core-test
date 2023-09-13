using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.BalanceSheet
{
    public partial class BalanceSheet : System.Web.UI.Page
    {
        private readonly SwiftLibrary _s1 = new SwiftLibrary();
        private readonly AccountStatementDAO st = new AccountStatementDAO();
        private string rDate = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            _s1.CheckSession();

            letterHead.Text = GetStatic.getCompanyHead();
            rDate = GetReportDate();

            GenerateReport();
        }

        protected string GetReportDate()
        {
            return GetStatic.ReadQueryString("reportDate", "");
        }

        private void GenerateReport()
        {
            double totalShareHolder = 0;
            double totalLoanFunds = 0;

            double totalFixedAssets = 0;
            double totalInvestment = 0;
            double totalDTN = 0;
            double totalCLAP = 0;
            double totalCALA = 0;


            reportDate.Text = rDate;

            var dt = st.GetBalancesheetReport(rDate);
            var shFund = dt.Select("grp='Shareholders Funds'");
            var loanFund = dt.Select("grp='Loan Funds'");
            var fixedAssets = dt.Select("grp='Fixed Assets'");
            var investment = dt.Select("grp='Investment'");
            var currALA = dt.Select("grp='Current Assets, Loans and Advances'");
            var CurrLAP = dt.Select("grp='Current Liabilities and Provisions'");
            var deferredTaxNet = dt.Select("grp='Deferred Tax-Net'");

            var sb = new StringBuilder("");


            sb.AppendLine(" <div class=\"table-responsive\"> <table id=\"basic-datatables\" class=\"table  table-bordered\" width='100%' cellspacing='0' class='TBLReport'>");
            sb.AppendLine(" <tr class='bg-gray'>");
            sb.AppendLine("<th nowrap='nowrap'> ");
            sb.AppendLine("<strong>I. SOURCES OF FUNDS </strong> ");
            sb.AppendLine("</th>");
            sb.AppendLine("<th colspan='2 nowrap='nowrap'>");
            sb.AppendLine("<div align='right'>");
            sb.AppendLine("<strong>Amount (In Rs)</strong></div> ");
            sb.AppendLine("</th>");

            sb.AppendLine("</tr>");

            sb.AppendLine(" <tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>A. Shareholders' Funds </strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalShareHolder = GenerateRows(ref sb, shFund, 3);

            sb.AppendLine(" <tr>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>B. Loan Funds</strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalLoanFunds = GenerateRows(ref sb, loanFund, 2);

            double sourceOfFundTotal = totalShareHolder + totalLoanFunds;

            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='2' style='padding-left: 30px;'>");
            sb.AppendLine(" <strong>Total</strong> </td>");
            sb.AppendLine("<td align='right'>");
            sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((sourceOfFundTotal).ToString()) + "</strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");


            sb.AppendLine("<tr class='bg-gray'>");
            sb.AppendLine("<th nowrap='nowrap' class='TBLReport'>");
            sb.AppendLine("<strong>II. APPLICATION OF FUNDS </strong> ");
            sb.AppendLine("</th>");
            sb.AppendLine("<th colspan='2' nowrap='nowrap'> </th>");
            sb.AppendLine("</tr>");

            sb.AppendLine(" <tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>A. Fixed Assets </strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");


            totalFixedAssets = GenerateRows(ref sb, fixedAssets, 3, true);

            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>B. Investment</strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalInvestment = GenerateRows(ref sb, investment, 1, true);


            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>C. Current Assets, Loans and Advances</strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalCALA = GenerateRows(ref sb, currALA, 5, true);


            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>D. Current Liabilities and Provisions </strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalCLAP = GenerateRows(ref sb, CurrLAP, 2);

            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='3' nowrap='nowrap' style='padding-left: 30px;'>");
            sb.AppendLine("<strong>E. Deferred Tax-Net</strong>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            totalDTN = GenerateRows(ref sb, deferredTaxNet, 1);


            double appOfFundTotal = totalFixedAssets + totalInvestment + totalCALA + totalCLAP + totalDTN;

            sb.AppendLine("<tr class='bg-gray'>");
            sb.AppendLine("<td colspan='2' style='padding-left: 30px;'>");
            sb.AppendLine(" <strong>Total</strong> </td>");
            sb.AppendLine("<td align='right'>");
            sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((appOfFundTotal < 0 ? appOfFundTotal * -1 : appOfFundTotal).ToString()) + "</strong>");
            /*
            if (appOfFundTotal < 0)
            {
                appOfFundTotal = appOfFundTotal * (-1);
                sb.AppendLine("<strong>(" + GetStatic.GetNegativeFigureOnBrac(appOfFundTotal.ToString()) + ")</strong>");
                appOfFundTotal = appOfFundTotal * (-1);
            }
            else
            {
                sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac(appOfFundTotal.ToString()) + "</strong>");
            }
            */
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("</table></div>");

            balanceSheetTable.InnerHtml = sb.ToString();

        }

        private double GenerateRows(ref StringBuilder sb, DataRow[] rowsArray, int rowCount, bool removeNegative = false)
        {
            int sno = 0;
            double totalMain = 0;
            //double total2 = 0;
            foreach (DataRow item in rowsArray)
            {
                sno++;
                var thisTotal = Convert.ToDouble(item["Total"].ToString());
                totalMain = totalMain + thisTotal;

                sb.AppendLine("<tr>");
                sb.AppendLine("<td nowrap='nowrap' style='padding-left: 50px;'>");
                sb.AppendLine(sno.ToString() + ".&nbsp;" + item["head"].ToString());
                sb.AppendLine("</td>");

                sb.AppendLine("<td align='right'><a style='text-decoration:none;' href='GL.aspx?company_id=1&dt=" + rDate + "&mapcode=" + item["reportid"].ToString() + "&head=" + item["head"].ToString() + "'>");
                //total2 = Convert.ToDouble(item["Total"].ToString());
                if (removeNegative)
                    sb.AppendLine(GetStatic.GetNegativeFigureOnBrac((thisTotal * -1).ToString()));
                else
                    sb.AppendLine(GetStatic.GetNegativeFigureOnBrac((thisTotal).ToString()));

                /*
                if (total2 < 0)
                {
                    total2 = total2 * (-1);
                    sb.AppendLine(total2.ToString());
                }
                else
                {
                    sb.AppendLine(GetStatic.GetNegativeFigureOnBrac(item["Total"].ToString()));

                }
                */
                sb.AppendLine("</a></td>");

                sb.AppendLine("<td width='20%' align='right'>");
                if (sno == rowCount)
                {
                    if (removeNegative)
                        sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((totalMain * -1).ToString()) + "</strong>");
                    else
                        sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((totalMain).ToString()) + "</strong>");
                    //if (totalMain < 0)
                    //{
                    //    if (removeNegative)
                    //        sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((totalMain).ToString()) + "</strong>");
                    //    else
                    //        sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac((totalMain).ToString()) + "</strong>");
                    //}
                    //else
                    //{
                    //    sb.AppendLine("<strong>" + GetStatic.GetNegativeFigureOnBrac(totalMain.ToString()) + "</strong>");
                    //}

                }
                else
                {
                    sb.AppendLine("&nbsp;");
                }
                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");


            }
            return totalMain;

        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}