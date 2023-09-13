using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.Administration.BankAccNumberUpload
{
    public partial class List : System.Web.UI.Page
    {
        private VoucherGeneration Dao = new VoucherGeneration();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnFileUpload_Click(object sender, EventArgs e)
        {
            var fName = fileUpload.FileName;
            var fPath = Server.MapPath("~/doc/BankandVirtualAccNumberUpload/" + fName);
            var fExtension = System.IO.Path.GetExtension(fName);
            var fSize = fileUpload.PostedFile.ContentLength;
            if (fileUpload.HasFile)
            {
                if (fileUpload.FileContent.Length > 0)
                {
                    if (fSize > GetStatic.ReadWebConfig("csvFileSize").ToInt()) // to avoid DOS attack put filesize restriction
                    {
                        msgSuccess.Visible = false;
                        msg.Visible = true;
                        msg.InnerText = "Maximum file size (2MB) exceeded";
                    }
                    else
                    {
                        //if (fileUpload.FileName.ToLower().Contains(".csv")) // my be file Name like  abcsv.csv.doc
                        if (fExtension.ToLower() != ".csv")
                        {
                            msgSuccess.Visible = false;
                            msg.Visible = true;
                            msg.InnerText = "Only files with .csv extension are allowed";
                        }
                        else
                        {
                            fileUpload.SaveAs(fPath);
                            var xml = GetStatic.GetCSVFileInTable(fPath, true);
                            DbResult res = Dao.UploadXMLDatas(xml, GetStatic.GetUser());

                            if (res.ErrorCode == "0")
                            {
                                msg.Visible = false;
                                msgSuccess.Visible = true;
                                msgSuccess.InnerText = res.Msg;
                            }
                            else
                            {
                                msgSuccess.Visible = false;
                                msg.Visible = true;
                                msg.InnerText = res.Msg;
                            }
                        }
                    }
                }
                else
                {
                    msgSuccess.Visible = false;
                    msg.Visible = true;
                    msg.InnerText = "Empty files are not allowed to upload";
                }
            }
            else
            {
                msgSuccess.Visible = false;
                msg.Visible = true;
                msg.InnerText = "Please Select a file to upload";
            }
        }
    }
}