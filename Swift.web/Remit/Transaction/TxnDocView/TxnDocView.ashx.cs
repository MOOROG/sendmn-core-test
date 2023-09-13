using Swift.web.Library;
using System;
using System.IO;
using System.Web;

namespace Swift.web.Remit.Transaction.TxnDocView
{
    /// <summary>
    /// Summary description for TxnDocView
    /// </summary>
    public class TxnDocView : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var createdDate = context.Request.QueryString["txnDate"];
            var controlNo = context.Request.QueryString["controlNo"];
            DateTime txnDate = Convert.ToDateTime(createdDate);

            string fileUrl = GetStatic.GetCustomerFilePath() + "Transaction\\CustomerSignature\\" + txnDate.Year.ToString() + "\\" + txnDate.Month.ToString() + "\\" + txnDate.Day.ToString() + "\\" + controlNo + ".png";

            if (File.Exists(fileUrl))
                context.Response.ContentType = fileUrl;
            else
                context.Response.ContentType = Path.Combine(GetStatic.ReadWebConfig("root", ""), "Images", "na.gif");

            context.Response.WriteFile(context.Response.ContentType);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}