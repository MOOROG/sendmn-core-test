USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[tblPayoutAgentAccount]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPayoutAgentAccount](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[transferType] [varchar](100) NULL,
	[nameOfPartner] [varchar](100) NULL,
	[receiveUSDNostro] [varchar](50) NULL,
	[receiveUSDCorrespondent] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPayoutAgentAccount] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
