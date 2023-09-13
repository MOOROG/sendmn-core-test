using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.web.Component.AutoCompleteCustom
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.Web.Script.Services.ScriptService]
    public class DataSourceCustom : System.Web.Services.WebService
    {

        bool isRemit = false;
        [WebMethod]
        public List<ValueTextPair> GetList(string category, string searchText)
        {
            return MakeList(category, "", "", "", searchText);
        }

        [WebMethod]
        public List<ValueTextPair> GetRemittanceList(string category, string searchText)
        {
            isRemit = true;
            return MakeList(category, "", "", "", searchText);

        }

        [WebMethod]
        public List<ValueTextPair> GetList1(string category, string param1, string searchText)
        {
            return MakeList(category, param1, "", "", searchText);
        }
        [WebMethod]
        public List<ValueTextPair> GetList2(string category, string param1, string param2, string searchText)
        {
            return MakeList(category, param1, param2, "", searchText);
        }
        [WebMethod]
        public List<ValueTextPair> GetList3(string category, string param1, string param2, string param3, string searchText)
        {
            return MakeList(category, param1, param2, param3, searchText);
        }

        private List<ValueTextPair> MakeList(string category, string param1, string param2, string param3, string searchText)
        {


            var itemList = new List<ValueTextPair>();
            var db = new SwiftDao();
            var dbremit = new RemittanceDao();
           var sql = "EXEC proc_autocomplete @category=" + db.FilterString(category);
            sql += ", @searchText=" + db.FilterString(searchText);

            if (!string.IsNullOrWhiteSpace(param1))
            {
                sql += ", @param1=" + db.FilterString(param1);
            }

            if (!string.IsNullOrWhiteSpace(param2))
            {
                sql += ", @param2=" + db.FilterString(param2);
            }

            if (!string.IsNullOrWhiteSpace(param3))
            {
                sql += ", @param3=" + db.FilterString(param3);
            }

            var dt = new DataTable();

            string cat = category.Split('-')[0];
            if (cat.ToLower() == "remit")
            {
                sql = sql.Replace("remit-", "");
                dt = dbremit.ExecuteDataset(sql).Tables[0];
            }
            else
                dt = db.ExecuteDataset(sql).Tables[0];

            //if (category == "acInfo" || category == "acInfoUSD")
            //    dt = db.ExecuteDataset(sql).Tables[0];
            //else
            //    dt = dbremit.ExecuteDataset(sql).Tables[0];

            foreach (DataRow row in dt.Rows)
            {
                itemList.Add(new ValueTextPair(row[0].ToString(), row[1].ToString()));
            }
            if (dt.Rows.Count == 0 && param1 == "NotClear")
            {
                itemList.Add(new ValueTextPair(searchText, searchText));
            }
            return itemList;
        }
    }

    public class ValueTextPair
    {
        public string Id;
        public string Value;

        public ValueTextPair(string id, string value)
        {
            Id = id;
            Value = value;
        }
        public ValueTextPair() { }
    }
}

