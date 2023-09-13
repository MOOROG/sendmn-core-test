using Swift.DAL.AccountReport;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.Remittance.CashAndVault;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace Swift.web.AccountReport.TransitCashSettlement
{
    public partial class Manage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20180000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        AccountStatementDAO cavDao = new AccountStatementDAO();
        protected void Page_Load(object sender, EventArgs e)
        {
            var methodName = Request.Form["MethodName"];
            if (methodName == "TransitSettle")
                TransitSettle();

            Authenticate();
            if (!IsPostBack)
            {
                //Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        private void TransitSettle()
        {
            SendTranIRHDao st = new SendTranIRHDao();
            var introducerCode = Request.Form["IntroducerCode"];
            var paymentMode = Request.Form["PaymentMode"];
            var bankOrBranch = Request.Form["BankOrBranch"];
            var amount = Request.Form["Amount"];
            var transferDate = Request.Form["TranDate"];
            var narration = Request.Form["Narration"];

            var dr = cavDao.TransitCashManagement(GetStatic.GetUser(), amount, transferDate
                , paymentMode, bankOrBranch, introducerCode, narration);

            Response.ContentType = "text/plain";
            GetStatic.JsonResponse(dr, this);// DataTableToJson(dr);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        protected void Transfer_Click(object sender, EventArgs e)
        {
            var amountVal = amount.Text;
            var tDateVal = transferDate.Text;
            if (string.IsNullOrEmpty(amountVal) || amountVal == "0")
            {
                GetStatic.AlertMessage(this, "Invalid input in amount field!");
            }

            var _dbRes = cavDao.TransitCashManagement(GetStatic.GetUser(), amountVal, tDateVal
                , paymentModeDDL.SelectedValue, bankOrBranchDDL.SelectedValue, introducerTxt.Value, narrationTxt.Text);

            //DbResult _dbRes = cavDao.ParseDbResult(ds.Tables[0]);
            if (_dbRes.ErrorCode == "0")
            {
                amount.Text = "";
                paymentModeDDL.SelectedValue = "";
                bankOrBranchDDL.Items.Clear();
                introducerTxt.Text = "";
                introducerTxt.Value = "";
                narrationTxt.Text = "";

                msgSuccessError.Text = _dbRes.Msg;
                //GetStatic.SetMessage(_dbRes);
                //Response.Redirect("Manage.aspx");
            }
            else
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
        }
        protected void paymentModeDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            string paymentMode = paymentModeDDL.SelectedValue;
            if (!string.IsNullOrEmpty(paymentMode))
            {
                string sql = "EXEC PROC_VAULTTRANSFER @flag = 'VAULT-TRANSIT', @user = " + _sl.FilterString(GetStatic.GetUser()) + ", @param1 = " + _sl.FilterString(paymentMode);
                _sl.SetDDL(ref bankOrBranchDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "Select Bank/Branch");
            }
            else
            {
                bankOrBranchDDL.Items.Clear();
            }
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
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }
    }
}