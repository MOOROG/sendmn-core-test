#pragma warning disable CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.API.Common.PayTransaction;
#pragma warning restore CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
#pragma warning disable CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.ThirdPartyApiServices' (are you missing an assembly reference?)
using Swift.API.ThirdPartyApiServices.PayTransaction;
#pragma warning restore CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.ThirdPartyApiServices' (are you missing an assembly reference?)
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.SwiftDAL;
using System;
using System.Text;

namespace Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn
{
    public class PayTransactionThirdpartyDao : IPayTransactionThirdpartyDao
    {
        private StringBuilder sql;

        // protected RemittanceDao _remit;
#pragma warning disable CS0246 // The type or namespace name 'IPayTransactionApiService' could not be found (are you missing a using directive or an assembly reference?)
        protected IPayTransactionApiService _serviceAPI;
#pragma warning restore CS0246 // The type or namespace name 'IPayTransactionApiService' could not be found (are you missing a using directive or an assembly reference?)

        public PayTransactionThirdpartyDao()
        {
            _serviceAPI = new PayTransactionApiService();
        }

#pragma warning disable CS0246 // The type or namespace name 'PayTxnCheck' could not be found (are you missing a using directive or an assembly reference?)
        public DbResult SearchTransaction(PayTxnCheck req)
#pragma warning restore CS0246 // The type or namespace name 'PayTxnCheck' could not be found (are you missing a using directive or an assembly reference?)
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

#pragma warning disable CS0246 // The type or namespace name 'PayTxnConfirm' could not be found (are you missing a using directive or an assembly reference?)
        public DbResult ConfirmTransaction(PayTxnConfirm req)
#pragma warning restore CS0246 // The type or namespace name 'PayTxnConfirm' could not be found (are you missing a using directive or an assembly reference?)
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
                if (res.ResponseCode == "0")
                {
                    _res.Id = req.ControlNo;
                }
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