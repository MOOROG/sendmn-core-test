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
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.BankDeposit
{
    public class BankDepositDao : IBankDepositDao
    {
#pragma warning disable CS0246 // The type or namespace name 'IBankDepositService' could not be found (are you missing a using directive or an assembly reference?)
        protected IBankDepositService _serviceAPI;
#pragma warning restore CS0246 // The type or namespace name 'IBankDepositService' could not be found (are you missing a using directive or an assembly reference?)

        public BankDepositDao()
        {
            _serviceAPI = new BankDepositService();
        }

        public DbResult PayBankDeposit(string user, string[] tranId)
        {
            DbResult _res = new DbResult();
            var id = "";

            try
            {
                WithdrawWalletRequestModel req = new WithdrawWalletRequestModel()
                {
                    UserName=user,
                    tranId = tranId,
                    RequestFrom="core"
                };

                var requestXml = ApiUtility.ObjectToXML(req);
                id = ApiUtility.LogRequest(req.UserName, "Thirdparty", "bankdepositremittance", req.tranId[0], requestXml).Id;

                var res = _serviceAPI.PayBankDepositThroughAPI(req);
                if (res == null)
                {
                    _res.SetError("1", "Null Response for method bankdepositremittance", "");
                    ApiUtility.LogDataError(id, _res.ErrorCode,_res.Msg);
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
    }
}
