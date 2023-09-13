using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserPool
{
    public class RedirectPool
    {
        private static readonly RedirectPool Instance = new RedirectPool();
        private static readonly Dictionary<string, UserType> AgentUserList = new Dictionary<string, UserType>();

        private RedirectPool()
        {
            
        }
        public UserType GetCurrentUserAgentType(string username)
        {
            if(IsAgentUserExists(username))
            {
                foreach(var user in AgentUserList)
                {
                    if (user.Key == username)
                        return user.Value;
                }
            }
            var userType = new UserType("", "");
            return userType;
        }
        public void AddAgentUser(string username, UserType userType)
        {
            if(!IsAgentUserExists(username))
                AgentUserList.Add(username, userType);
        }

        public void RemoveAgentUser(string username)
        {
            if(IsAgentUserExists(username))
                AgentUserList.Remove(username);
        }

        public bool IsAgentUserExists(string username)
        {
            if (AgentUserList.ContainsKey(username))
                return true;
            return false;
        }

        public Dictionary<string, UserType> GetAgentUserList()
        {
            return AgentUserList;
        }

        public static RedirectPool GetInstance()
        {
            return Instance;
        }
        
    }
}