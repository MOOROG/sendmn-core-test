using Newtonsoft.Json;
using Swift.API.Common;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.API.TPAPIs.GMESocialWallAPI
{
    public class SocialWallAPIService : ISocialWallAPIService
    {
        private const string providerName = "FuseMachine";
        string logId = "";
        string _baseURL = "http://10.1.1.171:8080/v1";
        DbResult dbResult = new DbResult();
        DbResult _dbResult = new DbResult();
        public FeedResponse GetFeeds(FeedRequest data, out DbResult err)
        {
            FeedResponse _feedResponse = new FeedResponse();
            string str = "";
            string sResponseFromServer = "";
            var serializer = new JavaScriptSerializer();
            var auth = Utility.GetSocialWallApiAuthKey();
            var _request = serializer.Serialize(data);
            _dbResult = Utility.LogRequest(data.userId, providerName, "GetFeeds", "", _request);
            logId = _dbResult.Id;
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/feeds/admins?userId=" + data.userId + "&country=" + data.country + "&onlyReported=" + data.onlyReported + "&before=" + data.before + "&after="+ data.after + "&limit=" + data.limit);
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "GET";
                _httpRequest.Headers.Add("Authorization", auth);

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                if (_httpResponse.StatusCode==HttpStatusCode.OK)
                {
                    using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                    {
                        sResponseFromServer = _streamReader.ReadToEnd();
                        _feedResponse = new JavaScriptSerializer().Deserialize<FeedResponse>(sResponseFromServer);
                        dbResult.SetError("0", "Success", "");
                    }
                }
                else
                {
                    //_dbResult.SetError("1",_httpResponse)
                }
                _httpResponse.Close();
                Utility.LogResponse(logId, sResponseFromServer, dbResult.ErrorCode, dbResult.Msg);
            }

            catch (Exception ex)
            {
                dbResult.SetError("1", ex.Message, "");
                str = serializer.Serialize(_dbResult);
            }
            err = dbResult;
            return _feedResponse;
        }
        public Feeds GetSpecificFeed(FeedQueryParameters data, out DbResult err)
        {
            Feeds _feed = new Feeds();
            string str = "";
            var serializer = new JavaScriptSerializer();

            var auth = Utility.GetSocialWallApiAuthKey();
            var _request = serializer.Serialize(data);
            _dbResult = Utility.LogRequest(data.userId, providerName, "GetFeeds", "", _request);
            logId = _dbResult.Id;
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/feeds/" + data.feedId + "?userId=" + data.userId);

                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "GET";
                _httpRequest.Headers.Add("Authorization", auth);
                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    String sResponseFromServer = _streamReader.ReadToEnd();
                    _feed = new JavaScriptSerializer().Deserialize<Feeds>(sResponseFromServer);
                    dbResult.SetError("0", "Success", "");
                }
                _httpResponse.Close();
                var responseXml = Utility.ObjectToXML(_feed);
                Utility.LogResponse(logId, responseXml, "", "");
            }

            catch (WebException ex)
            {
                var res=ex.Response.ToString();
                dbResult.SetError("1", ex.Message, "");
                str = serializer.Serialize(dbResult);
            }
            err = dbResult;
            return _feed;
        }
        public List<ReportedFeedResponse> GetFeedReportDetails(FeedQueryParameters data, out DbResult err)
        {
            List<ReportedFeedResponse> _reportedFeedResponse = new List<ReportedFeedResponse>();
            string str = "";
            var serializer = new JavaScriptSerializer();
            var auth = Utility.GetSocialWallApiAuthKey();
            var _request = serializer.Serialize(data);
            _dbResult = Utility.LogRequest(data.userId, providerName, "GetFeedReportDetails", data.feedId, _request);
            logId = _dbResult.Id;
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL + "/feeds/" + data.feedId + "/reports?page=" + data.page + "&size=" + data.size);
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "GET";
                _httpRequest.Headers.Add("Authorization", auth);
                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    str = _streamReader.ReadToEnd();
                    _reportedFeedResponse = new JavaScriptSerializer().Deserialize<List<ReportedFeedResponse>>(str);
                    dbResult.SetError("0", "Success", "");
                }
                _httpResponse.Close();
                Utility.LogResponse(logId, str, dbResult.ErrorCode, dbResult.Msg);
            }
            catch (Exception ex)
            {
                dbResult.SetError("1", ex.Message, "");
                str = serializer.Serialize(dbResult);
            }
            err = dbResult;
            return _reportedFeedResponse;
        }
        public string BlockUnblockFeed(BlockUnblockFeedParameters data,out DbResult err)
        {
            var result = "";
            try
            {
                var auth = Utility.GetSocialWallApiAuthKey();
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                var _request = serializer.Serialize(data);
                _dbResult = Utility.LogRequest(data.userId, providerName, "GetFeedReportDetails", data.feedId, _request);
                logId = _dbResult.Id;
                using (var client = new WebClient())
                {
                    client.Headers.Add("Content-Type:application/json");
                    client.Headers.Add("Authorization", auth);
                    result = client.UploadString(_baseURL + "/feeds/" + data.feedId + "/blocks", "PATCH", serializer.Serialize(data));
                    dbResult.SetError("0", "Feed block/unblock Successfully!!!", "");
                }
                Utility.LogResponse(logId, result, dbResult.ErrorCode, dbResult.Msg);
            }
            catch (WebException wex)
            {
                if (((HttpWebResponse)wex.Response).StatusCode == HttpStatusCode.InternalServerError)
                {
                   
                    dbResult.SetError("1", "Provided feed doesn't exist or it may have been deleted or you are not authorized to perform this action.", "");
                }
                else
                {
                    dbResult.SetError("0", "Oops Something Went Wrong!!!", "");
                }
            }
            err = dbResult;
            return result;
        }
    }
}
