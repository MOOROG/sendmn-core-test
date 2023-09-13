using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common
{
    public class GoogleAuthenticatorModel
    {
        public string BarCodeImageUrl { get; set; }
        public string SetupCode { get; set; }
        public string ManualEntryKey { get; set; }
    }
}
