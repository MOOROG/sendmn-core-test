USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ThirdPartyTxnLogs]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThirdPartyTxnLogs](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[provider] [int] NULL,
	[tranId] [bigint] NULL,
	[msg] [varchar](max) NULL,
	[createdBy] [varchar](30) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[xmlResult] [varchar](max) NULL,
	[transferNumber] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
