using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.Cancel;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.ApproveTxn
{
    public partial class Reject : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20122800";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ApproveTransactionDao atd = new ApproveTransactionDao();
        private ApproveTransactionDao at = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            //GetStatic.AttachConfirmMsg(ref btnReject, "Are you sure to reject this transaction?");
            string methodName = Request.Form["MethodName"];
            if (!IsPostBack)
            {
                Authenticate();
                switch (methodName)
                {
                    case "RejectClicked":
                        ManageReject();
                        break;
                }
                ManageHiddenField();
            }
            LoadTransaction();
        }

        private void ManageHiddenField()
        {
            DbResult _dbRes = at.GetTxnApproveData(GetStatic.GetUser(), GetTranNo());
            hddPartnerPin.Value = _dbRes.Id;
            hddIsRealTime.Value = _dbRes.Extra;
            hddPartnerId.Value = _dbRes.Msg;

            if (_dbRes.Extra == "True")//is realtime
            {
                string sql = "SELECT CANCEL_REASON_CODE, CANCEL_REASON_TITLE FROM TBL_PARTNER_CANCEL_REASON (NOLOCK) WHERE PARTNER_ID = 394130 AND IS_ACTIVE = 1";
                partnerRemarksDiv.Visible = true;
                _sdd.SetDDL(ref ddlRemarks, sql, "CANCEL_REASON_CODE", "CANCEL_REASON_TITLE", "", "Select Reason");
            }
            else
                partnerRemarksDiv.Visible = false;
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadTransaction()
        {
            string tranNo = GetTranNo();
            ucTran.SearchData(tranNo, "", "", "", "REJECT", "ADMIN: VIEW TXN TO REJECT");
            divTranDetails.Visible = ucTran.TranFound;
            if (!ucTran.TranFound)
            {
                divControlno.InnerHtml = "<h2>No Transaction Found</h2>";
                return;
            }
        }

        protected string GetTranNo()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private void ManageReject()
        {
            var tranId = Request.Form["id"];
            DbResult _dbRes = at.GetTxnApproveData(GetStatic.GetUser(), tranId);
            if (_dbRes.Extra == "True")//is realtime
            {
                string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":" + _dbRes.Extra2 + ":statusSync";

                CancelRequestServices crs = new CancelRequestServices();
                JsonResponse _resp = crs.CancelTransaction(new CancelTxn()
                {
                    ProviderId = _dbRes.Msg,
                    PartnerPinNo = _dbRes.Id,
                    CancelReason = Request.Form["partnerRemarksId"],
                    ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40)
                });

                if (_resp.ResponseCode == "0")
                {
                    string remarksAll = Request.Form["remarks"] + "/ Partner Remarks: " + Request.Form["partnerRemarksText"];
                    var dr = atd.Reject(GetStatic.GetUser(), tranId, remarksAll, GetStatic.GetSettlingAgent());
                    Response.ContentType = "application/json";
                    Response.Write(JsonConvert.SerializeObject(dr));
                    Response.End();
                }
                else
                {
                    var dr = new DbResult()
                    {
                        ErrorCode = "1",
                        Msg = _resp.Msg
                    };
                    Response.ContentType = "application/json";
                    Response.Write(JsonConvert.SerializeObject(dr));
                    Response.End();
                }
            }
            else
            {
                var dr = atd.Reject(GetStatic.GetUser(), tranId, Request.Form["remarks"], GetStatic.GetSettlingAgent());
                Response.ContentType = "application/json";
                Response.Write(JsonConvert.SerializeObject(dr));
                Response.End();
            }
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            ManageReject();
        }
    }
}