using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.BillVoucher.VoucherReport
{
    public partial class VoucherReportDetails : System.Web.UI.Page
    {
        private string vType = null;
        private string vNum = null;
        private string typeDDL = null;
        private string id = null;
        private SwiftLibrary _sl = new SwiftLibrary();
        private VoucherReportDAO st = new VoucherReportDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                GenerateVoucherReport();
            }
        }

        private void GetPDFMethod(string a)
        {
            string b = a;
        }

        protected string VoucherText()
        {
            return GetStatic.ReadQueryString("vText", "");
        }

        protected string VoucherNumber()
        {
            return GetStatic.ReadQueryString("vNum", "");
        }

        protected string TypeDDL()
        {
            return GetStatic.ReadQueryString("typeDDL", "");
        }

        private string GenerateVoucherReport()
        {
            vType = VoucherText();
            vNum = VoucherNumber();
            typeDDL = TypeDDL();
            string searchType = GetStatic.ReadQueryString("searchType", "");
            letterHead.Text = GetStatic.getCompanyHead();

            var dt = st.GetVoucherReport(vNum, typeDDL, searchType);
            if (dt == null || dt.Rows.Count == 0)
            {
                return null;
            }

            var sb = new StringBuilder();
            double DRTotal = 0, cRTotal = 0;
            int sNo = 1;
            //sb.AppendLine("<table width='60%' border='0' align='center' cellpadding='0' cellspacing='0'>");
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr class=\"border\">");
                DRTotal += GetStatic.ParseDouble(item["DRTotal"].ToString());
                cRTotal += GetStatic.ParseDouble(item["cRTotal"].ToString());

                sb.AppendLine("<td nowrap='nowrap' align='center' >" + sNo + " </td>");
                sb.AppendLine("<td nowrap='nowrap' >" + item["acc_num"] + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='left' &nbsp;>" + item["acct_name"] + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right' >" + GetStatic.ShowDecimal(item["DRTotal"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right' style=\"border-right: 0px none;\" >" + GetStatic.ShowDecimal(item["cRTotal"].ToString()) + " </td>");

                sb.AppendLine("</tr>");
                tansDate.Text = item["TRNDate"].ToString();
                transNumber.Text = item["TRNno"].ToString();
                userName.Text = item["entry_user_id"].ToString();
                transactionParticular.Text = item["tran_particular"].ToString();
                sNo++;
            }
            voucherData.InnerHtml = sb.ToString();
            if (vType.ToLower() == "all")
            {
                voucherType.Text = GetStatic.GetVoucherName(typeDDL);
            }
            else
            {
                voucherType.Text = vType;
            }
            totalCRAmount.Text = GetStatic.ShowDecimal(cRTotal.ToString());
            totalDRAmount.Text = GetStatic.ShowDecimal(DRTotal.ToString());
            return sb.ToString();
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}