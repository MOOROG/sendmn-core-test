using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.DayBook
{
    public partial class dayBookReportUser : System.Web.UI.Page
    {
        private string vName = null;
        private string fromDate = null;
        private string toDate = null;
        private string vType = null;
        private string userName = null;
        private SwiftLibrary _sl = new SwiftLibrary();
        private DayBookReportDAO st = new DayBookReportDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _sl.CheckSession();
                GenerateDayBookRepotUser();
            }
        }

        protected string FromDate()
        {
            return GetStatic.ReadQueryString("startDate", "");
        }

        protected string ToDate()
        {
            return GetStatic.ReadQueryString("endDate", "");
        }

        protected string VoucherType()
        {
            return GetStatic.ReadQueryString("vType", "");
        }

        protected string VoucherName()
        {
            return GetStatic.ReadQueryString("vName", "");
        }

        protected string UserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        private void GenerateDayBookRepotUser()
        {
            vName = VoucherName();
            fromDate = FromDate();
            toDate = ToDate();
            vType = VoucherType();
            userName = UserName();

            DataSet ds = st.GetDayBookReportUser(fromDate, toDate, vType, userName);
            if (ds == null || ds.Tables.Count == 0)
            {
                return;
            }
            int i = 0;
            if (ds.Tables != null)
            {
                var tbl = ds.Tables[i];

                var sb = new StringBuilder();
                double DRTotal = 0, cRTotal = 0;
                int sNo = 1;

                sb.AppendLine("<div class=\"row\"><div class=\"col-md-8\"><div class=\"table-responsive\"><table  class=\"table\" width='100%'> ");
                // sb.AppendLine("
                // <tr>
                // "); sb.AppendLine(" <td colspan="2"> "); sb.AppendLine(" <div align="center">
                // <strong> Daybook Report </strong></div> "); sb.AppendLine(" </td>"); sb.AppendLine("
                // </tr>
                // ");
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='2'> <strong> User Name: " + userName + " </strong>");

                sb.AppendLine("</td>");

                sb.AppendLine("</tr>");
                sb.AppendLine("<tr>");
                string vNumber = null;
                foreach (DataRow item in tbl.Rows) { vNumber = item["billno"].ToString(); }
                sb.AppendLine("<td nowrap='nowrap' ><strong>Voucher No : &nbsp;&nbsp;" + vNumber + "</strong></td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'><strong>Voucher Type : &nbsp;&nbsp;" + vName + "</strong></td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='2'>");
                sb.AppendLine(" <div class=\"table-responsive\"><table  class=\"table table-striped table-bordered\" width='100%'> ");
                sb.AppendLine("<tr>");
                sb.AppendLine("<th nowrap='nowrap' width='5%'><strong>SN</strong></th>");
                sb.AppendLine("<th nowrap='nowrap' width='15%' align='center'><strong>AC No</strong></th>");
                sb.AppendLine("<th nowrap='nowrap' width='60%' align='center'><strong>Name</strong></th>");
                sb.AppendLine("<th nowrap='nowrap' width='10%' align='center'><strong>Dr Amount</strong></th>");
                sb.AppendLine("<th nowrap='nowrap' width='5%' align='center'><strong>Cr Amount</strong></th>");
                sb.AppendLine("</tr>");

                foreach (DataRow item in tbl.Rows)
                {
                    sb.AppendLine("<tr>");
                    DRTotal += GetStatic.ParseDouble(item["DRTotal"].ToString());
                    cRTotal += GetStatic.ParseDouble(item["cRTotal"].ToString());
                    //var vNumber = item["billno"].ToString();
                    sb.AppendLine("<td nowrap='nowrap' align='center' >" + sNo + " </td>");
                    sb.AppendLine("<td nowrap='nowrap' >" + item["acc_num"] + " </td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + item["acct_name"] + " </td>");
                    sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(item["DRTotal"].ToString()) + " </td>");
                    sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(item["cRTotal"].ToString()) + " </td>");
                    sb.AppendLine("</tr>");

                    sNo++;
                }
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='3' nowrap='nowrap' align='right'><strong>" + "Total" + "</strong> </td>");
                sb.AppendLine("<td nowrap align='right' ><strong>" + GetStatic.ShowDecimal(DRTotal.ToString()) + "</strong> </td>");
                sb.AppendLine("<td nowrap align='right' ><strong>" + GetStatic.ShowDecimal(cRTotal.ToString()) + "</strong> </td>");
                sb.AppendLine("</tr>");
                sb.AppendLine("</table></div> ");

                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("</table></div></div></div>");
                reportDiv.InnerHtml = sb.ToString();
                i++;
            }

            //var sb = new StringBuilder();
            //double DRTotal = 0, cRTotal = 0;
            //int sNo = 1;

            //drTotal.Text = GetStatic.ShowDecimal(cRTotal.ToString());
            //crTotal.Text = GetStatic.ShowDecimal(DRTotal.ToString());
            //foreach (DataRow item in dt.Rows)
            //{
            //    sb.AppendLine("<table width='100%' border='1' cellpadding='3' cellspacing='0' style=\"margin-top:20px;\">");
            //    sb.AppendLine("<tr>");
            //    sb.AppendLine("<td nowrap='nowrap' colspan='2'><strong>Voucher No : &nbsp;&nbsp;" + item["billno"] + "</strong></td>");
            //    sb.AppendLine("<td nowrap='nowrap' colspan='3'><strong>Voucher Type : &nbsp;&nbsp;" + vName + "</strong></td>");
            //    sb.AppendLine("</tr>");
            //    sb.AppendLine("<tr>");
            //    sb.AppendLine("<td nowrap='nowrap' width='5%'><strong>SN</strong></td>");
            //    sb.AppendLine("<td nowrap='nowrap' width='15%' align='center'><strong>AC No</strong></td>");
            //    sb.AppendLine("<td nowrap='nowrap' width='60%' align='left'><strong>Name</strong></td>");
            //    sb.AppendLine("<td nowrap='nowrap' width='10%' align='right'><strong>Dr Amount</strong></td>");
            //    sb.AppendLine("<td nowrap='nowrap' width='5%' align='right'><strong>Cr Amount</strong></td>");
            //    sb.AppendLine("</tr>");
            //    sb.AppendLine("<tr>");
            //    DRTotal += GetStatic.ParseDouble(item["DRTotal"].ToString());
            //    cRTotal += GetStatic.ParseDouble(item["cRTotal"].ToString());

            // sb.AppendLine("<td nowrap='nowrap' align='center' >" + sNo + " </td>");
            // sb.AppendLine("<td nowrap='nowrap' >" + item["acc_num"] + " </td>");
            // sb.AppendLine("<td nowrap='nowrap'>" + item["acct_name"] + " </td>");
            // sb.AppendLine("<td nowrap align='right' >" +
            // GetStatic.ShowDecimal(item["DRTotal"].ToString()) + " </td>"); sb.AppendLine("<td
            // nowrap align='right' >" + GetStatic.ShowDecimal(item["cRTotal"].ToString()) + " </td>");

            //    sb.AppendLine("</tr>");
            //    sb.AppendLine("</table>");
            //    sNo++;
            //    reportDiv.InnerHtml = sb.ToString();
            //}

            //drTotal.Text = GetStatic.ShowDecimal(cRTotal.ToString());
            //crTotal.Text = GetStatic.ShowDecimal(DRTotal.ToString());
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}