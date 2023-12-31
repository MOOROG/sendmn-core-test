USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_FOR_JAN_MONTH]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_FOR_JAN_MONTH](
	[TranNo] [int] NOT NULL,
	[AgentId] [int] NOT NULL,
	[ServiceCharge] [float] NOT NULL,
	[EarnedFX] [float] NOT NULL,
	[IntroducerAmt] [float] NOT NULL,
	[IsCancel] [bit] NOT NULL
) ON [PRIMARY]
GO
