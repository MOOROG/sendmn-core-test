USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[LoginLogs]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoginLogs](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[logType] [varchar](50) NULL,
	[IP] [varchar](100) NULL,
	[Reason] [varchar](2000) NULL,
	[fieldValue] [varchar](2000) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[UserData] [varchar](max) NULL,
	[agentId] [int] NULL,
	[dcSerialNumber] [varchar](100) NULL,
	[dcUserName] [varchar](100) NULL,
	[LOGIN_COUNTRY] [nvarchar](200) NULL,
	[LOGIN_COUNTRY_CODE] [nvarchar](200) NULL,
	[LOGIN_CITY] [nvarchar](200) NULL,
	[LOGIN_REGION] [nvarchar](200) NULL,
	[LOGIN_LAT] [nvarchar](200) NULL,
	[LOGIN_LONG] [nvarchar](200) NULL,
	[LOGIN_TIMEZONE] [nvarchar](200) NULL,
	[LOGIN_ZIPCODDE] [nvarchar](200) NULL,
	[OTP_USED] [varchar](10) NULL,
	[IS_SUCCESSFUL] [bit] NULL,
 CONSTRAINT [pk_idx_LoginLogs_rowId] PRIMARY KEY NONCLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
