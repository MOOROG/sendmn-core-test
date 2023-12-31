USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[adminMasterMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adminMasterMod](
	[adminId] [int] NOT NULL,
	[userName] [varchar](100) NOT NULL,
	[userPassword] [varchar](50) NULL,
	[userCode] [varchar](20) NULL,
	[userPost] [varchar](100) NULL,
	[userPhone1] [varchar](20) NULL,
	[userPhone2] [varchar](20) NULL,
	[userFax1] [varchar](20) NULL,
	[userFax2] [varchar](20) NULL,
	[userMobile1] [varchar](20) NULL,
	[userMobile2] [varchar](20) NULL,
	[userEmail1] [varchar](50) NULL,
	[userEmail2] [varchar](50) NULL,
	[userAddress] [varchar](200) NULL,
	[userCity] [varchar](100) NULL,
	[userCountry] [varchar](100) NULL,
	[userType] [char](1) NULL,
	[session] [varchar](100) NULL,
	[loginTime] [datetime] NULL,
	[logoutTime] [datetime] NULL,
	[isActive] [char](10) NULL,
	[lastPwdChanged] [datetime] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modType] [char](1) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[adminId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[adminMasterMod] ADD  CONSTRAINT [MSrepl_tran_version_default_106DA927_C98C_4CA8_8E73_2B3ACDC2C689_1097211109]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
