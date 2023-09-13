using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Security;
using System.Xml.Serialization;

namespace Swift.DAL.BL.Helper.ThirdParty
{
    public class ApiUtility : XMLDataTableUtilityAPI
    {
        public static string GetDateToSqlDate(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToString("yyyy-MM-dd");
        }

        public static string GetDateInCEFormat(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToString("dd/MM/yyyy");
        }

        public static string GetDateToShortString(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToShortDateString();
        }

        public static string ReadWebConfig(string key, string defValue)
        {
            return (ConfigurationSettings.AppSettings[key] ?? defValue);
        }

        public static string ParseToValidXMLData(string data)
        {
            return SecurityElement.Escape(data);
        }

        public static ApiResult LogRequest(string user, string providerName, string methodName, string controlNo, string requestXml)
        {
            try
            {
                var sql = string.Format("EXEC proc_tpApiLogs @flag='i', @user={0}, @providerName='{1}', @methodName='{2}',@controlNo='{3}',@requestXml='{4}'", user, providerName, methodName, controlNo, requestXml.Replace("'", ""));
                var db = new Dao();
                return db.ParseDbResult(sql);
            }
            catch (Exception)
            {
                return new ApiResult();
            }
        }

        public static ApiResult LogResponse(string rowId, string responseXml, string errorCode, string errorMessage)
        {
            try
            {
                var db = new Dao();
                var sql = string.Format("EXEC proc_tpApiLogs @flag='u', @rowId='{0}',@responseXml='{1}',@errorCode='{2}',@errorMessage={3}", rowId, responseXml.Replace("'", ""), errorCode, db.FilterString(errorMessage));
                return db.ParseDbResult(sql);
            }
            catch (Exception)
            {
                return new ApiResult();
            }
        }

        public static ApiResult LogDataError(string rowId, string errorCode, string errorMessage)
        {
            try
            {
                var db = new Dao();
                var sql = string.Format("EXEC proc_tpApiLogs @flag='e', @rowId='{0}',@errorCode='{1}',@errorMessage={2}", rowId, errorCode, db.FilterString(errorMessage));
                return db.ParseDbResult(sql);
            }
            catch (Exception)
            {
                return new ApiResult();
            }
        }
    }

    public class XMLDataTableUtilityAPI
    {
        public static DataTable ParseXMLToDataTable(string xml)
        {
            if (string.IsNullOrWhiteSpace(xml))
            {
                return null;
            }
            DataSet ds = ParseXMLToDataSet(xml);
            if (ds == null || ds.Tables.Count == 0)
                return null;

            return ds.Tables[0];
        }

        public static DataSet ParseXMLToDataSet(string xml)
        {
            if (string.IsNullOrWhiteSpace(xml))
            {
                return null;
            }

            DataSet ds = new DataSet(); ;
            using (StringReader r = new StringReader(xml))
            {
                ds.ReadXml(r);
            }

            return ds;
        }

        public static DataRow ParseXMLToDataRow(string xml)
        {
            DataTable dt = ParseXMLToDataTable(xml);
            if (dt == null || dt.Rows.Count == 0)
                return null;

            return dt.Rows[0];
        }

        public static string GetDataRowData(ref DataRow dr, string colName, string defVal)
        {
            if (ColumnExists(ref dr, colName))
            {
                return (dr[colName] ?? defVal).ToString();
            }
            return "";
        }

        public static string GetDataRowData(ref DataRow dr, string colName)
        {
            return GetDataRowData(ref dr, colName, "");
        }

        protected static bool ColumnExists(ref DataRow dr, string colName)
        {
            foreach (DataColumn dc in dr.Table.Columns)
            {
                if (dc.ColumnName.ToUpper().Equals(colName.ToUpper()))
                {
                    return true;
                }
            }
            return false;
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
    }
}