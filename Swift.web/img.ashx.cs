using Swift.web.Library;
using System;
using System.IO;
using System.Web;

namespace Swift.web
{
    /// <summary>
    /// Summary description for img
    /// </summary>
    public class img : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                var id = context.Request.QueryString["id"];
                var functionId = context.Request.QueryString["functionId"];
                var imgPath = GetStatic.GetAppRoot() + @"\Images\na.gif";

                var primaryFilePath = GetStatic.GetAppRoot() + @"\doc\" + id;

                var defaultDocPath = GetStatic.GetDefaultDocPath() + @"\doc\" + id;

                var docFolder = context.Request.QueryString["df"];
                var doctype = (null != context.Request.QueryString["type"]) ? context.Request.QueryString["type"] : "";
                if (doctype.ToLower() == "txn")
                {
                    if (docFolder == "")
                        primaryFilePath = GetStatic.GetFilePath() + "TxnDocUpload\\" + id;
                    else
                        primaryFilePath = GetStatic.GetFilePath() + "TxnDocUpload\\" + docFolder + "\\" + id;
                }
                if (doctype.ToLower() == "txntmp")
                    primaryFilePath = GetStatic.GetFilePath() + "TxnDocUploadTmp\\" + id;

                var secondaryFilePath = "";
                if (functionId == "20181400")
                    secondaryFilePath = GetStatic.GetFilePath() + @"\doc\CreditSecurity\" + id;
                else if (functionId == "20182130")
                    secondaryFilePath = GetStatic.GetFilePath() + @"\ReconcilationDoc\" + id;
                else if (functionId == "10111100")
                    secondaryFilePath = GetStatic.GetFilePath() + @"\PopupMessage\" + id;
                else if (functionId == "vdoc")
                {
                    id = id.Replace("../", "");
                    id = id.Replace("doc", "");
                    secondaryFilePath = GetStatic.GetFilePath() + id;
                }
                else
                    secondaryFilePath = GetStatic.GetFilePath() + @"\doc\" + id;

                if (File.Exists(primaryFilePath) || File.Exists(secondaryFilePath) || File.Exists(defaultDocPath))
                {
                    imgPath = (File.Exists(primaryFilePath)) ? primaryFilePath : secondaryFilePath;

                    if (!File.Exists(imgPath))
                    {
                        imgPath = defaultDocPath;
                    }
                }

                if (imgPath.ToLower().EndsWith(".pdf"))
                {
                    context.Response.ContentType = "application/pdf";
                }
                else
                {
                    context.Response.ContentType = "image/png";
                }
                context.Response.WriteFile(imgPath);
            }
            catch (Exception ex)
            {
            }
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