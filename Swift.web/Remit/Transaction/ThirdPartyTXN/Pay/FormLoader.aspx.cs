using System;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Data;
using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.Pay
{
    public partial class FormLoader : System.Web.UI.Page
    {
        private readonly SendTransactionDao _obj = new SendTransactionDao();
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            _rl.CheckSession();
            ReturnValue();
        }

        private string GetQueryType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private void ReturnValue()
        {
            switch (GetQueryType())
            {
                case "rPayThirdParty":
                    LoadThirdParyReceiver();
                    break;
            }
        }

        private void LoadThirdParyReceiver()
        {
            string memId = GetStatic.ReadQueryString("memId", "");
            var dt = _obj.GetMemberFromPayForThirdParty(GetStatic.GetUser(), memId);
            if (dt.Rows.Count == 0)
                return;
            var jSon = GetJson(dt);
            Response.Write(jSon);
        }

        public string GetJson(DataTable dt)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            List<Dictionary<string, object>> rows =
              new List<Dictionary<string, object>>();
            Dictionary<string, object> row = null;

            foreach (DataRow dr in dt.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row.Add(col.ColumnName.Trim(), dr[col]);
                }
                rows.Add(row);
            }
            return serializer.Serialize(rows);
        }
    }
}