using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Reports.DailyCashReport
{
    public partial class DailyCashReportTransactionWise : System.Web.UI.Page
    {
        private TranAgentReportDao _dao = new TranAgentReportDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionIdAgent = "40200000";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                mainDiv.Visible = false;
            }
            
            Authenticate();
    
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionIdAgent));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        private void GenerateReport()
        {
            var fDate1 = fromDate.Text.ToString();
            var tDate1 = toDate.Text.ToString();
            var introducer = introducerTxt.Value;
            fDate.InnerText = fDate1;
            tDate.InnerText = tDate1;
            var result = _dao.getDailyCashReportTransactionWise(GetStatic.GetUser(), fDate1, tDate1, introducer);
            GenerateTable(result);
        }

        private void GenerateTable(DataSet result)
        {
            var sb = new StringBuilder("");
            double grandTotal = 0;
            int count = 0;

            foreach (DataRow item in result.Tables[1].Rows)
            {
                DataRow[] rows = result.Tables[0].Select("PSUPERAGENTNAME = ('" + item["PSUPERAGENTNAME"].ToString() + "')");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='5' align='center'><b>" + item["SHOW_NAME"].ToString() + "</b></td>");
                sb.AppendLine("</tr>");
                GetRows(rows, ref count, ref grandTotal, ref sb);
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='4' align='right'><b>Grand Total</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.ShowDecimal(grandTotal.ToString()) + "</b></td>");
            sb.AppendLine("</tr>");

            cashRport.InnerHtml = sb.ToString();
        }

        private void GetRows(DataRow[] rows, ref int count, ref double grandTotal, ref StringBuilder sb)
        {
            if (rows.Length == 0 || rows == null)
            {
                sb.AppendLine("<tr><td colspan='4' align='center'>No data to Display!</td></tr>");
            }
            foreach (DataRow item in rows)
            {
                count++;

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + count.ToString() + "</td>");
                sb.AppendLine("<td>" + item["DATE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["PIN_NO"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["SENDER_NAME"].ToString() + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["COLLECT_AMOUNT"].ToString()) + "</td>");
                sb.AppendLine("</tr>");

                grandTotal += GetDoubleValue(item["COLLECT_AMOUNT"].ToString());
            }
        }

        public double GetDoubleValue(string inPutVal)
        {
            double outPut = 0;
            Double.TryParse(inPutVal, out outPut);
            return outPut;
        }

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            GenerateReport();
            mainDiv.Visible = true;

        }
    }
}