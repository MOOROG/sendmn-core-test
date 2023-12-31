USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mobile_GmeApiClientRegistration]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mobile_GmeApiClientRegistration](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[applicationName] [varchar](200) NULL,
	[description] [varchar](max) NULL,
	[aboutUrl] [varchar](100) NULL,
	[applicationType] [varchar](100) NULL,
	[scope] [varchar](50) NULL,
	[clientId] [varchar](50) NULL,
	[secret] [varchar](100) NULL,
	[isActive] [bit] NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
