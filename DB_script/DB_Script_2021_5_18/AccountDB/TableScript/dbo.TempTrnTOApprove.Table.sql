USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[TempTrnTOApprove]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempTrnTOApprove](
	[TempId] [int] IDENTITY(1,1) NOT NULL,
	[v_type] [char](3) NULL,
	[Remarks] [varchar](2000) NULL,
	[TranCode] [varchar](100) NULL,
	[TranDate] [date] NULL,
	[Amount] [money] NULL,
	[TransitRate] [money] NULL,
	[DrAcc] [varchar](50) NULL,
	[CrAcc] [varchar](50) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedDate] [date] NULL,
	[Status] [char](3) NULL
) ON [PRIMARY]
GO
