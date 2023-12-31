USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[extCredentials]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[extCredentials](
	[providerCode] [varchar](50) NOT NULL,
	[agentAuthCode] [varchar](50) NULL,
	[agentCode] [varchar](50) NULL,
	[userId] [varchar](50) NULL,
	[pwd] [varchar](50) NULL,
	[pin] [varchar](50) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[providerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[extCredentials] ADD  CONSTRAINT [MSrepl_tran_version_default_551C6A13_7E46_4436_ABAA_34FE3EE5522F_1682469418]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
