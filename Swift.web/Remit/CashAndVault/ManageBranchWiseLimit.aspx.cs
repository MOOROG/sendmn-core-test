using Swift.DAL.Remittance.CashAndVault;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace Swift.web.Remit.CashAndVault
{
    public partial class ManageBranchWise : System.Web.UI.Page
    {
        protected const string GridName = "cashAndVault";
        private string ViewFunctionId = "20178000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            string reqMethod = Request.Form["MethodName"];
            if (String.IsNullOrEmpty(reqMethod))
            {
                Misc.MakeNumericTextbox(ref cashHoldLimit);
                Misc.MakeNumericTextbox(ref perTopUpLimit);
            }

            switch (reqMethod)
            {
                case "PopulateBranchAndAgents":
                    PopulateBranchAndAgents();
                    break;

                case "PopulateForm":
                    PopulateForm();
                    break;

                case "SaveCashAndVault":
                    Save_Click();
                    break;
            }

            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected string GetRuleId()
        {
            return GetStatic.ReadQueryString("cashHoldLimitId", "");
        }

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        private void PopulateBranchAndAgents()
        {
            string flag = Request.Form["Flag"];
            var dt = cavDao.PopulateDdl(GetStatic.GetUser(), flag);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

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

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateForm()
        {
            string eId = Request.Form["RuleId"];
            string agentId = Request.Form["AgentId"];
            var dr = cavDao.GetCashAndVaultDetails(eId, GetStatic.GetUser(), agentId);

            Response.ContentType = "text/plain";
            string json = DataTableToJson(dr);
            Response.Write(json);
            Response.End();
        }

        protected void Save_Click()
        {
            var agentId = Request.Form["ddlAgentBranch"];
            var cashLimit = Request.Form["cashHoldLimit"];
            var perTopUpLimitVal = Request.Form["perTopUpLimit"];
            var ruleType = Request.Form["ddlruleType"];
            var ruleId = Request.Form["ruleId"];
            var res = cavDao.SaveCashAndVault(GetStatic.GetUser(), agentId, cashLimit, perTopUpLimitVal, ruleType, ruleId);
            if (res == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(res);
            Response.Write(json);
            Response.End();
        }
    }
}