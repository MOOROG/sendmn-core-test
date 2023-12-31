USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ComplianceLog]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ComplianceLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[senderName] [varchar](50) NULL,
	[senderCountry] [varchar](50) NULL,
	[senderIdType] [varchar](50) NULL,
	[senderIdNumber] [varchar](50) NULL,
	[senderMobile] [varchar](50) NULL,
	[receiverName] [varchar](50) NULL,
	[receiverCountry] [varchar](50) NULL,
	[payOutAmt] [money] NULL,
	[complianceId] [int] NULL,
	[complianceReason] [varchar](500) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[complainceDetailMessage] [nvarchar](1000) NULL,
	[logType] [varchar](15) NULL,
	[agentRefId] [varchar](30) NULL,
	[tranId] [bigint] NULL,
	[isDocumentRequired] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
