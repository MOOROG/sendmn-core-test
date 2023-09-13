using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace Swift.web.SwiftSystem.ReceivePageFieldSetup
{
    public class Fieldsetting
    {
        public string field { get; set; }
        public string fieldRequired { get; set; }
        public string minFieldlength { get; set; }
        public string maxFieldlength { get; set; }
        public string KeyWord { get; set; }
    }
}