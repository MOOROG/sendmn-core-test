using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserPool
{
    public class UserType
    {
        public UserType()
        {
            
        }

        public UserType(string agentType, string isActAsBranch)
        {
            AgentType = agentType;
            IsActAsBranch = isActAsBranch;
        }

        public string AgentType { get; set; }
        public string IsActAsBranch { get; set; }
    }
}