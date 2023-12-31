USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[accountDepositOutStanding]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountDepositOutStanding](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[tokenId] [varchar](50) NULL,
	[tokenStatus] [varchar](20) NULL,
	[viewOn] [datetime] NULL,
	[markOn] [datetime] NULL,
	[createdBy] [varchar](30) NULL
) ON [PRIMARY]
GO
