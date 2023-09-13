using Swift.API.Common;
using System;
using System.Data;
using System.IO;
using System.Net;
using System.Web.Script.Serialization;

namespace Swift.API.TPAPIs.CancelTPTxn
{
    public class WingApiService : IWingApiService
    {
        protected readonly string _baseURL;

        public WingApiService()
        {
            //_baseURL = Utility.ReadWebConfig("coreApiBaseURL", "");
            _baseURL = "http://10.15.18.150:9091/";
        }

        public GetStatusResponse GetStatusWing(string controlNo, string provider)
        {
            GetStatusResponse _getStatusResult = new GetStatusResponse();

            var _pushData = new
            {
                transaction_id = controlNo,
                use_wing_id = "false"
            };

            SendTxnRequest _requestData = new SendTxnRequest();
            _requestData.provider = provider;
            _requestData.requestJSON = new JavaScriptSerializer().Serialize(_pushData);

            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/api/GetAPIStatus");
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "POST";


                _httpRequest.Headers.Add("HeaderToken", "C1A2E2774D4158A909CC4B727C412E95595E8731E10FEFDFC931AE8123BF4F51");
                _httpRequest.Headers.Add("Authorization", "E3B8C3C55A6FB072E458D21DF2DD7CA7CFE176FB28D6047603B07B1B3C92749D");


                using (var _streamWriter = new StreamWriter(_httpRequest.GetRequestStream()))
                {
                    string _request = new JavaScriptSerializer().Serialize(_requestData);

                    _streamWriter.Write(_request);
                    _streamWriter.Flush();
                    _streamWriter.Close();
                }

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    _getStatusResult = new JavaScriptSerializer().Deserialize<GetStatusResponse>(_streamReader.ReadToEnd());
                }

                _httpResponse.Close();
            }
            catch (Exception e)
            {
                _getStatusResult.ErrorCode = "999";
                _getStatusResult.ErrorMsg = e.Message.ToString();
            }

            return _getStatusResult;
        }
    }
}
