USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[Sheet1$]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sheet1$](
	[AgentId] [float] NULL,
	[Name] [nvarchar](255) NULL,
	[TranNo] [float] NULL,
	[ServiceCharge] [float] NULL,
	[EarnedFX] [float] NULL,
	[IntroducerAmt] [float] NULL,
	[IsCancel] [float] NULL
) ON [PRIMARY]
GO
