using Swift.DAL.BL.System.Utility;
using Swift.DAL.net.inficare.kumari;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace Swift.DAL.BL.Helper.ThirdParty.KumariBank
{
    class KumariBankApi
    {
        protected readonly string userName;
        protected readonly string password;
        protected readonly string accessCode;
        protected readonly string complienceAmt;
        public KumariBankApi()
        {
            userName = Utility.GetkumariUserid();
            password = Utility.GetkumariPassword();
            accessCode = Utility.GetkumariAccessCode();
            complienceAmt = Utility.GetComplienceAmount();
        }

        public Swift.DAL.net.inficare.kumari.iRemitWsPayV49 kumariApi = new Swift.DAL.net.inficare.kumari.iRemitWsPayV49();
        public Return_TXNStatus GetStatus(string user, string refNo, string payTokenId)
        {
            
            var _res = new Return_TXNStatus();
            string session = GetAgentSession();
            string signature = GetSignature(session, refNo, payTokenId);
            var requestXml = "refNo=" + refNo + ";payTokenId=" + payTokenId +
                ";userSessionId=" + session + ";signature=" + signature;
            var id = ApiUtility.LogRequest(user, "Kumari Bank", "GetStatus", refNo, requestXml).Id;
            try
            {
                _res = kumariApi.GetStatus(accessCode, userName, refNo, session, signature);

                var responseXml = ApiUtility.ObjectToXML(_res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
            }

            return _res;
        }

        public Return_TXNUnLock TXNUnLock(string user, string refNo, string payTokenId, string subPartnerId)
        {
            string session = GetAgentSession();
            string signature = GetSignature(session, refNo, payTokenId);
            var requestXml = "refNo=" + refNo + ";payTokenId=" + payTokenId +
                ";userSessionId=" + session + ";signature=" + signature;
            var _res = new Return_TXNUnLock();
            var id = ApiUtility.LogRequest(user, "Kumari Bank", "TXNUnLock", refNo, requestXml).Id;
            try
            {
                _res = kumariApi.TXNUnLock(accessCode, userName, refNo, session, payTokenId, subPartnerId, signature);

                var responseXml = ApiUtility.ObjectToXML(_res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
            }

            return _res;
        }
        private string GetSignatureForRpt(string value)
        {
            StringBuilder Sb = new StringBuilder();
            using (SHA256 hash = SHA256Managed.Create())
            {
                Encoding enc = Encoding.UTF8;
                Byte[] result = hash.ComputeHash(enc.GetBytes(value));

                foreach (Byte b in result)
                    Sb.Append(b.ToString("x2"));
            }
            return Sb.ToString();
        }
        public Return_TRANSREPORT[] ReconcileReport(string user, string fromDate, string toDate, string reportType)
        {
            string session = GetAgentSession();
            string fromTime = "00:00:00";
            string toTime = "23:59:59";
            string value = accessCode + userName + session + fromDate + fromTime + toDate + toTime + reportType + password;
            string signature = GetSignatureForRpt(value);
            var requestXml = ";userSessionId=" + session + ";signature=" + signature +
                ";fromDate=" + fromDate + ";toDate=" + toDate + ";fromTime=" + fromTime + ";toTime=" + toTime +
                ";reportType=" + reportType;
            //var _res = new List<Return_TRANSREPORT>();
            var id = ApiUtility.LogRequest(user, "Kumari Bank", "ReconcileReport", "", requestXml).Id;
            try
            {
                var  _res = kumariApi.ReconcileReport(accessCode, userName, session, fromDate, fromTime, toDate, toTime, reportType, signature);

                if (_res == null || _res.Length.Equals(0))
                {
                    _res[0].CODE = "1";
                    _res[0].MESSAGE = "API Server Could Not Process Your Request.";
                    ApiUtility.LogDataError(id, _res[0].CODE, _res[0].MESSAGE);
                    return _res;
                }
                else
                {
                    var responseXml = ApiUtility.ObjectToXML(_res);
                    ApiUtility.LogResponse(id, responseXml, "0", "Success");
                    return _res;
                }
                
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
            }
            return null;
        }

        public Return_PAYCHECKDetail SelectByPinNo(string user, string branchId, string refNo, string subPartnerId)
        {
            string session = GetAgentSession();
            string signature = GetSignature(session, subPartnerId, refNo);
            var requestXml = "refNo=" + refNo + 
                ";userSessionId=" + session + ";signature=" + signature;
            var res = new Return_PAYCHECKDetail();
            var id = ApiUtility.LogRequest(user, "Kumari Bank", "PayCheckDetail", refNo, requestXml).Id;
            try
            {
                res = kumariApi.PayTXNCheck(accessCode, userName, refNo, session, subPartnerId, signature);

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, res.CODE, res.MESSAGE);

                if (res == null)
                {
                    ApiUtility.LogDataError(id, "999", "Internal Error");
                }
                else if (res.CODE != "0")
                {
                    ApiUtility.LogDataError(id, res.CODE, res.MESSAGE);
                }
                return res;
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
            }
            return res;
        }

        private string GetSignature(string session, string subPartnerId="", string refNo = "", string payTokenId = "", string pBranch = "", string idType = "", string idNum = "", string idIssuedPlace = "", 
            string mobileNum = "", string pAmount = "", string bankName = "", string bankBranchName = "")
        {
            StringBuilder Sb = new StringBuilder();
            string value = "";
            Double amount = Convert.ToDouble(!string.IsNullOrEmpty(pAmount) ? pAmount : "0.00");
            Double complienceAmount = Convert.ToDouble(!string.IsNullOrEmpty(complienceAmt) ? complienceAmt : "0.00");
            if (!string.IsNullOrEmpty(payTokenId))
            {
                if (!string.IsNullOrEmpty(amount.ToString()))
                {
                    if (amount <= complienceAmount)
                    {
                        value = accessCode + userName + refNo + session + payTokenId + pBranch + idType + idNum + idIssuedPlace + mobileNum + subPartnerId + password;
                    }
                    else
                    {
                        value = accessCode + userName + refNo + session + subPartnerId + payTokenId + pBranch + idType + idNum + idIssuedPlace + mobileNum + subPartnerId + password;
                    }
                }
                else
                {
                    value = accessCode + userName + refNo + session + payTokenId + subPartnerId + password;
                }
            }
            else
            {
                value = accessCode + userName + refNo + session + subPartnerId + password;
            }

            using (SHA256 hash = SHA256Managed.Create())
            {
                Encoding enc = Encoding.UTF8;
                Byte[] result = hash.ComputeHash(enc.GetBytes(value));

                foreach (Byte b in result)
                    Sb.Append(b.ToString("x2"));
            }

            return Sb.ToString();
        }

        private string GetAgentSession()
        {
            string session = (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
            return session;
        }

        internal DbResult PayConfirm(string pBranch, string payTokenId, string refNo, string idType, string idNum, string mobileNum, string idIssuedPlace,
            string bankName, string bankBranchName, string pAmount, string subPartnerId)
        {
            var dr = new DbResult();
            string session = GetAgentSession();
            string signature = GetSignature(session, subPartnerId, refNo, payTokenId, pBranch, idType, idNum, idIssuedPlace, mobileNum, pAmount, bankName, bankBranchName);
            var requestXml = "refNo=" + refNo +
                ";userSessionId=" + session + ";signature=" + signature +
                ";payTockenId=" + payTokenId + ";pBranch=" + pBranch + ";idType=" + idType + ";idIssuedPlace=" + idIssuedPlace +
                ";mobileNumber=" + mobileNum + ";BankName=" + bankName + ";BankBranchName=" + bankBranchName + ";subPartnerId=" + subPartnerId;
            var drApi = ApiUtility.LogRequest(pBranch, "Kumari Bank", "PayConfirm", refNo, requestXml);
            var id = drApi.Id;
            if (!drApi.ErrorCode.Equals("0"))
            {
                dr.SetError(drApi.ErrorCode, "Technical Error. Please try again.", refNo);
                return dr;
            }

            try
            {
                var res = kumariApi.PayTXNConfirm(accessCode, userName, refNo, session, payTokenId, pBranch, idType, idNum, idIssuedPlace, mobileNum, subPartnerId, "", "",
                    bankName, bankBranchName, signature);

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");

                if (res.CODE == "0")
                {
                    dr.SetError("0", res.MESSAGE, "");
                    dr.Extra = res.Confirm_ID;
                    dr.Extra2 = res.PayoutCommission;
                }
                else if (res.CODE == "100")
                {
                    dr.SetError("0", res.MESSAGE, "");
                    dr.Extra = res.Confirm_ID;
                    dr.Extra2 = res.PayoutCommission;
                }
                else
                {
                    dr.SetError(res.CODE, res.MESSAGE, res.Confirm_ID);
                    dr.Extra = res.Confirm_ID;//Api response Code
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                    if (subPartnerId.Equals("1"))
                    {
                        TXNUnLock(pBranch, refNo, payTokenId, subPartnerId);
                    }
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
    }
}
