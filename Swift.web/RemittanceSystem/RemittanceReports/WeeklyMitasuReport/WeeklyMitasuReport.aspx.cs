using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.IO;
using System.Xml.Serialization;

namespace Swift.web.RemittanceSystem.RemittanceReports.WeeklyMitasuReport
{
    public partial class WeeklyMitasuReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        ImportSettlementRateDao _isd = new ImportSettlementRateDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        protected TranReportDao _dao = new TranReportDao();
        protected ExchangeRateAPIService _map = new ExchangeRateAPIService();
        private string ViewFunctionId = "20190100";
        protected void Page_Load(object sender, EventArgs e)
        {
            var methodName = Request.Form["MethodName"];
            if (methodName == "Recalculate")
                Recalculate();

            if (!IsPostBack)
            {
                Authenticate();
                from.Text = DateTime.Now.ToString("yyyy-MM-dd");
                to.Text = DateTime.Now.ToString("yyyy-MM-dd");
                fromDateCalculate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Recalculate()
        {
            string dateFrom = Request.Form["FromDate"];
            string flag = Request.Form["Flag"];
            DbResult _dbRes = new DbResult();
            if (flag == "SYNC-PAID")
            {
                _dbRes = DownloadInficareData(dateFrom);
            }
            else
            {
                _dbRes = _dao.Recalculate(dateFrom, GetStatic.GetUser(), flag); 
            }

            GetStatic.JsonResponse(_dbRes, this);
        }

        private DbResult DownloadInficareData(string dateFrom)
        {
            var url = "http://agent.jmejapan.com/account/GetTransactionStatus?passKey=jme.com.jp@1934321&DateType=1&dateFrom=" + dateFrom + "&dateTo=" + dateFrom;
            var response = _map.DownloadInficareTransactionForSync(url);
            if (response[0].errorCode == "0")
            {
                var xml = ObjectToXML(response);
                return _isd.SaveTransactionInficare(GetStatic.GetUser(), xml, "SYNC-PAID-MITATSU"); ;
            }
            else
            {
                return new DbResult {
                    ErrorCode = "0",
                    Msg = "Error connecting to inficare system!"
                };
            }
        }

        public string ObjectToXML(object input)
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

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

    }
}