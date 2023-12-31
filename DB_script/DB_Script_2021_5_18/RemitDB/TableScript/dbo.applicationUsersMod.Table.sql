USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationUsersMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationUsersMod](
	[userId] [int] NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[agentCode] [varchar](20) NULL,
	[firstName] [varchar](30) NULL,
	[middleName] [varchar](30) NULL,
	[lastName] [varchar](30) NULL,
	[salutation] [varchar](10) NULL,
	[gender] [varchar](10) NULL,
	[countryId] [varchar](30) NULL,
	[state] [int] NULL,
	[zip] [varchar](10) NULL,
	[district] [int] NULL,
	[city] [varchar](30) NULL,
	[address] [varchar](255) NULL,
	[telephoneNo] [varchar](15) NULL,
	[mobileNo] [varchar](15) NULL,
	[email] [varchar](255) NULL,
	[pwd] [varchar](255) NULL,
	[agentId] [int] NULL,
	[sessionTimeOutPeriod] [int] NULL,
	[tranApproveLimit] [money] NULL,
	[agentCrLimitAmt] [money] NULL,
	[loginTime] [time](0) NULL,
	[logoutTime] [time](0) NULL,
	[userAccessLevel] [char](1) NULL,
	[perDayTranLimit] [int] NULL,
	[fromSendTrnTime] [time](7) NULL,
	[toSendTrnTime] [time](7) NULL,
	[fromPayTrnTime] [time](7) NULL,
	[toPayTrnTime] [time](7) NULL,
	[fromRptViewTime] [time](7) NULL,
	[toRptViewTime] [time](7) NULL,
	[isActive] [char](1) NULL,
	[isLocked] [char](1) NULL,
	[lastLoginTs] [datetime] NULL,
	[pwdChangeDays] [int] NULL,
	[pwdChangeWarningDays] [int] NULL,
	[lastPwdChangedOn] [varchar](30) NULL,
	[forceChangePwd] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NOT NULL,
	[maxReportViewDays] [int] NULL,
	[employeeId] [varchar](10) NULL,
	[userType] [varchar](2) NULL,
	[txnPwd] [varchar](255) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__applicat__CB9A1CFF1348B5CC] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationUsersMod] ADD  CONSTRAINT [MSrepl_tran_version_default_17753A3B_CAB4_40AC_BDE6_B41463B0C806_138079878]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
