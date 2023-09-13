USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempTrack]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempTrack](
	[m1] [varchar](max) NULL,
	[m2] [varchar](max) NULL,
	[d1] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempTrack] ADD  DEFAULT (getdate()) FOR [d1]
GO
