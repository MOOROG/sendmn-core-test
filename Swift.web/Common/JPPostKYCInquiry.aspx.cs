using OpenQA.Selenium.Chrome;
using Swift.web.Library;
using System;
using System.IO;
using System.Net;
using System.Threading;

namespace Swift.web.Common
{
    public partial class JPPostKYCInquiry : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "GetTrackingInfo")
                GetKYCStatus();
        }

        protected string GetTranckingNumber()
        {
            return GetStatic.ReadQueryString("tranckingNumber", "");
        }

        private void GetKYCStatus()
        {
            string kycTranckingNumber = Request.Form["TrackingNumber"];
            string url = "https://trackings.post.japanpost.jp/services/srv/search/direct?reqCodeNo1=" + kycTranckingNumber + "&searchKind=S002&locale=en";

            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(url);
            myRequest.Method = WebRequestMethods.Http.Get;
            WebResponse response = myRequest.GetResponse();
            string json = null;
            using (Stream stream = response.GetResponseStream())
            {
                json = (new StreamReader(stream)).ReadToEnd();
            }
            int length = (json.Length) / 4;
            int indexOfTable = json.IndexOf("<div id=\"con_wrap_no_rnav\" class=\"clearfix\">");
            int indexOfTableEnd = json.IndexOf("<div id=\"btm_nav\" class=\"clearfix\">");
            if (indexOfTable != -1)
            {
                length = indexOfTableEnd - indexOfTable;
            }
            json = json.Substring(indexOfTable, length);
            json = json.Replace("class=\"txt_type02\"", "Id =\"other-options\"");
            json = json.Replace("m_b10 txt_c", "remove-tag-p");
            GetStatic.JsonResponse(json, Page);
        }

        protected void btnSaveImg_Click(object sender, EventArgs e)
        {
            string folderPath = GetStatic.ReadQueryString("dt", "").Replace("-", "\\") + "\\" + GetStatic.ReadQueryString("membershipId", "");
            string fileData = hddImgURL.Value;
            string path = GetStatic.GetCustomerFilePath() + folderPath;
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string fileName = path + "\\postal_code_verification.png";

            using (FileStream fs = new FileStream(fileName, FileMode.Create))
            {
                using (BinaryWriter bw = new BinaryWriter(fs))
                {
                    byte[] data = Convert.FromBase64String(fileData);
                    bw.Write(data);
                    bw.Close();
                }
            }
        }

        protected void btnReSchedule_Click(object sender, EventArgs e)
        {
            var trackingNumber = GetTranckingNumber();
            using (var driver = new ChromeDriver(@"E:\chromedriver_win32"))
            {
                driver.Navigate().GoToUrl("https://trackings.post.japanpost.jp/delivery/deli/firstDeliveryInput/");

                Thread.Sleep(1000);
                var trackingNumberElem = driver.FindElementByName("firstDeliveryInputTrackNo");

                Thread.Sleep(1000);
                trackingNumberElem.SendKeys(trackingNumber);

                Thread.Sleep(1000);
                var btnNext = driver.FindElementByName("externalWeb");
                btnNext.Click();

                Thread.Sleep(1000);

                //var passwordSection = driver.FindElementByXPath("//*[@id=\"strMain\"]/form/table/tbody/tr[2]/td/div/div/p/input");
                ////var passwordSection = driver.FindElementByName("loginPassword");
                //passwordSection.SendKeys("bankof7700");

                //Thread.Sleep(1000);

                //var loginBtn = driver.FindElementByXPath("//*[@id=\"strMain\"]/form/ul/li[2]/input");
                //loginBtn.Click();

                //var showStatement = driver.FindElementByXPath("//*[@id=\"strMain\"]/p[13]/a");
                //showStatement.Click();

                //Thread.Sleep(1000);

                //var showAllDataStatement = driver.FindElementByXPath("//*[@id=\"strMain\"]/div[4]/h2/a");
                //showAllDataStatement.Click();

                //var ddl = driver.FindElementByXPath("//*[@id=\"strMain\"]/div/div[3]/div[2]/p/select[1]");

                //Thread.Sleep(1000);

                ////var selectElement = new SelectElement(ddl);
                ////selectElement.SelectByValue("100");

                ////var statementTable = driver.FindElementByXPath("//*[@id=\"strMain\"]/div/div[4]");
                ////var tableHtml = statementTable.GetAttribute("innerHTML");

                ////DataTable dt = ConvertHTMLTablesToDataTable(tableHtml);
                ////if (dt != null)
                ////{
                ////    var xml = GetXMlFromTable(dt);
                ////    var res = _obj.SaveStatement(xml);

                ////}
                //Console.ReadLine();
                driver.Quit();
            }
        }
    }
}