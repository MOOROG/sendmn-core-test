using Swift.API.Common.PayTransaction;
using Swift.API.ThirdPartyApiServices.PayTransaction;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn
{
   public class PayTransactionDao : IPayTransactionDao
    {
        private StringBuilder sql;
     //   protected RemittanceDao _remit;
        protected IPayTransactionApiService _serviceAPI;
        public PayTransactionDao()
        {
            _serviceAPI = new PayTransactionApiService();
        }
        public DbResult SearchTransaction(PayTxnCheck req)
        {
            DbResult _res = new DbResult();
            var id = "";

            try
            {
                var requestXml = ApiUtility.ObjectToXML(req);
                id = ApiUtility.LogRequest(req.UserName, "Thirdparty", "payTxnCheck", req.ControlNo, requestXml).Id;

                var res = _serviceAPI.PaySearch(req);
                if (res == null)
                {
                    _res.SetError("1", "Null Response for method payTxnCheck", "");
                    ApiUtility.LogDataError(id, "1", "Null Response for method payTxnCheck");
                    return _res;
                }

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, res.ResponseCode, res.Msg);

                _res.SetError(res.ResponseCode, res.Msg, res.Id);
                return _res;
            }
            catch (Exception ex)
            {
                _res.SetError("999", "1.Exception : " + ex.Message, "");
                ApiUtility.LogDataError(id, _res.ErrorCode, _res.Msg);
                return _res;
            }
        }

        public DbResult ConfirmTransaction(PayTxnConfirm req)
        {
            DbResult _res = new DbResult();
            var id = "";

            try
            {
                var requestXml = ApiUtility.ObjectToXML(req);
                id = ApiUtility.LogRequest(req.UserName, "Thirdparty", "payTxnConfirm", req.ControlNo, requestXml).Id;

                var res = _serviceAPI.PayConfirm(req);
                if (res == null)
                {
                    _res.SetError("1", "Null Response for method payTxnConfirm", "");
                    ApiUtility.LogDataError(id, "1", "Null Response for method payTxnConfirm");
                    return _res;
                }
                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, res.ResponseCode, res.Msg);

                _res.SetError(res.ResponseCode, res.Msg, res.Id);
                return _res;
            }
            catch (Exception ex)
            {
                _res.SetError("999", "2.Exception : " + ex.Message, "");
                ApiUtility.LogDataError(id, _res.ErrorCode, _res.Msg);
                return _res;
            }
        }
    }
}
