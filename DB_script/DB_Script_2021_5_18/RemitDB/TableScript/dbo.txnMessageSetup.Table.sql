USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[txnMessageSetup]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnMessageSetup](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[country] [nvarchar](max) NULL,
	[service] [nvarchar](max) NULL,
	[codeDescription] [nvarchar](max) NULL,
	[paymentMethodDesc] [nvarchar](max) NULL,
	[flag] [varchar](100) NULL,
	[isActive] [varchar](50) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__txnMessa__3213E83F27E8A409] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[txnMessageSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_CBB19E98_D18D_49E8_95A6_E69628594799_813558282]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
