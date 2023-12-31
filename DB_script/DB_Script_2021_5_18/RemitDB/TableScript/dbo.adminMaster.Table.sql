USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[adminMaster]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adminMaster](
	[adminId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[isActive] [char](10) NULL,
	[isDeleted] [char](1) NULL,
	[lastPwdChanged] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_adminMaster_adminId] PRIMARY KEY CLUSTERED 
(
	[adminId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[adminMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_ACE98337_8AB3_451B_9ED9_2DB52E81D8B4_1081211052]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
