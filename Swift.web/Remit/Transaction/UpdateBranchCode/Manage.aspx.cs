using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.Remittance.Transaction;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.UpdateBranchCode
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20317000";
        private const string UpdateFunctionId = "20317010";
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly UpdateBranchDao _rd = new UpdateBranchDao();
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (!IsPostBack)
                {
                    PopulateDDL();
                }
                string reqMethod = Request.Form["MethodName"];
                if (string.IsNullOrEmpty(reqMethod))
                {
                    if (GetStatic.GetUser() == "")
                    {
                        Response.ContentType = "text/plain";
                        Response.Write("[{\"session_end\":\"1\"}]");
                        Response.End();
                        return;
                    }
                }
                switch (reqMethod)
                {
                    case "LoadBank":
                        LoadBank();
                        break;
                    case "LoadBankBranch":
                        LoadBankBranch();
                        break;
                    case "UpdateBranchCode":
                        UpdateBranchCode();
                        break;
                    case "InsertBranch":
                        InsertBranch();
                        break;

                }

            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateDDL()
        {
            _sdd.SetDDL(ref countryDDL, "EXEC [proc_dropDownLists] @flag='r-country-list'", "countryId", "countryName", "", "Select Country");
            _sdd.SetDDL(ref countryDDL1, "EXEC [proc_dropDownLists] @flag='r-country-list'", "countryId", "countryName", "", "Select Country");
            //_sdd.SetDDL(ref BranchDDl, "EXEC [proc_dropDownLists] @flag='branch-list'", "agentId", "agentName", "", "All");
        }

        private void LoadBank()
        {
            var countryId = Request.Form["countryId"];
            DataTable dt = null;

            dt = _rd.LoadBank(GetStatic.GetCountryId(), countryId, null, GetStatic.GetAgent(), "getBankByCountry", GetStatic.GetUser());
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }
        private void LoadBankBranch()
        {
            var bankId = Request.Form["bankId"];
            var countryId = Request.Form["countryId"];
            DataTable dt = null;

            dt = _rd.GetBranchByBankAndCountry(GetStatic.GetUser(), "getBranchByBankAndCountry", countryId, bankId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }
        private void UpdateBranchCode()
        {
            var countryId = Request.Form["countryId"];
            var bankId = Request.Form["bankId"];
            var branchId = Request.Form["branchId"];
            var branchCode = Request.Form["branchCode"];
            var editedBranchName = Request.Form["editedBranchName"];

            DataTable dt = null;

            dt = _rd.UpdateBranch(GetStatic.GetUser(), "updateBranchCode", countryId, bankId,branchId, branchCode, editedBranchName);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }
        private void InsertBranch()
        {
            var countryId = Request.Form["countryId"];
            var bankId = Request.Form["bankId"];
            var branchName = Request.Form["branchName"].ToUpper();
            var branchCode = Request.Form["branchCode"];

            DataTable dt = null;

            dt = _rd.InsertBranch(GetStatic.GetUser(), "insertBranch", countryId, bankId, branchName, branchCode);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
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

    }
}