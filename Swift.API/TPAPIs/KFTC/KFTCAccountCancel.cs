using Newtonsoft.Json;
using Swift.API.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.API.TPAPIs.KFTC
{
    public class KFTCAccountCancel : IKFTCAccountCancel
    {
        protected readonly string _baseURL;

        public KFTCAccountCancel()
        {
            _baseURL = Utility.ReadWebConfig("coreApiBaseURL", "");
        }

        public DbResult CancelAccount(DataTable dt)
        {
            DbResult _dbRes = new DbResult();
            
            List<account_cancel> _lst = new List<account_cancel>();

            foreach (DataRow item in dt.Rows)
            {
                account_cancel cancel = new account_cancel();

                cancel.scope = "transfer";//Request.Form["Scope"];
                cancel.fintech_use_num = item["fintech_use_num"].ToString(); //핀테크번호

                _lst.Add(cancel);
            }
            
            request_main_data _requestMain = new request_main_data();
            _requestMain._cancelURL = @"account/cancel";
            _requestMain.access_token = dt.Rows[0]["access_token"].ToString();
            _requestMain.postData = _lst;

            SendTxnRequest _requestData = new SendTxnRequest();
            _requestData.provider = "kftc";
            _requestData.requestJSON = new JavaScriptSerializer().Serialize(_requestMain);

            var _request = new JavaScriptSerializer().Serialize(_requestData);
            
            //log request
            string id = Utility.LogRequestKFTC(dt.Rows[0]["customerId"].ToString(), "Core: CancelAccount", _request).Id;

            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/api/CancelTransaction");
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "POST";

                _httpRequest.Headers.Add("HeaderToken", "C1A2E2774D4158A909CC4B727C412E95595E8731E10FEFDFC931AE8123BF4F51");
                _httpRequest.Headers.Add("Authorization", "E3B8C3C55A6FB072E458D21DF2DD7CA7CFE176FB28D6047603B07B1B3C92749D");

                using (var _streamWriter = new StreamWriter(_httpRequest.GetRequestStream()))
                {
                    _streamWriter.Write(_request);
                    _streamWriter.Flush();
                    _streamWriter.Close();
                }

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    _dbRes = new JavaScriptSerializer().Deserialize<DbResult>(_streamReader.ReadToEnd());
                }
                _httpResponse.Close();

                //log response
                Utility.LogResponseKFTC(id, Utility.ObjectToXML(_dbRes), _dbRes.ErrorCode, _dbRes.Msg);
            }
            catch (Exception e)
            {
                //log response
                Utility.LogResponseKFTC(id, "Exception occured!", "999", e.Message);

                _dbRes.SetError("999", e.Message, null);
                return _dbRes;
            }
            return _dbRes;
        }

        public class account_cancel
        {
            public string scope { get; set; } //inquiry, transfer
            public string fintech_use_num { get; set; }
        }

        public class request_main_data
        {
            public string _cancelURL { get; set; } //inquiry, transfer
            public string access_token { get; set; }
            //public string postData { get; set; }
            public List<account_cancel> postData { get; set; }
        }
    }
}
