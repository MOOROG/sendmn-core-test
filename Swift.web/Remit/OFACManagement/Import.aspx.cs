using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Xml;
using Swift.DAL.BL.Remit.OFACManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.OFACManagement
{
    public partial class Import : System.Web.UI.Page
    {
        private OFACDao obj = new OFACDao();
        private const string ViewFunctionId = "20211000";
        private string root = GetStatic.GetAppRoot();
        private string directory;

        RemittanceLibrary rl = new RemittanceLibrary();

        public Import()
        {
            directory = root + "doc";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadLogGrid();
            LoadSourceWiseData();
        }
        private void Authenticate()
        {
            rl.CheckAuthentication(ViewFunctionId);
        }
        protected void btnImport_Click(object sender, EventArgs e)
        {
            var dbResult = new DbResult();
            try
            {
                /*
                GetSDNContent("http://www.treasury.gov/ofac/downloads/sdn.pip");
                GetALTContent("http://www.treasury.gov/ofac/downloads/alt.pip");
                GetADDContent("http://www.treasury.gov/ofac/downloads/add.pip");
                */

                GetSDNContent(GetStatic.GetOFACSDN());
                GetALTContent(GetStatic.GetOFACALT());
                GetADDContent(GetStatic.GetOFACADD());


                DivMessage.InnerHtml = "File Download Completed !";
            }
            catch (Exception ex)
            {
                dbResult.SetError("1", "Server Response : " + ex, "");
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.PrintMessage(this.Page);
                GetStatic.PrintMessage(Page);
                LoadLogGrid();
            }
            else
            {
                GetStatic.SetMessage(dbResult.Msg, "1");
                return;
            }
        }


        private void ReadUNSCRFile(string URL)
        {
            XmlDocument xDoc = new XmlDocument();
            xDoc.Load(URL);
            if (!Directory.Exists(directory + "\\OFAC"))
                Directory.CreateDirectory(directory + "\\OFAC");
            string filPath = GetStatic.GetAppRoot() + "doc\\OFAC\\AQList.xml";
            xDoc.Save(filPath);
        }

        private void GetSDNContent(string URL)
        {
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(URL);
            myRequest.Method = WebRequestMethods.Http.Get;
            WebResponse myResponse = myRequest.GetResponse();
            StreamReader sr = new StreamReader(myResponse.GetResponseStream(), System.Text.Encoding.UTF8);
            string line;

            string fileToCreate = directory + "\\OFAC\\SDN.pip";

            if (!Directory.Exists(directory +"\\OFAC"))
                Directory.CreateDirectory(directory + "\\OFAC");

            using (var file = new StreamWriter(fileToCreate))
            {
                while ((line = sr.ReadLine()) != null)
                {
                    file.WriteLine(line);
                }
            }

            //Eliminate Last Line
            var lines = File.ReadAllLines(fileToCreate);
            File.WriteAllLines(fileToCreate, lines.Take(lines.Length - 1).ToArray());

            sr.Close();
            myResponse.Close();
        }

        private void GetALTContent(string URL)
        {
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(URL);
            myRequest.Method = "GET";
            WebResponse myResponse = myRequest.GetResponse();
            StreamReader sr = new StreamReader(myResponse.GetResponseStream(), System.Text.Encoding.UTF8);
            string line;

            string fileToCreate = directory + "\\OFAC\\ALT.pip";

            if (!Directory.Exists(directory +"\\OFAC"))
                Directory.CreateDirectory(directory + "\\OFAC");

            using (var file = new StreamWriter(fileToCreate))
            {
                while ((line = sr.ReadLine()) != null)
                {
                    file.WriteLine(line);
                }
            }

            var lines = File.ReadAllLines(fileToCreate);
            File.WriteAllLines(fileToCreate, lines.Take(lines.Length - 1).ToArray());

            sr.Close();
            myResponse.Close();
        }

        private void GetADDContent(string URL)
        {
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(URL);
            myRequest.Method = "GET";
            WebResponse myResponse = myRequest.GetResponse();
            StreamReader sr = new StreamReader(myResponse.GetResponseStream(), System.Text.Encoding.UTF8);
            string line;

            string fileToCreate = directory +"\\OFAC\\ADD.pip";

            if (!Directory.Exists(directory + "\\OFAC"))
                Directory.CreateDirectory(directory + "\\OFAC");

            using (var file = new StreamWriter(fileToCreate))
            {
                while ((line = sr.ReadLine()) != null)
                {
                    file.WriteLine(line);
                }
            }
            var lines = File.ReadAllLines(fileToCreate);
            File.WriteAllLines(fileToCreate, lines.Take(lines.Length - 1).ToArray());

            sr.Close();
            myResponse.Close();
        }

        private void LoadLogGrid()
        {
            DataTable dt = obj.LoadLog(GetStatic.GetUser());
            rpt_grid.InnerHtml = Misc.DataTableToHtmlTable(ref dt);
        }

        private void LoadSourceWiseData()
        {
            DataTable dt = obj.LoadSourceWiseData(GetStatic.GetUser());
            SourceWiseData.InnerHtml = Misc.DataTableToHtmlTable(ref dt);
        }

        private void LoadAQLogGrid()
        {
            DataTable dt = obj.LoadLog(GetStatic.GetUser());
            rpt_grid.InnerHtml = Misc.DataTableToHtmlTable(ref dt);
        }


        protected void BtnImpAQList_Click(object sender, EventArgs e)
        {
            //ReadUNSCRFile("http://www.un.org/sc/committees/1267/AQList.xml");
            ReadUNSCRFile(GetStatic.GetOFACUNSCR());
            DivMessage.InnerHtml = "File Download Completed !";
        }
        private string GetUNSCRData()
        {
           
            var aqFilePath = GetStatic.GetAppRoot() + "doc\\OFAC\\AQList.xml";
            FileWebRequest myRequest = (FileWebRequest)WebRequest.Create(aqFilePath);
            myRequest.Method = "GET";
            WebResponse myResponse = myRequest.GetResponse();

            StreamReader sr = new StreamReader(myResponse.GetResponseStream(), System.Text.Encoding.UTF8);
            string xmlContent = sr.ReadToEnd().Trim();

            xmlContent = xmlContent.Replace("'", "");
            xmlContent = xmlContent.Replace("utf-8", "utf-16");
            xmlContent = xmlContent.Replace("UTF-8", "UTF-16");
            xmlContent = xmlContent.Replace("&amp", "and");

            return xmlContent;
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string xmlContent = GetUNSCRData();
            var dbResult = obj.UpdateAQList(GetStatic.GetUser(), xmlContent, "AQList.xml");
            ManageMessage(dbResult);
            DivMessage.InnerHtml = dbResult.Msg;

            LoadAQLogGrid();

        }

        protected void btnLoadOfac_Click(object sender, EventArgs e)
        {

            var dbResult = new DbResult();
            var sdnFilePath = GetStatic.GetAppRoot() + "doc\\OFAC\\SDN.pip";
            var altFilePath = GetStatic.GetAppRoot() + "doc\\OFAC\\ALT.pip";
            var addFilePath = GetStatic.GetAppRoot() + "doc\\OFAC\\ADD.pip";

            dbResult = obj.Update(GetStatic.GetUser(), sdnFilePath, altFilePath, addFilePath);

            ManageMessage(dbResult);
            DivMessage.InnerHtml = dbResult.Msg;
        }

        protected void Button1_Click(object sender, EventArgs e)
        {

            var dbResult = new DbResult();

            //import from inficare DB
            dbResult = obj.UpdateOther(GetStatic.GetUser());

            ManageMessage(dbResult);
            DivMessage.InnerHtml = dbResult.Msg;
        }
    }
}