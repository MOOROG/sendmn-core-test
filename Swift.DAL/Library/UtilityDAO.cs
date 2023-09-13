using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.Library {
  public static class GetUtilityDAO {
    public static string AccountDbName() {
      var dbname = ConfigurationManager.AppSettings["accountDbName"].ToString();
      return dbname;
    }

    public static string RemitDbName() {
      var dbname = ConfigurationManager.AppSettings["remitDbName"].ToString();
      return dbname;
    }
    public static String ShowDecimal(String strVal) {
      if(strVal != "")
        return String.Format("{0:0,0.00}", double.Parse(strVal));
      else
        return strVal;
    }
  }
}