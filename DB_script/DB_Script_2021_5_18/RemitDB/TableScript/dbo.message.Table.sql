USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[message]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[message](
	[msgId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[agentId] [int] NULL,
	[headMsg] [nvarchar](max) NULL,
	[commonMsg] [nvarchar](max) NULL,
	[countrySpecificMsg] [nvarchar](max) NULL,
	[promotionalMsg] [nvarchar](max) NULL,
	[msgType] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[newsFeederMsg] [nvarchar](max) NULL,
	[isActive] [varchar](10) NULL,
	[transactionType] [varchar](10) NULL,
	[rCountry] [varchar](50) NULL,
	[rAgent] [varchar](50) NULL,
	[userType] [varchar](2) NULL,
	[branchId] [bigint] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__message__A96042E71BFEC2B5] PRIMARY KEY CLUSTERED 
(
	[msgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[message] ADD  CONSTRAINT [MSrepl_tran_version_default_94AFE041_C97A_4AB3_BF1C_EB3B7EA00089_73923485]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
