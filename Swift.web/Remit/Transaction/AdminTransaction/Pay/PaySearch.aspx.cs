using Swift.API.Common.PayTransaction;
using Swift.DAL.BL.Remit.Transaction.PayTransaction;
using Swift.DAL.BL.Remit.Transaction.ThirdParty;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.web.Remit.Transaction.PayTransaction
{
    public partial class PaySearch : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly PayDao _obj = new PayDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20121000";
        private const string ProcessFunctionId = "20121010";
        private string _partnerId = "";
        private string _userName = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                string reqMethod = Request.Form["MethodName"];
                if (string.IsNullOrWhiteSpace(reqMethod))
                {
                    loadDDL();
                }
                switch (reqMethod)
                {
                    case "search":
                        SearchTxnPriority();
                        break;

                    case "loadbranchuser":
                        LoadBranchUser();
                        break;
                }
                GetStatic.PrintMessage(this);
            }
            PopulatePayoutMessage();
        }

        private void loadDDL()
        {
            _sdd.SetDDL(ref partner, "EXEC [proc_dropDownLists2] @flag = 'provider'", "value", "text", "", "");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        public void LoadBranchUser()
        {
            var branchId = Request.Form["branchid"].Trim();

            var dt = _obj.LoadBranchUser(branchId);
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

        private void SearchTxnPriority()
        {
            _userName = Request.Form["branchuser"].Trim();
            var _dbRes = new DbResult();
            var branchId = Request.Form["branchId"];
            var controlNo = Request.Form["controlNo"].Trim();
            _partnerId = Request.Form["partener"];

            if (!string.IsNullOrEmpty(_partnerId))
            {
                _dbRes = SelectByPinNo(_partnerId, controlNo, branchId);
            }
            else
            {
                var dt = _obj.GetProviderByControlNo(_userName, controlNo);
                if (dt == null || dt.Rows.Count == 0)
                    _dbRes.SetError("1", "Invalid pin format.", null);
                else
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        _dbRes.SetError("1", "Error", null);
                        _partnerId = Convert.ToString(row["ID"]);

                        _dbRes = SelectByPinNo(_partnerId, controlNo, branchId);

                        if (string.IsNullOrEmpty(_dbRes.ErrorCode))
                        {
                            _dbRes.SetError("1", "Unknown Error (Null Error)!", "");
                        }

                        if (_dbRes.ErrorCode.Equals("0"))
                            break;
                    }
                }
            }

            _dbRes.Extra2 = _partnerId;
            _dbRes.Extra = branchId;
            _dbRes.TpErrorCode = _userName;

            ReturnJson(ref _dbRes);
        }

        private DbResult GetStatus(string partnerId, string controlNo)
        {
            return new TransactionUtilityDao().GetTxnStatus(_userName, partnerId, controlNo);
        }

        private DbResult SelectByPinNo(string partnerId, string controlNo, string branchId)
        {
            try
            {
                DbResult dbResult = new DbResult()
                {
                    ErrorCode = "1"
                ,
                    Msg = "No any matching provider found!!"
                };

                if (partnerId.Equals("IME-I"))
                {
                    dbResult = _obj.CheckPinValidationIntl(_userName, controlNo, branchId, partnerId);
                    if (dbResult.ErrorCode.Equals("1"))
                        _sl.ManageInvalidControlNoAttempt(Page, _userName, "N");
                    if (dbResult.ErrorCode == "1000")
                        _sdd.ManageInvalidControlNoAttempt(Page, _userName, "N");
                    return dbResult;
                }
                else if (GetPartnerIdArr(partnerId)[0].Equals(GetStatic.ReadWebConfig("gmepartnerid", "")))
                {
                    //IGMEDao _gme = new GMEDao();
                    //return _gme.SelectByPinNo(GetStatic.GetUser(), branchId, controlNo);
                    IPayTransactionThirdpartyDao _dao = new PayTransactionThirdpartyDao();
                    PayTxnCheck _detail = GetSearchDetails(controlNo, branchId, partnerId);
                    return _dao.SearchTransaction(_detail);
                }
                else if (GetPartnerIdArr(partnerId)[0].Equals(GetStatic.ReadWebConfig("riapartnerid", "")))
                {
                    //IGMEDao _gme = new GMEDao();
                    //return _gme.SelectByPinNo(GetStatic.GetUser(), branchId, controlNo);
                    IPayTransactionThirdpartyDao _dao = new PayTransactionThirdpartyDao();
                    PayTxnCheck _detail = GetSearchDetails(controlNo, branchId, partnerId);
                    return _dao.SearchTransaction(_detail);
                }
                else
                {
                    return dbResult;
                }
            }
            catch (Exception ex)
            {
                return new DbResult
                {
                    ErrorCode = "1",
                    Msg = "Internal error (Exception occured)!" + ex.Message
                };
            }
        }

        public PayTxnCheck GetSearchDetails(string controlNo, string branchId, string providerId)
        {
            PayTxnCheck _detail = new PayTxnCheck()
            {
                RequestFrom = "core",
                UserName = _userName, // GetStatic.GetUser(),
                ControlNo = controlNo,
                SessionId = GetAgentSession(),
                PBranch = branchId,
                ProcessId = "111",
                ProviderId = providerId
            };

            return _detail;
        }

        private void ReturnJson(ref DbResult dr)
        {
            var json = new JavaScriptSerializer().Serialize(dr);
            Response.Write(json);
            Response.End();
        }

        private string GetAgentSession()
        {
            return (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
        }

        protected string[] GetPartnerIdArr(string partnerAndSubPartner)
        {
            if (!string.IsNullOrEmpty(partnerAndSubPartner))
            {
                return partnerAndSubPartner.Split('|');
            }
            else
            {
                return null;
            }
        }

        private void PopulatePayoutMessage()
        {
            var obj = new TxnMessageSettingDao();
            var ds = obj.SelectByFlag(_userName, "Pay");

            if (ds == null)
            {
                dvContent.Visible = true;
                var str = new StringBuilder("<table class=\"table table-bordered table-striped table-condensed table-responsive\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                str.Append("<th><div align=\"left\">देश</div></th>");
                str.Append("<th><div align=\"left\">&nbsp;</div></th>");
                str.Append("<th><div align=\"left\">BRN कोडको विवरण</div></th>");
                str.Append("</tr>");
                str.Append("<tr>");
                str.Append("<td align='left' colspan='3'> NO record to display</td>");
                str.Append("</tr>");
                str.Append("</table>");
                dvContent.InnerHtml = str.ToString();
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class=\"table table-bordered table-striped table-condensed table-responsive\">");
                str.Append("<tr>");
                str.Append("<th><div align=\"left\">देश</div></th>");
                str.Append("<th><div align=\"left\">&nbsp;</div></th>");
                str.Append("<th><div align=\"left\">BRN कोडको विवरण</div></th>");

                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 0; i < cols - 1; i++)
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table>");
                dvContent.InnerHtml = str.ToString();
            }
        }
    }
}