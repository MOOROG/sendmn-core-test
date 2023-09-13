using System.Collections.Generic;
using System.Linq;
using Swift.DAL.SwiftDAL;



namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserPool
{
    public class UserPool
    {
        private static UserPool Instance = new UserPool();
        private static readonly Dictionary<string, LoggedInUser> UserList = new Dictionary<string, LoggedInUser>();

        private UserPool()
        {
        }

        public DbResult MutipleRemoteLogin(LoggedInUser user)
        {
            var dbResult = new DbResult();

            if (!IsUserExists(user.UserName))
                UserList.Add(user.UserName, user);
            else
            {
                UserPool pool = GetInstance();
                var loggedInUsers = pool.GetLoggedInUsers();

                lock (UserList)
                {
                    foreach (
                        KeyValuePair<string, LoggedInUser> loggedInUser in
                            loggedInUsers.ToList().Where(loggedInUser => loggedInUser.Value.UserName == user.UserName))
                    {
                        loggedInUser.Value.UserAccessLevel = "M";
                        loggedInUser.Value.SessionID = user.SessionID;
                        loggedInUser.Value.Browser = user.Browser;
                        loggedInUser.Value.LastLoginTime = user.LastLoginTime;
                        loggedInUser.Value.IPAddress = user.IPAddress;
                    }
                }
            }
            dbResult.SetError("0", "Login Successful", user.UserName);
            return dbResult;
        }

        public DbResult AddUser(LoggedInUser user)
        {
            var dbResult = new DbResult();
            switch (user.UserAccessLevel)
            {
                case "M":
                    if (!IsUserExists(user.UserName))
                    {
                        lock (UserList)
                        {
                            UserList.Add(user.UserName, user);
                        }
                    }
                    else
                    {
                        UserPool pool = GetInstance();
                        var loggedInUsers = pool.GetLoggedInUsers();

                        lock (UserList)
                        {
                            foreach (
                                var loggedInUser in
                                    loggedInUsers.ToList().Where(
                                        loggedInUser => loggedInUser.Value.UserName == user.UserName))
                            {
                                loggedInUser.Value.UserAccessLevel = user.UserAccessLevel;
                                //loggedInUser.Value.DcInfo = user.DcInfo;
                                loggedInUser.Value.SessionID = user.SessionID;
                                loggedInUser.Value.Browser = user.Browser;
                                loggedInUser.Value.LoginTime = user.LoginTime;
                                loggedInUser.Value.LastLoginTime = user.LastLoginTime;
                                loggedInUser.Value.IPAddress = user.IPAddress;
                            }
                        }
                    }
                    dbResult.SetError("0", "Login Successful", user.UserName);
                    break;
                case "S":
                    if (IsUserExists(user.UserName))
                        dbResult.SetError("1", "User Already Logged In", user.UserName);
                    else
                    {
                        lock (UserList)
                        {
                            UserList.Add(user.UserName, user);
                        }
                        dbResult.SetError("0", "Login Successful", user.UserName);
                    }
                    break;
            }
            return dbResult;
        }

        public void RemoveAllUser()
        {
            UserList.Clear();
        }
        public void RemoveUser(string username)
        {
            if (IsUserExists(username))
            {
                lock (UserList)
                {
                    UserList.Remove(username);
                }
            }
        }

        public string GetUserBySessionId(string sessionId)
        {
            foreach (
                var loggedInUser in UserList.Values.ToList().Where(loggedInUser => loggedInUser.SessionID == sessionId))
            {
                return loggedInUser.UserName;
            }
            return "";
        }

        public bool IsUserExists(string username, string SessionID)
        {
            foreach (
                LoggedInUser loggedInUser in 
                UserList.Values.Where(loggedInUser => loggedInUser.UserName == username && loggedInUser.SessionID == SessionID)) {
                    return true;
                }
            return false;
        }

        public bool IsUserExists(string username)
        {
            if (UserList.ContainsKey(username))
                return true;
            return false;
        }

        public LoggedInUser GetUser(string username)
        {
            var user = new LoggedInUser();
            foreach (
                LoggedInUser loggedInUser in UserList.Values.Where(loggedInUser => loggedInUser.UserName == username))
            {
                return loggedInUser;
            }
            return user;
        }

        public Dictionary<string, LoggedInUser> GetLoggedInUsers()
        {
            return UserList;
        }

        public static UserPool GetInstance()
        {
            if (Instance == null)
            {
                lock (UserList)
                {
                    if (Instance == null)
                        return Instance = new UserPool();
                }
            }
            return Instance;
        }
    }
}