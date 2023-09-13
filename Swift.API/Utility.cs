using System;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using System.Xml.Serialization;

namespace Swift.API
{
	public class Utility
	{
		public static string ReadWebConfig(string key, string defValue)
		{
			return (ConfigurationSettings.AppSettings[key] ?? defValue).ToString();
		}
        public static string ReadSession(string key, string defVal)
        {
            try
            {
                return HttpContext.Current.Session[key] == null ? defVal : HttpContext.Current.Session[key].ToString();
            }
            catch (Exception ex)
            {
                return "";
            }
        }
        public static void WriteSession(string key, string value)
        {
            HttpContext.Current.Session[key] = value;
        }
        public static string GetSocialWallApiAuthKey()
        {
            return ReadWebConfig("socialWallApiAuth", "");
        }
		public static string ArrayToXML(string[] arr)
		{
			XDocument doc = new XDocument();
			doc.Add(new XElement("root", arr.Select(x => new XElement("item", x))));
			return doc.ToString();
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

		public static string GetDateInCEFormat(string strDate)
		{
			var date = DateTime.Parse(strDate);
			return date.ToString("dd/MM/yyyy");
		}

		public static string GetDateInICFormat(string strDate)
		{
			var date = DateTime.Parse(strDate);
			return date.ToString("yyyyMMdd");
		}

		public static string GetDateInMGFormat(string strDate, string type)
		{
			var date = DateTime.Parse(strDate);
			var res = "";
			if (type.ToLower().Equals("t"))
			{
				res = date.ToString("dd.MM.yyyy 23:59:59");
			}
			else
			{
				res = date.ToString("dd.MM.yyyy 00:00:00");
			}
			return res;
		}

		public static string GetDateToShortString(string strDate)
		{
			var date = DateTime.Parse(strDate);
			return date.ToShortDateString();
		}

		public static string GetDateToSqlDate(string strDate)
		{
			var date = DateTime.Parse(strDate);
			return date.ToString("yyyy-MM-dd");
		}

		#region Global Bank Configs

		public static string GetgblUserid()
		{
			return ReadWebConfig("gbluserid", "");
		}

		public static string GetgblPassword()
		{
			return ReadWebConfig("gblpassword", "");
		}

		public static string GetgblpayoutCode()
		{
			return ReadWebConfig("gblpayagentcode", "");
		}

		public static string GetgblAgentId()
		{
			return ReadWebConfig("gblAgentID", "");
		}

		public static string GetgblCertName()
		{
			return ReadWebConfig("gblCertName", "");
		}

		public static string GetgblCertPath()
		{
			return ReadWebConfig("gblCertPath", "");
		}

		public static string GetgblCertPwd()
		{
			return ReadWebConfig("gblCertPwd", "");
		}

		#endregion Global Bank Configs

        public static DbResult LogRequestKFTC(string user, string methodName, string requestXml, string processId = "")
        {
            var db = new Dao();
            if (String.IsNullOrEmpty(requestXml))
                requestXml = "";
            var sql = String.Format("EXEC PROC_KFTC_LOGS @flag='i', @CUSTOMERID='{0}', @methodName='{1}',@requestXml=N'{2}',@processId='{3}'", user, methodName, requestXml.Replace("'", ""), processId);

            return db.ParseDbResult(sql);
        }

        public static DbResult LogResponseKFTC(string rowId, string responseXml, string tpErrorCode, string tpErrorMsg)
        {
            var db = new Dao();
            try
            {
                if (String.IsNullOrEmpty(responseXml))
                    responseXml = "";
                var sql =
                    String.Format(
                        "EXEC PROC_KFTC_LOGS @flag='u', @rowId='{0}',@responseXml=N'{1}', @errorCode='{2}', @errorMessage=N'{3}'",
                        rowId, responseXml.Replace("'", ""), tpErrorCode, tpErrorMsg);

                return db.ParseDbResult(sql);
            }
            catch (Exception)
            {
                return new DbResult();
            }
        }

		public static DbResult LogRequest(string user, string providerName, string methodName, string controlNo, string requestXml, string processId = "")
		{
			if (String.IsNullOrEmpty(requestXml))
				requestXml = "";
			var sql = String.Format("EXEC proc_tpApiLogs @flag='i', @user='{0}', @providerName='{1}', @methodName='{2}',@controlNo='{3}',@requestXml='{4}',@processId='{5}'", user, providerName, methodName, controlNo, requestXml.Replace("'", ""), processId);
			var db = new Dao();
			return db.ParseDbResult(sql);
		}

		public static DbResult LogResponse(string rowId, string responseXml)
		{
			try
			{
				if (String.IsNullOrEmpty(responseXml))
					responseXml = "";
				var sql = String.Format("EXEC proc_tpApiLogs @flag='u', @rowId='{0}',@responseXml='{1}'", rowId,
										responseXml.Replace("'", ""));
				var db = new Dao();
				return db.ParseDbResult(sql);
			}
			catch (Exception)
			{
				return new DbResult();
			}
		}

		public static string ObjectToXML(object input)
		{
			try
			{
				var stringwriter = new StringWriter();
				var serializer = new XmlSerializer(input.GetType());
				serializer.Serialize(stringwriter, input);
				return stringwriter.ToString();
			}
			catch (Exception ex)
			{
				if (ex.InnerException != null)
					ex = ex.InnerException;

				return "Could not convert: " + ex.Message;
			}
		}

		public static string BlankIfNull(string val)
		{
			if (!String.IsNullOrWhiteSpace(val))
			{
				return val;
			}
			return "";
		}

		public static DbResult ValidateRequest(string user, string controlNo)
		{
			var db = new Dao();
			var sql = "EXEC proc_tpApiLogs @flag = 'vr'";
			sql += ", @user = " + db.FilterString(user);
			sql += ", @controlNo = " + db.FilterString(controlNo);

			return db.ParseDbResult(sql);
		}

		public static DbResult LogResponse(string rowId, string responseXml, string tpErrorCode, string tpErrorMsg)
		{
			try
			{
				if (String.IsNullOrEmpty(responseXml))
					responseXml = "";
				var sql =
					String.Format(
						"EXEC proc_tpApiLogs @flag='u', @rowId='{0}',@responseXml='{1}', @errorCode='{2}', @errorMessage='{3}'",
						rowId, responseXml.Replace("'", ""), tpErrorCode, tpErrorMsg);
				var db = new Dao();
				return db.ParseDbResult(sql);
			}
			catch (Exception)
			{
				return new DbResult();
			}
		}
	}
}