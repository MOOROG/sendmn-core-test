using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using System;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.web.Library
{
    public static class KJBankAPIConnection
    {
        private static string GMEWalletApiBaseUrl = GetStatic.ReadWebConfig("KJURL", "");
        private static string secretKey = GetStatic.ReadWebConfig("KJsecretKey", "");

        private static byte[] CalcHMACSHA256Hash(string plaintext, string salt)
        {
            var utf8 = Encoding.UTF8;

            byte[] key = utf8.GetBytes(plaintext);
            byte[] message = utf8.GetBytes(salt);
            var hash = new HMACSHA256(key);
            return hash.ComputeHash(message);
        }

        private static string CreateToken(string message, string secret)
        {
            secret = secret ?? "";
            var encoding = new System.Text.ASCIIEncoding();
            byte[] keyByte = encoding.GetBytes(secret);
            byte[] messageBytes = encoding.GetBytes(message);
            using (var hmacsha256 = new HMACSHA256(keyByte))
            {
                byte[] hashmessage = hmacsha256.ComputeHash(messageBytes);
                return Convert.ToBase64String(hashmessage);
            }
        }

        public static AuthTokenResponse GetAuthentication()
        {
            AuthTokenResponse resp = new AuthTokenResponse();
            try
            {
                string body = "grant_type=client_credentials&client_id=" + GetStatic.ReadWebConfig("client_id", "") + "&client_secret=" + GetStatic.ReadWebConfig("KJsecretKey", "") + "&scope=public";
                WebRequest req = WebRequest.Create(GMEWalletApiBaseUrl + "/auth/oauth/v2/token");

                byte[] send = Encoding.Default.GetBytes(body);

                req.Method = "POST";
                req.ContentType = "application/x-www-form-urlencoded";
                req.ContentLength = send.Length;

                Stream sout = req.GetRequestStream();
                sout.Write(send, 0, send.Length);
                sout.Flush();
                sout.Close();

                WebResponse res = req.GetResponse();
                StreamReader sr = new StreamReader(res.GetResponseStream());
                resp = new JavaScriptSerializer().Deserialize<AuthTokenResponse>(sr.ReadToEnd());
                res.Close();
            }
            catch (Exception e)
            {
                return resp;
            }
            return resp;
        }

        public static string GetSHAValue(string plaintext, string sertetKey)
        {
            string key = CreateToken(plaintext, sertetKey);
            return key;
        }

        public static DbResult PostToKJBank(string body)
        {
            var dbResult = new DbResult();
            try
            {
                var url = "/api/partnerserviceaccount?body=" + body;
                var root = GMEWalletApiBaseUrl + url;

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(root);
                req.ContentType = "application/json";
                req.Headers.Add("Authorization", GetStatic.ReadWebConfig("KJsecretKey", ""));
                req.Headers.Add("HeaderToken", GetStatic.ReadWebConfig("client_id", ""));
                //req.Headers.Add("Authorization", auth.token_type + " " + auth.access_token);
                //string signatureurl = GetSHAValue("GET&" + url, secretKey);
                //req.Headers.Add("x-obp-signature-url", signatureurl);
                //req.Headers.Add("x-obp-partnercode", GetStatic.ReadWebConfig("KJpartnercode", ""));
                req.Method = "GET";

                HttpWebResponse res = (HttpWebResponse)req.GetResponse();
                StreamReader sr = new StreamReader(res.GetResponseStream());
                var result = sr.ReadToEnd();
                dbResult = new JavaScriptSerializer().Deserialize<DbResult>(result);
                OnlineCustomerDao onlineCustomerDao = new OnlineCustomerDao();
                onlineCustomerDao.RequestLog(new JavaScriptSerializer().Serialize((dbResult)));
                res.Close();
                return dbResult;
            }
            catch (Exception e)
            {
                dbResult.Msg = e.Message;
                dbResult.ErrorCode = "1";
                return dbResult;
            }
        }

        public static DbResult GetAccountDetailKJBank(string AccountNo, string bankCode)
        {
            var dbResult = new DbResult();
            try
            {
                var url = "/api/bankaccount/name?institution=" + bankCode + "&no=" + AccountNo;
                var root = GMEWalletApiBaseUrl + url;
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(root);
                req.Headers.Add("Authorization", GetStatic.ReadWebConfig("KJsecretKey", ""));
                req.Headers.Add("HeaderToken", GetStatic.ReadWebConfig("client_id", ""));
                req.ContentType = "application/json";
                //req.Headers.Add("Authorization", auth.token_type + " " + auth.access_token);
                //string signatureurl = GetSHAValue("GET&" + url, secretKey);
                //req.Headers.Add("x-obp-signature-url", signatureurl);
                //req.Headers.Add("x-obp-partnercode", GetStatic.ReadWebConfig("KJpartnercode", ""));
                req.Method = "GET";

                HttpWebResponse res = (HttpWebResponse)req.GetResponse();
                StreamReader sr = new StreamReader(res.GetResponseStream());
                var result = sr.ReadToEnd();
                dbResult = new JavaScriptSerializer().Deserialize<DbResult>(result);
                res.Close();
                return dbResult;
            }
            catch (Exception e)
            {
                dbResult.Msg = e.Message;
                dbResult.ErrorCode = "1";
                return dbResult;
            }
        }

        /// <summary>
        /// METHOD USED TO TRANSFER AMOUNT IN BANK ACCOUNT USING KJ BANK
        /// </summary>
        /// <param name="body">
        /// </param>
        /// <param name="baseUrl">
        /// </param>
        /// <param name="kjSecretKey">
        /// </param>
        /// <param name="clientId">
        /// </param>
        /// <returns>
        /// </returns>
        public static DbResult AccountTransferKJBank(string body, string baseUrl, string kjSecretKey, string clientId)
        {
            var dbResult = new DbResult();

            try
            {
                var url = "/api/moneytransfer/partner?body=" + body;
                var root = GMEWalletApiBaseUrl + url;

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(root);
                req.ContentType = "application/json";
                req.Headers.Add("Authorization", kjSecretKey);
                req.Headers.Add("HeaderToken", clientId);
                req.Method = "GET";

                var _httpResponse = (HttpWebResponse)req.GetResponse();
                using (var sr = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    var result = sr.ReadToEnd();
                    dbResult = new JavaScriptSerializer().Deserialize<DbResult>(result);

                    _httpResponse.Close();
                    return dbResult;
                }
            }
            catch (Exception e)
            {
                return new DbResult() { ErrorCode = "1", Msg = e.Message };
            }
        }

        public static string AccountTransferKJBank(string body)
        {
            var auth = GetAuthentication();

            var root = GMEWalletApiBaseUrl + "/api/moneytransfer/partner";

            WebRequest req = WebRequest.Create(root);
            req.ContentType = "application/json";
            req.Headers.Add("Authorization", auth.token_type + " " + auth.access_token);
            req.Headers.Add("scope", "public");
            string signatureurl = KJBankAPIConnection.GetSHAValue("POST&/api/moneytransfer/partner", secretKey);
            req.Headers.Add("x-obp-signature-url", signatureurl);

            req.Headers.Add("x-obp-partnercode", GetStatic.ReadWebConfig("KJpartnercode", ""));
            string signaturebody = KJBankAPIConnection.GetSHAValue(body, secretKey);
            req.Headers.Add("x-obp-signature-body", signaturebody);
            req.Method = "POST";

            byte[] send = Encoding.Default.GetBytes(body);
            Stream sout = req.GetRequestStream();
            sout.Write(send, 0, send.Length);
            sout.Flush();
            sout.Close();

            WebResponse res = req.GetResponse();
            StreamReader sr = new StreamReader(res.GetResponseStream());

            var result = sr.ReadToEnd();
            return result;
        }

        /*
         * @Max - 2018.09
         * 실지명의조회 API
         * */

        public static DbResult GetRealNameCheck(string body)
        {
            var dbResult = new DbResult();

            try
            {
                var url = "/api/realname/name?body=" + body;
                var root = GMEWalletApiBaseUrl + url;

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(root);
                req.ContentType = "application/json";
                req.Headers.Add("Authorization", GetStatic.ReadWebConfig("KJsecretKey", ""));
                req.Headers.Add("HeaderToken", GetStatic.ReadWebConfig("client_id", ""));
                req.Method = "GET";

                var _httpResponse = (HttpWebResponse)req.GetResponse();
                using (var sr = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    var result = sr.ReadToEnd();
                    dbResult = new JavaScriptSerializer().Deserialize<DbResult>(result);

                    _httpResponse.Close();
                    return dbResult;
                }
            }
            catch (Exception e)
            {
                return new DbResult();
            }
        }

        public static DbResult CustomerRegistration(string body)
        {
            var dbResult = new DbResult();
            try
            {
                /*
                 * @Max-2018.09
                 * 파트너서비스 정보등록
                 * */
                var url = "/api/partnerserviceaccount_v2?body=" + body;
                var root = GMEWalletApiBaseUrl + url;

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(root);
                req.ContentType = "application/json";
                req.Headers.Add("Authorization", GetStatic.ReadWebConfig("KJsecretKey", ""));
                req.Headers.Add("HeaderToken", GetStatic.ReadWebConfig("client_id", ""));
                //req.Headers.Add("Authorization", auth.token_type + " " + auth.access_token);
                //string signatureurl = GetSHAValue("GET&" + url, secretKey);
                //req.Headers.Add("x-obp-signature-url", signatureurl);
                //req.Headers.Add("x-obp-partnercode", GetStatic.ReadWebConfig("KJpartnercode", ""));
                req.Method = "GET";

                HttpWebResponse res = (HttpWebResponse)req.GetResponse();
                StreamReader sr = new StreamReader(res.GetResponseStream());
                var result = sr.ReadToEnd();
                dbResult = new JavaScriptSerializer().Deserialize<DbResult>(result);
                OnlineCustomerDao onlineCustomerDao = new OnlineCustomerDao();
                onlineCustomerDao.RequestLog(new JavaScriptSerializer().Serialize((dbResult)));
                res.Close();
                return dbResult;
            }
            catch (WebException wex)
            {
                //resp.Msg = ex.Message;
                //resp.ErrorCode = "1";

                string exMessage = wex.Message;

                if (wex.Response != null)
                {
                    using (StreamReader srException = new StreamReader(wex.Response.GetResponseStream()))
                    {
                        exMessage = srException.ReadToEnd();
                    }
                }
                dbResult.Msg = exMessage;
                dbResult.ErrorCode = "1";
                return dbResult;
            }
        }
    }

    public class AcountTransferToBank
    {
        public string obpId { get; set; }
        public string accountNo { get; set; }
        public string accountPassword { get; set; }
        public string receiveInstitution { get; set; }
        public string receiveAccountNo { get; set; }
        public string amount { get; set; }
    }

    public class PartnerServiceAccountRequest
    {
        public string processDivision { get; set; }
        public string institution { get; set; }
        public string depositor { get; set; }
        public string no { get; set; }
        public string virtualAccountNo { get; set; }
        public string obpId { get; set; }
        public string partnerServiceKey { get; set; }
        public string realNameDivision { get; set; }
        public string realNameNo { get; set; }
    }

    public class PartnerServiceModificationRequest
    {
        public string processDivision { get; set; }
        public string institution { get; set; }
        public string depositor { get; set; }
        public string no { get; set; }
        public string virtualAccountNo { get; set; }
        public string obpId { get; set; }
    }

    public class PartnerServiceAccountResponse
    {
        public string obpId { get; set; }
        public string code { get; set; }
    }

    public class AuthTokenResponse
    {
        public string access_token { get; set; }
        public string token_type { get; set; }
        public string expires_in { get; set; }
        public string scope { get; set; }
    }

    /*
     * @Max-2018.09
     * 실지명의조회 API
     * */

    public class RealNameRequest
    {
        public string institution { get; set; }
        public string no { get; set; }
        public string realNameDivision { get; set; }
        public string realNameNo { get; set; }
    }
}