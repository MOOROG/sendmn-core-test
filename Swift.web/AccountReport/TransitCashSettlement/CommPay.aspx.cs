using Swift.DAL.AccountReport;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.Library;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AccountReport.TransitCashSettlement
{
    public partial class CommPay : System.Web.UI.Page
    {
        private string ViewFunctionId = "20250000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private AccountStatementDAO cavDao = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            var methodName = Request.Form["MethodName"];
            if (methodName == "CommPayAgent")
                TransitSettle();
            if (methodName == "GetAvailableBal")
                GetAvailableBal();

            Authenticate();
            if (!IsPostBack)
            {
                //Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateDDL();
            }
        }

        private void GetAvailableBal()
        {
            var referralCode = Request.Form["ReferralCode"];

            var dr = cavDao.GetBalance(GetStatic.GetUser(), referralCode);
            dr.Msg = GetStatic.ShowDecimal(dr.Msg);

            Response.ContentType = "text/plain";
            GetStatic.JsonResponse(dr, this);// DataTableToJson(dr);
        }

        private void PopulateDDL()
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".DBO.PROC_AGENT_COMM_ENTRY @flag = 'ACC-LIST', @user = " + _sl.FilterString(GetStatic.GetUser());
            _sl.SetDDL(ref bankOrBranchDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "");
        }

        private void TransitSettle()
        {
            SendTranIRHDao st = new SendTranIRHDao();
            var introducerCode = Request.Form["IntroducerCode"];
            var bankOrBranch = Request.Form["BankOrBranch"];
            var amount = Request.Form["Amount"];
            var transferDate = Request.Form["TranDate"];
            var narration = Request.Form["Narration"];

            var dr = cavDao.PayAgentComm(GetStatic.GetUser(), amount, transferDate
                , bankOrBranch, introducerCode, narration);

            Response.ContentType = "text/plain";
            GetStatic.JsonResponse(dr, this);// DataTableToJson(dr);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<System.Collections.Generic.Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }
    }
}