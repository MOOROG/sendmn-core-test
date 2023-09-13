using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.PushNotification
{
    public interface IPushNotification
    {
        object SendPushNotification(string cmRegistrationId, string os, string message, string notificationId);
        DataTable GetDeviceDetail(string customerId);
        DbResult CreateNotification(Notifiers notifiers);


    }
}
