using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.Send.SendRegional
{
    public partial class Send : System.Web.UI.Page
    {
        private readonly SendTransactionDao _obj = new SendTransactionDao();
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private const string ViewFunctionId = "40102700";
        private const string AddEditFunctionId = "40102710";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            _sl.CheckSendTransactionAllowedTime();
            PopulateDdl();
            deliveryMethod.Focus();
            transferAmt.Attributes.Add("onchange", "LoadServiceCharge()");
            deliveryMethod.Attributes.Add("onchange", "ManageDeliveryMethod()");
            bankName.Attributes.Add("onchange", "PopulateBankBranch()");
            if (!IsPostBack)
            {
                #region Ajax methods

                string reqMethod = Request.Form["MethodName"];
                switch (reqMethod)
                {
                    case "SearchCustomer":
                        CustomerSearchLoadData();
                        break;

                    case "LoadImages":
                        LoadImages();
                        break;
                }

                #endregion Ajax methods
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateSender(DataRow dr)
        {
            _sl.SetDDL(ref sIdType, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5201'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "idType"), "Select");
        }

        private void PopulateReceiver(DataRow dr)
        {
            _sl.SetDDL(ref rIdType, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5202'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "idType"), "");
        }

        private void RelWithSender()
        {
            _sl.SetStaticDdl2(ref relWithSender, "2100", "", "Select");
        }

        private void PopulateDdl()
        {
            PopulateLocation();
            PopulateDistrict();
            PopulateBankName();
            PopulateSender(null);
            PopulateReceiver(null);
            RelWithSender();
            _sl.SetDDL2(ref deliveryMethod, "EXEC proc_serviceTypeMaster @flag='l3'", "typeTitle", "", "");

            _sl.SetDDL(ref sBranch, "EXEC proc_agentMaster @flag = 'rblByAId2',@agentType= "
                    + _sl.FilterString(GetStatic.GetAgentType()) + " ,@parentId=" + _sl.FilterString(GetStatic.GetAgent()), "agentId", "agentName", "", "Select");

            _sl.SetStaticDdl(ref por, "3800", "", "Select");
            _sl.SetStaticDdl(ref sof, "3900", "", "Select");
            _sl.SetStaticDdl(ref occupation, "2000", "", "Select");
        }

        private void PopulateBankName()
        {
            _sl.SetDDL(ref bankName, "EXEC proc_agentMaster @flag = 'banklist'", "agentId", "agentName", "", "Select");
        }

        private void PopulateDistrict()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'd'";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"district\" class=\"form-control\" onchange=\"PopulateLocation();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"district\" class=\"form-control\" onchange=\"PopulateLocation();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["districtId"] + "\">" + dr["districtName"] + "</option>");
            }
            html.Append("</select>");
            divDistrict.InnerHtml = html.ToString();
        }

        private void PopulateLocation()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'll'";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"location\" class=\"form-control\" onchange=\"PopulateDistrict();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"location\" class=\"form-control\" onchange=\"PopulateDistrict();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["locationId"] + "\">" + dr["locationName"] + "</option>");
            }
            html.Append("</select>");
            divLocation.InnerHtml = html.ToString();
        }

        private void CustomerSearchLoadData()
        {
            string customerCardNumber = Request.Form["customerCardNumber"];
            DataTable dt = _obj.GetCustomer(GetStatic.GetUser(), customerCardNumber);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadImages()
        {
            string customerId = Request.Form["customerId"];
            DataTable dt = _obj.GetCustomerImagesAgent(GetStatic.GetUser(), customerId);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }
    }
}