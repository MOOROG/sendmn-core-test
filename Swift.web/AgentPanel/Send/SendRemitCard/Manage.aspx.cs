using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.GlobalBankCard;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.Send.SendRemitCard
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly GlobalBankCardDao _obj = new GlobalBankCardDao();
        private const string ViewFunctionId = "40102600";
        private const string ProcessFunctionId = "40102610";

        protected void Page_Load(object sender, EventArgs e)
        {
            //Authenticate();
            _sdd.CheckSendTransactionAllowedTime();
            LoadAvailableAccountBalance();
            remitCardNo.Focus();
            if (!Page.IsPostBack)
            {
                #region Ajax methods

                string reqMethod = Request.Form["MethodName"];
                switch (reqMethod)
                {
                    case "sc":
                        CalculateServiceCharge();
                        break;

                    case "lc":
                        LoadCustomer();
                        break;
                }

                #endregion Ajax methods

                PopulateDdl();
            }
            tAmt.Attributes.Add("onchange", "CalculateServiceCharge()");
        }

        private void LoadAvailableAccountBalance()
        {
            var obj = new SendTransactionDao();
            DataRow dr = obj.GetAcDetail(GetStatic.GetUser(), GetStatic.GetSettlingAgent());
            if (dr == null)
            {
                availableAmt.Text = "N/A";
                return;
            }
            availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
        }

        protected void CalculateServiceCharge()
        {
            var sBranch = GetStatic.GetBranch();
            var settlingAgent = GetStatic.GetSettlingAgent();
            string transferAmt = Request.Form["tAmt"];

            DataTable dt = _obj.GetServiceCharge(GetStatic.GetUser(), sBranch, settlingAgent, transferAmt);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        private void PopulateDdl()
        {
            _sdd.SetStaticDdl2(ref purpose, "3800", "", "Select");
            _sdd.SetStaticDdl2(ref sourceOfFund, "3900", "", "Select");
            _sdd.SetDDL(ref senderIdType, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5201'", "detailTitle", "detailTitle", "", "Select");
        }

        public string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        private void LoadCustomer()
        {
            var rCardNo = Request.Form["remitCardNo"];
            DataTable dt = _obj.GetCardHolderInfo(GetStatic.GetUser(), rCardNo);
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