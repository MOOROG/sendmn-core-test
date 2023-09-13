using Swift.API.Common.PayTransaction;
using Swift.DAL.BL.Remit.Transaction.PayTransaction;
using Swift.DAL.BL.Remit.Transaction.ThirdParty;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.BL.ThirdParty.GME;
using Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.Pay.PayTransaction
{
    public partial class PaySearch : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly PayDao _obj = new PayDao();
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private const string ViewFunctionId = "40101300";
        private const string ProcessFunctionId = "40101310";
        private string _partnerId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
           _sdd.CheckPayTransactionAllowedTime();

            if (!IsPostBack)
            {
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
                }
            }
            PopulatePayoutMessage();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        private void loadDDL()
        {
            _sdd.SetDDL(ref partner, "EXEC [proc_dropDownLists2] @flag = 'provider'", "value", "text", "", "");
        }

        private void SearchTxnPriority()
        {
            var branchId = GetStatic.GetBranch();
            var controlNo = Request.Form["controlNo"];
            _partnerId = Request.Form["partener"];
            var _dbRes = new DbResult();

            if (!string.IsNullOrEmpty(_partnerId))
            {
                _dbRes = SelectByPinNo(_partnerId, controlNo, branchId);
            }
            else
            {
                var dt = _obj.GetProviderByControlNo(GetStatic.GetUser(), controlNo);
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
            ReturnJson(ref _dbRes);
        }

        private DbResult GetStatus(string partnerId, string controlNo)
        {
            return new TransactionUtilityDao().GetTxnStatus(GetStatic.GetUser(), partnerId, controlNo);
        }

        private DbResult SelectByPinNo(string partnerId, string controlNo, string branchId)
        {
            DbResult dbResult = new DbResult()
            {
                ErrorCode ="1"
                ,Msg="No any matching provider found!!"
            };

            if (GetPartnerIdArr(partnerId)[0].Equals("IME-I"))
            {
                dbResult = _obj.CheckPinValidationIntl(GetStatic.GetUser(), controlNo, branchId, partnerId);
                if (dbResult.ErrorCode.Equals("1"))
                    _rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                if (dbResult.ErrorCode == "1000")
                    _sdd.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return dbResult;
            }
            else if (GetPartnerIdArr(partnerId)[0].Equals(GetStatic.ReadWebConfig("gmepartnerid","")))
            {
                IPayTransactionThirdpartyDao _dao = new PayTransactionThirdpartyDao();
                PayTxnCheck _detail = GetSearchDetails(controlNo, branchId, partnerId);
               return  _dao.SearchTransaction(_detail);
            }
            else if (GetPartnerIdArr(partnerId)[0].Equals(GetStatic.ReadWebConfig("riapartnerid", "")))
            {
                IPayTransactionThirdpartyDao _dao = new PayTransactionThirdpartyDao();
                PayTxnCheck _detail = GetSearchDetails(controlNo, branchId, partnerId);
                return _dao.SearchTransaction(_detail);
            }
            else
            {
                return dbResult;
            }
        }
        
        public PayTxnCheck GetSearchDetails(string controlNo, string branchId, string providerId)
        {
            PayTxnCheck _detail = new PayTxnCheck()
            {
                RequestFrom ="core",
                UserName = GetStatic.GetUser(),
                ControlNo = controlNo,
                SessionId = GetAgentSession(),
                PBranch = branchId,
                ProcessId = "111",
                ProviderId = providerId
            };

            return _detail;
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

        private void ReturnJson(ref DbResult dr)
        {
            var json = new JavaScriptSerializer().Serialize(dr);
            Response.Write(json);
            Response.End();
        }

        private void PopulatePayoutMessage()
        {
            var obj = new TxnMessageSettingDao();
            var ds = obj.SelectByFlag(GetStatic.GetUser(), "Pay");

            if (ds == null)
            {
                dvContent.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
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