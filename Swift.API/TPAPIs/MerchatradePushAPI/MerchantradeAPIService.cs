using Swift.API.Common;
using Swift.API.Common.ExRate;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.API.TPAPIs.MerchatradePushAPI
{
    public class MerchantradeAPIService : IMerchantradeAPIService
    {
        private string logId = "";
        private string _baseURL = "http://10.15.18.150:9091/";

        public DbResult SendTxnMtrade(string user, MtradePushDetail _txnDetail, string provider)
        {
            DbResult _dbResult = new DbResult();

            SendTxnRequest _requestData = new SendTxnRequest();
            _requestData.provider = provider;
            _requestData.requestJSON = new JavaScriptSerializer().Serialize(_txnDetail);

            var _request = new JavaScriptSerializer().Serialize(_requestData);

            _dbResult = Utility.LogRequest(user, "Merchantrade", "SendTxnMtrade", _txnDetail.controlNo, _request);

            logId = _dbResult.Id;
            _requestData.processId = _dbResult.Extra;
            var _requestMain = new JavaScriptSerializer().Serialize(_requestData);   //this contains the processId from log request
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/api/SendAPITxn");
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "POST";

                _httpRequest.Headers.Add("HeaderToken", "C1A2E2774D4158A909CC4B727C412E95595E8731E10FEFDFC931AE8123BF4F51");
                _httpRequest.Headers.Add("Authorization", "E3B8C3C55A6FB072E458D21DF2DD7CA7CFE176FB28D6047603B07B1B3C92749D");

                using (var _streamWriter = new StreamWriter(_httpRequest.GetRequestStream()))
                {
                    _streamWriter.Write(_requestMain);
                    _streamWriter.Flush();
                    _streamWriter.Close();
                }

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    _dbResult = new JavaScriptSerializer().Deserialize<DbResult>(_streamReader.ReadToEnd());
                }

                Utility.LogResponse(logId, _dbResult.Extra2, _dbResult.ErrorCode, _dbResult.Msg);
                _httpResponse.Close();
            }
            catch (Exception e)
            {
                _dbResult.ErrorCode = "999";
                _dbResult.Msg = e.Message.ToString();

                Utility.LogResponse(logId, "Core: Exception Occured", _dbResult.ErrorCode, _dbResult.Msg);
                return _dbResult;
            }
            return _dbResult;
        }

        public DbResult GetExRate(string user, string provider, string pAgentCode)
        {
            DbResult _retResult = new DbResult();
            ExRateResponse _exRateResponse = new ExRateResponse();
            DbResult _dbResult = new DbResult();
            MtradeGetExRate _exRate = new MtradeGetExRate();
            _exRate.payoutAgentCode = pAgentCode;

            SendTxnRequest _requestData = new SendTxnRequest();
            _requestData.provider = provider;
            _requestData.requestJSON = new JavaScriptSerializer().Serialize(_exRate);

            var _request = new JavaScriptSerializer().Serialize(_requestData);

            _dbResult = Utility.LogRequest(user, "Merchantrade", "GetExRate", "", _request);

            logId = _dbResult.Id;
            _requestData.processId = _dbResult.Extra;
            var _requestMain = new JavaScriptSerializer().Serialize(_requestData);   //this contains the processId from log request
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/api/GetExRate");
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "POST";

                _httpRequest.Headers.Add("HeaderToken", "C1A2E2774D4158A909CC4B727C412E95595E8731E10FEFDFC931AE8123BF4F51");
                _httpRequest.Headers.Add("Authorization", "E3B8C3C55A6FB072E458D21DF2DD7CA7CFE176FB28D6047603B07B1B3C92749D");

                using (var _streamWriter = new StreamWriter(_httpRequest.GetRequestStream()))
                {
                    _streamWriter.Write(_requestMain);
                    _streamWriter.Flush();
                    _streamWriter.Close();
                }

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    _exRateResponse = new JavaScriptSerializer().Deserialize<ExRateResponse>(_streamReader.ReadToEnd());
                }
                _httpResponse.Close();

                var responseXml = Utility.ObjectToXML(_exRateResponse);
                Utility.LogResponse(logId, responseXml, _exRateResponse.ErrorCode, _exRateResponse.ErrorMsg);

                _retResult.ErrorCode = _exRateResponse.mirsErrCode;
                _retResult.Msg = _exRateResponse.ErrorMsg;
                _retResult.Extra = _exRateResponse.mirsPayoutAgentRate;
                _retResult.Extra2 = _exRateResponse.mirsPayoutCurrency;
            }
            catch (Exception e)
            {
                _retResult.ErrorCode = "999";
                _retResult.Msg = e.Message.ToString();

                Utility.LogResponse(logId, "Core: Exception Occured", _retResult.ErrorCode, _retResult.Msg);
                return _dbResult;
            }
            return _retResult;
        }
    }
}