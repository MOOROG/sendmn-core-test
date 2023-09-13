using System;
using System.Configuration;
using System.Data;
using System.IO;

namespace Swift.DAL.BL.System.Utility
{
    public class Utility : XMLDataTableUtility
    {
        public static string BlankIfNull(string val)
        {
            if (!string.IsNullOrWhiteSpace(val))
            {
                return val;
            }
            return "";
        }
        public static string GetDateInCEReconsileFormat(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToString("dd-MMM-yyyy");
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
        public static string GetDateToShortString(string strDate)
        {
            var date = DateTime.Parse(strDate);
            return date.ToShortDateString();
        }

        public static string ReadWebConfig(string key, string defValue)
        {
            return (ConfigurationSettings.AppSettings[key] ?? defValue);
        }


        #region GIBL API
        public static string GetgblCertName()
        {
            return ReadWebConfig("gblCertName", "");
        }
        public static string GetgblUserid()
        {
            return ReadWebConfig("gbluserid", "");
        }
        public static string GetgblPassword()
        {
            return ReadWebConfig("gblpassword", "");
        }
        public static string GetgblAgentId()
        {
            return ReadWebConfig("gblAgentID", "");
        }
        public static string GetgblCertPath()
        {
            return ReadWebConfig("gblCertPath", "");
        }
        public static string GetgblCertPwd()
        {
            return ReadWebConfig("gblCertPwd", "");
        }
        public static string GetGIBLISOBC()
        {
            return ReadWebConfig("GIBL_ISO_BC", "");
        }
        public static string GetgblAgentIDPay()
        {
            return ReadWebConfig("gblAgentIDPay", "");
        }
        //
        #endregion

        #region CashExpress API
        public static string GetCEAgentId()
        {
            return ReadWebConfig("CEAgentId", "");
        }
        #endregion
        public static string GetxmAgentID()
        {
            return ReadWebConfig("xmAgentID", "");
        }
        #region Email CRedentials
        public static string GetSMTP()
        {
            return ReadWebConfig("smtp", "");
        }
        public static string GetMailFrom()
        {
            return ReadWebConfig("mailFrom", "");
        }
        public static string GetPSW()
        {
            return ReadWebConfig("mailPwd", "");
        }
        public static string GetEnableSSL()
        {
            return ReadWebConfig("enableSSL", "");
        }
        public static string GetPort()
        {
            return ReadWebConfig("port", "");
        }
        #endregion
      public static string GetmgAgentId()
        {
            return ReadWebConfig("mgAgentID", "");
        }



      public static string GetkumariAgentId()
      {
          return ReadWebConfig("kumariBranchMapCode", "");
      }

      internal static string GetkumariPassword()
      {
          return ReadWebConfig("kumaripassword", "");
      }

      internal static string GetkumariUserid()
      {
          return ReadWebConfig("kumariuserid", "");
      }

      internal static string GetkumariAccessCode()
      {
          return ReadWebConfig("kumariAccessCode", "");
      }

      internal static string GetComplienceAmount()
      {
          return ReadWebConfig("kumariComplienceAmt", "");
      }

      public static string GetMaxMoneyAgentId()
      {
          return ReadWebConfig("maxMoneyBranchMapCode", "");
      }
    }

   
    public class XMLDataTableUtility
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
    }
}
