USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempTableUpload]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempTableUpload](
	[iccidFrom] [varchar](30) NULL,
	[iccidTo] [varchar](30) NULL,
	[mobileNoFrom] [varchar](30) NULL,
	[mobileNoTo] [varchar](30) NULL
) ON [PRIMARY]
GO
