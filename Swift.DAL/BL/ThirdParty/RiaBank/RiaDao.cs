#pragma warning disable CS0234 // The type or namespace name 'BankDeposit' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.API.Common.BankDeposit;
#pragma warning restore CS0234 // The type or namespace name 'BankDeposit' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
#pragma warning disable CS0234 // The type or namespace name 'DAL_BankDeposit' does not exist in the namespace 'Swift.API.ThirdPartyApiServices' (are you missing an assembly reference?)
using Swift.API.ThirdPartyApiServices.DAL_BankDeposit;
#pragma warning restore CS0234 // The type or namespace name 'DAL_BankDeposit' does not exist in the namespace 'Swift.API.ThirdPartyApiServices' (are you missing an assembly reference?)
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.RiaBank
{
    public class RiaDao : IRiaDao
    {
#pragma warning disable CS0246 // The type or namespace name 'IBankDepositService' could not be found (are you missing a using directive or an assembly reference?)
        protected IBankDepositService _serviceAPI;
#pragma warning restore CS0246 // The type or namespace name 'IBankDepositService' could not be found (are you missing a using directive or an assembly reference?)
        protected RemittanceDao _remit;

        public RiaDao()
        {
            _serviceAPI = new BankDepositService();
            _remit = new RemittanceDao();
        }

        private DbResult GetPartnerIdUsingControlNo(string controlNo)
        {
            string sql = "EXEC proc_SendTransaction @flag='getPartnerId',@controlNo=" + _remit.FilterString(controlNo);
            return _remit.ParseDbResult(sql);
        }

        public DataTable LoadRiaCancelTxn(string user)
        {
            var sql = "exec Proc_RiaBankHistory @flag='Ria-Cancel-List'";
            return _remit.ExecuteDataTable(sql);
        }

#pragma warning disable CS0246 // The type or namespace name 'CancelRiaTxn' could not be found (are you missing a using directive or an assembly reference?)
        public DbResult CancelRiaTxn(CancelRiaTxn req)
#pragma warning restore CS0246 // The type or namespace name 'CancelRiaTxn' could not be found (are you missing a using directive or an assembly reference?)
        {
            var partnerIdResponse = GetPartnerIdUsingControlNo(req.PartnerPinNo);
            if (partnerIdResponse.ErrorCode != "0")
            {
                return partnerIdResponse;
            }
            req.ProviderId = partnerIdResponse.Id;
            DbResult _res = new DbResult()
            {
                ErrorCode = "1",
                Msg = "Error Occured"
            };

            var id = "";

            try
            {
                var requestXml = ApiUtility.ObjectToXML(req);
                id = ApiUtility.LogRequest(req.UserName, "Thirdparty", "cancelTxnRequest", req.PartnerPinNo, requestXml).Id;

                var res = _serviceAPI.CancelRiaTxn(req);

                if (res == null)
                {
                    _res.SetError("1", "Null Response for method cancelTxnRequest", "");
                    ApiUtility.LogDataError(id, _res.ErrorCode, _res.Msg);
                    return _res;
                }

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, res.ResponseCode, res.Msg);

                _res.SetError(res.ResponseCode, res.Msg, res.Id);
                return _res;
            }
            catch (Exception ex)
            {
                _res.SetError("999", "cancelTxnRequest Exception : " + ex.Message, "");
                ApiUtility.LogDataError(id, _res.ErrorCode, _res.Msg);
                return _res;
            }
        }
    }
}