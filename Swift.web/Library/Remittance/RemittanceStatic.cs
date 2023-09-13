using Swift.DAL.Library;
using Swift.DAL.Remittance;
using Swift.DAL.SwiftDAL;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Net.Mail;
using System.Security;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

//using Swift.DAL.BL.Remit.Transaction.MoneyGram;

namespace Swift.web.Library.Remittance
{
    public static class RemittanceStatic
    {
        /*
        public static MoneyGramDao GetMoneyGramInstance()
        {
            MoneyGramDao md = new MoneyGramDao();
            md.SetCredential(GetPointCode(), GetUserLogin(), GetUserPassword());
            return md;
        }

        public static MoneyGramDao GetMoneyGramInstance(string branchId)
        {
            MoneyGramDao md = new MoneyGramDao();

            var sql = "EXEC proc_ws_moneyGramUtility @flag='pointcode'";
            sql += ", @branchId=" + md.FilterString(branchId);
            sql += ", @userType=" + md.FilterString(GetUserType());

            var dr = md.ParseDbResult(sql);

            var pointCode = dr.ErrorCode;
            var userLogin = dr.Msg;
            var userPassword = dr.Id;
            md.SetCredential(pointCode, userLogin, userPassword);
            return md;
        }
        */

        public static string ParseXmlData(string data)
        {
            return SecurityElement.Escape(data);
        }

        public static string GetPointCode()
        {
            return ReadSession("mgPointCode", "");
        }

        public static string GetUserLogin()
        {
            return ReadSession("mgUserLogin", "");
        }

        public static string GetUserPassword()
        {
            return ReadSession("mgUserPassword", "");
        }

        public static string RemoveAllTags(string html)
        {
            var loop = true;
            var pFrom = 0;
            var pTo = 0;
            var refined = html;
            while (loop)
            {
                pFrom = refined.IndexOf("<");
                pTo = refined.IndexOf(">");

                var t = refined.Substring(pFrom, pTo + 1 - pFrom);
                if (string.IsNullOrWhiteSpace(t))
                {
                    return refined.Trim();
                }
                refined = refined.Replace(t, "");
                loop = refined.Contains("<") || refined.Contains(">");
            }

            return refined.Trim();
        }

        public static string CalculateMD5Hash(string input)
        {
            // step 1, calculate MD5 hash from input
            MD5 md5 = MD5.Create();
            byte[] inputBytes = Encoding.ASCII.GetBytes(input);
            byte[] hash = md5.ComputeHash(inputBytes);

            // step 2, convert byte array to hex string
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hash.Length; i++)
            {
                sb.Append(hash[i].ToString("X2"));
            }
            return sb.ToString();
        }

        public static bool HasOnlyDigit(string value)
        {
            var pattern = "0123456789";
            for (var i = 0; i < value.Length; i++)
            {
                if (!pattern.Contains(value.Substring(i, 1)))
                {
                    return false;
                }
            }
            return true;
        }

        public static string GetDateInC2CFormat(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToString("yyyyMMdd");
        }

        public static string GetDateInMGFormat(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToString("dd.MM.yyyy 00:00:00");
        }

        public static DbResult LogError(HttpException lastError, string page, string referer = "")
        {
            Exception err = lastError;
            if (lastError.InnerException != null)
                err = lastError.InnerException;

            var db = new SwiftDao();

            var errPage = db.FilterString(page);
            var errMsg = db.FilterString(err.Message);
            var errDetails = db.FilterString(lastError.GetHtmlErrorMessage());

            var user = GetUser();

            var ipAddress = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
            var dcIdNo = HttpContext.Current.Request.ClientCertificate["SERIALNUMBER"];
            var dcUserName = HttpContext.Current.Request.ClientCertificate["SUBJECTCN"];

            if (string.IsNullOrWhiteSpace(user))
            {
                user = ipAddress;
            }

            string sql = string.Format(@"EXEC proc_ErrorLogs @flag = 'i'
                ,@errorPage={0}, @errorMsg={1}, @errorDetails={2}, @user = {3}, @referer={4}, @ipAddress={5}, @dcUserName={6}, @dcIdNo={7}",
                errPage, errMsg, errDetails, db.FilterString(user), db.FilterString(referer), db.FilterString(ipAddress), db.FilterString(dcUserName), db.FilterString(dcIdNo));

            return db.ParseDbResult(sql);
        }

        public static DbResult GetResultInDbResultFormat(string sql)
        {
            var db = new SwiftDao();
            return db.ParseDbResult(sql);
        }

        public static string GetSingleResult(string sql)
        {
            var db = new SwiftDao();
            return db.GetSingleResult(sql);
        }

        public static double RoundOff(double num, int place, int currDecimal)
        {
            if (currDecimal != 0)
                return Math.Round(num, currDecimal);
            else if (place != 0)
                return (Math.Round(num / place)) * place;
            return Math.Round(num, 0);
        }

        public static double RoundDecimal(double num, int currDecimal)
        {
            return Math.Round(num, currDecimal);
        }

        public static Boolean IsNumeric(string stringToTest)
        {
            int result;
            return int.TryParse(stringToTest, out result);
        }

        public static string ShowVoucherType(string vType)
        {
            var voucher = "";

            vType.ToLower();

            if (vType == "j")
                voucher = "Journal Voucher";
            else if (vType == "c")
                voucher = "Contra Voucher";
            else if (vType == "r")
                voucher = "Receipt Voucher";
            else if (vType == "y")
                voucher = "Payment Voucher";
            else
                voucher = "Voucher Type not defined";

            return voucher;
        }

        #region Userpool

        public static LoggedInUser GetLoggedInUser()
        {
            var userPool = UserPool.GetInstance();
            return userPool.GetUser(GetUser());
        }

        public static string GetAgentId()
        {
            return GetBranch();
        }

        /*
        public static string GetAgentType()
        {
            return GetLoggedInUser().AgentType;
        }

        public static string GetActAsBranchFlag()
        {
            return GetLoggedInUser().IsActAsBranch;
        }
         * */

        public static string GetUserDateTime()
        {
            var db = new SwiftDao();
            var sql = "EXEC proc_MatrixReport @flag = 'udt', @user = '" + GetUser() + "'";
            return db.GetSingleResult(sql);
        }

        public static string GetAgentNameByMapCodeInt(string mapCodeInt)
        {
            var db = new SwiftDao();
            var sql = "SELECT agent_name FROM " + GetUtilityDAO.AccountDbName() + ".dbo.agentTable with(nolock) where map_code = '" + mapCodeInt + "'";
            return db.GetSingleResult(sql);
        }

        public static string GetScRefund(string tranId)
        {
            var db = new SwiftDao();
            var sql = "SELECT dbo.ShowDecimalExceptComma(ISNULL(scRefund,0)) FROM tranCancelrequest WITH(NOLOCK) WHERE tranId=" + tranId + "";
            return db.GetSingleResult(sql);
        }

        public static string GetTellerBalance(string user)
        {
            var db = new SwiftDao();
            var sql = "SELECT dbo.FNAGetTellerBalance('" + user + "')";
            return db.GetSingleResult(sql);
        }

        public static string GetUser()
        {
            var user = ReadSession("admin", "");
            WriteSession("admin", user);
            //WriteSession("lastActiveTS", DateTime.Now.ToString());
            return user;
        }

        public static void SetXmwsSessionID(string xmwsSessionID)
        {
            WriteSession("xmwsSessionID", xmwsSessionID);
        }

        public static string GetXmwsSessionID()
        {
            return ReadSession("xmwsSessionID", "");
        }

        public static string GetUser1()
        {
            var user = ReadSession("admin1", "");
            return user;
        }

        public static void RemoveUserSession()
        {
            WriteSession("admin", "");
        }

        #endregion Userpool

        public static string ToShortDate(string datetime)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(datetime))
                    return "";

                DateTime dt;
                DateTime.TryParse(datetime, out dt);

                return dt.ToShortDateString();
            }
            catch
            {
                return "";
            }
        }

        public static string GetToday()
        {
            return DateTime.Today.ToShortDateString();
        }

        // GetStatic.GetDcId() //41-05-72-dd-00-01-00-00-71-67
        public static string GetDcId()
        {
            return HttpContext.Current.Request.ClientCertificate["SERIALNUMBER"];
        }

        //GetStatic.GetDcUserName() //Basant Tandan (IME-IRH)
        public static string GetDcUserName()
        {
            return HttpContext.Current.Request.ClientCertificate["SUBJECTCN"];
        }

        //GetStatic.GetDcInfo() //41-05-72-dd-00-01-00-00-71-67:Basant Tandan (IME-IRH)

        public static string GetIp()
        {
            return GetLoggedInUser().IPAddress;
            return HttpContext.Current.Request.ClientCertificate["REMOTE_ADDR"];
        }

        public static string GetUserFullName()
        {
            return ReadSession("fullname", "");
        }

        public static string GetCountryId()
        {
            return ReadSession("countryId", "");
        }

        public static string GetCountry()
        {
            return ReadSession("country", "");
        }

        public static string GetBranch()
        {
            return ReadSession("branch", "");
        }

        public static string GetParentId()
        {
            return ReadSession("parentId", "");
        }

        public static string GetBranchName()
        {
            return ReadSession("branchName", "");
        }

        public static string GetAgent()
        {
            return ReadSession("agent", "");
        }

        public static string GetAgentName()
        {
            return ReadSession("agentName", "");
        }

        public static string GetSuperAgent()
        {
            return ReadSession("superAgent", "");
        }

        public static string GetSuperAgentName()
        {
            return ReadSession("superAgentName", "");
        }

        public static string GetSettlingAgent()
        {
            return ReadSession("settlingAgent", "");
        }

        public static string GetMapCodeInt()
        {
            return ReadSession("mapCodeInt", "");
        }

        public static string GetParentMapCodeInt()
        {
            return ReadSession("parentMapCodeInt", "");
        }

        public static string GetMapCodeDom()
        {
            return ReadSession("mapCodeDom", "");
        }

        public static string GetAgentType()
        {
            return ReadSession("agentType", "");
        }

        public static string GetIsActAsBranch()
        {
            return ReadSession("isActAsBranch", "");
        }

        public static string GetUserType()
        {
            return ReadSession("userType", "");
        }

        public static string GetFromSendTrnTime()
        {
            return ReadSession("fromSendTrnTime", "");
        }

        public static string GetToSendTrnTime()
        {
            return ReadSession("toSendTrnTime", "");
        }

        public static string GetFromPayTrnTime()
        {
            return ReadSession("fromPayTrnTime", "");
        }

        public static string GetToPayTrnTime()
        {
            return ReadSession("toPayTrnTime", "");
        }

        public static string GetIsHeadOffice()
        {
            return ReadSession("isHeadOffice", "");
        }

        public static string GetAgentLocation()
        {
            return ReadSession("agentLocation", "");
        }

        public static string GetAgentGroup()
        {
            return ReadSession("agentGrp", "");
        }

        public static string GetSessionId()
        {
            return HttpContext.Current.Session.SessionID;
        }

        public static string GetAgentEmail()
        {
            return ReadSession("agentEmail", "");
        }

        public static string GetAgentPhone()
        {
            return ReadSession("agentPhone", "");
        }

        public static string EncryptPassword(string pwd)
        {
            return pwd;
        }

        #region Read/Write Data

        public static string ReadCookie(string key, string defVal)
        {
            var cookie = HttpContext.Current.Request.Cookies[key];
            return cookie == null ? defVal : HttpContext.Current.Server.HtmlEncode(cookie.Value);
        }

        public static string ReadFormData(string key, string defVal)
        {
            return HttpContext.Current.Request.Form[key] ?? defVal;
        }

        public static string ReadReportFormData(string key, string defVal)
        {
            var prefix = ReadWebConfig("controlNamePrefix");
            return ReadFormData(prefix + key, defVal);
        }

        public static string GetWarningInMiliSec()
        {
            return (ParseInt((ReadWebConfig("idleWarningInSec") ?? "0").ToString()) * 1000).ToString();
        }

        public static string GetCountDownInSec()
        {
            return (ReadWebConfig("countDownInSec") ?? "0").ToString();
        }

        public static string ReadQueryString(string key, string defVal)
        {
            ////string str=HttpContext.Current.Request.QueryString[key] ?? defVal;
            ////str = str.Replace("#", "");
            ////return str;
            return HttpContext.Current.Request.QueryString[key] ?? defVal;
        }

        public static string ReadValue(string gridName, string key)
        {
            key = gridName + "_ck_" + key;
            var ck = ReadCookie(key, "");
            return ck;
        }

        public static void WriteValue(string gridName, ref DropDownList ddl, string key)
        {
            key = gridName + "_ck_" + key;
            WriteCookie(key, ddl.Text);
        }

        public static void WriteValue(string gridName, ref TextBox tb, string key)
        {
            key = gridName + "_ck_" + key;
            WriteCookie(key, tb.Text);
        }

        #endregion Read/Write Data

        public static string ReadSession(string key, string defVal)
        {
            try
            {
                return HttpContext.Current.Session[key] == null ? defVal : HttpContext.Current.Session[key].ToString();
            }
            catch (Exception ex)
            {
                return defVal;
            }
        }

        public static void WriteSession(string key, string value)
        {
            try
            {
                HttpContext.Current.Session[key] = value;
            }
            catch { }
        }

        public static void RemoveSession(string key)
        {
            if (HttpContext.Current.Session[key] == null)
            {
                return;
            }
            HttpContext.Current.Session.Remove(key);
        }

        public static void DeleteCookie(string key)
        {
            if (HttpContext.Current.Request.Cookies[key] != null)
            {
                var aCookie = new HttpCookie(key);
                aCookie.Expires = DateTime.Now.AddDays(-1);
                HttpContext.Current.Response.Cookies.Add(aCookie);
            }
        }

        public static void AttachJSFunction(ref Button ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachJSFunction(ref DropDownList ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachJSFunction(ref TextBox ctl, string evt, string function)
        {
            ctl.Attributes.Add(evt, function);
        }

        public static void AttachConfirmMsg(ref Button ctl)
        {
            AttachConfirmMsg(ref ctl, "Are you sure?");
        }

        public static void AttachConfirmMsg(ref Button ctl, string confirmText)
        {
            var function = "return confirm('" + confirmText + "');";
            ctl.Attributes.Add("onclick", function);
        }

        public static void Process(ref Button ctl)
        {
            var function = "return Process();";
            ctl.Attributes.Add("onclick", function);
        }

        public static void ProcessWithConfirm(ref Button ctl)
        {
            var function = "return ProcessWithConfirm();";
            ctl.Attributes.Add("onclick", function);
        }

        public static void ProcessWithConfirm(ref Button ctl, string msg)
        {
            var function = "return ProcessWithConfirm('" + msg.Replace("'", "").Replace(@"""", "") + "');";
            ctl.Attributes.Add("onclick", function);
        }

        public static void WriteCookie(string key, string value)
        {
            if (string.IsNullOrEmpty(value.Trim()))
            {
                DeleteCookie(key);
                return;
            }

            var httpCookie = new HttpCookie(key, value);
            httpCookie.Expires = DateTime.Now.AddDays(1);
            HttpContext.Current.Response.Cookies.Add(httpCookie);
        }

        public static string FormatData(string data)
        {
            if (string.IsNullOrEmpty(data))
                return "";
            decimal m;
            decimal.TryParse(data, out m);

            return m.ToString("F2");
        }

        public static string FormatData(string data, string dataType)
        {
            if (string.IsNullOrEmpty(data))
                return "&nbsp;";
            dataType = dataType.ToUpper();
            if (data == "-")
                return data;
            if (dataType == "D")
            {
                DateTime d;
                DateTime.TryParse(data, out d);
                return d.Year + "-" + d.Month.ToString("00") + "-" + d.Day.ToString("00");
            }

            if (dataType == "DT")
            {
                DateTime t;
                DateTime.TryParse(data, out t);
                return t.Year + "-" + t.Month.ToString("00") + "-" + t.Day.ToString("00") + " " + t.Hour.ToString("00") + ":" + t.Minute.ToString("00");
            }

            if (dataType == "M")
            {
                decimal m;
                decimal.TryParse(data, out m);

                return m.ToString("N");
            }
            return data;
        }

        public static string FormatDataForForm(string data, string dataType)
        {
            if (string.IsNullOrEmpty(data))
                return "";
            if (data == "-")
                return data;
            if (dataType == "D")
            {
                DateTime d;
                DateTime.TryParse(data, out d);
                return d.Year + "-" + d.Month.ToString("00") + "-" + d.Day.ToString("00");
            }

            if (dataType == "DT")
            {
                DateTime t;
                DateTime.TryParse(data, out t);
                return t.Year + "-" + t.Month.ToString("00") + "-" + t.Day.ToString("00") + " " + t.Hour.ToString("00") + ":" + t.Minute.ToString("00");
            }

            if (dataType == "M")
            {
                decimal m;
                decimal.TryParse(data, out m);

                return m.ToString("N");
            }
            return data;
        }

        public static string NumberToWord(string data1)
        {
            double data = double.Parse(data1);
            var str = data.ToString().Split('.');
            int number = Convert.ToInt32(str[0]);
            int dec = 0;
            if (str.Length > 1)
                if (str[1].Length > 1)
                    dec = Convert.ToInt32(str[1].Substring(0, 2));
                else
                    dec = Convert.ToInt32(str[1]);

            if (number == 0) return "Zero";

            if (number == -2147483648)
                return
                    GetStatic.ReadWebConfig("minusTwoHundred", "");

            int[] num = new int[4];
            int first = 0;
            int u, h, t;
            StringBuilder sb = new System.Text.StringBuilder();

            if (number < 0)
            {
                sb.Append("Minus ");
                number = -number;
            }

            string[] words0 = {
                                  "", "One ", "Two ", "Three ", "Four ",
                                  "Five ", "Six ", "Seven ", "Eight ", "Nine "
                              };

            string[] words1 = {
                                  "Ten ", "Eleven ", "Twelve ", "Thirteen ", "Fourteen ",
                                  "Fifteen ", "Sixteen ", "Seventeen ", "Eighteen ", "Nineteen "
                              };

            string[] words2 = {
                                  "Twenty ", "Thirty ", "Forty ", "Fifty ", "Sixty ",
                                  "Seventy ", "Eighty ", "Ninety "
                              };

            string[] words3 = { "Thousand ", "Lakh ", "Crore " };

            num[0] = number % 1000;               // units
            num[1] = number / 1000;
            num[2] = number / 100000;
            num[1] = num[1] - 100 * num[2];       // thousands
            num[3] = number / 10000000;           // crores
            num[2] = num[2] - 100 * num[3];       // lakhs

            for (int i = 3; i > 0; i--)
            {
                if (num[i] != 0)
                {
                    first = i;
                    break;
                }
            }

            for (int i = first; i >= 0; i--)
            {
                if (num[i] == 0) continue;

                u = num[i] % 10;  // ones
                t = num[i] / 10;
                h = num[i] / 100; // hundreds
                t = t - 10 * h;   // tens

                if (h > 0) sb.Append(words0[h] + "Hundred ");

                if (u > 0 || t > 0)
                {
                    if (h > 0 && i == 0) sb.Append("");

                    if (t == 0)
                        sb.Append(words0[u]);
                    else if (t == 1)
                        sb.Append(words1[u]);
                    else
                        sb.Append(words2[t - 2] + words0[u]);
                }

                if (i != 0) sb.Append(words3[i - 1]);
            }
            //int d1 = dec / 10;
            //int d2 = dec % 10;
            //if (d1 == 0)
            //    sb.Append(words0[d1]);
            //else if (d1 == 1)
            //    sb.Append(words1[d2]);
            //else
            //    sb.Append(words2[d1 - 2] + words0[d2]);

            //if (dec > 0)
            //{
            //    sb.Append(" And ");
            //    sb.Append(words0[dec]);
            //    sb.Append(" Paisa");
            //}

            return sb.ToString().TrimEnd() + " only";
        }

        public static string NumberToWord(string data, string currName, string currDecimal)
        {
            var str = data.Split('.');
            int number = Convert.ToInt32(str[0]);
            int dec = 0;
            if (str.Length > 1)
                dec = Convert.ToInt32(str[1].Substring(0, 2));

            if (number == 0) return "Zero";

            if (number == -2147483648)
                return
                    GetStatic.ReadWebConfig("minusTwoHundred", "");

            int[] num = new int[4];
            int first = 0;
            int u, h, t;
            StringBuilder sb = new System.Text.StringBuilder();

            if (number < 0)
            {
                sb.Append("Minus ");
                number = -number;
            }

            string[] words0 = {
                                  "", "One ", "Two ", "Three ", "Four ",
                                  "Five ", "Six ", "Seven ", "Eight ", "Nine "
                              };

            string[] words1 = {
                                  "Ten ", "Eleven ", "Twelve ", "Thirteen ", "Fourteen ",
                                  "Fifteen ", "Sixteen ", "Seventeen ", "Eighteen ", "Nineteen "
                              };

            string[] words2 = {
                                  "Twenty ", "Thirty ", "Forty ", "Fifty ", "Sixty ",
                                  "Seventy ", "Eighty ", "Ninety "
                              };

            //string[] words3 = { "Thousand ", "Lakh ", "Crore " };

            string[] words3 = { "Thousand ", "Million ", "Billion " };
            num[0] = number % 1000;           // units
            num[1] = number / 1000;
            num[2] = number / 1000000;
            num[1] = num[1] - 1000 * num[2];  // thousands
            num[3] = number / 1000000000;     // billions
            num[2] = num[2] - 1000 * num[3];  // millions
            for (int i = 3; i > 0; i--)
            {
                if (num[i] != 0)
                {
                    first = i;
                    break;
                }
            }

            //for (int i = first; i >= 0; i--)
            //{
            //    if (num[i] == 0) continue;
            //    u = num[i] % 10;              // ones
            //    t = num[i] / 10;
            //    h = num[i] / 100;             // hundreds
            //    t = t - 10 * h;               // tens
            //    if (h > 0) sb.Append(words0[h] + "Hundred ");
            //    if (u > 0 || t > 0)
            //    {
            //        if (h > 0 || i < first) sb.Append("and ");
            //        if (t == 0)
            //            sb.Append(words0[u]);
            //        else if (t == 1)
            //            sb.Append(words1[u]);
            //        else
            //            sb.Append(words2[t - 2] + words0[u]);
            //    }
            //    if (i != 0) sb.Append(words3[i - 1]);
            //}

            //num[0] = number % 1000;               // units
            //num[1] = number / 1000;
            //num[2] = number / 100000;
            //num[1] = num[1] - 100 * num[2];       // thousands
            //num[3] = number / 10000000;           // crores
            //num[2] = num[2] - 100 * num[3];       // lakhs

            //for (int i = 3; i > 0; i--)
            //{
            //    if (num[i] != 0)
            //    {
            //        first = i;
            //        break;
            //    }
            //}

            for (int i = first; i >= 0; i--)
            {
                if (num[i] == 0) continue;

                u = num[i] % 10;  // ones
                t = num[i] / 10;
                h = num[i] / 100; // hundreds
                t = t - 10 * h;   // tens

                if (h > 0) sb.Append(words0[h] + "Hundred ");

                if (u > 0 || t > 0)
                {
                    if (h > 0 && i == 0) sb.Append("and ");
                    //if (h > 0 || i < first) sb.Append("and ");
                    //if (h > 0) sb.Append("and ");
                    if (t == 0)
                        sb.Append(words0[u]);
                    else if (t == 1)
                        sb.Append(words1[u]);
                    else
                        sb.Append(words2[t - 2] + words0[u]);
                }

                if (i != 0) sb.Append(words3[i - 1]);
            }

            sb.Append(" " + currName + " ");

            int d1 = dec / 10;
            int d2 = dec % 10;
            if (d1 == 0)
                sb.Append(words0[d1]);
            else if (d1 == 1)
                sb.Append(words1[d2]);
            else
                sb.Append(words2[d1 - 2] + words0[d2]);

            if (dec > 0 && !string.IsNullOrEmpty(currDecimal))
                sb.Append(" " + currDecimal);
            return sb.ToString().TrimEnd() + " only";
        }

        #region Read From Web Config

        public static string GetHoAgentId()
        {
            return ReadWebConfig("hoAgentId");
        }

        public static string GetDomesticCountryId()
        {
            return ReadWebConfig("domesticCountryId");
        }

        public static string GetDomesticSuperAgentId()
        {
            return ReadWebConfig("domesticSuperAgentId");
        }

        public static string GetAcSystemUrl()
        {
            return ReadWebConfig("acSystemUrl");
        }

        public static string GetGBLAPIUrl()
        {
            return ReadWebConfig("GBLAPIUrl");
        }

        public static string GetGBLAPIUsername()
        {
            return ReadWebConfig("GBLAPIUsername");
        }

        public static string GetGBLAPIPwd()
        {
            return ReadWebConfig("GBLAPIPwd");
        }

        public static string GetIsApiFlag()
        {
            return ReadWebConfig("isAPI");
        }

        public static string GetAppRoot()
        {
            return ReadWebConfig("root");
        }

        public static string GetFilePath()
        {
            return ReadWebConfig("filePath");
        }

        public static string TXNDocumentUploadPath()
        {
            return ReadWebConfig("txnDocumentUploadPath");
        }

        public static string GetUrlRoot()
        {
            return ReadWebConfig("urlRoot");
        }

        public static string GetJQuerySubmitURL()
        {
            return GetUrlRoot() + "/SwiftSystem/Utility/jquerySubmit.aspx";
        }

        public static string GetVirtualDirName()
        {
            return ReadWebConfig("virtualDirName");
        }

        public static string GetIMEMalaysiaAgentId()
        {
            return ReadWebConfig("imeMalaysiaAgentId");
        }

        public static string GetTranNoName()
        {
            return ReadWebConfig("tranNoName");
        }

        public static string GetCurrencyList()
        {
            return ReadWebConfig("currencyList");
        }

        public static string GetParent()
        {
            return ReadWebConfig("parent");
        }

        public static string GetDBUrlRoot()
        {
            return ReadWebConfig("dbUrlRoot");
        }

        public static string GetDBRoot()
        {
            return ReadWebConfig("dbRoot");
        }

        public static string GetReportPagesize()
        {
            return ReadWebConfig("reportPageSize");
        }

        public static string GetAdminReportRoot()
        {
            return ReadWebConfig("adminReport");
        }

        public static string GetAgentReportRoot()
        {
            return ReadWebConfig("agentReport");
        }

        #endregion Read From Web Config

        public static DataTable GetHistoryChangedListForFunction(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForFunction(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForRole(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForRole(oldData, newData);
        }

        /*
        public static DataTable GetHistoryChangedListForTellerLimit(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForTellerLimit(oldData, newData);
        }*/

        public static DataTable GetHistoryChangedListForAgent(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForAgent(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForRuleCriteria(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForRuleCriteria(oldData, newData);
        }

        public static DataTable GetHistoryChangedListForIdCriteria(string oldData, string newData, string id)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            return applicationLogsDao.GetAuditDataForIdCriteria(oldData, newData, id);
        }

        //public static DataTable GetHistoryChangedListForSendingAmountThreshold(string oldData, string newData)
        //{
        //    var applicationLogsDao = new ApplicationLogsDao();
        //    return applicationLogsDao.GetAuditDataForSendingAmountThreshold(oldData, newData);
        //}
        public static DataTable GetHistoryChangedListForCommissionPackage(string oldData, string newData)
        {
            var applicationLogsDao = new ApplicationLogsDao();
            if (string.IsNullOrEmpty(oldData))
                oldData = newData;
            if (string.IsNullOrEmpty(newData))
                newData = oldData;
            return applicationLogsDao.GetAuditDataForCommissionPackage(oldData, newData);
        }

        public static DataTable GetHistoryChangedList(string logType, string oldData, string newData)
        {
            var stringSeparators = new[] { "-:::-" };

            var oldDataList = oldData.Split(stringSeparators, StringSplitOptions.None);
            var newDataList = newData.Split(stringSeparators, StringSplitOptions.None);

            var dt = new DataTable();
            var col1 = new DataColumn("Field");
            var col2 = new DataColumn("Old Value");
            var col3 = new DataColumn("New Value");
            var col4 = new DataColumn("hasChanged");

            dt.Columns.Add(col1);
            dt.Columns.Add(col2);
            dt.Columns.Add(col3);
            dt.Columns.Add(col4);

            var colCount = newData == "" ? oldDataList.Length : newDataList.Length;

            for (var i = 0; i < colCount; i++)
            {
                var changeList = ParseChangesToArray(logType, (oldData == "") ? "" : oldDataList[i], (newData == "") ? "" : newDataList[i]);

                var row = dt.NewRow();
                row[col1] = changeList[0];
                row[col2] = changeList[1];
                row[col3] = changeList[2];

                if (changeList[1] == changeList[2])
                {
                    row[col4] = "N";
                }
                else
                {
                    row[col4] = "Y";
                }
                dt.Rows.Add(row);
            }
            return dt;
        }

        public static DataTable GetStringToTable(string data)
        {
            var stringSeparators = new[] { "-:::-" };

            var dataList = data.Split(stringSeparators, StringSplitOptions.None);

            var dt = new DataTable();
            var col1 = new DataColumn("field1");
            var col2 = new DataColumn("field2");
            var col3 = new DataColumn("field3");

            dt.Columns.Add(col1);
            dt.Columns.Add(col2);
            dt.Columns.Add(col3);

            var colCount = dataList.Length;

            for (var i = 0; i < colCount; i++)
            {
                var changeList = dataList[i].Split('=');
                var changeListCout = changeList.Length;
                var value1 = changeListCout > 0 ? changeList[0].Trim() : "";
                var value2 = changeListCout > 1 ? changeList[1].Trim() : "";
                var value3 = changeListCout > 2 ? changeList[2].Trim() : "";

                var row = dt.NewRow();
                row[col1] = value1;
                row[col2] = value2;
                row[col3] = value3;

                dt.Rows.Add(row);
            }
            return dt;
        }

        private static string[] ParseChangesToArray(string logType, string oldData, string newData)
        {
            const string seperator = "=";
            var oldValue = "";
            var newValue = "";
            var field = "";

            if (logType.ToLower() == "insert" || logType.ToLower() == "i" || logType.ToLower() == "update" || logType.ToLower() == "u" || logType.ToLower() == "login fails" || logType.ToLower() == "log in")
            {
                var seperatorPos = newData.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    field = newData.Substring(0, seperatorPos - 1).Trim();
                    newValue = newData.Substring(seperatorPos + 1).Trim();
                }
            }

            if (logType.ToLower() == "delete" || logType.ToLower() == "d" || logType.ToLower() == "update" || logType.ToLower() == "u")
            {
                var seperatorPos = oldData.IndexOf(seperator);
                if (seperatorPos > -1)
                {
                    if (field == "")
                        field = oldData.Substring(0, seperatorPos - 1).Trim();

                    oldValue = oldData.Substring(seperatorPos + 1).Trim();
                }
            }
            return new[] { field, oldValue, newValue };
        }

        public static DbResult GetPasswordStatus()
        {
            DbResult dr = null;
            if (HttpContext.Current.Session["passwordStatus"] != null)
            {
                dr = (DbResult)HttpContext.Current.Session["passwordStatus"];
            }
            return dr;
        }

        public static void SetPasswordStatus(DbResult dr)
        {
            HttpContext.Current.Session["passwordStatus"] = dr;
        }

        public static string GetUserName()
        {
            var identityArray = HttpContext.Current.User.Identity.Name.Split('\\');
            return identityArray.Length > 1 ? identityArray[1] : identityArray[0];
        }

        public static string GetDefaultPage()
        {
            switch (ReadCookie("loginType", "").ToUpper())
            {
                case "ADMIN":
                    return GetUrlRoot() + "/admin";

                case "AGENT":
                    return GetUrlRoot() + "/agentlogin";
            }

            return GetUrlRoot();
        }

        public static string GetLogoutPage()
        {
            return GetUrlRoot() + "/Logout.aspx";
        }

        public static string GetErrorPage()
        {
            return GetUrlRoot() + "/Error.aspx";
        }

        public static string GetAuthenticationPage()
        {
            return GetUrlRoot() + "/Authentication.aspx";
        }

        public static string NoticeMessage
        {
            get { return ReadSession("message", ""); }
            set { WriteSession("message", value); }
        }

        public static string DataTable2ExcelXML(ref DataTable dt)
        {
            var date = DateTime.Now.Date.ToString("yyyy-MM-dd");
            var header = new StringBuilder("");

            header.AppendLine("<?xml version=\"1.0\"?>");
            header.AppendLine("<?mso-application progid=\"Excel.Sheet\"?>");
            header.AppendLine("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"");
            header.AppendLine("xmlns:o=\"urn:schemas-microsoft-com:office:office\"");
            header.AppendLine("xmlns:x=\"urn:schemas-microsoft-com:office:excel\"");
            header.AppendLine("xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"");
            header.AppendLine("xmlns:html=\"http://www.w3.org/TR/REC-html40\">");
            header.AppendLine("<DocumentProperties xmlns=\"urn:schemas-microsoft-com:office:office\">");
            header.AppendLine("<Created>" + date + "</Created>");
            header.AppendLine("<LastSaved>" + date + "</LastSaved>");
            header.AppendLine("<Version>12.00</Version>");
            header.AppendLine("</DocumentProperties>");
            header.AppendLine("<OfficeDocumentSettings xmlns=\"urn:schemas-microsoft-com:office:office\">");
            header.AppendLine("<RemovePersonalInformation/>");
            header.AppendLine("</OfficeDocumentSettings>");
            header.AppendLine("<ExcelWorkbook xmlns=\"urn:schemas-microsoft-com:office:excel\">");
            header.AppendLine("<WindowHeight>8010</WindowHeight>");
            header.AppendLine("<WindowWidth>14805</WindowWidth>");
            header.AppendLine("<WindowTopX>240</WindowTopX>");
            header.AppendLine("<WindowTopY>105</WindowTopY>");
            header.AppendLine("<ProtectStructure>False</ProtectStructure>");
            header.AppendLine("<ProtectWindows>False</ProtectWindows>");
            header.AppendLine("</ExcelWorkbook>");
            header.AppendLine("<Styles>");
            header.AppendLine("<Style ss:ID=\"Default\" ss:Name=\"Normal\">");
            header.AppendLine("<Alignment ss:Vertical=\"Bottom\"/>");
            header.AppendLine("<Borders/>");
            header.AppendLine("<Font ss:FontName=\"Calibri\" x:Family=\"Swiss\" ss:Size=\"11\" ss:Color=\"#000000\"/>");
            header.AppendLine("<Interior/>");
            header.AppendLine("<NumberFormat/>");
            header.AppendLine("<Protection/>");
            header.AppendLine("</Style>");
            header.AppendLine("<Style ss:ID=\"s16\">");
            header.AppendLine(" <NumberFormat ss:Format=\"@\"/>");
            header.AppendLine("</Style>");
            header.AppendLine("</Styles>");
            header.AppendLine("<Worksheet ss:Name=\"Sheet1\">");
            header.AppendLine("<Table  ss:ExpandedColumnCount=\"{columns}\" ss:ExpandedRowCount=\"{rows}\" x:FullColumns=\"1\" x:FullRows=\"1\" ss:DefaultRowHeight=\"15\">");

            var footer = new StringBuilder("");
            footer.AppendLine("</Table>");
            footer.AppendLine("<WorksheetOptions xmlns=\"urn:schemas-microsoft-com:office:excel\">");
            footer.AppendLine("<PageSetup>");
            footer.AppendLine("<Header x:Margin=\"0.3\"/>");
            footer.AppendLine("<Footer x:Margin=\"0.3\"/>");
            footer.AppendLine("<PageMargins x:Bottom=\"0.75\" x:Left=\"0.7\" x:Right=\"0.7\" x:Top=\"0.75\"/>");
            footer.AppendLine("</PageSetup>");
            footer.AppendLine("<Print>");
            footer.AppendLine("<ValidPrinterInfo/>");
            footer.AppendLine("<HorizontalResolution>300</HorizontalResolution>");
            footer.AppendLine("<VerticalResolution>300</VerticalResolution>");
            footer.AppendLine("</Print>");
            footer.AppendLine("<Selected/>");
            footer.AppendLine("<Panes>");
            footer.AppendLine("<Pane>");
            footer.AppendLine("<Number>3</Number>");
            footer.AppendLine("<ActiveRow>1</ActiveRow>");
            footer.AppendLine("</Pane>");
            footer.AppendLine("</Panes>");
            footer.AppendLine("<ProtectObjects>False</ProtectObjects>");
            footer.AppendLine("<ProtectScenarios>False</ProtectScenarios>");
            footer.AppendLine("</WorksheetOptions>");
            footer.AppendLine("</Worksheet>");
            footer.AppendLine("</Workbook>");

            const string dataTemplate = "<Cell ss:StyleID=\"s16\"><Data ss:Type=\"String\">{data}</Data></Cell>";

            var body = new StringBuilder("");

            var columnCount = dt.Columns.Count;
            body.AppendLine("<Row>");
            for (var i = 0; i < columnCount; i++)
            {
                body.AppendLine(dataTemplate.Replace("{data}", dt.Columns[i].ColumnName));
            }
            body.AppendLine("</Row>");

            foreach (DataRow dr in dt.Rows)
            {
                body.AppendLine("<Row>");
                for (var i = 0; i < columnCount; i++)
                {
                    body.AppendLine(dataTemplate.Replace("{data}", dr[i].ToString()));
                }
                body.AppendLine("</Row>");
            }

            header.AppendLine(body.ToString());
            header.AppendLine(footer.ToString());

            return header.ToString().Replace("{rows}", (dt.Rows.Count + 1).ToString()).Replace("{columns}",
                                                                                         dt.Columns.Count.ToString());
        }

        public static string ReadWebConfig(string key)
        {
            return ReadWebConfig(key, "");
        }

        public static string ReadWebConfig(string key, string defValue)
        {
            return ConfigurationManager.AppSettings[key] ?? defValue;
        }

        public static string PutYellowBackGround(string mes)
        {
            return "<span style = \"background-color : yellow\">" + mes + "</span>";
        }

        public static string PutRedBackGround(string mes)
        {
            return "<span style = \"background-color : red\">" + mes + "</span>";
        }

        public static string PutBlueBackGround(string mes)
        {
            return "<span style = \"background-color : blue\">" + mes + "</span>";
        }

        public static string PutHalfYellowBackGround(string mes)
        {
            return "<span style = \"background-color : #FFA822\">" + mes + "</span>";
        }

        public static long ReadNumericDataFromQueryString(string key)
        {
            var tmpId = ReadQueryString(key, "0");
            long tmpIdLong;
            long.TryParse(tmpId, out tmpIdLong);
            return tmpIdLong;
        }

        public static decimal ReadDecimalDataFromQueryString(string key)
        {
            var tmpId = ReadQueryString(key, "0");
            decimal tmpIdDecimal;
            decimal.TryParse(tmpId, out tmpIdDecimal);
            return tmpIdDecimal;
        }

        public static void SetActiveMenu(string menuFunctionId)
        {
            HttpContext.Current.Session["activeMenu"] = menuFunctionId;
        }

        public static void ResizeFrame(Page page)
        {
            CallBackJs1(page, "Resize Iframe", "window.parent.resizeIframe();");
        }

        /// <summary>
        /// Set DbResult in Session
        /// </summary>
        public static void SetMessage(DbResult value)
        {
            HttpContext.Current.Session["message"] = value;
        }

        /// <summary>
        /// Set Error Code and Message in Session
        /// </summary>
        /// <param name="errorCode">Error Code</param>
        /// <param name="msg">Message</param>
        public static void SetMessage(string errorCode, string msg)
        {
            var dbResult = new DbResult { ErrorCode = errorCode, Msg = msg };
            SetMessage(dbResult);
        }

        /// <summary>
        /// Jquery Print Message from session
        /// </summary>
        public static void PrintMessage(Page page)
        {
            if (HttpContext.Current.Session["message"] == null)
            {
                return;
            }

            var dbResult = GetMessage();
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + dbResult.Msg + "\",\"" + dbResult.ErrorCode + "\");");
            HttpContext.Current.Session.Remove("message");
        }

        /// <summary>
        /// Jquery Print Message from DbResult
        /// </summary>
        public static void PrintMessage(Page page, DbResult dbResult)
        {
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + dbResult.Msg + "\",\"" + dbResult.ErrorCode + "\");");
        }

        public static void PrintMessage1(Page page, DbResult dbResult)
        {
            CallBackJs3(page, "Set Message", "window.parent.parent.SetMessageBox(\"" + dbResult.Msg + "\",\"" + dbResult.ErrorCode + "\");");
        }

        /// <summary>
        /// Jquery Print Message directly passing Error Code and Message
        /// </summary>
        public static void PrintMessage(Page page, string errorCode, string msg)
        {
            CallBackJs1(page, "Set Message", "window.parent.SetMessageBox(\"" + msg + "\",\"" + errorCode + "\");");
        }

        public static void PrintSuccessMessage(Page page, string msg)
        {
            PrintMessage(page, "0", msg);
        }

        public static void PrintErrorMessage(Page page, string msg)
        {
            PrintMessage(page, "1", msg);
        }

        /// <summary>
        /// Alert Message from session
        /// </summary>
        public static void AlertMessage(Page page)
        {
            if (HttpContext.Current.Session["message"] == null)
                return;
            var dbResult = GetMessage();
            if (dbResult.Msg == "")
                return;
            CallBackJs1(page, "Alert Message", "alert(\"" + FilterMessageForJs(dbResult.Msg) + "\");");
            HttpContext.Current.Session.Remove("message");
        }

        /// <summary>
        /// Alert Message directly passing Message
        /// </summary>
        public static void AlertMessage(Page page, string msg)
        {
            CallBackJs1(page, "Alert Message", "RemoveProcessDivWithMsg(\"" + FilterMessageForJs(msg) + "\");");
        }

        public static void ShowSuccessMessage(string msg)
        {
            HttpContext.Current.Server.Transfer(GetVirtualDirName() + "/PrintMessage.aspx?errorCode=0&msg=" + msg);
        }

        public static void ShowErrorMessage(string msg)
        {
            HttpContext.Current.Server.Transfer(GetVirtualDirName() + "/PrintMessage.aspx?errorCode=1&msg=" + msg);
        }

        public static string GetActiveMenu()
        {
            return ReadSession("activeMenu", "");
        }

        public static string GetBoolToChar(bool chk)
        {
            return chk ? "Y" : "N";
        }

        public static bool GetCharToBool(string value)
        {
            return value.ToUpper() == "Y" ? true : false;
        }

        public static DbResult GetMessage()
        {
            return (DbResult)HttpContext.Current.Session["message"];
        }

        public static void Redirect(Page page, string url)
        {
            page.ClientScript.RegisterStartupScript(typeof(string), "script", "<script language = 'javascript'>Redirect('" + url + "');</script>");
        }

        public static void CloseDialog(Page page, string returnValue)
        {
            page.ClientScript.RegisterStartupScript(typeof(string), "scriptClose", "<script language = 'javascript'>CloseDialog('" + returnValue + "');</script>");
        }

        public static bool VerifyMode()
        {
            return ReadQueryString("mode", "") == "verify" ? true : false;
        }

        public static String ShowDecimal(String strVal)
        {
            if (strVal != "")
                return String.Format("{0:0,0.00}", double.Parse(strVal));
            else
                return strVal;
        }

        public static String ShowDecimal4(String strVal)
        {
            if (strVal != "")
                return String.Format("{0:0,0.0000}", double.Parse(strVal));
            else
                return strVal;
        }

        public static string GetRowData(DataRow dr, string fieldName, string defValue)
        {
            return dr == null ? defValue : dr[fieldName].ToString();
        }

        public static string GetRowData(DataRow dr, string fieldName)
        {
            return GetRowData(dr, fieldName, "");
        }

        public static string GetRowDataInShortDateFormat(DataRow dr, string fieldName)
        {
            return dr[fieldName].ToString() == "" ? "" : Convert.ToDateTime(dr[fieldName].ToString()).ToShortDateString();
        }

        public static string ParseResultJsPrint(DbResult dbResult)
        {
            return dbResult.ErrorCode + "-:::-" + dbResult.Msg + "-:::-" + dbResult.Id;
        }

        public static void CallBackJs1(Page page, String scriptName, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), scriptName, functionName, true);
        }

        public static void CallBackJs3(Page page, String scriptName, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), scriptName, functionName, true);
        }

        public static void CallJSFunction(Page page, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), "cb", functionName, true);
        }

        public static void CallBackJs2(Page page, string scriptName, string functionName)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), scriptName, functionName, true);
        }

        public static double ParseDouble(string value)
        {
            double tmp;
            double.TryParse(value, out tmp);
            return tmp;
        }

        public static int ParseInt(string value)
        {
            int tmp;
            int.TryParse(value, out tmp);
            return tmp;
        }

        public static string DataTableToCheckBox(DataTable dt, string name, string valueField, string textField)
        {
            var sb = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine("<input type = \"checkbox\" name = \"" + name + "\" value = \"" + row[valueField] +
                              "\" />" + row[textField] + " <br />");
            }

            return sb.ToString();
        }

        public static string ParseMinusValue(double data)
        {
            var retVal = Math.Abs(data).ToString("N");
            if (data < 0)
            {
                return "(" + retVal + ")";
            }
            return retVal;
        }

        public static string ParseMinusValue(string data)
        {
            var m = ParseDouble(data);

            return ParseMinusValue(m);
        }

        public static string GetFullName(string firstName, string middleName, string lastName1, string lastName2)
        {
            var fullName = firstName;
            if (!string.IsNullOrWhiteSpace(middleName))
                fullName += " " + middleName;
            if (!string.IsNullOrWhiteSpace(lastName1))
                fullName += " " + lastName1;
            if (!string.IsNullOrEmpty(lastName2))
                fullName += " " + lastName2;

            return fullName;
        }

        public static FullName ParseName(string fullName)
        {
            var fn = new FullName();
            var name = fullName.Split(' ');
            var names = name.Length;
            fn.FirstName = name[0];
            fn.MiddleName = "";
            fn.LastName1 = "";
            fn.LastName2 = "";
            if (names > 1)
            {
                fn.LastName1 = name[1];
                if (names > 2)
                {
                    fn.MiddleName = name[1];
                    fn.LastName1 = name[2];
                    if (names > 3)
                        fn.LastName2 = name[3];
                    if (names > 4)
                        fn.LastName2 += " " + name[4];
                }
            }
            return fn;
        }

        public static DbResult CheckSlab(string pcnt, string minAmt, string maxAmt)
        {
            //bool PreError = false;
            var dbResult = new DbResult();
            if ((pcnt == "" ? "0" : pcnt) != "0")
            {
                if ((minAmt == "" ? "0" : minAmt) == "0" || (maxAmt == "" ? "0" : maxAmt) == "0")
                {
                    dbResult.Id = "1";
                    dbResult.Msg = "Please set Min or Max Amt ..";
                    //PreError = true;
                }
            }
            else if ((pcnt == "" ? "0" : pcnt) == "0" && (minAmt == "" ? "0" : minAmt) == "0")
            {
                dbResult.Id = "1";
                dbResult.Msg = "Please set Min Amt ..";
                //PreError = true;
            }

            return dbResult;
        }

        //DateTime dt = GetStatic.GMTDatetime();
        public static DateTime GMTDatetime()
        {
            System.DateTime CurrTime = System.DateTime.Now;
            System.DateTime CurrUTCTime = CurrTime.ToUniversalTime();
           //var dt1 = CurrUTCTime.AddMinutes(45);
            var dt1 = CurrUTCTime.AddMinutes(545);
            return dt1;
        }

        public static DateTime GetDateInNepalTz()
        {
            DateTime saveUtcNow = DateTime.UtcNow.AddMinutes(545);
           // DateTime saveUtcNow = DateTime.UtcNow.AddMinutes(345);
            return saveUtcNow;
        }

        public static String FilterMessageForJs(string strVal)
        {
            if (strVal.ToLower() != "null")
            {
                strVal = strVal.Replace("\"", "");
            }

            return strVal;
        }

        public static void ReloadJQueryDatePicket(Page p, string textBoxName)
        {
            CallBackJs1(p, "ajax", "AsyncDone('#" + textBoxName + "');");
            //This script handles ajax postbacks, by registering the js to run at the end of *AJAX* requests
            //p.ClientScript.RegisterStartupScript(typeof(Page), "ajaxTrigger", "Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);", true);
            //p.ClientScript.RegisterClientScriptBlock(typeof(Page), "EndRequest", "function EndRequestHandler(sender, args){" + callBack + ";}", true);
        }

        /// <summary>
        /// </summary>
        /// <param name="page"></param>
        /// <param name="controlNo"></param>
        /// <param name="message"></param>
        /// <param name="successMessageType">1 - Jquery Message, 2 - Js Alert Message</param>

        public static string GetCountryFlag(string countryCode)
        {
            var html = "<img src=\"" + GetUrlRoot() + "/images/countryflag/" + countryCode + ".png" + "\" border=\"0\">";
            return html;
        }

        public static string ParseMGError(string msg)
        {
            return ParseMGError("", msg);
        }

        public static string ParseMGError(string errorType, string msg)
        {
            return ParseMGText(msg).Replace("\"", "`").Replace("'", "`").Replace("\n", "");
        }

        private static string ParseMGText(string str)
        {
            var res = ParseMGTextHelper(ParseMGTextHelper(str, true), false).Trim();
            if (string.IsNullOrEmpty(res))
            {
                return str;
            }

            return res;
        }

        private static string ParseMGTextHelper(string str, bool reverse)
        {
            var pos = -1;
            var findText = "  at";
            if (reverse)
            {
                while (true)
                {
                    pos = str.LastIndexOf(findText);
                    if (pos < 0) break;
                    str = str.Substring(0, pos);
                }
            }
            else
            {
                findText = "Arguments has errors:";
                pos = str.LastIndexOf(findText);
                if (pos < 0)
                {
                    findText = "MG.ClientException:";
                    pos = str.LastIndexOf(findText);
                }

                if (pos < 0)
                {
                    findText = "Novatech.SW.BaseException:";
                    pos = str.LastIndexOf(findText);
                }
                if (pos > 0)
                {
                    str = str.Substring(pos + 1 + findText.Length);
                }
            }

            return str;
        }

        public static string GetAgentCountry(string agentId)
        {
            var db = new SwiftDao();
            var sql = "EXEC proc_transactionUtility @flag='ac', @user=" + db.FilterString(GetUser()) + ", @agentId=" + db.FilterString(agentId);
            return db.GetSingleResult(sql);
        }

        public static string GetSendingCountryBySCurr(string sCurr)
        {
            var db = new SwiftDao();
            var sql = "EXEC proc_transactionUtility @flag='sCountry', @user=" + db.FilterString(GetUser()) + ", @curr=" + db.FilterString(sCurr);
            return db.GetSingleResult(sql);
        }

        private static bool IsValidEmailAdd(string emailaddress)
        {
            try
            {
                var m = new MailAddress(emailaddress);
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        private static bool IsValidEmailAdd(string emailaddress, ref List<MailAddress> addList)
        {
            try
            {
                foreach (var itm in emailaddress.Split(';'))
                {
                    if (IsValidEmailAdd(itm))
                        addList.Add(new MailAddress(itm));
                }
                return (addList.Count > 0);
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public static DbResult SendEmail(ref string mailTo, string replyToAddress, string cc, string bcc, string subject, string bodyOfMail, string attachment, string importance, string flag = "smtpCredential")
        {
            var obj = new SystemEmailSetupDao();
            DbResult dr = new DbResult();
            var dtRow = obj.GetSmtpCredential(GetUser(), flag);
            if (dtRow == null)
            {
                dr.SetError("1", "SMTP Server Not Found", "");
                return dr;
            }
            string smtp = dtRow["smtpServer"].ToString();// ReadWebConfig("smtp");
            string mailFrom = dtRow["sendID"].ToString();// ReadWebConfig("mailFrom");
            string pwd = dtRow["sendPSW"].ToString();//ReadWebConfig("mailPwd");
            bool enableSSL = dtRow["enableSsl"].ToString().ToLower().Equals("y");// ReadWebConfig("enableSSL").ToLower().Equals("true");
            int port = int.Parse(dtRow["smtpPort"].ToString()); //Convert.ToInt16(string.IsNullOrWhiteSpace(ReadWebConfig("port")) ? "0" : ReadWebConfig("port"));

            try
            {
                bool boolTo = false;
                bool boolCC = false;
                bool boolBCC = false;
                List<MailAddress> MailToList = new List<MailAddress>();
                List<MailAddress> CCList = new List<MailAddress>();
                List<MailAddress> BCCList = new List<MailAddress>();
                boolTo = IsValidEmailAdd(mailTo, ref MailToList);
                boolCC = IsValidEmailAdd(cc, ref CCList);
                boolBCC = IsValidEmailAdd(bcc, ref BCCList);

                if (!boolTo && !boolCC && !boolBCC)
                {
                    dr.ErrorCode = "1";
                    dr.Msg = "Invalid email addresses";
                    return dr;
                }

                if (!boolTo)
                {
                    mailTo = cc;
                    MailToList = CCList;
                    boolTo = boolCC;
                    boolCC = false;
                }

                if (!boolTo)
                {
                    mailTo = bcc;
                    MailToList = BCCList;
                    boolTo = boolBCC;
                    boolBCC = false;
                }

                MailMessage oMail = new MailMessage();
                oMail.From = new MailAddress(mailFrom);
                oMail.Body = bodyOfMail;
                oMail.Subject = subject;

                if (boolTo)
                {
                    foreach (MailAddress itm in MailToList)
                    {
                        oMail.To.Add(itm);
                    }
                }

                //= New MailMessage(mailFrom, mailTo, subject, bodyOfMail) ' //first your adress, then the person you want to send it to. This order is important!
                SmtpClient oClient = new SmtpClient(smtp);
                // //this is where the difference is made between hotmail, gmail, and others.
                oMail.IsBodyHtml = true;

                if (boolCC)
                {
                    foreach (MailAddress itm in CCList)
                    {
                        oMail.CC.Add(itm);
                    }
                }
                if (boolBCC)
                {
                    foreach (MailAddress itm in BCCList)
                    {
                        oMail.Bcc.Add(itm);
                    }
                }
                if (!string.IsNullOrEmpty(attachment))
                {
                    oMail.Attachments.Add(new Attachment(attachment));
                }

                if (IsValidEmailAdd(replyToAddress))
                {
                    oMail.ReplyTo = new MailAddress(replyToAddress);
                }

                oClient.Port = port;
                // //you could use port 21.. but alot of spam gets send trough here, so it's blocked
                // by many ISPs
                oClient.Credentials = new System.Net.NetworkCredential(mailFrom, pwd);
                oClient.EnableSsl = enableSSL;
                oClient.Send(oMail);
                dr.ErrorCode = "0";
                dr.Msg = "Email Sent Successfully.";
                return dr;
            }
            catch (Exception ex)
            {
                dr.Msg = ex.Message;
                if (dr.Msg.ToLower().StartsWith("mailbox unavailable"))
                {
                    dr.ErrorCode = "10";
                }
                else
                {
                    dr.ErrorCode = "1";
                }
                return dr;
            }
        }

        public static string GetAgentNameFromAgentId(string agentId)
        {
            var db = new SwiftDao();
            var sql = "EXEC proc_transactionUtility @flag='agentNameFromAgentId', @user=" + db.FilterString(GetUser()) + ", @agentId=" + db.FilterString(agentId);
            return db.GetSingleResult(sql);
        }

        public static string GetMapCodeIntFromAgentId(string agentId)
        {
            var db = new SwiftDao();
            var sql = "SELECT mapCodeInt FROM agentMaster am WITH(NOLOCK) WHERE am.agentId = " + agentId + "";
            return db.GetSingleResult(sql);
        }

        public static string GetProfileUpdateFlag()
        {
            var db = new SwiftDao();
            var sql = "EXEC proc_agentProfileUpdate @flag = 'check-update'";
            sql += ", @user =" + db.FilterString(GetUser());
            sql += ", @agentId  = " + db.FilterString(GetAgentId());
            return db.GetSingleResult(sql);
        }

        public static string GetOFACSDN()
        {
            return ReadWebConfig("OFAC_SDN");
        }

        public static string GetOFACALT()
        {
            return ReadWebConfig("OFAC_ALT");
        }

        public static string GetOFACADD()
        {
            return ReadWebConfig("OFAC_ADD");
        }

        public static string GetOFACUNSCR()
        {
            return ReadWebConfig("OFAC_UNSCR");
        }

        public static bool ToImage(this string value)
        {
            value = value.ToLower();
            if (!value.Contains("."))
            {
                value = "." + value;
            }
            if (value == ".jpeg" || value == ".jpg" || value == ".png" || value == ".gif" || value == ".bmp")
                return true;
            else
            {
                return false;
            }
        }
    }
}