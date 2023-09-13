using System;

namespace Swift.DAL.BL.SwiftSystem
{
    public class LoggedInUser
    {
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserFullName { get; set; }
        public DateTime LoginTime { get; set; }
        public string UserAccessLevel { get; set; }
        public string IPAddress { get; set; }
        public string Browser { get; set; }
        public int SessionTimeOutPeriod { get; set; }
        public string UserAgentName { get; set; }
        public DateTime LastLoginTime { get; set; }
        public DateTime LastActiveTime { get; set; }
        public string SessionID { get; set; }

        //public int AgentId { get; set; }
        //public int ParentId { get; set; }
    }
}
