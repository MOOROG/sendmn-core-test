USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_ERROR_CODE]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_ERROR_CODE](
	[ERROR_CODE] [varchar](20) NULL,
	[MSG] [varchar](250) NULL,
	[ID] [varchar](20) NULL,
	[row_id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
