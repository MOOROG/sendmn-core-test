USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankGuarantee]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankGuarantee](
	[bgId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[guaranteeNo] [varchar](20) NULL,
	[amount] [money] NULL,
	[currency] [int] NULL,
	[bankName] [varchar](50) NULL,
	[issuedDate] [datetime] NULL,
	[expiryDate] [datetime] NULL,
	[followUpDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[bgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bankGuarantee] ADD  CONSTRAINT [MSrepl_tran_version_default_DE44C7C2_7084_498F_B017_7E9B327B483B_2075258548]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
