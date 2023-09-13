using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.ReportPrintBankDeposit
{
    public partial class List : Page
    {
        private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private const string ViewFunctionId = "20163000";
        protected void Page_Load(object sender, EventArgs e)
        {
            string mode = GetStatic.ReadQueryString("mode", "").ToLower();
            string reportName = "report";
            lblDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            if (mode == "download")
            {
                string format = GetStatic.ReadQueryString("format", "xls");
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "inline; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
            }
            if (!IsPostBack)
            {
                Authenticate();
                string flag = GetStatic.ReadQueryString("flag", "");
                if (flag == "detail")
                    LoadDetail();
                else if (flag=="summary")
                    LoadSummary();
                else 
                    LoadGrid();
            }
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string bankId = GetStatic.ReadQueryString("bankId", "");
            string dateType = GetStatic.ReadQueryString("dateType", "");
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");
            string fromTime = GetStatic.ReadQueryString("fromTime1", "");
            string toTime = GetStatic.ReadQueryString("toTime1", "");
            string tranType = GetStatic.ReadQueryString("tranType", "");
            string chkSender = GetStatic.ReadQueryString("chkSender", "");
            string chkBankComm = GetStatic.ReadQueryString("chkBankComm", "");
            string chkGenerator = GetStatic.ReadQueryString("chkGenerator", "");
            string chkIMERef = GetStatic.ReadQueryString("chkIMERef", "");

            lblBankName.Text = GetStatic.ReadQueryString("bankName", "");

            var ds = _obj.ShowDataForPrintReport(GetStatic.GetUser(), bankId, dateType, fromDate, toDate, tranType, chkSender,chkBankComm, chkGenerator,chkIMERef,fromTime,toTime);

            if (ds == null)
            {
                PrintMessage("Data not found!");
                return;
            }
            double totAmt = 0.00;
            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='unpaidACdeposit' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    totAmt = totAmt + double.Parse(dr["PAYOUT AMOUNT"].ToString());
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        if(i==3)
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        else
                            str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                        
                    }
                    str.Append("</tr>");
                }
                str.Append("<tr>");
                str.Append("<td colspan='3'><b>Total </b></td>");
                str.Append("<td><div align='right'><b>"+GetStatic.ShowDecimal(totAmt.ToString())+"</b></div></td>");
                str.Append("</tr>");
                str.Append("</table>");
                rpt_grid.InnerHtml = str.ToString();
                lblAmtInWords.Text = GetStatic.NumberToWord(totAmt.ToString());
            }
        }

        private void LoadDetail()
        {
            
        }

        private void LoadSummary()
        {

        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }
    }
}