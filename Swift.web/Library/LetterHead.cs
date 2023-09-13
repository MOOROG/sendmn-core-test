using System.Configuration;

namespace Swift.web.Library
{
    public class LetterHead
    {
        public string getLetterHead(string companyDetail)
        {
            return ConfigurationSettings.AppSettings[companyDetail].ToString();
        }
    }
}