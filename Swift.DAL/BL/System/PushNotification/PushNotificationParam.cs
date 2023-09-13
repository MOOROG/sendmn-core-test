using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.System.PushNotification
{
    public class PushNotificationParam
    {
        public string cmRegistrationId { get; set; }
        public string message { get; set; }
        public string os { get; set; }

    }
}
