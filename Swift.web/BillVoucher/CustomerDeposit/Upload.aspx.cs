using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.BillVoucher.CustomerDeposit
{
    public partial class Upload : System.Web.UI.Page
    {
        private string ViewFunctionId = "20302300";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        AccountStatementDAO cavDao = new AccountStatementDAO();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();

            var methodName = Request.Form["MethodName"];
            if (methodName == "UploadVoucher")
                UploadVoucher();
            if (methodName == "CheckData")
                CheckData();
        }

        private void CheckData()
        {
            var xml = Request.Form["XmlData"];
            xml = xml.Replace("&lt;", "<");
            xml = xml.Replace("&gt;", ">");

            DbResult _dbRes = cavDao.CheckUploadVoucher(GetStatic.GetUser(), xml);

            GetStatic.JsonResponse(_dbRes, this);
        }

        private void UploadVoucher()
        {
            var xml = Request.Form["XmlData"];
            xml = xml.Replace("&lt;", "<");
            xml = xml.Replace("&gt;", ">");

            DataTable dt = cavDao.UploadVoucher(GetStatic.GetUser(), GetStatic.GetSessionId(), xml);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = GetStatic.DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}